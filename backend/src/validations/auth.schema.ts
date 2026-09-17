import { z } from 'zod';

export const registerSchema = z.object({
  fullName: z
    .string({ required_error: 'Full name is required' })
    .trim()
    .min(2, 'Full name must be at least 2 characters')
    .max(100, 'Full name must not exceed 100 characters'),
  mobile: z
    .string({ required_error: 'Mobile number is required' })
    .trim()
    .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number'),
  dob: z
    .string()
    .optional()
    .nullable(),
  address: z
    .string()
    .trim()
    .max(500, 'Address must not exceed 500 characters')
    .optional()
    .nullable(),
  mpin: z
    .string({ required_error: 'MPIN is required' })
    .regex(/^\d{4}$/, 'MPIN must be exactly 4 digits'),
});

export const loginSchema = z.object({
  mobile: z
    .string({ required_error: 'Mobile number is required' })
    .trim()
    .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number'),
  mpin: z
    .string({ required_error: 'MPIN is required' })
    .regex(/^\d{4}$/, 'MPIN must be exactly 4 digits'),
});

export const updateProfileSchema = z.object({
  userId: z.string({ required_error: 'User ID is required' }),
  fullName: z
    .string()
    .trim()
    .min(2, 'Full name must be at least 2 characters')
    .max(100, 'Full name must not exceed 100 characters')
    .optional(),
  mobile: z
    .string()
    .trim()
    .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number')
    .optional(),
  dob: z
    .string()
    .optional()
    .nullable(),
  address: z
    .string()
    .trim()
    .max(500, 'Address must not exceed 500 characters')
    .optional()
    .nullable(),
});

export const resetMpinSchema = z.object({
  mobile: z
    .string({ required_error: 'Mobile number is required' })
    .trim()
    .regex(/^[6-9]\d{9}$/, 'Please enter a valid 10-digit mobile number'),
  dob: z
    .string({ required_error: 'Date of Birth is required' })
    .trim()
    .min(1, 'Date of Birth is required'),
  newMpin: z
    .string({ required_error: 'New 4-digit MPIN is required' })
    .regex(/^\d{4}$/, 'MPIN must be exactly 4 digits'),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type ResetMpinInput = z.infer<typeof resetMpinSchema>;

