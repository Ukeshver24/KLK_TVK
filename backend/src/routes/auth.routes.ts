import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { validateRequest } from '../middlewares/validate.middleware';
import {
  authenticate,
  optionalAuthenticate,
  requireRoles,
  requireSelfOrAdmin,
} from '../middlewares/auth.middleware';
import {
  authLimiter,
  resetLimiter,
  apiLimiter,
} from '../middlewares/rate-limit.middleware';
import {
  registerSchema,
  loginSchema,
  updateProfileSchema,
  resetMpinSchema,
} from '../validations/auth.schema';

const router = Router();

// Citizen Authentication Routes
router.post(
  '/register',
  apiLimiter,
  validateRequest(registerSchema),
  AuthController.register
);

router.post(
  '/login',
  authLimiter,
  validateRequest(loginSchema),
  AuthController.login
);

router.post(
  '/reset-mpin',
  resetLimiter,
  validateRequest(resetMpinSchema),
  AuthController.resetMpin
);

router.get(
  '/me',
  authenticate,
  AuthController.getMe
);

router.put(
  '/profile',
  authenticate,
  requireSelfOrAdmin((req) => req.body?.userId),
  validateRequest(updateProfileSchema),
  AuthController.updateProfile
);

router.post(
  '/fcm-token',
  optionalAuthenticate,
  AuthController.updateFcmToken
);

// Admin & Overview Management Routes
router.get(
  '/users',
  optionalAuthenticate,
  AuthController.getUsers
);

// Admin Authentication & Email Password Reset Routes (Rate limiting temporarily lifted for Admin Reset testing)
router.post(
  '/admin/login',
  authLimiter,
  AuthController.adminLogin
);

router.post(
  '/admin/forgot-password',
  AuthController.forgotAdminPassword
);

router.get(
  '/admin/verify-reset-token/:token',
  AuthController.verifyResetToken
);

router.post(
  '/admin/reset-password',
  AuthController.resetAdminPassword
);

router.post(
  '/admin/change-password',
  authenticate,
  requireRoles('ADMIN', 'MLA_OFFICE'),
  AuthController.changeAdminPassword
);

export default router;
