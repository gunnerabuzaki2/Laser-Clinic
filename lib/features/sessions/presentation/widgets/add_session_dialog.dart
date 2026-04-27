// =============================================================================
//  features/sessions/presentation/widgets/add_session_dialog.dart
//
//  Modal dialog for adding a new laser session.
//  Supports multi-select area chips + a free-text custom area.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/session_providers.dart';

/// Predefined laser treatment areas shown as selectable chips.
const List<String> kLaserAreas = [
  'Face',
  'Full Body',
  'Underarms',
  'Legs',
  'Arms',
  'Back',
  'Chest',
  'Bikini Line',
  'Brazilian',
  'Upper Lip',
  'Chin',
  'Neck',
  'Shoulders',
];

class AddSessionDialog extends ConsumerStatefulWidget {
  const AddSessionDialog({super.key, required this.patientId});

  final String patientId;

  @override
  ConsumerState<AddSessionDialog> createState() => _AddSessionDialogState();
}

class _AddSessionDialogState extends ConsumerState<AddSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _laserPowerController = TextEditingController();
  final _notesController = TextEditingController();
  final _customAreaController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedAreas = {};
  bool _showCustomField = false;
  bool _submitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _laserPowerController.dispose();
    _notesController.dispose();
    _customAreaController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// Returns the final area string to store:
  /// - Predefined selections joined with ", "
  /// - Custom text (if the custom chip is active and text is entered)
  /// - Both combined if applicable
  String get _finalAreaValue {
    final parts = <String>[..._selectedAreas];
    final custom = _customAreaController.text.trim();
    if (_showCustomField && custom.isNotEmpty) parts.add(custom);
    return parts.join(', ');
  }

  bool get _hasAreaSelected =>
      _selectedAreas.isNotEmpty ||
      (_showCustomField && _customAreaController.text.trim().isNotEmpty);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasAreaSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one laser area.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    await ref.read(sessionNotifierProvider.notifier).addSession(
          patientId: widget.patientId,
          sessionDate: _selectedDate,
          laserArea: _finalAreaValue,
          price: double.parse(_priceController.text.trim()),
          laserPower: _laserPowerController.text.trim(),
          notes: _notesController.text.trim(),
        );

    if (!mounted) return;
    final mutationState = ref.read(sessionNotifierProvider);
    setState(() => _submitting = false);

    mutationState.whenOrNull(
      error: (err, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $err'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      data: (_) => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────────
                Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: colorScheme.primary, size: 28),
                    const SizedBox(width: 10),
                    Text('Add New Session',
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Date Picker ───────────────────────────────────────
                        Text('Session Date',
                            style: textTheme.labelLarge
                                ?.copyWith(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outline),
                              borderRadius: BorderRadius.circular(10),
                              color: colorScheme.surface,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    color: colorScheme.primary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy')
                                      .format(_selectedDate),
                                  style: textTheme.bodyLarge,
                                ),
                                const Spacer(),
                                Icon(Icons.edit_rounded,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Laser Area Multi-Select ───────────────────────────
                        Row(
                          children: [
                            Text('Laser Area(s)',
                                style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            Text('(select one or more)',
                                style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Predefined area chips
                            ...kLaserAreas.map((area) {
                              final selected = _selectedAreas.contains(area);
                              return FilterChip(
                                label: Text(area),
                                selected: selected,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      _selectedAreas.add(area);
                                    } else {
                                      _selectedAreas.remove(area);
                                    }
                                  });
                                },
                                selectedColor:
                                    colorScheme.primaryContainer,
                                checkmarkColor: colorScheme.primary,
                              );
                            }),
                            // "Other / Custom" chip
                            FilterChip(
                              label: const Text('Other / Custom'),
                              selected: _showCustomField,
                              avatar: const Icon(Icons.edit_note_rounded,
                                  size: 16),
                              onSelected: (val) {
                                setState(() {
                                  _showCustomField = val;
                                  if (!val) _customAreaController.clear();
                                });
                              },
                              selectedColor: colorScheme.tertiaryContainer,
                              checkmarkColor: colorScheme.tertiary,
                            ),
                          ],
                        ),

                        // Custom area text field (shown only when "Other" selected)
                        if (_showCustomField) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _customAreaController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Custom area description',
                              hintText: 'e.g. Inner thighs, Knees…',
                              prefixIcon:
                                  const Icon(Icons.my_location_rounded),
                              filled: true,
                              fillColor: colorScheme.tertiaryContainer
                                  .withValues(alpha: 0.3),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],

                        // Selection summary
                        if (_hasAreaSelected) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 16, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _finalAreaValue,
                                    style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // ── Price ─────────────────────────────────────────────
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Price (EGP)',
                            hintText: 'e.g. 1500.00',
                            prefixIcon: Icon(Icons.attach_money_rounded),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter the session price.';
                            }
                            final parsed = double.tryParse(v.trim());
                            if (parsed == null || parsed < 0) {
                              return 'Please enter a valid price.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Laser Power ───────────────────────────────────────
                        TextFormField(
                          controller: _laserPowerController,
                          decoration: const InputDecoration(
                            labelText: 'Laser Power (optional)',
                            hintText: 'e.g. 18 J/cm², 20W, 15ms',
                            prefixIcon: Icon(Icons.bolt_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Notes ─────────────────────────────────────────────
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                            hintText:
                                'e.g. Patient reacted well, follow-up in 6 weeks…',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 64),
                              child: Icon(Icons.notes_rounded),
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action buttons ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _submitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(_submitting ? 'Saving…' : 'Save Session'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
