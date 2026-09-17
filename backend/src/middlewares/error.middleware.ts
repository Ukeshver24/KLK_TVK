import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  statusCode: number;

  constructor(message: string, statusCode: number = 500) {
    super(message);
    this.statusCode = statusCode;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let statusCode = err instanceof AppError ? err.statusCode : 500;
  let message = 'Server error occurred. Please try again.';

  // If it's a known application error with a clean client-safe message
  if (err instanceof AppError) {
    message = err.message;
  } else if (err?.code === 'P2003') {
    // Prisma Foreign Key Constraint error (e.g. user was deleted from database)
    statusCode = 401;
    message = 'User account not found. Please log in again.';
  } else if (err?.code === 'P2002') {
    // Prisma Unique Constraint error
    statusCode = 409;
    message = 'A record with this information already exists.';
  } else if (err?.code === 'P2025') {
    // Prisma Record Not Found
    statusCode = 404;
    message = 'Requested record was not found.';
  } else {
    // Any other unhandled error -> Log internally for developers, but NEVER leak code/Prisma stack traces to citizens!
    console.error(`[Unhandled Server Error] ${err?.message || err}`, err?.stack);
    message = 'Server error occurred. Please try again.';
  }

  console.error(`[Response ${statusCode}] ${message}`);

  res.status(statusCode).json({
    success: false,
    message,
  });
};
