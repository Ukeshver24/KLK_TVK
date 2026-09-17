import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { AppError } from './error.middleware';
import prisma from '../config/db';

export interface AuthTokenPayload {
  userId: string;
  userCode?: string;
  role: 'CITIZEN' | 'ADMIN' | 'MLA_OFFICE';
  identifier: string; // mobile for Citizen, username/email for Admin
  type: 'CITIZEN' | 'ADMIN';
  iat?: number;
  exp?: number;
}

// Extend Express Request declaration to include user payload
declare global {
  namespace Express {
    interface Request {
      user?: AuthTokenPayload;
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'tvk_super_secure_jwt_secret_key_2026_kallakurichi';

/**
 * Helper to generate signed JWT token with expiry
 */
export const signJwtToken = (
  payload: Omit<AuthTokenPayload, 'iat' | 'exp'>,
  expiresIn: string | number = '30d'
): string => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn } as jwt.SignOptions);
};

/**
 * Helper to verify JWT token
 */
export const verifyJwtToken = (token: string): AuthTokenPayload => {
  return jwt.verify(token, JWT_SECRET) as AuthTokenPayload;
};

/**
 * Middleware: Enforces that the request has a valid, non-expired JWT Bearer token
 * and that the corresponding user account is active in the database.
 */
export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization || (req.headers['x-access-token'] as string);

    if (!authHeader) {
      throw new AppError('Authentication required. Please login to continue.', 401);
    }

    let token = authHeader;
    if (authHeader.startsWith('Bearer ')) {
      token = authHeader.substring(7).trim();
    }

    if (!token) {
      throw new AppError('Authentication token is missing or invalid.', 401);
    }

    let decoded: AuthTokenPayload;
    try {
      decoded = verifyJwtToken(token);
    } catch (err: any) {
      if (err.name === 'TokenExpiredError') {
        throw new AppError('Your session has expired. Please login again.', 401);
      }
      throw new AppError('Invalid authentication token.', 401);
    }

    // Verify user account exists and is not blocked
    if (decoded.type === 'CITIZEN') {
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: { id: true, status: true, role: true, userCode: true },
      });

      if (!user) {
        throw new AppError('User account associated with this session no longer exists.', 401);
      }

      if (user.status === 'BLOCKED') {
        throw new AppError('Your account has been deactivated. Please contact support.', 403);
      }
    } else if (decoded.type === 'ADMIN') {
      const admin = await prisma.adminUser.findUnique({
        where: { id: decoded.userId },
        select: { id: true, status: true, role: true },
      });

      if (!admin) {
        throw new AppError('Administrator account associated with this session no longer exists.', 401);
      }

      if (admin.status === 'BLOCKED') {
        throw new AppError('This administrator account has been disabled.', 403);
      }
    }

    req.user = decoded;
    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Middleware: Optional Authentication (attaches req.user if token is present, but doesn't reject if missing)
 */
export const optionalAuthenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization || (req.headers['x-access-token'] as string);
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

    const decoded = verifyJwtToken(token);
    req.user = decoded;
    next();
  } catch (_) {
    // Silently continue without user context for optional auth
    next();
  }
};

/**
 * Middleware: Restricts route to specified roles (e.g., ['ADMIN', 'MLA_OFFICE'])
 */
export const requireRoles = (
  ...allowedRoles: Array<'CITIZEN' | 'ADMIN' | 'MLA_OFFICE'>
) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new AppError('Authentication required.', 401));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(
        new AppError(
          'Access denied. You do not have sufficient permissions to perform this action.',
          403
        )
      );
    }

    next();
  };
};

/**
 * Middleware: Enforces that a citizen can only access/modify their own resource,
 * while ADMIN and MLA_OFFICE roles have administrative access.
 */
export const requireSelfOrAdmin = (
  extractTargetUserId: (req: Request) => string | undefined
) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new AppError('Authentication required.', 401));
    }

    // Admins and MLA_OFFICE have full permission
    if (req.user.role === 'ADMIN' || req.user.role === 'MLA_OFFICE') {
      return next();
    }

    const targetUserId = extractTargetUserId(req);
    if (!targetUserId) {
      return next(new AppError('Target user identifier is required.', 400));
    }

    // Citizen can only access their own user id or user code
    if (req.user.userId !== targetUserId && req.user.userCode !== targetUserId) {
      return next(
        new AppError(
          'Access forbidden: You cannot access or modify data belonging to another user.',
          403
        )
      );
    }

    next();
  };
};
