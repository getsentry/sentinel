// Sentry SDK Example - JavaScript/Node.js (v10)
import * as Sentry from '@sentry/node';
import { nodeProfilingIntegration } from '@sentry/profiling-node';
import express from 'express';

// Constants and configuration
const PORT = process.env.PORT || 3000;
const DSN = 'https://your-key@o0.ingest.sentry.io/0';
const RATE_LIMIT = 100;

/**
 * Initialize Sentry error tracking
 * @param {Object} options - Configuration options
 * @returns {Promise<boolean>} Success status
 */
async function initializeSentry(options = {}) {
  try {
    Sentry.init({
      dsn: DSN,
      integrations: [
        nodeProfilingIntegration(),
      ],
      tracesSampleRate: 1.0,
      environment: process.env.NODE_ENV || 'development',
      // v10: Use tracePropagationTargets instead of tracingOrigins
      tracePropagationTargets: ['localhost', /^https:\/\/yourserver\.io\/api/],
      ...options,
    });
    
    console.log('✅ Sentry initialized successfully');
    return true;
  } catch (error) {
    console.error('❌ Failed to initialize:', error.message);
    return false;
  }
}

// Express app setup
const app = express();

// Middleware
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.tracingHandler());
app.use(express.json());

// Route handlers
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

app.post('/api/errors', async (req, res) => {
  const { message, level = 'error', user } = req.body;
  
  // Capture custom error
  Sentry.captureMessage(message, level);
  
  if (user) {
    Sentry.setUser({ id: user.id, email: user.email });
  }
  
  res.status(201).json({ 
    success: true,
    eventId: Sentry.lastEventId() 
  });
});

// Error handler middleware
app.use(Sentry.Handlers.errorHandler());

// Generic error handler
app.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  
  res.status(statusCode).json({
    error: {
      message: err.message,
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
});

// Start server
async function startServer() {
  const initialized = await initializeSentry();
  
  if (!initialized) {
    console.warn('⚠️  Starting without Sentry');
  }
  
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  Sentry.captureException(error);
  process.exit(1);
});

// Export for testing
export { app, initializeSentry, startServer };
