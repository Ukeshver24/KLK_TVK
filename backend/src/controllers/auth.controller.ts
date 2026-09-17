import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { AppError } from '../middlewares/error.middleware';

export class AuthController {
  /**
   * POST /api/v1/auth/register
   */
  static async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await AuthService.registerUser(req.body);
      res.status(201).json({
        success: true,
        message: 'Account registered successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/login
   */
  static async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await AuthService.loginUser(req.body);
      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/auth/me (Get Authenticated User Profile)
   */
  static async getMe(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user || !req.user.userId) {
        throw new AppError('Authentication required.', 401);
      }
      const user = await AuthService.getMe(req.user.userId);
      res.status(200).json({
        success: true,
        data: user,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/auth/users (Protected: Admin & MLA Office only)
   */
  static async getUsers(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const users = await AuthService.getAllUsers();
      res.status(200).json({
        success: true,
        count: users.length,
        data: users,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /api/v1/auth/profile
   */
  static async updateProfile(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // Prioritize authenticated user's ID to prevent IDOR attacks
      const targetUserId = req.user?.role === 'CITIZEN' ? req.user.userId : (req.body.userId || req.user?.userId);
      if (!targetUserId) {
        throw new AppError('User ID is required', 400);
      }

      const updatedUser = await AuthService.updateUserProfile({
        ...req.body,
        userId: targetUserId,
      });

      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: updatedUser,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/reset-mpin
   */
  static async resetMpin(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await AuthService.resetMpin(req.body);
      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/fcm-token (Register device push token)
   */
  static async updateFcmToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const userId = req.user?.userId || req.body.userId;
      const { fcmToken } = req.body;
      if (!userId || !fcmToken) {
        throw new AppError('User ID and FCM token are required.', 400);
      }

      const updated = await AuthService.updateFcmToken(userId, fcmToken);
      res.status(200).json({
        success: true,
        message: 'FCM Token registered successfully for push notifications.',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  // ==========================================
  // 🛡️ ADMIN AUTHENTICATION CONTROLLER METHODS
  // ==========================================

  /**
   * POST /api/v1/auth/admin/login
   */
  static async adminLogin(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { username, password } = req.body;
      const admin = await AuthService.adminLogin(username, password);
      res.status(200).json({
        success: true,
        message: 'Admin login successful',
        data: admin,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/admin/forgot-password
   */
  static async forgotAdminPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { email } = req.body;
      const result = await AuthService.requestAdminPasswordReset(email);
      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/auth/admin/verify-reset-token/:token
   */
  static async verifyResetToken(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const token = String(req.params.token || '');
      const result = await AuthService.verifyResetToken(token);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/admin/reset-password
   */
  static async resetAdminPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { token, newPassword } = req.body;
      const result = await AuthService.resetAdminPasswordWithToken(token, newPassword);
      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /api/v1/auth/admin/change-password (Protected with JWT)
   */
  static async changeAdminPassword(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const adminUserId = req.user?.userId;
      if (!adminUserId) {
        throw new AppError('Authentication required to change admin password.', 401);
      }

      const { currentPassword, newPassword } = req.body;
      const result = await AuthService.changeAdminPassword(adminUserId, currentPassword, newPassword);
      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }
}
