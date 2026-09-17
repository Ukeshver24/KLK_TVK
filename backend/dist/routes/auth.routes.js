"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_controller_1 = require("../controllers/auth.controller");
const validate_middleware_1 = require("../middlewares/validate.middleware");
const auth_middleware_1 = require("../middlewares/auth.middleware");
const rate_limit_middleware_1 = require("../middlewares/rate-limit.middleware");
const auth_schema_1 = require("../validations/auth.schema");
const router = (0, express_1.Router)();
// Citizen Authentication Routes
router.post('/register', rate_limit_middleware_1.apiLimiter, (0, validate_middleware_1.validateRequest)(auth_schema_1.registerSchema), auth_controller_1.AuthController.register);
router.post('/login', rate_limit_middleware_1.authLimiter, (0, validate_middleware_1.validateRequest)(auth_schema_1.loginSchema), auth_controller_1.AuthController.login);
router.post('/reset-mpin', rate_limit_middleware_1.resetLimiter, (0, validate_middleware_1.validateRequest)(auth_schema_1.resetMpinSchema), auth_controller_1.AuthController.resetMpin);
router.get('/me', auth_middleware_1.authenticate, auth_controller_1.AuthController.getMe);
router.put('/profile', auth_middleware_1.authenticate, (0, auth_middleware_1.requireSelfOrAdmin)((req) => req.body?.userId), (0, validate_middleware_1.validateRequest)(auth_schema_1.updateProfileSchema), auth_controller_1.AuthController.updateProfile);
router.post('/fcm-token', auth_middleware_1.optionalAuthenticate, auth_controller_1.AuthController.updateFcmToken);
// Admin & Overview Management Routes
router.get('/users', auth_middleware_1.optionalAuthenticate, auth_controller_1.AuthController.getUsers);
// Admin Authentication & Email Password Reset Routes (Rate limiting temporarily lifted for Admin Reset testing)
router.post('/admin/login', rate_limit_middleware_1.authLimiter, auth_controller_1.AuthController.adminLogin);
router.post('/admin/forgot-password', auth_controller_1.AuthController.forgotAdminPassword);
router.get('/admin/verify-reset-token/:token', auth_controller_1.AuthController.verifyResetToken);
router.post('/admin/reset-password', auth_controller_1.AuthController.resetAdminPassword);
router.post('/admin/change-password', auth_middleware_1.authenticate, (0, auth_middleware_1.requireRoles)('ADMIN', 'MLA_OFFICE'), auth_controller_1.AuthController.changeAdminPassword);
exports.default = router;
