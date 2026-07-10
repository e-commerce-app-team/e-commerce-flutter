# OTP & 2FA Implementation Blueprint (For Claude)

This blueprint contains the exact architectural and execution steps required to implement OTP (Email/Phone) and Two-Factor Authentication (2FA) across the Laravel backend and the Flutter frontend. 
**Please follow this plan strictly and meticulously.**

## 1. Backend (Laravel) Execution Plan

### A. Environment Configuration
Ensure the following variables are present in the `.env` file (User will provide values):
- `ULTRAMSG_TOKEN` and `ULTRAMSG_API_URL` (For WhatsApp OTP).
- `MAIL_MAILER`, `MAIL_HOST`, `MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_ENCRYPTION`, `MAIL_FROM_ADDRESS` (For Email OTP).

### B. Database Migrations
Run: `php artisan make:migration add_two_factor_and_otp_to_users_table`
Add the following columns to the `users` table:
- `otp_code` (string, nullable)
- `otp_expires_at` (timestamp, nullable)
- `two_factor_enabled` (boolean, default false)
- `two_factor_method` (string, default 'email' or 'phone')

### C. Models Updates
In `app/Models/User.php`:
- Add `otp_code`, `otp_expires_at`, `two_factor_enabled`, `two_factor_method` to the `$fillable` array.
- Add `otp_expires_at` to the `$casts` array as `datetime`.

### D. Service Layer
Create `app/Services/OtpService.php`:
- Implement a method to generate a 6-digit random code and save it to the user with an expiration of 1 minute.
- Method `sendEmailOtp(User $user)`: Sends the OTP using Laravel's `Mail` facade.
- Method `sendPhoneOtp(User $user)`: Integrate the custom WhatsApp API logic (from `OtpHelper.php`) to send the OTP via WhatsApp.

### E. Controllers & Routing (`routes/api.php`)
Modify `UserController@login`:
- If authentication is successful and `two_factor_enabled` is true, **DO NOT** return the sanctum token. 
- Instead, generate an OTP, send it via the selected `two_factor_method`, and return a `202 Accepted` response (e.g., `requires_otp: true`, `method: email/phone`, `user_id`).

Create new endpoints (either in `UserController` or a new `OtpController`):
- `POST /api/login/verify-otp`: Validates the OTP for login. If successful, issues and returns the `access_token` and user data.
- `POST /api/forgot-password/send-otp`: Finds user by email/phone, generates and sends OTP.
- `POST /api/forgot-password/verify-otp`: Validates the OTP before allowing password reset.
- `POST /api/forgot-password/reset`: Updates the password.
- `POST /api/user/toggle-2fa` (Protected by Sanctum): Enables/disables 2FA and sets the preferred method (Email/Phone).

---

## 2. Frontend (Flutter) Execution Plan

### A. Login Flow Updates
- Modify `LoginControllerImp` to handle the `requires_otp` response.
- Create or modify an OTP screen (`VerifyLoginCode`).
- Integrate a 60-second countdown `Timer`. The "Resend OTP" button must remain disabled until the timer reaches zero.
- Upon successful OTP validation, navigate the user to their respective home screen based on their role.

### B. Forgot Password Flow Updates
- Update `lib/view/screen/auth/forgetpassword/forgetpassword.dart` and its controller to accept either an Email or a Phone number.
- Update `VerifyCodeControllerImp` to integrate the 60-second countdown timer and connect to the `/forgot-password/verify-otp` API.
- Update `ResetPasswordControllerImp` to connect to the new reset API endpoint.

### C. Sign Up Flow Updates
- After calling the register API in `SignUpBuyer` or `SignUpSeller`, intercept the navigation to the "Success" screen.
- Redirect the user to `VerifyCodeSignUpScreen`.
- Connect this screen to an OTP verification API. Only navigate to the "Success" screen upon correct OTP entry.

### D. Profile / 2FA Settings
- Add a UI section in the user profile to toggle Two-Factor Authentication.
- Include a Switch (Enable/Disable) and a selection mechanism (Radio buttons or Dropdown) to choose between Email and WhatsApp.
- Connect to the `/user/toggle-2fa` API.

### E. Strict Flutter UI Standards (CRITICAL)
1. **Localization**: Never use hardcoded strings. Add all new strings (timer messages, OTP errors) to `translation.dart` and use `.tr`.
2. **Colors**: Never use raw colors (e.g., `Colors.red`). Always use the centralized `AppColor` class.
3. **Typography**: Ensure all text elements use the centralized text theme (`Theme.of(context).textTheme`).
