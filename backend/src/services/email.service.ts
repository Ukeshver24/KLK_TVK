import nodemailer from 'nodemailer';

export class EmailService {
  private static getTransporter() {
    const host = process.env.SMTP_HOST || 'smtp.gmail.com';
    const port = parseInt(process.env.SMTP_PORT || '465', 10);
    const secure = process.env.SMTP_SECURE !== 'false'; // true for 465, false for 587
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASS;

    if (!user || !pass) {
      return null;
    }

    return nodemailer.createTransport({
      host,
      port,
      secure,
      auth: {
        user,
        pass,
      },
    });
  }

  /**
   * Send TVK Administrator Password Reset Link Email (Clean English, 3-min expiry, No raw link)
   */
  static async sendPasswordResetEmail(toEmail: string, adminName: string, resetLink: string): Promise<boolean> {
    const fromAddress = process.env.EMAIL_FROM || `TVK MLA Command Center <${process.env.SMTP_USER || 'no-reply@tvk.in'}>`;
    const transporter = this.getTransporter();

    if (!transporter) {
      console.log('----------------------------------------------------');
      console.log(`📧 [EMAIL NOTIFICATION] Password Reset Link for: ${toEmail}`);
      console.log(`👤 Admin Name: ${adminName}`);
      console.log(`🔗 Reset Link (3-min validity): ${resetLink}`);
      console.log('ℹ️ (Configure SMTP_USER & SMTP_PASS in backend .env to deliver real emails)');
      console.log('----------------------------------------------------');
      return false;
    }

    const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Admin Password</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f6f6f6; margin: 0; padding: 20px; }
    .container { max-width: 560px; margin: 0 auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.08); border: 1px solid #e2e8f0; }
    .header { background: linear-gradient(135deg, #6B0000 0%, #850000 50%, #600000 100%); padding: 30px 24px; text-align: center; color: #ffffff; border-bottom: 3px solid #FEF08A; }
    .header h1 { margin: 0; font-size: 20px; font-weight: 900; letter-spacing: 0.5px; }
    .header p { margin: 6px 0 0 0; font-size: 12px; color: #FEF08A; font-weight: 700; }
    .body { padding: 32px 24px; color: #334155; line-height: 1.6; }
    .greeting { font-size: 16px; font-weight: 800; color: #0f172a; margin-bottom: 12px; }
    .text { font-size: 13.5px; color: #475569; margin-bottom: 20px; }
    .button-container { text-align: center; margin: 28px 0; }
    .btn { display: inline-block; background: linear-gradient(135deg, #8B0000 0%, #6B0000 100%); color: #FEF08A !important; font-weight: 800; font-size: 14px; text-decoration: none; padding: 14px 36px; border-radius: 12px; box-shadow: 0 4px 14px rgba(107, 0, 0, 0.3); border: 1px solid #FEF08A; }
    .security-note { background: #f8fafc; border-left: 4px solid #8B0000; padding: 12px 16px; border-radius: 6px; font-size: 12px; color: #475569; margin-top: 24px; }
    .footer { background: #f8fafc; padding: 20px; text-align: center; font-size: 11px; color: #94a3b8; border-top: 1px solid #f1f5f9; line-height: 1.5; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Tamizhaga Vettri Kazhagam</h1>
      <p>Kallakurichi Assembly Constituency • MLA Command Center</p>
    </div>
    <div class="body">
      <div class="greeting">Dear ${adminName},</div>
      <div class="text">
        We received a request to reset the password for your TVK Administrator Account. Click the secure button below to set your new password:
      </div>
      
      <div class="button-container">
        <a href="${resetLink}" class="btn" target="_blank">Reset Admin Password</a>
      </div>

      <div class="security-note">
        ⏱️ <b>Important Security Notice:</b><br>
        This link is valid for <b>3 minutes only</b> and can be used <b>only once</b>.<br>
        If you did not request this password reset, please ignore this email or contact system administration immediately.
      </div>
    </div>
    <div class="footer">
      © 2026 Tamizhaga Vettri Kazhagam • Kallakurichi MLA Command Center Portal<br>
      Confidential • For Authorized TVK MLA Office Administrators Only
    </div>
  </div>
</body>
</html>
    `;

    try {
      await transporter.sendMail({
        from: fromAddress,
        to: toEmail,
        subject: '🔒 TVK MLA Command Center - Password Reset Request',
        html: htmlContent,
      });
      console.log(`✅ Password reset email dispatched to ${toEmail} (3-min expiry, one-time use)`);
      return true;
    } catch (error) {
      console.error(`❌ Failed to send email via SMTP to ${toEmail}:`, error);
      return false;
    }
  }
}
