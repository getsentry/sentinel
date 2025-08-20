// Sentry SDK Example - Go (Latest SDK as of Aug 2025)
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/getsentry/sentry-go"
	sentryhttp "github.com/getsentry/sentry-go/http"
	"github.com/gorilla/mux"
)

// Constants
const (
	DefaultPort    = ":8080"
	DefaultTimeout = 30 * time.Second
	MaxRetries     = 3
	APIVersion     = "v2"
)

// Custom error types
var (
	ErrUserNotFound = errors.New("user not found")
	ErrUnauthorized = errors.New("unauthorized access")
	ErrRateLimit    = errors.New("rate limit exceeded")
)

// Types
type User struct {
	ID        string    `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
}

type ErrorResponse struct {
	Error   string    `json:"error"`
	Code    string    `json:"code,omitempty"`
	Details string    `json:"details,omitempty"`
	Time    time.Time `json:"timestamp"`
}

// SentryConfig holds Sentry configuration
type SentryConfig struct {
	DSN              string
	Environment      string
	Release          string
	TracesSampleRate float64
	Debug            bool
}

// Initialize Sentry with custom configuration
func initSentry(cfg SentryConfig) error {
	err := sentry.Init(sentry.ClientOptions{
		Dsn:              cfg.DSN,
		Environment:      cfg.Environment,
		Release:          cfg.Release,
		TracesSampleRate: cfg.TracesSampleRate,
		Debug:            cfg.Debug,
		BeforeSend: func(event *sentry.Event, hint *sentry.EventHint) *sentry.Event {
			// Filter sensitive data
			if event.Request != nil {
				event.Request.Cookies = ""
				// Remove auth headers
				delete(event.Request.Headers, "Authorization")
			}
			return event
		},
		AttachStacktrace: true,
	})

	if err != nil {
		return fmt.Errorf("sentry initialization failed: %w", err)
	}

	// Flush events on shutdown
	defer sentry.Flush(2 * time.Second)

	return nil
}

// Middleware for Sentry transaction tracking
func sentryMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		hub := sentry.GetHubFromContext(ctx)
		if hub == nil {
			hub = sentry.CurrentHub().Clone()
			ctx = sentry.SetHubOnContext(ctx, hub)
		}

		// Start transaction
		span := sentry.StartSpan(ctx, "http.server",
			sentry.TransactionName(fmt.Sprintf("%s %s", r.Method, r.URL.Path)),
		)
		defer span.Finish()

		// Add request data to span
		span.SetTag("http.method", r.Method)
		span.SetTag("http.url", r.URL.String())
		span.SetTag("user_agent", r.UserAgent())

		// Pass span through context
		r = r.WithContext(span.Context())

		// Call next handler
		next.ServeHTTP(w, r)
	})
}

// Error handler with Sentry integration
func handleError(w http.ResponseWriter, err error, code int) {
	// Capture error to Sentry
	sentry.CaptureException(err)

	// Prepare error response
	resp := ErrorResponse{
		Error: err.Error(),
		Time:  time.Now(),
	}

	// Add error-specific details
	switch {
	case errors.Is(err, ErrUserNotFound):
		resp.Code = "USER_NOT_FOUND"
		resp.Details = "The requested user does not exist"
	case errors.Is(err, ErrUnauthorized):
		resp.Code = "UNAUTHORIZED"
		resp.Details = "You don't have permission to access this resource"
	case errors.Is(err, ErrRateLimit):
		resp.Code = "RATE_LIMIT_EXCEEDED"
		resp.Details = "Too many requests, please try again later"
	default:
		resp.Code = "INTERNAL_ERROR"
		resp.Details = "An unexpected error occurred"
	}

	// Send response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(resp)
}

// API Handlers
func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":    "healthy",
		"timestamp": time.Now(),
		"version":   APIVersion,
		"service":   "sentinel-theme-api",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	userID := vars["id"]

	// Create span for database query
	span := sentry.StartSpan(r.Context(), "db.query", sentry.TransactionName("SELECT * FROM users"))
	span.SetTag("db.system", "postgresql")
	defer span.Finish()

	// Simulate user lookup
	if userID == "404" {
		handleError(w, ErrUserNotFound, http.StatusNotFound)
		return
	}

	user := User{
		ID:        userID,
		Email:     fmt.Sprintf("user%s@example.com", userID),
		Name:      fmt.Sprintf("User %s", userID),
		Role:      "user",
		CreatedAt: time.Now().Add(-24 * time.Hour),
	}

	// Set user context in Sentry
	if hub := sentry.GetHubFromContext(r.Context()); hub != nil {
		hub.Scope().SetUser(sentry.User{
			ID:       user.ID,
			Email:    user.Email,
			Username: user.Name,
		})
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

func createErrorHandler(w http.ResponseWriter, r *http.Request) {
	// Parse request body
	var data map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		handleError(w, err, http.StatusBadRequest)
		return
	}

	// Get error details
	message, _ := data["message"].(string)
	level, _ := data["level"].(string)

	// Capture custom error to Sentry
	hub := sentry.GetHubFromContext(r.Context())
	if hub != nil {
		hub.WithScope(func(scope *sentry.Scope) {
			scope.SetLevel(sentry.Level(level))
			scope.SetTag("source", "api")
			scope.SetExtra("custom_data", data)
			hub.CaptureMessage(message)
		})
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"eventId": sentry.LastEventID(),
	})
}

// Panic recovery middleware
func recoveryMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				// Capture panic to Sentry
				sentry.CurrentHub().Recover(err)
				sentry.Flush(time.Second * 2)

				// Respond with error
				w.WriteHeader(http.StatusInternalServerError)
				json.NewEncoder(w).Encode(map[string]string{
					"error": "Internal server error",
				})
			}
		}()

		next.ServeHTTP(w, r)
	})
}

func main() {
	// Load configuration from environment
	cfg := SentryConfig{
		DSN:              os.Getenv("SENTRY_DSN"),
		Environment:      getEnvOrDefault("ENVIRONMENT", "development"),
		Release:          getEnvOrDefault("RELEASE", "sentinel-theme@1.0.0"),
		TracesSampleRate: 1.0,
		Debug:            os.Getenv("DEBUG") == "true",
	}

	// Initialize Sentry
	if err := initSentry(cfg); err != nil {
		log.Printf("Warning: Sentry initialization failed: %v", err)
	}

	// Create router
	r := mux.NewRouter()

	// Add middleware
	r.Use(recoveryMiddleware)
	r.Use(sentryMiddleware)
	r.Use(sentryhttp.New(sentryhttp.Options{
		Repanic: true,
	}).Handle)

	// Register routes
	r.HandleFunc("/health", healthHandler).Methods("GET")
	r.HandleFunc("/api/v2/users/{id}", getUserHandler).Methods("GET")
	r.HandleFunc("/api/v2/errors", createErrorHandler).Methods("POST")

	// Start server
	port := getEnvOrDefault("PORT", DefaultPort)
	srv := &http.Server{
		Addr:         port,
		Handler:      r,
		ReadTimeout:  DefaultTimeout,
		WriteTimeout: DefaultTimeout,
		IdleTimeout:  120 * time.Second,
	}

	log.Printf("🚀 Server starting on %s", port)
	if err := srv.ListenAndServe(); err != nil {
		sentry.CaptureException(err)
		log.Fatalf("Server failed to start: %v", err)
	}
}

// Helper function
func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
