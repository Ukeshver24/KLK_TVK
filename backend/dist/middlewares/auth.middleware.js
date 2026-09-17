"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireSelfOrAdmin = exports.requireRoles = exports.optionalAuthenticate = exports.authenticate = exports.verifyJwtToken = exports.signJwtToken = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const error_middleware_1 = require("./error.middleware");
const db_1 = __importDefault(require("../config/db"));
const JWT_SECRET = process.env.JWT_SECRET || 'tvk_super_secure_jwt_secret_key_2026_kallakurichi';
/**
 * Helper to generate signed JWT token with expiry
 */
const signJwtToken = (payload, expiresIn = '30d') => {
    return jsonwebtoken_1.default.sign(payload, JWT_SECRET, { expiresIn });
};
exports.signJwtToken = signJwtToken;
/**
 * Helper to verify JWT token
 */
const verifyJwtToken = (token) => {
    return jsonwebtoken_1.default.verify(token, JWT_SECRET);
};
exports.verifyJwtToken = verifyJwtToken;
/**
 * Middleware: Enforces that the request has a valid, non-expired JWT Bearer token
 * and that the corresponding user account is active in the database.
 */
const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization || req.headers['x-access-token'];
        if (!authHeader) {
            throw new error_middleware_1.AppError('Authentication required. Please login to continue.', 401);
        }
        let token = authHeader;
        if (authHeader.startsWith('Bearer ')) {
            token = authHeader.substring(7).trim();
        }
        if (!token) {
            throw new error_middleware_1.AppError('Authentication token is missing or invalid.', 401);
        }
        let decoded;
        try {
            decoded = (0, exports.verifyJwtToken)(token);
        }
        catch (err) {
            if (err.name === 'TokenExpiredError') {
                throw new error_middleware_1.AppError('Your session has expired. Please login again.', 401);
            }
            throw new error_middleware_1.AppError('Invalid authentication token.', 401);
        }
        // Verify user account exists and is not blocked
        if (decoded.type === 'CITIZEN') {
            const user = await db_1.default.user.findUnique({
                where: { id: decoded.userId },
                select: { id: true, status: true, role: true, userCode: true },
            });
            if (!user) {
                throw new error_middleware_1.AppError('User account associated with this session no longer exists.', 401);
            }
            if (user.status === 'BLOCKED') {
                throw new error_middleware_1.AppError('Your account has been deactivated. Please contact support.', 403);
            }
        }
        else if (decoded.type === 'ADMIN') {
            const admin = await db_1.default.adminUser.findUnique({
                where: { id: decoded.userId },
                select: { id: true, status: true, role: true },
            });
            if (!admin) {
                throw new error_middleware_1.AppError('Administrator account associated with this session no longer exists.', 401);
            }
            if (admin.status === 'BLOCKED') {
                throw new error_middleware_1.AppError('This administrator account has been disabled.', 403);
            }
        }
        req.user = decoded;
        next();
    }
    catch (error) {
        next(error);
    }
};
exports.authenticate = authenticate;
/**
 * Middleware: Optional Authentication (attaches req.user if token is present, but doesn't reject if missing)
 */
const optionalAuthenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization || req.headers['x-access-token'];
        if (!authHeader) {
            return next();
        }
        let token = authHeader;
        if (authHeader.startsWith('Bearer ')) {
            token = authHeader.substring(7).trim();
        }
        if (!token) {
            return next();
        }
        const decoded = (0, exports.verifyJwtToken)(token);
        req.user = decoded;
        next();
    }
    catch (_) {
        // Silently continue without user context for optional auth
        next();
    }
};
exports.optionalAuthenticate = optionalAuthenticate;
/**
 * Middleware: Restricts route to specified roles (e.g., ['ADMIN', 'MLA_OFFICE'])
 */
const requireRoles = (...allowedRoles) => {
    return (req, res, next) => {
        if (!req.user) {
            return next(new error_middleware_1.AppError('Authentication required.', 401));
        }
        if (!allowedRoles.includes(req.user.role)) {
            return next(new error_middleware_1.AppError('Access denied. You do not have sufficient permissions to perform this action.', 403));
        }
        next();
    };
};
exports.requireRoles = requireRoles;
/**
 * Middleware: Enforces that a citizen can only access/modify their own resource,
 * while ADMIN and MLA_OFFICE roles have administrative access.
 */
const requireSelfOrAdmin = (extractTargetUserId) => {
    return (req, res, next) => {
        if (!req.user) {
            return next(new error_middleware_1.AppError('Authentication required.', 401));
        }
        // Admins and MLA_OFFICE have full permission
        if (req.user.role === 'ADMIN' || req.user.role === 'MLA_OFFICE') {
            return next();
        }
        const targetUserId = extractTargetUserId(req);
        if (!targetUserId) {
            return next(new error_middleware_1.AppError('Target user identifier is required.', 400));
        }
        // Citizen can only access their own user id or user code
        if (req.user.userId !== targetUserId && req.user.userCode !== targetUserId) {
            return next(new error_middleware_1.AppError('Access forbidden: You cannot access or modify data belonging to another user.', 403));
        }
        next();
    };
};
exports.requireSelfOrAdmin = requireSelfOrAdmin;
