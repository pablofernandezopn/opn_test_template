import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:opn_test_template/bootstrap.dart';
import 'package:opn_test_template/app/config/theme/color.dart';
import 'package:opn_test_template/config/app_texts.dart';
import 'package:opn_test_template/config/device_info.dart' hide isMobileDevice;
import 'package:url_launcher/url_launcher_string.dart';

import '../../../config/go_route/app_router.dart';
import '../../../config/go_route/app_routes.dart';
import '../../auth/cubit/auth_cubit.dart';

// TODO: Importar tus cubits y repositorios cuando los tengas
// import 'package:opn_test_template/app/auth/cubit/auth_cubit.dart';
// import 'package:opn_test_template/app/auth/repository/auth_repository.dart';
// import 'package:opn_test_template/app/signinup/signin/cubit/signin_cubit.dart';
// import 'package:opn_test_template/app/signinup/signin/cubit/signin_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage._();

  static Widget create() => const SignInPage._();
  // TODO: Descomentar cuando tengas los cubits
  // static Widget create() => BlocProvider(
  //       create: (_) => SignInCubit(
  //         getIt<AuthRepository>(),
  //         getIt<PreferencesService>(),
  //         getIt<LocalAuthentication>(),
  //       ),
  //       child: const SignInPage._(),
  //     );

  static const String route = '/signin';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _isUpdatingFromCubit = false;
  bool _obscurePassword = true; // Estado para mostrar/ocultar contraseña
  bool _isLoading = false; // Estado para el loading

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // TODO: Descomentar cuando tengas el cubit
    // final cubit = context.read<SignInCubit>();
    // emailController = TextEditingController(text: cubit.state.email ?? '');
    // passwordController = TextEditingController(text: cubit.state.password ?? '');

    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    // Actualizar el estado para habilitar/deshabilitar el botón
    setState(() {});

    // TODO: Descomentar cuando tengas el cubit
    // if (!_isUpdatingFromCubit) {
    //   context.read<SignInCubit>().email(emailController.text);
    // }
  }

  void _onPasswordChanged() {
    // Actualizar el estado para habilitar/deshabilitar el botón
    setState(() {});

    // TODO: Descomentar cuando tengas el cubit
    // if (!_isUpdatingFromCubit) {
    //   context.read<SignInCubit>().password(passwordController.text);
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TODO: Descomentar cuando tengas el cubit
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     context.read<SignInCubit>().checkBioLogin();
    //   }
    // });
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _updateControllersFromState(dynamic state) {
    // TODO: Implementar cuando tengas el SignInState
    // _isUpdatingFromCubit = true;
    // if (state.email != null && emailController.text != state.email) {
    //   emailController.value = TextEditingValue(
    //     text: state.email!,
    //     selection: TextSelection.collapsed(offset: state.email!.length),
    //   );
    // }
    // if (state.password != null && passwordController.text != state.password) {
    //   passwordController.value = TextEditingValue(
    //     text: state.password!,
    //     selection: TextSelection.collapsed(offset: state.password!.length),
    //   );
    // }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     _isUpdatingFromCubit = false;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // TODO: Descomentar cuando tengas el cubit
    // final cubit = context.read<SignInCubit>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header con botón de cerrar
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
                child: SingleChildScrollView(
                  child: _buildContent(context, theme, colorScheme, textTheme),
                  // TODO: Descomentar cuando tengas el cubit
                  // child: BlocConsumer<SignInCubit, SignInState>(
                  //   listener: (context, state) {
                  //     if (state.status == SignInStatus.done) {
                  //       context.read<AuthCubit>().check(firstStart: true);
                  //     }
                  //     _updateControllersFromState(state);
                  //   },
                  //   builder: (context, state) {
                  //     return _buildContent(context, theme, colorScheme, textTheme, state);
                  //   },
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
    // TODO: Agregar state cuando tengas el cubit
    // SignInState state,
  ) {
    // TODO: Descomentar cuando tengas el cubit
    // final cubit = context.read<SignInCubit>();
    // final hasError = state.status == SignInStatus.error && state.errorMessage != null;
    // final isLoading = state.status == SignInStatus.loading || state.status == SignInStatus.done;

    // Valores temporales (eliminar cuando tengas el cubit)
    final hasError = false;
    final isLoading = false;
    final isComplete = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;

    return Form(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              const SizedBox(height: 76),

              // Título
              Text(
                AppTexts.signInTitle,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 44),

              // Campo Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: AppTexts.emailLabel,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? colorScheme.error : colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? colorScheme.error : colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? colorScheme.error : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
                // TODO: Descomentar cuando tengas el cubit
                // onChanged: cubit.email,
              ),

              const SizedBox(height: 20),

              // Campo Contraseña
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: AppTexts.passwordLabel,
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? colorScheme.error : colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? colorScheme.error : colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? colorScheme.error : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
                // TODO: Descomentar cuando tengas el cubit
                // onChanged: cubit.password,
              ),

              const SizedBox(height: 12),

              // Mensaje de error
              Visibility(
                maintainSize: true,
                maintainInteractivity: false,
                maintainAnimation: true,
                maintainState: true,
                visible: hasError,
                child: Row(
                  children: [
                    Text(
                      '', // TODO: state.errorMessage ?? ''
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),

              // Huella dactilar (solo móvil)
              if (isMobileDevice) ...[
                const SizedBox(height: 22),
                InkWell(
                  onTap: isLoading ? null : () {
                    // TODO: cubit.checkBioLogin()
                  },
                  child: Icon(
                    Icons.fingerprint,
                    color: isLoading
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.primary,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 22),
              ] else
                const SizedBox(height: 22),

              // Botón Acceder
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: !isComplete || _isLoading
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();

                          // Activar estado de loading
                          setState(() {
                            _isLoading = true;
                          });

                          // Llamar al AuthCubit para hacer login
                          try {
                            final success = await context.read<AuthCubit>().signIn(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );

                            // Si el login fue exitoso, navegar a la página de éxito
                            if (success && mounted) {
                              context.go(AppRoutes.home);
                            }
                          } catch (e) {
                            // El error se manejará en el AuthCubit
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al iniciar sesión: ${e.toString()}'),
                                  backgroundColor: colorScheme.error,
                                ),
                              );
                            }
                          } finally {
                            // Desactivar estado de loading
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
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
                  child: _isLoading
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
                          AppTexts.signInButton,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 36),

              // Texto informativo
              Text(
                AppTexts.informationText,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                AppTexts.website,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 106),

              // Recuperar contraseña
              InkWell(
                onTap: () => launchUrlString(AppTexts.recoverPasswordUrl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppTexts.forgotPasswordQuestion,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppTexts.recoverPassword,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Divider(color: colorScheme.outlineVariant),

              const SizedBox(height: 20),

              // Descargo de responsabilidad
              Text(
                AppTexts.disclaimer,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
