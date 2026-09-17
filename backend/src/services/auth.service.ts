import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import prisma from '../config/db';
import { RegisterInput, LoginInput, ResetMpinInput } from '../validations/auth.schema';
import { AppError } from '../middlewares/error.middleware';
import { signJwtToken } from '../middlewares/auth.middleware';
import { EmailService } from './email.service';

const CITIZEN_JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '30d';
const ADMIN_JWT_EXPIRES_IN = process.env.ADMIN_JWT_EXPIRES_IN || '8h';

export class AuthService {
  /**
   * Helper to generate unique sequential User Code (e.g., TVK-C-0001)
   */
  static async generateUserCode(role: 'CITIZEN' | 'ADMIN' | 'MLA_OFFICE' = 'CITIZEN'): Promise<string> {
    const prefix = role === 'CITIZEN' ? 'TVK-C' : role === 'ADMIN' ? 'TVK-A' : 'TVK-M';
    try {
      const result: any = await prisma.$queryRaw`SELECT nextval('citizen_user_seq') as seq`;
      const seq = Number(result[0]?.seq || 1);
      return `${prefix}-${String(seq).padStart(4, '0')}`;
    } catch {
      const count = await prisma.user.count({ where: { role } });
      return `${prefix}-${String(count + 1).padStart(4, '0')}`;
    }
  }

  /**
   * Backfill existing users without a userCode
   */
  private static async backfillExistingUsers(): Promise<void> {
    const usersWithoutCode = await prisma.user.findMany({
      where: { userCode: null },
      orderBy: { createdAt: 'asc' },
    });

    for (let i = 0; i < usersWithoutCode.length; i++) {
      const u = usersWithoutCode[i];
      const prefix = u.role === 'CITIZEN' ? 'TVK-C' : u.role === 'ADMIN' ? 'TVK-A' : 'TVK-M';
      const code = `${prefix}-${String(i + 1).padStart(4, '0')}`;
      await prisma.user.update({
        where: { id: u.id },
        data: { userCode: code },
      });
    }
  }

  /**
   * Hash a raw reset token with SHA-256 before database storage or lookup
   */
  private static hashToken(rawToken: string): string {
    return crypto.createHash('sha256').update(rawToken.trim()).digest('hex');
  }

