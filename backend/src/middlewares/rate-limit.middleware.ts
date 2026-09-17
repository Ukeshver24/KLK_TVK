import rateLimit from 'express-rate-limit';

const shouldSkip = () => process.env.DISABLE_RATE_LIMIT === 'true' || process.env.NODE_ENV === 'test';

/**
 * Rate Limiter for Authentication endpoints (Login & Admin Login)
 * Max 5 attempts per 15 minutes per IP address to prevent brute-force attacks on MPIN / Passwords.
 */
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  standardHeaders: true, // Return standard RateLimit-* headers
  legacyHeaders: false, // Disable X-RateLimit-* headers
  skip: shouldSkip,
  message: {
    success: false,
    message: 'Too many login attempts. Please try again after 15 minutes.',
    code: 'RATE_LIMIT_EXCEEDED',
  },
  skipSuccessfulRequests: false, // Count both success and failure to prevent automated credential stuffing
});

/**
 * Rate Limiter for Sensitive Reset endpoints (Reset MPIN & Forgot Password)
 * Max 3 requests per 15 minutes per IP to prevent spamming SMS/Email or enumeration.
 */
export const resetLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 3, // Limit each IP to 3 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  skip: shouldSkip,
  message: {
    success: false,
    message: 'Too many password/MPIN reset attempts. Please try again after 15 minutes.',
    code: 'RATE_LIMIT_EXCEEDED',
  },
});

/**
 * Global Rate Limiter for all general API endpoints
 * Max 100 requests per 15 minutes per IP.
 */
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // Reasonable threshold for active mobile app usage
  standardHeaders: true,
  legacyHeaders: false,
  skip: shouldSkip,
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.',
    code: 'RATE_LIMIT_EXCEEDED',
  },
});
