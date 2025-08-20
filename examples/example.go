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

const (
	DefaultPort    = ":8080"
	DefaultTimeout = 30 * time.Second
	MaxRetries     = 3
	APIVersion     = "v2"
)

var (
	ErrUserNotFound = errors.New("user not found")
	ErrUnauthorized = errors.New("unauthorized access")
	ErrRateLimit    = errors.New("rate limit exceeded")
)

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

func initSentry(cfg SentryConfig) error {
	err := sentry.Init(sentry.ClientOptions{
		Dsn:              cfg.DSN,
		Environment:      cfg.Environment,
		Release:          cfg.Release,
		TracesSampleRate: cfg.TracesSampleRate,
		Debug:            cfg.Debug,
		BeforeSend: func(event *sentry.Event, hint *sentry.EventHint) *sentry.Event {
			if event.Request != nil {
				event.Request.Cookies = ""
				delete(event.Request.Headers, "Authorization")
			}
			return event
		},
		AttachStacktrace: true,
	})

	if err != nil {
		return fmt.Errorf("sentry initialization failed: %w", err)
	}

	defer sentry.Flush(2 * time.Second)

	return nil
}

func sentryMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		hub := sentry.GetHubFromContext(ctx)
		if hub == nil {
			hub = sentry.CurrentHub().Clone()
			ctx = sentry.SetHubOnContext(ctx, hub)
		}

		span := sentry.StartSpan(ctx, "http.server",
			sentry.TransactionName(fmt.Sprintf("%s %s", r.Method, r.URL.Path)),
		)
		defer span.Finish()

		span.SetTag("http.method", r.Method)
		span.SetTag("http.url", r.URL.String())
		span.SetTag("user_agent", r.UserAgent())

		r = r.WithContext(span.Context())

		next.ServeHTTP(w, r)
	})
}

func handleError(w http.ResponseWriter, err error, code int) {
	sentry.CaptureException(err)

	resp := ErrorResponse{
		Error: err.Error(),
		Time:  time.Now(),
	}

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

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(resp)
}

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

	span := sentry.StartSpan(r.Context(), "db.query", sentry.TransactionName("SELECT * FROM users"))
	span.SetTag("db.system", "postgresql")
	defer span.Finish()

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
	var data map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		handleError(w, err, http.StatusBadRequest)
		return
	}

	message, _ := data["message"].(string)
	level, _ := data["level"].(string)

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

func recoveryMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
							if err := recover(); err != nil {
				sentry.CurrentHub().Recover(err)
				sentry.Flush(time.Second * 2)

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
	cfg := SentryConfig{
		DSN:              os.Getenv("SENTRY_DSN"),
		Environment:      getEnvOrDefault("ENVIRONMENT", "development"),
		Release:          getEnvOrDefault("RELEASE", "sentinel-theme@1.0.0"),
		TracesSampleRate: 1.0,
		Debug:            os.Getenv("DEBUG") == "true",
	}

	if err := initSentry(cfg); err != nil {
		log.Printf("Warning: Sentry initialization failed: %v", err)
	}

	r := mux.NewRouter()

	r.Use(recoveryMiddleware)
	r.Use(sentryMiddleware)
	r.Use(sentryhttp.New(sentryhttp.Options{
		Repanic: true,
	}).Handle)

	r.HandleFunc("/health", healthHandler).Methods("GET")
	r.HandleFunc("/api/v2/users/{id}", getUserHandler).Methods("GET")
	r.HandleFunc("/api/v2/errors", createErrorHandler).Methods("POST")

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

func getEnvOrDefault(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
