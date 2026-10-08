const nodemailer = require('nodemailer');

class EmailService {
  /**
   * Send Password Reset Link Email
   * @param {string} toEmail - Recipient email address
   * @param {string} resetLink - Secure reset link with raw token
   */
  static async sendPasswordResetEmail(toEmail, resetLink) {
    const provider = (process.env.EMAIL_PROVIDER || 'CONSOLE').toUpperCase();

    if (provider === 'SMTP' && process.env.SMTP_HOST && process.env.SMTP_USER) {
      try {
        const transporter = nodemailer.createTransport({
          host: process.env.SMTP_HOST,
          port: parseInt(process.env.SMTP_PORT || '587', 10),
          secure: process.env.SMTP_SECURE === 'true',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
          },
        });

        await transporter.sendMail({
          from: process.env.EMAIL_FROM || '"SVPUAT Study Hub" <noreply@svpuat.ac.in>',
          to: toEmail,
          subject: 'Password Reset Request - SVPUAT Portal',
          html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; color: #1B365D;">
              <h2>SVPUAT Academic Portal - Password Reset</h2>
              <p>You requested a password reset for your account.</p>
              <p>Please click the button below to reset your password. This link will expire in 30 minutes:</p>
              <a href="${resetLink}" style="display: inline-block; padding: 12px 24px; color: #ffffff; background-color: #1B365D; text-decoration: none; border-radius: 8px; font-weight: bold;">Reset Password</a>
              <p style="margin-top: 20px; font-size: 12px; color: #64748B;">If you did not request this, please ignore this email.</p>
            </div>
          `,
        });
        console.log(`[EMAIL DISPATCH] Password reset email sent via SMTP to ${toEmail}`);
        return { success: true, provider: 'SMTP' };
      } catch (err) {
        console.error('SMTP Email Send Error:', err.message);
        return { success: false, error: err.message };
      }
    } else {
      console.log(`[EMAIL CONSOLE DISPATCH] Password reset link for ${toEmail}: ${resetLink}`);
      return { success: true, provider: 'CONSOLE' };
    }
  }
}

module.exports = EmailService;
