#!/usr/bin/env bash
# Sentry Deployment Script - Bash Example (Latest CLI as of Aug 2025)
# Demonstrates shell scripting with error handling and Sentry CLI

set -euo pipefail
IFS=$'\n\t'

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

readonly SENTRY_ORG="${SENTRY_ORG:-your-org}"
readonly SENTRY_PROJECT="${SENTRY_PROJECT:-your-project}"
readonly SENTRY_AUTH_TOKEN="${SENTRY_AUTH_TOKEN:-}"
readonly ENVIRONMENT="${ENVIRONMENT:-production}"
readonly VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/sentry-deploy-$(date +%Y%m%d-%H%M%S).log"
readonly MAX_RETRIES=3
readonly RETRY_DELAY=5

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        ERROR)   color=$RED ;;
        SUCCESS) color=$GREEN ;;
        WARNING) color=$YELLOW ;;
        INFO)    color=$BLUE ;;
        DEBUG)   color=$PURPLE ;;
        *)       color=$NC ;;
    esac
    
    echo -e "${color}[$timestamp] [$level] $message${NC}" | tee -a "$LOG_FILE"
}

handle_error() {
    local exit_code=$?
    local line_number=$1
    
    log ERROR "Script failed with exit code $exit_code at line $line_number"
    log ERROR "Check log file: $LOG_FILE"
    
    if command -v sentry-cli &> /dev/null; then
        sentry-cli send-event \
            -m "Deployment script failed" \
            -e "environment:$ENVIRONMENT" \
            -t "script:deploy" \
            -l "error" \
            --logfile "$LOG_FILE"
    fi
    
    exit $exit_code
}

trap 'handle_error ${LINENO}' ERR

check_dependencies() {
    log INFO "Checking dependencies..."
    
    local deps=("git" "node" "npm" "sentry-cli")
    local missing=()
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        else
            log DEBUG "✓ $cmd found: $(command -v $cmd)"
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log ERROR "Missing dependencies: ${missing[*]}"
        log INFO "Install with: npm install -g @sentry/cli"
        return 1
    fi
    
    log SUCCESS "All dependencies satisfied"
}

retry_with_backoff() {
    local max_attempts=$1
    local delay=$2
    shift 2
    local command=("$@")
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log INFO "Attempt $attempt/$max_attempts: ${command[*]}"
        
        if "${command[@]}"; then
            log SUCCESS "Command succeeded on attempt $attempt"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            log WARNING "Command failed, retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2))
        fi
        
        ((attempt++))
    done
    
    log ERROR "Command failed after $max_attempts attempts"
    return 1
}

create_sentry_release() {
    log INFO "Creating Sentry release: $VERSION"
    
    retry_with_backoff $MAX_RETRIES $RETRY_DELAY \
        sentry-cli releases new "$VERSION" \
            --org "$SENTRY_ORG" \
            --project "$SENTRY_PROJECT"
    
    if [ -d .git ]; then
        log INFO "Associating commits with release..."
        sentry-cli releases set-commits "$VERSION" --auto \
            --org "$SENTRY_ORG" \
            --project "$SENTRY_PROJECT"
    fi
    
    if [ -d dist ]; then
        log INFO "Uploading source maps..."
        sentry-cli releases files "$VERSION" upload-sourcemaps ./dist \
            --org "$SENTRY_ORG" \
            --project "$SENTRY_PROJECT" \
            --url-prefix "~/" \
            --rewrite
    fi
}

deploy_release() {
    log INFO "Deploying release $VERSION to $ENVIRONMENT"
    
    sentry-cli releases deploys "$VERSION" new \
        --org "$SENTRY_ORG" \
        --project "$SENTRY_PROJECT" \
        --env "$ENVIRONMENT" \
        --started $(date +%s)
    
    local steps=(
        "Building application"
        "Running tests"
        "Uploading artifacts"
        "Updating services"
        "Running migrations"
    )
    
    for step in "${steps[@]}"; do
        log INFO "$step..."
        sleep 2
    done
    
    sentry-cli releases deploys "$VERSION" finish \
        --org "$SENTRY_ORG" \
        --project "$SENTRY_PROJECT" \
        --env "$ENVIRONMENT" \
        --finished $(date +%s)
    
    log SUCCESS "Deployment completed successfully!"
}

finalize_release() {
    log INFO "Finalizing release $VERSION"
    
    sentry-cli releases finalize "$VERSION" \
        --org "$SENTRY_ORG" \
        --project "$SENTRY_PROJECT"
    
    if [ -n "${SLACK_WEBHOOK:-}" ]; then
        send_slack_notification
    fi
}

send_slack_notification() {
    local payload=$(cat <<EOF
{
    "text": "🚀 Deployment Complete",
    "attachments": [{
        "color": "good",
        "fields": [
            {"title": "Version", "value": "$VERSION", "short": true},
            {"title": "Environment", "value": "$ENVIRONMENT", "short": true},
            {"title": "Project", "value": "$SENTRY_PROJECT", "short": true},
            {"title": "Time", "value": "$(date)", "short": true}
        ]
    }]
}
EOF
)
    
    curl -X POST \
        -H 'Content-type: application/json' \
        --data "$payload" \
        "$SLACK_WEBHOOK" 2>/dev/null || log WARNING "Failed to send Slack notification"
}

rollback() {
    local previous_version=$1
    log WARNING "Rolling back to version: $previous_version"
    
    sentry-cli releases deploys "$VERSION" finish \
        --org "$SENTRY_ORG" \
        --project "$SENTRY_PROJECT" \
        --env "$ENVIRONMENT" \
        --finished $(date +%s) \
        --failed
    
    VERSION=$previous_version deploy_release
}

main() {
    log INFO "Starting Sentry deployment script"
    log INFO "Version: $VERSION, Environment: $ENVIRONMENT"
    
    if [ -z "$SENTRY_AUTH_TOKEN" ]; then
        log ERROR "SENTRY_AUTH_TOKEN is not set"
        exit 1
    fi
    
    check_dependencies || exit 1
    
    create_sentry_release
    deploy_release
    finalize_release
    
    log SUCCESS "Deployment script completed successfully!"
    log INFO "Log file saved to: $LOG_FILE"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            cat <<EOF
Usage: $0 [OPTIONS]

Sentry deployment script with release management

Options:
    -h, --help          Show this help message
    -e, --env ENV       Set environment (default: production)
    -v, --version VER   Set version (default: git tag/hash)
    -r, --rollback VER  Rollback to specified version
    --dry-run           Show what would be done

Environment Variables:
    SENTRY_ORG          Sentry organization slug
    SENTRY_PROJECT      Sentry project slug
    SENTRY_AUTH_TOKEN   Sentry authentication token
    ENVIRONMENT         Deployment environment
    SLACK_WEBHOOK       Optional Slack webhook URL

Examples:
    $0                          # Deploy current version to production
    $0 --env staging            # Deploy to staging
    $0 --rollback v1.2.3        # Rollback to v1.2.3
EOF
            exit 0
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -r|--rollback)
            rollback "$2"
            exit $?
            ;;
        --dry-run)
            log INFO "DRY RUN MODE - No changes will be made"
            set -n
            shift
            ;;
        *)
            log ERROR "Unknown option: $1"
            exit 1
            ;;
    esac
done

main "$@"
