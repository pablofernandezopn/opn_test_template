import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/go_route/app_routes.dart';
import '../auth/cubit/auth_cubit.dart';
import '../auth/cubit/auth_state.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage._();

  static Widget create() => const SuccessPage._();

  static const String route = '/success';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Cuando el estado cambia a unauthenticated, navegar a signin
          if (state.status == AuthStatus.unauthenticated) {
            context.go(AppRoutes.signin);
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state.user;

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de éxito
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Título
                      Text(
                        '¡Bienvenido!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Has iniciado sesión correctamente',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.green[700],
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Card con datos del usuario
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tus datos',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                            ),
                            const SizedBox(height: 20),

                            // ID
                            _buildInfoRow(
                              context,
                              icon: Icons.badge_outlined,
                              label: 'ID',
                              value: user.id.toString(),
                            ),

                            const SizedBox(height: 16),

                            // Username
                            _buildInfoRow(
                              context,
                              icon: Icons.person_outline,
                              label: 'Usuario',
                              value: user.username,
                            ),

                            const SizedBox(height: 16),

                            // Email
                            _buildInfoRow(
                              context,
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email ?? 'No disponible',
                            ),

                            const SizedBox(height: 16),

                            // Nombre completo
                            if (user.fullName != null || user.role != null)
                              _buildInfoRow(
                                context,
                                icon: Icons.account_circle_outlined,
                                label: 'Nombre',
                                value: '${user.roleName ?? ''} ${user.role ?? ''}'.trim(),
                              ),



                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Botón de Logout
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await context.read<AuthCubit>().logout();
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Cerrar Sesión'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Texto informativo
                      Text(
                        'Fecha de registro: ${_formatDate(user.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.green[700],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.grey[800],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return '${date.day}/${date.month}/${date.year}';
  }
}
