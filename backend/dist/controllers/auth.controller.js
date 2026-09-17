"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const auth_service_1 = require("../services/auth.service");
const error_middleware_1 = require("../middlewares/error.middleware");
class AuthController {
    /**
     * POST /api/v1/auth/register
     */
    static async register(req, res, next) {
        try {
            const result = await auth_service_1.AuthService.registerUser(req.body);
            res.status(201).json({
                success: true,
                message: 'Account registered successfully',
                data: result,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/auth/login
     */
    static async login(req, res, next) {
        try {
            const result = await auth_service_1.AuthService.loginUser(req.body);
            res.status(200).json({
                success: true,
                message: 'Login successful',
                data: result,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/auth/me (Get Authenticated User Profile)
     */
    static async getMe(req, res, next) {
        try {
            if (!req.user || !req.user.userId) {
                throw new error_middleware_1.AppError('Authentication required.', 401);
            }
            const user = await auth_service_1.AuthService.getMe(req.user.userId);
            res.status(200).json({
                success: true,
                data: user,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/auth/users (Protected: Admin & MLA Office only)
     */
    static async getUsers(req, res, next) {
        try {
            const users = await auth_service_1.AuthService.getAllUsers();
            res.status(200).json({
                success: true,
                count: users.length,
                data: users,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * PUT /api/v1/auth/profile
     */
    static async updateProfile(req, res, next) {
        try {
            // Prioritize authenticated user's ID to prevent IDOR attacks
            const targetUserId = req.user?.role === 'CITIZEN' ? req.user.userId : (req.body.userId || req.user?.userId);
            if (!targetUserId) {
                throw new error_middleware_1.AppError('User ID is required', 400);
            }
            const updatedUser = await auth_service_1.AuthService.updateUserProfile({
                ...req.body,
                userId: targetUserId,
            });
            res.status(200).json({
                success: true,
                message: 'Profile updated successfully',
                data: updatedUser,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/auth/reset-mpin
     */
    static async resetMpin(req, res, next) {
        try {
            const result = await auth_service_1.AuthService.resetMpin(req.body);
            res.status(200).json({
                success: true,
                message: result.message,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/auth/fcm-token (Register device push token)
     */
    static async updateFcmToken(req, res, next) {
        try {
            const userId = req.user?.userId || req.body.userId;
            const { fcmToken } = req.body;
            if (!userId || !fcmToken) {
                throw new error_middleware_1.AppError('User ID and FCM token are required.', 400);
            }
            const updated = await auth_service_1.AuthService.updateFcmToken(userId, fcmToken);
            res.status(200).json({
                success: true,
                message: 'FCM Token registered successfully for push notifications.',
                data: updated,
            });
        }
        catch (error) {
            next(error);
        }
    }
    // ==========================================
    // 🛡️ ADMIN AUTHENTICATION CONTROLLER METHODS
    // ==========================================
    /**
     * POST /api/v1/auth/admin/login
     */
    static async adminLogin(req, res, next) {
        try {
            const { username, password } = req.body;
            const admin = await auth_service_1.AuthService.adminLogin(username, password);
            res.status(200).json({
                success: true,
                message: 'Admin login successful',
                data: admin,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/auth/admin/forgot-password
     */
    static async forgotAdminPassword(req, res, next) {
        try {
            const { email } = req.body;
            const result = await auth_service_1.AuthService.requestAdminPasswordReset(email);
            res.status(200).json({
                success: true,
                message: result.message,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * GET /api/v1/auth/admin/verify-reset-token/:token
     */
    static async verifyResetToken(req, res, next) {
        try {
            const token = String(req.params.token || '');
            const result = await auth_service_1.AuthService.verifyResetToken(token);
            res.status(200).json({
                success: true,
                data: result,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/auth/admin/reset-password
     */
    static async resetAdminPassword(req, res, next) {
        try {
            const { token, newPassword } = req.body;
            const result = await auth_service_1.AuthService.resetAdminPasswordWithToken(token, newPassword);
            res.status(200).json({
                success: true,
                message: result.message,
            });
        }
        catch (error) {
            next(error);
        }
    }
    /**
     * POST /api/v1/auth/admin/change-password (Protected with JWT)
     */
    static async changeAdminPassword(req, res, next) {
        try {
            const adminUserId = req.user?.userId;
            if (!adminUserId) {
                throw new error_middleware_1.AppError('Authentication required to change admin password.', 401);
            }
            const { currentPassword, newPassword } = req.body;
            const result = await auth_service_1.AuthService.changeAdminPassword(adminUserId, currentPassword, newPassword);
            res.status(200).json({
                success: true,
                message: result.message,
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.AuthController = AuthController;
