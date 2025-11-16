import 'package:flutter/material.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/model/membership_level_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';

class SpecialtyEditDialog extends StatefulWidget {
  final MembershipLevel membership;
  final List<Specialty> specialties;

  const SpecialtyEditDialog({
    super.key,
    required this.membership,
    required this.specialties,
  });

  @override
  State<SpecialtyEditDialog> createState() => _SpecialtyEditDialogState();
}

class _SpecialtyEditDialogState extends State<SpecialtyEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late int _selectedSpecialtyId;

  @override
  void initState() {
    super.initState();
    _selectedSpecialtyId = widget.membership.specialtyId;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedMembership = widget.membership.copyWith(
      specialtyId: _selectedSpecialtyId,
    );

    Navigator.of(context).pop(updatedMembership);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Editar Especialidad',
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

            // Información de la membresía
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: colorScheme.surfaceVariant.withOpacity(0.3),
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(
            //       color: colorScheme.outline.withOpacity(0.2),
            //     ),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         widget.membership.name,
            //         style: theme.textTheme.titleMedium?.copyWith(
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       if (widget.membership.description != null) ...[
            //         const SizedBox(height: 4),
            //         Text(
            //           widget.membership.description!,
            //           style: theme.textTheme.bodySmall?.copyWith(
            //             color: colorScheme.onSurfaceVariant,
            //           ),
            //         ),
            //       ],
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: DropdownMenu<int>(
                initialSelection: _selectedSpecialtyId,
                label: const Text('Especialidad *'),
                helperText:
                    'Seleccione la especialidad asociada a esta membresía',
                dropdownMenuEntries: widget.specialties.map((specialty) {
                  return DropdownMenuEntry<int>(
                    value: specialty.id!,
                    label: specialty.name,
                    leadingIcon: specialty.colorHex != null
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(specialty.colorHex!
                                    .replaceFirst('#', '0xFF')),
                              ),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  );
                }).toList(),
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSpecialtyId = value;
                    });
                  }
                },
              ),
              // child: Text('hola'),
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
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
