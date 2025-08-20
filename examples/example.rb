# Sentry SDK Example - Ruby/Rails (Latest SDK as of Aug 2025)
# frozen_string_literal: true

require 'sentry-ruby'
require 'sentry-rails'
require 'json'
require 'logger'

# Module for Sentry integration helpers
module SentryHelpers
  # Constants
  SENTRY_DSN = ENV['SENTRY_DSN'] || 'https://key@sentry.io/0'
  DEFAULT_ENVIRONMENT = ENV['RAILS_ENV'] || 'development'
  API_VERSION = '2.0'
  MAX_RETRIES = 3
  
  # Custom error classes
  class UserNotFoundError < StandardError; end
  class AuthorizationError < StandardError; end
  class RateLimitError < StandardError; end
  
  # Configure Sentry
  def self.configure_sentry
    Sentry.init do |config|
      config.dsn = SENTRY_DSN
      config.breadcrumbs_logger = [:active_support_logger, :http_logger]
      config.traces_sample_rate = 1.0
      config.profiles_sample_rate = 1.0
      config.environment = DEFAULT_ENVIRONMENT
      config.release = "sentinel-theme@#{API_VERSION}"
      
      # Performance monitoring
      config.traces_sampler = lambda do |context|
        # Sample all transactions in development
        return 1.0 if DEFAULT_ENVIRONMENT == 'development'
        
        # Sample based on transaction name in production
        transaction_name = context[:transaction_context][:name]
        case transaction_name
        when /health_check/
          0.0  # Don't sample health checks
        when /api/
          0.5  # Sample 50% of API requests
        else
          0.1  # Sample 10% of other requests
        end
      end
      
      # Filter sensitive data
      config.before_send = lambda do |event, hint|
        # Remove sensitive parameters
        if event.request && event.request[:data]
          event.request[:data] = filter_sensitive_data(event.request[:data])
        end
        
        event
      end
      
      # Excluded exceptions
      config.excluded_exceptions += [
        'ActionController::RoutingError',
        'ActiveRecord::RecordNotFound'
      ]
    end
  end
  
  # Filter sensitive data from parameters
  def self.filter_sensitive_data(data)
    sensitive_keys = %w[password credit_card ssn api_key token secret]
    
    data.transform_values do |value|
      if value.is_a?(Hash)
        filter_sensitive_data(value)
      elsif sensitive_keys.any? { |key| data.key?(key) }
        '[FILTERED]'
      else
        value
      end
    end
  end
  
  # Performance tracking decorator
  def self.track_performance(operation_name)
    lambda do |target, method_name|
      original_method = target.instance_method(method_name)
      
      target.define_method(method_name) do |*args, &block|
        Sentry.with_scope do |scope|
          scope.set_transaction_name("#{operation_name}.#{method_name}")
          
          transaction = Sentry.start_transaction(
            op: operation_name,
            name: method_name.to_s
          )
          
          scope.set_span(transaction)
          
          begin
            result = original_method.bind(self).call(*args, &block)
            transaction.set_status('ok')
            result
          rescue StandardError => e
            transaction.set_status('internal_error')
            raise e
          ensure
            transaction.finish
          end
        end
      end
    end
  end
end

# Rails Application Example
class ApplicationController < ActionController::API
  include Sentry::Rails::ControllerMethods
  include Sentry::Rails::ControllerTransaction
  
  # Error handling
  rescue_from StandardError do |exception|
    Sentry.capture_exception(exception)
    render_error(exception, :internal_server_error)
  end
  
  rescue_from SentryHelpers::UserNotFoundError do |exception|
    render_error(exception, :not_found)
  end
  
  rescue_from SentryHelpers::AuthorizationError do |exception|
    render_error(exception, :unauthorized)
  end
  
  rescue_from SentryHelpers::RateLimitError do |exception|
    render_error(exception, :too_many_requests)
  end
  
  private
  
  def render_error(exception, status)
    error_response = {
      error: exception.message,
      type: exception.class.name,
      timestamp: Time.current,
      request_id: request.request_id
    }
    
    render json: error_response, status: status
  end
  
  # Set Sentry user context
  def set_sentry_context
    return unless current_user
    
    Sentry.set_user(
      id: current_user.id,
      email: current_user.email,
      username: current_user.username
    )
    
    Sentry.set_tags(
      user_role: current_user.role,
      account_type: current_user.account_type
    )
  end
end

