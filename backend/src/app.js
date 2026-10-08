const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./routes/authRoutes');
const noteRoutes = require('./routes/noteRoutes');
const questionPaperRoutes = require('./routes/questionPaperRoutes');
const syllabusRoutes = require('./routes/syllabusRoutes');
const noticeRoutes = require('./routes/noticeRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const importantQuestionRoutes = require('./routes/importantQuestionRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const collegeRoutes = require('./routes/collegeRoutes');

const app = express();

// Security HTTP Headers
app.use(
  helmet({
    contentSecurityPolicy: false, // Allows cross-origin PDF streaming
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// CORS Configuration
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : '*';

app.use(
  cors({
    origin: allowedOrigins,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Body Parsing & Size Limits (15MB for base64/files)
app.use(express.json({ limit: '15mb' }));
app.use(express.urlencoded({ extended: true, limit: '15mb' }));

// Rate Limiter for Authentication Sensitive Endpoints (15 req / 15 min)
const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // Limit each IP to 30 authentication requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many authentication attempts from this IP. Please try again after 15 minutes.',
  },
});

// Health Check Route
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'SVPUAT College Study Hub API is running',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/auth', authRateLimiter, authRoutes);
app.use('/api/notes', noteRoutes);
app.use('/api/question-papers', questionPaperRoutes);
app.use('/api/syllabus', syllabusRoutes);
app.use('/api/notices', noticeRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/important-questions', importantQuestionRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/colleges', collegeRoutes);

// Global Production-Safe Error Handler
app.use((err, req, res, next) => {
  console.error('API Server Error:', err.stack);

  const isProduction = process.env.NODE_ENV === 'production';

  res.status(err.status || 500).json({
    success: false,
    message: isProduction ? 'An unexpected server error occurred' : err.message || 'Internal Server Error',
    ...(isProduction ? {} : { stack: err.stack }),
  });
});

module.exports = app;
