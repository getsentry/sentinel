// Sentry SDK Example - TypeScript with React (v10)
import * as Sentry from '@sentry/react';
// Note: In v10, all integrations are functions from the main package
import React, { useState, useEffect } from 'react';

// Type definitions
interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'user' | 'guest';
}

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
}

type LogLevel = 'debug' | 'info' | 'warning' | 'error' | 'fatal';

// Configuration
const SENTRY_CONFIG = {
  dsn: process.env.REACT_APP_SENTRY_DSN,
  integrations: [
    Sentry.browserTracingIntegration(),
    Sentry.replayIntegration({
      maskAllText: false,
      blockAllMedia: false,
    }),
  ],
  tracesSampleRate: 1.0,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
} as const;

/**
 * Custom hook for error tracking
 */
function useErrorHandler(): (error: Error, errorInfo?: React.ErrorInfo) => void {
  return React.useCallback((error: Error, errorInfo?: React.ErrorInfo) => {
    console.error('Error caught:', error);
    
    Sentry.withScope((scope) => {
      scope.setTag('component', errorInfo?.componentStack || 'unknown');
      scope.setLevel('error');
      scope.setContext('errorInfo', errorInfo || {});
      Sentry.captureException(error);
    });
  }, []);
}

/**
 * Error Boundary Component
 */
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback?: React.ComponentType<{ error: Error }> },
  ErrorBoundaryState
> {
  constructor(props: any) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo): void {
    Sentry.captureException(error, {
      contexts: {
        react: {
          componentStack: errorInfo.componentStack,
        },
      },
    });
  }

  render(): React.ReactNode {
    if (this.state.hasError && this.state.error) {
      const FallbackComponent = this.props.fallback;
      
      if (FallbackComponent) {
        return <FallbackComponent error={this.state.error} />;
      }
      
      return (
        <div className="error-boundary">
          <h2>Something went wrong</h2>
          <details style={{ whiteSpace: 'pre-wrap' }}>
            {this.state.error.toString()}
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}

/**
 * Performance monitoring decorator
 */
function withPerformanceMonitoring<T extends (...args: any[]) => any>(
  fn: T,
  name: string
): T {
  return ((...args: Parameters<T>) => {
    const transaction = Sentry.startTransaction({
      name,
      op: 'function',
    });

    Sentry.getCurrentHub().configureScope((scope) => scope.setSpan(transaction));

    try {
      const result = fn(...args);
      
      if (result instanceof Promise) {
        return result
          .then((res) => {
            transaction.setStatus('ok');
            return res;
          })
          .catch((error) => {
            transaction.setStatus('internal_error');
            throw error;
          })
          .finally(() => {
            transaction.finish();
          });
      }
      
      transaction.setStatus('ok');
      transaction.finish();
      return result;
    } catch (error) {
      transaction.setStatus('internal_error');
      transaction.finish();
      throw error;
    }
  }) as T;
}

/**
 * Example React component with error handling
 */
const UserDashboard: React.FC<{ userId: string }> = ({ userId }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const handleError = useErrorHandler();

  useEffect(() => {
    const fetchUser = async (): Promise<void> => {
      try {
        const response = await fetch(`/api/users/${userId}`);
        
        if (!response.ok) {
          throw new Error(`Failed to fetch user: ${response.statusText}`);
        }
        
        const userData: User = await response.json();
        setUser(userData);
        
        // Set user context for Sentry
        Sentry.setUser({
          id: userData.id,
          email: userData.email,
          username: userData.name,
        });
      } catch (error) {
        handleError(error as Error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId, handleError]);

  if (loading) {
    return <div className="loading">Loading user data...</div>;
  }

  if (!user) {
    return <div className="error">User not found</div>;
  }

  return (
    <div className="user-dashboard">
      <h1>Welcome, {user.name}!</h1>
      <p>Role: <span className={`role-${user.role}`}>{user.role}</span></p>
      <button 
        onClick={() => {
          Sentry.captureMessage('User clicked dashboard button', 'info');
        }}
      >
        Track Event
      </button>
    </div>
  );
};

// Initialize Sentry
Sentry.init(SENTRY_CONFIG);

export { ErrorBoundary, UserDashboard, useErrorHandler, withPerformanceMonitoring };
export type { User, LogLevel };
