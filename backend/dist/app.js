"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const path_1 = __importDefault(require("path"));
const routes_1 = __importDefault(require("./routes"));
const error_middleware_1 = require("./middlewares/error.middleware");
const rate_limit_middleware_1 = require("./middlewares/rate-limit.middleware");
const app = (0, express_1.default)();
// Trust reverse proxy (Nginx) for correct client IP detection and rate limiting
app.set('trust proxy', 1);
// Disable x-powered-by header for information disclosure protection
app.disable('x-powered-by');
// Security HTTP headers with cross-origin resource policy for uploaded images
app.use((0, helmet_1.default)({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
// Enable Cross-Origin Resource Sharing
app.use((0, cors_1.default)({
    origin: '*', // In production, restrict to verified client domains
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-user-id', 'x-access-token'],
}));
// Serve uploaded proof images and banners statically
app.use('/uploads', express_1.default.static(path_1.default.resolve(process.cwd(), 'uploads')));
// HTTP request logger
app.use((0, morgan_1.default)('dev'));
// Parse incoming JSON requests
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
// Apply global rate limiting and mount API v1 routes
app.use('/api/v1', rate_limit_middleware_1.apiLimiter, routes_1.default);
// Global Error Handler
app.use(error_middleware_1.errorHandler);
exports.default = app;
