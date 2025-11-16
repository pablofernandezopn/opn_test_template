import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../config/environment.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/preferences_service.dart';
import '../../../config/service_locator.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/repository/auth_repository.dart';
import '../components/hidde_key_board.dart';
import '../components/pass_text_field.dart';
import '../components/text_field.dart';
import 'cubit/signup_cubit.dart';
import 'cubit/signup_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage._();

  static Widget create() => BlocProvider(
    create: (_) => SignUpCubit(
      getIt<PreferencesService>(),
      getIt<AuthRepository>(),
    ),
    child: const SignUpPage._(),
  );

  static const String route = '/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: HideKeyboard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      child: BlocConsumer<SignUpCubit, SignUpState>(
                        listener: _handleSignUpState,
                        builder: (context, state) {
                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                'Datos de registro',
                                style: textTheme.displaySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                'Elige tu nombre de usuario. Este nombre se mostrará en los rankings.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Nombre de usuario',
                                suffixIcon: Icons.person_outline_rounded,
                                controller: _usernameController,
                                onChanged: cubit.username,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Email',
                                suffixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                onChanged: cubit.email,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Número de teléfono',
                                suffixIcon: Icons.phone,
                                keyboardType: TextInputType.number,
                                controller: _phoneController,
                                onChanged: cubit.phone,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Nombre',
                                suffixIcon: Icons.badge_outlined,
                                textCapitalization: TextCapitalization.words,
                                controller: _nameController,
                                onChanged: cubit.name,
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: 'Apellidos',
                                suffixIcon: Icons.badge_outlined,
                                textCapitalization: TextCapitalization.words,
                                controller: _surnameController,
                                onChanged: cubit.surname,
                              ),
                              const SizedBox(height: 20),
                              PasswordTextField(
                                label: 'Contraseña',
                                controller: _passwordController,
                                onChanged: cubit.password,
                              ),
                              const SizedBox(height: 20),
                              PasswordTextField(
                                label: 'Repetir contraseña',
                                controller: _repeatPasswordController,
                                onChanged: cubit.repeatedPassword,
                              ),
                              const SizedBox(height: 33),
                              Row(
                                children: [
                                  Checkbox(
                                    value: state.acceptPolicy,
                                    onChanged: (bool? value) => cubit.acceptPolicy(value ?? false),
                                    activeColor: colorScheme.primary,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openTerms,
                                      child: Text(
                                        'Acepto los Términos y Política de Privacidad',
                                        style: textTheme.bodyMedium?.copyWith(
                                          decoration: TextDecoration.underline,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 33),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: !state.isComplete
                                      ? null
                                      : () {
                                    primaryFocus?.unfocus();
                                    cubit.signUp();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
                                    disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: (state.status == SignUpStatus.loading ||
                                      state.status == SignUpStatus.done)
                                      ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                      : Text(
                                    'Comenzar ahora',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTerms() async {
    if (!await launchUrlString(
      Environment.instance.termsUrl,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch terms and conditions url');
    }
  }

  void _handleSignUpState(BuildContext context, SignUpState state) {
    switch (state.status) {
      case SignUpStatus.done:
        context.read<AuthCubit>().check(firstStart: true);
        context.go(AppRoutes.home);
    // No break para continuar y mostrar mensaje en caso de error
      case SignUpStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(state.errorMessage ?? 'Se ha producido un error')),
        );
        break;
      case SignUpStatus.editing:
      case SignUpStatus.loading:
        break;
    }
  }
}