  /**
   * Register a new Citizen user with auto-generated TVK-C-XXXX & JWT Token
   */
  static async registerUser(input: RegisterInput) {
    if (!input.fullName || !input.fullName.trim()) {
      throw new AppError('Full name is required for registration.', 400);
    }

    if (!input.address || !input.address.trim()) {
      throw new AppError('Address is required. Please provide your residential address.', 400);
    }

    const existingUser = await prisma.user.findUnique({
      where: { mobile: input.mobile },
    });

    if (existingUser) {
      throw new AppError(
        'This mobile number is already registered. Please login with your MPIN.',
        409
      );
    }

    // Hash the 4-digit MPIN efficiently
    const saltRounds = process.env.DISABLE_RATE_LIMIT === 'true' ? 6 : 10;
    const mpinHash = await bcrypt.hash(input.mpin, saltRounds);

    const userCode = await this.generateUserCode('CITIZEN');

    const newUser = await prisma.user.create({
      data: {
        userCode,
        fullName: input.fullName,
        mobile: input.mobile,
        dob: input.dob || null,
        address: input.address || null,
        mpinHash,
        role: 'CITIZEN',
        status: 'ACTIVE',
      },
      select: {
        id: true,
        userCode: true,
        fullName: true,
        mobile: true,
        dob: true,
        address: true,
        role: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    // Generate signed JWT Token for the new user session
    const token = signJwtToken(
      {
        userId: newUser.id,
        userCode: newUser.userCode ?? undefined,
        role: newUser.role,
        identifier: newUser.mobile,
        type: 'CITIZEN',
      },
      CITIZEN_JWT_EXPIRES_IN
    );

    return {
      ...newUser,
      token,
      expiresIn: CITIZEN_JWT_EXPIRES_IN,
    };
  }

  /**
   * User Login with Mobile & MPIN -> Returns User details & signed JWT Token
   */
  static async loginUser(input: LoginInput) {
    const user = await prisma.user.findUnique({
      where: { mobile: input.mobile },
    });

    if (!user) {
      throw new AppError('Invalid mobile number or MPIN.', 401);
    }

    if (user.status === 'BLOCKED') {
      throw new AppError('Your account has been deactivated. Please contact support.', 403);
    }

    const isMatch = await bcrypt.compare(input.mpin, user.mpinHash);
    if (!isMatch) {
      throw new AppError('Invalid mobile number or MPIN.', 401);
    }

    let finalUser = user;
    if (!user.userCode) {
      const generatedCode = await this.generateUserCode(user.role);
      finalUser = await prisma.user.update({
        where: { id: user.id },
        data: { userCode: generatedCode },
      });
    }

    // Generate signed JWT Token
    const token = signJwtToken(
      {
        userId: finalUser.id,
        userCode: finalUser.userCode ?? undefined,
        role: finalUser.role,
        identifier: finalUser.mobile,
        type: 'CITIZEN',
      },
      CITIZEN_JWT_EXPIRES_IN
    );

    // Sanitize response to remove sensitive hash
    const { mpinHash, ...userWithoutPassword } = finalUser;

    return {
      ...userWithoutPassword,
      token,
      expiresIn: CITIZEN_JWT_EXPIRES_IN,
    };
  }

  /**
   * Get Current Authenticated Citizen Profile
   */
  static async getMe(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        userCode: true,
        fullName: true,
        mobile: true,
        dob: true,
        address: true,
        role: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new AppError('User profile not found.', 404);
    }

    return user;
  }

  /**
   * Reset / Forgot MPIN with Mobile & Date of Birth verification
   */
  static async resetMpin(input: ResetMpinInput) {
    const user = await prisma.user.findUnique({
      where: { mobile: input.mobile },
    });

    if (!user) {
      throw new AppError('Invalid details. Mobile number or Date of Birth does not match.', 400);
    }

    if (!user.dob) {
      throw new AppError('Date of Birth is not registered for this account. Please contact support.', 400);
    }

    // Helper to compare dates flexibly (handles DD/MM/YYYY vs YYYY-MM-DD vs DD-MM-YYYY)
    const normalizeDob = (d: string) => d.trim().replace(/[-.]/g, '/');
    const userDobNorm = normalizeDob(user.dob);
    const inputDobNorm = normalizeDob(input.dob);

    let isDobMatch = userDobNorm.toLowerCase() === inputDobNorm.toLowerCase();
    if (!isDobMatch) {
      const userParts = userDobNorm.split('/');
      const inputParts = inputDobNorm.split('/');
      if (userParts.length === 3 && inputParts.length === 3) {
        if (
          (userParts[0] === inputParts[0] && userParts[1] === inputParts[1] && userParts[2] === inputParts[2]) ||
          (userParts[0] === inputParts[2] && userParts[1] === inputParts[1] && userParts[2] === inputParts[0])
        ) {
          isDobMatch = true;
        }
      }
    }

    if (!isDobMatch) {
      throw new AppError('Invalid details. Mobile number or Date of Birth does not match.', 400);
    }

    // Hash the new 4-digit MPIN with 12 salt rounds
    const saltRounds = 12;
    const newMpinHash = await bcrypt.hash(input.newMpin, saltRounds);

    await prisma.user.update({
      where: { id: user.id },
      data: { mpinHash: newMpinHash },
    });

    return { message: 'MPIN has been reset successfully. You can now log in with your new MPIN.' };
  }

  /**
   * Admin / Listing: Fetch all registered users (Protected: Admin only)
   */
  static async getAllUsers() {
    await this.backfillExistingUsers();

    return prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        userCode: true,
        fullName: true,
        mobile: true,
        dob: true,
        address: true,
        role: true,
        status: true,
        createdAt: true,
      },
    });
  }

  /**
   * Update Citizen User Profile
   */
  static async updateUserProfile(input: {
    userId: string;
    fullName?: string;
    mobile?: string;
    dob?: string | null;
    address?: string | null;
  }) {
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ id: input.userId }, { userCode: input.userId }],
      },
    });

    if (!user) {
      throw new AppError('User not found in database.', 404);
    }

    // Check if new mobile number is already used by another user
    if (input.mobile && input.mobile !== user.mobile) {
      const mobileExists = await prisma.user.findUnique({
        where: { mobile: input.mobile },
      });
      if (mobileExists && mobileExists.id !== user.id) {
        throw new AppError(
          'This mobile number is already associated with another account.',
          409
        );
      }
    }

    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: {
        ...(input.fullName !== undefined && { fullName: input.fullName.trim() }),
        ...(input.mobile !== undefined && { mobile: input.mobile.trim() }),
        ...(input.dob !== undefined && { dob: input.dob }),
        ...(input.address !== undefined && { address: input.address ? input.address.trim() : null }),
      },
      select: {
        id: true,
        userCode: true,
        fullName: true,
        mobile: true,
        dob: true,
        address: true,
        role: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    return updatedUser;
  }

  /**
   * Update or register Firebase FCM Device Token for Push Notifications
   */
  static async updateFcmToken(userId: string, fcmToken: string) {
    if (!userId || !fcmToken) {
      throw new AppError('User ID and FCM Token are required.', 400);
    }

    const userExists = await prisma.user.findUnique({
      where: { id: userId },
      select: { id: true },
    });

    if (!userExists) {
      return { message: 'User session expired or not found. FCM Token sync skipped.' };
    }

    const updated = await prisma.user.update({
      where: { id: userId },
      data: { fcmToken: fcmToken.trim() },
      select: { id: true, userCode: true, mobile: true, fcmToken: true },
    });

    return updated;
  }

  // ==========================================
  // 🛡️ SECURE ADMIN AUTHENTICATION METHODS
  // ==========================================

  /**
   * Automatically ensure at least one default Admin User exists in DB
   * Configurable via environment variable ADMIN_DEFAULT_PASSWORD
   */
  static async initAdminUser() {
    const adminCount = await prisma.adminUser.count();
    if (adminCount === 0) {
      const initialPassword = process.env.ADMIN_DEFAULT_PASSWORD || 'TVK_Admin@2026!';
      const defaultPasswordHash = await bcrypt.hash(initialPassword, 12);
      await prisma.adminUser.create({
        data: {
          username: 'admin',
          email: process.env.ADMIN_DEFAULT_EMAIL || 'mla.kallakurichi@tvk.in',
          fullName: 'Kallakurichi MLA Office Admin',
          passwordHash: defaultPasswordHash,
          role: 'ADMIN',
          status: 'ACTIVE',
        },
      });
      console.log('✅ Initialized default Admin user safely (username: admin)');
    }
  }

  /**
   * Admin Login with Username / Email and Password (Bcrypt verified & JWT Token issued)
   */
  static async adminLogin(usernameOrEmail: string, passwordPlain: string) {
    await this.initAdminUser();

    const trimmedIdentifier = (usernameOrEmail || '').trim();
    const trimmedPassword = (passwordPlain || '').trim();

    if (!trimmedIdentifier || !trimmedPassword) {
      throw new AppError('Please enter both username and password.', 400);
    }

    const admin = await prisma.adminUser.findFirst({
      where: {
        OR: [
          { username: { equals: trimmedIdentifier, mode: 'insensitive' } },
          { email: { equals: trimmedIdentifier, mode: 'insensitive' } },
        ],
      },
    });

    if (!admin) {
      throw new AppError('Invalid username or password.', 401);
    }

    if (admin.status === 'BLOCKED') {
      throw new AppError('This administrator account has been disabled. Please contact system support.', 403);
    }

    const isMatch = await bcrypt.compare(trimmedPassword, admin.passwordHash);
    if (!isMatch) {
      throw new AppError('Invalid username or password.', 401);
    }

    // Generate signed Admin JWT Token
    const token = signJwtToken(
      {
        userId: admin.id,
        role: admin.role,
        identifier: admin.username,
        type: 'ADMIN',
      },
      ADMIN_JWT_EXPIRES_IN
    );

    return {
      id: admin.id,
      username: admin.username,
      email: admin.email,
      fullName: admin.fullName,
      role: admin.role,
      status: admin.status,
      token,
      expiresIn: ADMIN_JWT_EXPIRES_IN,
    };
  }

  /**
   * Request Password Reset Link
   * Generates secure 64-char crypto token, stores SHA-256 hash in DB with 3-min expiry
   */
  static async requestAdminPasswordReset(emailInput: string) {
    await this.initAdminUser();

    const trimmedEmail = (emailInput || '').trim().toLowerCase();
    if (!trimmedEmail) {
      throw new AppError('Please provide your registered administrator email address.', 400);
    }

    const admin = await prisma.adminUser.findFirst({
      where: {
        email: { equals: trimmedEmail, mode: 'insensitive' },
      },
    });

    // Timing-attack / enumeration mitigation: Don't leak if email doesn't exist
    if (!admin) {
      return {
        message: 'If the provided email is registered, a password reset link has been dispatched.',
      };
    }

    // Generate secure cryptographic random token (64 hex characters)
    const rawResetToken = crypto.randomBytes(32).toString('hex');
    const hashedResetToken = this.hashToken(rawResetToken);
    const resetTokenExpires = new Date(Date.now() + 3 * 60 * 1000); // 3 minutes validity strictly

    // Store SHA-256 hash in database to prevent token leakage from DB dumps
    await prisma.adminUser.update({
      where: { id: admin.id },
      data: {
        resetToken: hashedResetToken,
        resetTokenExpires,
      },
    });

    const baseUrl = process.env.ADMIN_WEB_URL || 'http://localhost:5173';
    const resetLink = `${baseUrl}/?token=${rawResetToken}#reset-password`;

    // Dispatch real email via Nodemailer / SMTP
    await EmailService.sendPasswordResetEmail(admin.email, admin.fullName, resetLink);

    return {
      message: 'If the provided email is registered, a password reset link has been dispatched.',
    };
  }

  /**
   * Verify whether a password reset token is valid and unexpired (3-minute single-use)
   */
  static async verifyResetToken(rawTokenInput: string) {
    const trimmedToken = (rawTokenInput || '').trim();
    if (!trimmedToken) {
      throw new AppError('Invalid reset token.', 400);
    }

    const hashedToken = this.hashToken(trimmedToken);

    const admin = await prisma.adminUser.findUnique({
      where: { resetToken: hashedToken },
      select: {
        id: true,
        username: true,
        email: true,
        fullName: true,
        resetTokenExpires: true,
      },
    });

    if (!admin || !admin.resetTokenExpires || admin.resetTokenExpires < new Date()) {
      throw new AppError('This password reset link is invalid, has expired (3-minute time limit), or has already been used.', 400);
    }

    return {
      valid: true,
      email: admin.email,
      username: admin.username,
      fullName: admin.fullName,
    };
  }

  /**
   * Reset Admin Password with Token (SHA-256 verification, Bcrypt 12-round hash, one-time use)
   */
  static async resetAdminPasswordWithToken(rawTokenInput: string, newPasswordPlain: string) {
    const trimmedToken = (rawTokenInput || '').trim();
    const trimmedPassword = (newPasswordPlain || '').trim();

    if (!trimmedToken) {
      throw new AppError('Invalid or missing reset token.', 400);
    }

    if (!trimmedPassword || trimmedPassword.length < 8) {
      throw new AppError('Password must be at least 8 characters long.', 400);
    }

    const hashedToken = this.hashToken(trimmedToken);

    const admin = await prisma.adminUser.findUnique({
      where: { resetToken: hashedToken },
    });

    if (!admin || !admin.resetTokenExpires || admin.resetTokenExpires < new Date()) {
      throw new AppError('This password reset link is invalid, has expired (3-minute time limit), or has already been used.', 400);
    }

    // Hash the new password with bcrypt 12 salt rounds
    const passwordHash = await bcrypt.hash(trimmedPassword, 12);

    // Update password and strictly clear resetToken to make it single-use
    await prisma.adminUser.update({
      where: { id: admin.id },
      data: {
        passwordHash,
        resetToken: null,
        resetTokenExpires: null,
      },
    });

    return {
      message: 'Your administrator password has been updated successfully. You can now login with your new password.',
    };
  }

  /**
   * Change Admin Password (Strict identity verification, eliminates insecure fallback logic)
   */
  static async changeAdminPassword(
    adminUserId: string,
    currentPasswordPlain: string,
    newPasswordPlain: string
  ) {
    const trimmedCurrent = (currentPasswordPlain || '').trim();
    const trimmedNew = (newPasswordPlain || '').trim();

    if (!adminUserId) {
      throw new AppError('Authenticated administrator identity is required.', 400);
    }

    if (!trimmedCurrent) {
      throw new AppError('Please enter your current password.', 400);
    }

    if (!trimmedNew || trimmedNew.length < 8) {
      throw new AppError('New password must be at least 8 characters long.', 400);
    }

    // Strictly locate the specific admin account by authenticated Admin User ID
    const admin = await prisma.adminUser.findUnique({
      where: { id: adminUserId },
    });

    if (!admin) {
      throw new AppError('Administrator account not found.', 404);
    }

    if (admin.status === 'BLOCKED') {
      throw new AppError('This administrator account has been disabled.', 403);
    }

    // Verify current password with bcrypt
    const isMatch = await bcrypt.compare(trimmedCurrent, admin.passwordHash);
    if (!isMatch) {
      throw new AppError('Current password is incorrect.', 400);
    }

    // Hash the new password with bcrypt 12 salt rounds
    const newPasswordHash = await bcrypt.hash(trimmedNew, 12);

    await prisma.adminUser.update({
      where: { id: admin.id },
      data: {
        passwordHash: newPasswordHash,
      },
    });

    return {
      message: 'Admin password changed successfully.',
    };
  }
}
