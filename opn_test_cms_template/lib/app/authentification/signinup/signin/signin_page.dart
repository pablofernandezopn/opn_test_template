import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../bootstrap.dart';
import '../../../../config/app_texts.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/preferences_service.dart';
import '../../../config/service_locator.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/repository/auth_repository.dart';
import 'cubit/signin_cubit.dart';
import 'cubit/signin_state.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  static const String route = '/signin';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInCubit(
        getIt<AuthRepository>(),
        getIt<PreferencesService>(),
        LocalAuthentication(),
        context.read<AuthCubit>(),
      ),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.secondary.withOpacity(0.8),
                  colorScheme.secondary,
                ],
                stops: const [0, 0.5, 1.0],
              ),
            ),
          ),
          // Formulario de login
          const _SignInForm(),
        ],
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm();

  @override
  Widget build(BuildContext context) {
    final FocusNode emailFocusNode = FocusNode();
    final FocusNode passwordFocusNode = FocusNode();

    return BlocListener<SignInCubit, SignInState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SignInStatus.done) {
          logger.debug('🎯 [SIGNIN_PAGE] Login successful, navigating to home');
          context.go(AppRoutes.home);
        }
      },
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),

                  // Email & Password
                  _buildStylizedTextField(
                    context: context,
                    focusNode: emailFocusNode,
                    hintText: AppTexts.emailLabel,
                    icon: Icons.email_outlined,
                    onChanged: (value) =>
                        context.read<SignInCubit>().email(value),
                    onSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(passwordFocusNode),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    context: context,
                    focusNode: passwordFocusNode,
                    onChanged: (value) =>
                        context.read<SignInCubit>().password(value),
                    onSubmitted: (value) => _signIn(context),
                  ),
                  const SizedBox(height: 16),

                  // Error Message
                  _buildErrorMessage(),
                  const SizedBox(height: 32),

                  // Sign In Button
                  _buildSignInButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<SignInCubit>().signIn();
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.8),
                colorScheme.secondary.withOpacity(0.8),
              ],
            ),
          ),
          child: SvgPicture.asset(
            'assets/images/opn_logos/opn-logo-main.svg',
            height: 60,
            colorFilter: ColorFilter.mode(
              colorScheme.onPrimary,
              BlendMode.dstIn,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppTexts.signInTitle,
          style: textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppTexts.appName,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStylizedTextField({
    required BuildContext context,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required Function(String) onChanged,
    required Function(String) onSubmitted,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: colorScheme.primary),
      ),
      autofillHints: const [AutofillHints.email],
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required FocusNode focusNode,
    required Function(String) onChanged,
    required Function(String) onSubmitted,
  }) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, state) {
        return TextField(
          focusNode: focusNode,
          obscureText: !state.showPassword,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: AppTexts.passwordLabel,
            prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                state.showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                context.read<SignInCubit>().togglePasswordVisibility();
              },
            ),
          ),
          autofillHints: const [AutofillHints.password],
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return BlocBuilder<SignInCubit, SignInState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.status == SignInStatus.error && state.errorMessage != null) {
          return Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return BlocSelector<SignInCubit, SignInState, SignInStatus>(
      selector: (state) => state.status,
      builder: (context, status) {
        final isLoading = status == SignInStatus.loading;

        return ElevatedButton(
          onPressed: isLoading ? null : () => _signIn(context),
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text(AppTexts.signInButton),
        );
      },
    );
  }
}
