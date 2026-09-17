import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';
import routes from './routes';
import { errorHandler } from './middlewares/error.middleware';
import { apiLimiter } from './middlewares/rate-limit.middleware';

const app: Application = express();

// Trust reverse proxy (Nginx) for correct client IP detection and rate limiting
app.set('trust proxy', 1);

// Disable x-powered-by header for information disclosure protection
app.disable('x-powered-by');

// Security HTTP headers with cross-origin resource policy for uploaded images
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);

// Enable Cross-Origin Resource Sharing
app.use(
  cors({
    origin: '*', // In production, restrict to verified client domains
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-user-id', 'x-access-token'],
  })
);

// Serve uploaded proof images and banners statically
app.use('/uploads', express.static(path.resolve(process.cwd(), 'uploads')));

// HTTP request logger
app.use(morgan('dev'));

// Parse incoming JSON requests
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Apply global rate limiting and mount API v1 routes
app.use('/api/v1', apiLimiter, routes);

// Global Error Handler
app.use(errorHandler);

export default app;
