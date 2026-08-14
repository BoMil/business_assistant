import 'package:business_assistant/config/routes/bottom_nav_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:business_assistant/config/tenant/tenant_config.dart';
import 'package:business_assistant/config/translations/translation_storage.dart';
import 'package:business_assistant/core/features/authentication/cubits/auth/auth_cubit.dart';
import 'package:business_assistant/core/features/authentication/cubits/login/login_cubit.dart';
import 'package:business_assistant/core/shared/enums/cubit_state.dart';
import 'package:business_assistant/core/shared/pages/page_frame/page_frame.dart';
import 'package:business_assistant/core/shared/widgets/buttons/button_with_loading_state.dart';
import 'package:business_assistant/core/shared/widgets/checkboxes/custom_checkbox.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/core/utils/toast_message.dart';
import 'package:business_assistant/theme/get_theme_color.dart';
import 'package:business_assistant/theme/theme_constants.dart';

/// Email / password login screen.
///
/// Architecture overview:
///   - LoginCubit (page-scoped, provided here) handles POST /auth/login.
///   - AuthCubit (app-scoped, provided in main.dart) holds the global auth state.
///   - BlocConsumer reacts to LoginCubit state:
///       loading   → spinner on button, inputs disabled
///       completed → call AuthCubit.loginUserToApp() → navigate to landing page
///                   (GoRouter's refreshListenable will route to home once implemented)
///       error     → show error toast
///
/// Form validation:
///   - Client-side: email format, password not empty.
///   - Server-side: Identity API returns 401 for invalid credentials.
///   - autovalidateMode is switched to onUserInteraction after the first submit
///     attempt, so errors appear immediately on subsequent edits.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide LoginCubit locally so it's scoped to this page only
    return BlocProvider<LoginCubit>(create: (_) => LoginCubit(), child: const _LoginPageContent());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content widget (StatefulWidget owns form state and controllers)
// ─────────────────────────────────────────────────────────────────────────────

class _LoginPageContent extends StatefulWidget {
  const _LoginPageContent();

  @override
  State<_LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<_LoginPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Whether the password field renders characters or dots
  bool _isPasswordVisible = false;

  // Switched to true after the first submit so errors appear while typing
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().loadSavedCredentials().then((saved) {
      if (!mounted) return;
      setState(() {
        _emailController.text = saved.email;
        _passwordController.text = saved.password;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    final t = TranslationStorage.translation;
    if (value == null || value.trim().isEmpty) return t.emailRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return t.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return TranslationStorage.translation.passwordRequired;
    }
    return null;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _submit() {
    // Enable live validation after the first attempt
    if (!_autoValidate) setState(() => _autoValidate = true);
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginCubit>().login(email: _emailController.text.trim(), password: _passwordController.text);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tenant = TenantConfig();

    return BlocConsumer<LoginCubit, LoginState>(
      listener: _onStateChange,
      builder: (context, state) {
        final isLoading = state.currentState == CubitState.loading;

        return PageFrame(
          pageBody: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildLogoSection(tenant),
                    const SizedBox(height: 40),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(isLoading),
                    const SizedBox(height: 20),
                    _buildRememberMeCheckbox(),
                    // const SizedBox(height: 12),
                    // _buildForgotPasswordLink(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          pageBottomBar: _buildSignInButton(isLoading),
        );
      },
    );
  }

  // ── BlocListener callback ──────────────────────────────────────────────────

  void _onStateChange(BuildContext context, LoginState state) {
    if (state.loginResponse != null) {
      // Persist tokens and emit Authenticated — GoRouter refreshListenable
      // will redirect to homePage once that route is implemented.
      context.read<AuthCubit>().loginUserToApp(state.loginResponse!);

      final loginCubit = context.read<LoginCubit>();
      if (loginCubit.remember) {
        loginCubit.rememberMe(email: _emailController.text.trim(), password: _passwordController.text);
      } else {
        loginCubit.deleteCredentials();
      }

      final String firstPageRoute = visibleBottomNavTabs().first.path;
      context.go(firstPageRoute);
    }

    if (state.errorMessage != null) {
      ToastMessage().showErrorToast(text: state.errorMessage!);
    }
  }

  // ── Hero: logo + title + subtitle ─────────────────────────────────────────

  Widget _buildLogoSection(TenantConfig tenant) {
    final t = TranslationStorage.translation;
    return Column(
      children: [
        SvgPicture.asset(tenant.logoPath, height: 56),
        const SizedBox(height: 12),
        Text(
          tenant.appName,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.brandPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          t.signInSubtitle,
          style: TextStyle(fontSize: 14, color: context.colors.primaryText.withValues(alpha: 0.55)),
        ),
      ],
    );
  }

  // ── Email input ────────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    final t = TranslationStorage.translation;
    return PrimaryInputField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      placeholderText: t.email,
      customValidator: _validateEmail,
      prefixIcon: Icon(Icons.email_outlined, size: 20, color: context.colors.primaryText.withValues(alpha: 0.45)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      inputBackgroundCollor: context.colors.secondaryBackground,
      borderColor: context.colors.primaryText.withValues(alpha: 0.15),
      borderWidth: 1.2,
    );
  }

  // ── Password input ─────────────────────────────────────────────────────────

  Widget _buildPasswordField(bool isLoading) {
    final t = TranslationStorage.translation;
    return PrimaryInputField(
      controller: _passwordController,
      passwordFieldVisible: !_isPasswordVisible,
      customValidator: _validatePassword,
      placeholderText: t.password,
      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: context.colors.primaryText.withValues(alpha: 0.45)),
      sufixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: context.colors.primaryText.withValues(alpha: 0.45),
        ),
        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      inputBackgroundCollor: context.colors.secondaryBackground,
      borderColor: context.colors.primaryText.withValues(alpha: 0.15),
      borderWidth: 1.2,
    );
  }

  // ── Remember me checkbox ───────────────────────────────────────────────────

  Widget _buildRememberMeCheckbox() {
    final t = TranslationStorage.translation;
    return CustomCheckbox(
      labelWidget: Text(t.rememberMe, style: TextStyle(fontSize: 13, color: context.colors.primaryText)),
      isChecked: context.watch<LoginCubit>().remember,
      itemPressed: (value) {
        setState(() {
          context.read<LoginCubit>().remember = value;
        });
      },
    );
  }

  // ── Forgot password link ───────────────────────────────────────────────────

  Widget _buildForgotPasswordLink() {
    final t = TranslationStorage.translation;
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to RouteNames.resetPassword when implemented
          ToastMessage().showInfoToast(text: 'Coming soon');
        },
        child: Text(
          t.forgotPassword,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.brandPrimary),
        ),
      ),
    );
  }

  // ── Sign In button ─────────────────────────────────────────────────────────

  Widget _buildSignInButton(bool isLoading) {
    final t = TranslationStorage.translation;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(ThemeConstants.pagePadding, 12, ThemeConstants.pagePadding, 16),
        child: ButtonWithLoadingState(
          buttonText: t.signIn,
          loading: isLoading,
          buttonPressed: _submit,
          backgroundColor: context.colors.brandPrimary,
          textColor: Colors.white,
          radius: 22,
        ),
      ),
    );
  }
}