# API Controller Example
class Api::V2::UsersController < ApplicationController
  before_action :set_sentry_context
  before_action :set_user, only: [:show, :update, :destroy]
  
  # GET /api/v2/users
  def index
    users = User.includes(:profile).page(params[:page])
    
    Sentry.add_breadcrumb(
      message: 'Fetched users list',
      category: 'users',
      data: { page: params[:page], count: users.count }
    )
    
    render json: users, status: :ok
  end
  
  # GET /api/v2/users/:id
  def show
    render json: @user, include: :profile
  end
  
  # POST /api/v2/users
  def create
    user = User.new(user_params)
    
    ActiveRecord::Base.transaction do
      if user.save
        # Track successful user creation
        Sentry.capture_message(
          'New user created',
          level: :info,
          extra: { user_id: user.id, email: user.email }
        )
        
        render json: user, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Sentry.capture_exception(e)
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  # PATCH/PUT /api/v2/users/:id
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v2/users/:id
  def destroy
    @user.destroy
    head :no_content
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise SentryHelpers::UserNotFoundError, "User with ID #{params[:id]} not found"
  end
  
  def user_params
    params.require(:user).permit(:email, :username, :name, :role)
  end
end

# Background Job Example
class ErrorProcessingJob < ApplicationJob
  queue_as :critical
  
  retry_on StandardError, wait: :exponentially_longer, attempts: SentryHelpers::MAX_RETRIES
  
  def perform(error_data)
    Sentry.with_scope do |scope|
      scope.set_tags(job: self.class.name)
      scope.set_context('error_data', error_data)
      
      # Process error data
      error = process_error_data(error_data)
      
      # Send notifications
      ErrorMailer.notify_team(error).deliver_later if error.critical?
      
      # Update metrics
      update_error_metrics(error)
      
      Sentry.capture_message(
        "Processed error: #{error.message}",
        level: :info
      )
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
    raise # Re-raise to trigger retry
  end
  
  private
  
  def process_error_data(data)
    Error.create!(
      message: data['message'],
      level: data['level'],
      occurred_at: data['timestamp'],
      metadata: data
    )
  end
  
  def update_error_metrics(error)
    Rails.cache.increment("errors:#{error.level}:count")
    Rails.cache.write("errors:latest:#{error.level}", error.to_json, expires_in: 1.hour)
  end
end

# Service Object with Performance Tracking
class UserAnalyticsService
  extend SentryHelpers
  
  track_performance('analytics').call(self, :calculate_user_metrics)
  
  def initialize(user)
    @user = user
  end
  
  def calculate_user_metrics
    Sentry.with_child_span(op: 'db.query', description: 'Load user events') do
      events = @user.events.where(created_at: 30.days.ago..Time.current)
      
      {
        total_events: events.count,
        error_rate: calculate_error_rate(events),
        active_days: events.pluck(:created_at).map(&:to_date).uniq.count,
        last_seen: @user.last_sign_in_at
      }
    end
  end
  
  private
  
  def calculate_error_rate(events)
    return 0 if events.empty?
    
    error_count = events.where(level: 'error').count
    (error_count.to_f / events.count * 100).round(2)
  end
end

# Rake task example
namespace :sentry do
  desc 'Test Sentry integration'
  task test: :environment do
    Sentry.with_scope do |scope|
      scope.set_tags(task: 'sentry:test')
      
      begin
        puts '🧪 Testing Sentry integration...'
        
        # Test message
        Sentry.capture_message('Test message from Rake task', level: :info)
        
        # Test exception
        raise 'Test exception for Sentry'
      rescue StandardError => e
        Sentry.capture_exception(e)
        puts "✅ Sentry test completed. Check your Sentry dashboard!"
      end
    end
  end
end

# Lambda example
process_with_sentry = ->(data) do
  Sentry.with_scope do |scope|
    scope.set_transaction_name('lambda.process')
    scope.set_extra(:input_data, data)
    
    # Process data
    result = data.transform_values(&:upcase)
    
    Sentry.add_breadcrumb(
      message: 'Processed data with lambda',
      data: { keys: data.keys }
    )
    result
  end
end

# Module with class methods
module ErrorReporting
  extend self
  
  def report(exception, context = {})
    Sentry.capture_exception(exception) do |scope|
      scope.set_context('error_context', context)
      scope.set_level(:error)
    end
  end
  
  def track_event(name, properties = {})
    Sentry.capture_message(
      "Event: #{name}",
      level: :info,
      extra: properties
    )
  end
end
