"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resetMpinSchema = exports.updateProfileSchema = exports.loginSchema = exports.registerSchema = void 0;
const zod_1 = require("zod");
exports.registerSchema = zod_1.z.object({
    fullName: zod_1.z
        .string({ required_error: 'Full name is required' })
        .trim()
        .min(2, 'Full name must be at least 2 characters')
        .max(100, 'Full name must not exceed 100 characters'),
    mobile: zod_1.z
        .string({ required_error: 'Mobile number is required' })
        .trim()
        .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number'),
    dob: zod_1.z
        .string()
        .optional()
        .nullable(),
    address: zod_1.z
        .string()
        .trim()
        .max(500, 'Address must not exceed 500 characters')
        .optional()
        .nullable(),
    mpin: zod_1.z
        .string({ required_error: 'MPIN is required' })
        .regex(/^\d{4}$/, 'MPIN must be exactly 4 digits'),
});
exports.loginSchema = zod_1.z.object({
    mobile: zod_1.z
        .string({ required_error: 'Mobile number is required' })
        .trim()
        .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number'),
    mpin: zod_1.z
        .string({ required_error: 'MPIN is required' })
        .regex(/^\d{4}$/, 'MPIN must be exactly 4 digits'),
});
exports.updateProfileSchema = zod_1.z.object({
    userId: zod_1.z.string({ required_error: 'User ID is required' }),
    fullName: zod_1.z
        .string()
        .trim()
        .min(2, 'Full name must be at least 2 characters')
        .max(100, 'Full name must not exceed 100 characters')
        .optional(),
    mobile: zod_1.z
        .string()
        .trim()
        .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number')
        .optional(),
    dob: zod_1.z
        .string()
        .optional()
        .nullable(),
    address: zod_1.z
        .string()
        .trim()
        .max(500, 'Address must not exceed 500 characters')
        .optional()
        .nullable(),
});
exports.resetMpinSchema = zod_1.z.object({
    mobile: zod_1.z
        .string({ required_error: 'Mobile number is required' })
        .trim()
        .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number'),
    dob: zod_1.z
        .string({ required_error: 'Date of Birth is required' })
        .trim()
        .min(1, 'Date of Birth is required'),
    newMpin: zod_1.z
        .string({ required_error: 'New 4-digit MPIN is required' })
        .regex(/^\d{4}$/, 'MPIN must be exactly 4 digits'),
});
