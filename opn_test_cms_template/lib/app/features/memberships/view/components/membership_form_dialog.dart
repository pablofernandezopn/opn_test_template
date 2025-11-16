import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/model/membership_level_model.dart';

class MembershipFormDialog extends StatefulWidget {
  final MembershipLevel? membership;
  final int specialtyId;

  const MembershipFormDialog({
    super.key,
    this.membership,
    required this.specialtyId,
  });

  @override
  State<MembershipFormDialog> createState() => _MembershipFormDialogState();
}

class _MembershipFormDialogState extends State<MembershipFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceEurController;
  late final TextEditingController _priceUsdController;
  late final TextEditingController _durationDaysController;
  late final TextEditingController _trialDaysController;
  late final TextEditingController _accessLevelController;
  late final TextEditingController _displayOrderController;
  late final TextEditingController _wordpressRcpIdController;
  late final TextEditingController _wordpressLevelNameController;
  late final TextEditingController _revenuecatEntitlementIdController;
  late final TextEditingController _maxContentAccessController;

  late bool _isRecurring;
  late bool _isActive;
  late String _currencyCode;

  bool get _isEditing => widget.membership != null;

  @override
  void initState() {
    super.initState();
    final membership = widget.membership;

    _nameController = TextEditingController(text: membership?.name ?? '');
    _descriptionController =
        TextEditingController(text: membership?.description ?? '');
    _priceEurController =
        TextEditingController(text: membership?.priceEur?.toString() ?? '');
    _priceUsdController =
        TextEditingController(text: membership?.priceUsd?.toString() ?? '');
    _durationDaysController =
        TextEditingController(text: membership?.durationDays?.toString() ?? '');
    _trialDaysController =
        TextEditingController(text: membership?.trialDays.toString() ?? '0');
    _accessLevelController =
        TextEditingController(text: membership?.accessLevel.toString() ?? '1');
    _displayOrderController =
        TextEditingController(text: membership?.displayOrder.toString() ?? '0');
    _wordpressRcpIdController =
        TextEditingController(text: membership?.wordpressRcpId?.toString() ?? '');
    _wordpressLevelNameController =
        TextEditingController(text: membership?.wordpressLevelName ?? '');
    _revenuecatEntitlementIdController =
        TextEditingController(text: membership?.revenuecatEntitlementId ?? '');
    _maxContentAccessController =
        TextEditingController(text: membership?.maxContentAccess?.toString() ?? '');

    _isRecurring = membership?.isRecurring ?? false;
    _isActive = membership?.isActive ?? true;
    _currencyCode = membership?.currencyCode ?? 'EUR';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceEurController.dispose();
    _priceUsdController.dispose();
    _durationDaysController.dispose();
    _trialDaysController.dispose();
    _accessLevelController.dispose();
    _displayOrderController.dispose();
    _wordpressRcpIdController.dispose();
    _wordpressLevelNameController.dispose();
    _revenuecatEntitlementIdController.dispose();
    _maxContentAccessController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final membershipLevel = MembershipLevel(
      id: widget.membership?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priceEur: _priceEurController.text.isEmpty
          ? null
          : double.tryParse(_priceEurController.text),
      priceUsd: _priceUsdController.text.isEmpty
          ? null
          : double.tryParse(_priceUsdController.text),
      durationDays: _durationDaysController.text.isEmpty
          ? null
          : int.tryParse(_durationDaysController.text),
      trialDays: int.tryParse(_trialDaysController.text) ?? 0,
      accessLevel: int.tryParse(_accessLevelController.text) ?? 1,
      displayOrder: int.tryParse(_displayOrderController.text) ?? 0,
      wordpressRcpId: _wordpressRcpIdController.text.isEmpty
          ? null
          : int.tryParse(_wordpressRcpIdController.text),
      wordpressLevelName: _wordpressLevelNameController.text.trim().isEmpty
          ? null
          : _wordpressLevelNameController.text.trim(),
      revenuecatEntitlementId:
          _revenuecatEntitlementIdController.text.trim().isEmpty
              ? null
              : _revenuecatEntitlementIdController.text.trim(),
      maxContentAccess: _maxContentAccessController.text.isEmpty
          ? null
          : int.tryParse(_maxContentAccessController.text),
      isRecurring: _isRecurring,
      isActive: _isActive,
      currencyCode: _currencyCode,
      specialtyId: widget.specialtyId,
      revenuecatProductIds: widget.membership?.revenuecatProductIds ?? [],
      features: widget.membership?.features,
    );

    Navigator.of(context).pop(membershipLevel);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add_circle,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isEditing
                        ? 'Editar Nivel de Membresía'
                        : 'Nuevo Nivel de Membresía',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información Básica
                      _SectionTitle('Información Básica'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          hintText: 'Ej: Premium, Básico, VIP',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es requerido';
                          }
                          if (value.length > 100) {
                            return 'El nombre no puede exceder 100 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText: 'Descripción del nivel de membresía',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Configuración de Acceso
                      _SectionTitle('Configuración de Acceso'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _accessLevelController,
                              decoration: const InputDecoration(
                                labelText: 'Nivel de Acceso *',
                                hintText: '1',
                                border: OutlineInputBorder(),
                                helperText: 'Mayor número = más acceso',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El nivel de acceso es requerido';
                                }
                                final level = int.tryParse(value);
                                if (level == null || level <= 0) {
                                  return 'Debe ser un número mayor a 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _displayOrderController,
                              decoration: const InputDecoration(
                                labelText: 'Orden de Visualización',
                                hintText: '0',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _maxContentAccessController,
                        decoration: const InputDecoration(
                          labelText: 'Máximo de Contenido',
                          hintText: 'Dejar vacío para ilimitado',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),

                      // Precios
                      _SectionTitle('Precios'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceEurController,
                              decoration: const InputDecoration(
                                labelText: 'Precio (EUR)',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixText: '€ ',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final price = double.tryParse(value);
                                  if (price == null || price < 0) {
                                    return 'Precio inválido';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceUsdController,
                              decoration: const InputDecoration(
                                labelText: 'Precio (USD)',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _currencyCode,
                        decoration: const InputDecoration(
                          labelText: 'Moneda Principal',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _currencyCode = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Duración y Recurrencia
                      _SectionTitle('Duración y Recurrencia'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _durationDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Duración (días)',
                          hintText: 'Dejar vacío para ilimitado',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final days = int.tryParse(value);
                            if (days == null || days <= 0) {
                              return 'Debe ser un número positivo';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Membresía Recurrente (Suscripción)'),
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() => _isRecurring = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _trialDaysController,
                        decoration: const InputDecoration(
                          labelText: 'Días de Prueba Gratis',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 16),

                      // Integraciones
                      _SectionTitle('Integraciones'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _wordpressRcpIdController,
                              decoration: const InputDecoration(
                                labelText: 'WordPress RCP ID',
                                hintText: 'ID del nivel en WordPress',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _wordpressLevelNameController,
                              decoration: const InputDecoration(
                                labelText: 'WordPress Level Name',
                                hintText: 'Nombre en WordPress',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _revenuecatEntitlementIdController,
                        decoration: const InputDecoration(
                          labelText: 'RevenueCat Entitlement ID',
                          hintText: 'ID del entitlement en RevenueCat',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estado
                      _SectionTitle('Estado'),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Nivel Activo'),
                        subtitle: const Text(
                            'Los niveles inactivos no estarán disponibles para los usuarios'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() => _isActive = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(_isEditing ? Icons.save : Icons.add),
                  label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Nivel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
