// =============================================================================
//  features/sessions/presentation/widgets/session_detail_dialog.dart
//
//  Read-only dialog showing full details of a single LaserSession,
//  including the complete multi-line notes field.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/session_model.dart';

class SessionDetailDialog extends StatelessWidget {
  const SessionDetailDialog({super.key, required this.session});

  final LaserSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded,
                      color: colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text('Session Details',
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const Divider(height: 28),

              // ── Date ────────────────────────────────────────────────────────
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                value: DateFormat('EEEE, d MMMM yyyy')
                    .format(session.sessionDate),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),

              // ── Doctor ──────────────────────────────────────────────────────
              _DetailRow(
                icon: Icons.medical_services_rounded,
                label: 'Doctor',
                value: session.doctorName ?? 'Not assigned',
                valueColor: session.doctorName != null
                    ? colorScheme.onSurface
                    : colorScheme.outline,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),

              // ── Laser Area(s) ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.my_location_rounded,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Laser Area(s)',
                            style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        // Split comma-separated areas into individual chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: session.laserArea
                              .split(',')
                              .map((a) => a.trim())
                              .where((a) => a.isNotEmpty)
                              .map((area) => Chip(
                                    label: Text(area),
                                    backgroundColor:
                                        colorScheme.primaryContainer,
                                    labelStyle: textTheme.labelMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Pulses ──────────────────────────────────────────────────────
              _DetailRow(
                icon: Icons.flash_on_rounded,
                label: 'Session Pulses',
                value: session.pulses > 0
                    ? '${session.pulses}'
                    : 'Not recorded',
                valueColor: session.pulses > 0
                    ? colorScheme.tertiary
                    : colorScheme.outline,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),

              // ── Laser Power ──────────────────────────────────────────
              _DetailRow(
                icon: Icons.bolt_rounded,
                label: 'Laser Power',
                value: session.laserPower.isEmpty
                    ? 'Not recorded'
                    : session.laserPower,
                valueColor: session.laserPower.isEmpty
                    ? colorScheme.outline
                    : colorScheme.secondary,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),

              // ── Price ────────────────────────────────────────────────────────
              _DetailRow(
                icon: Icons.attach_money_rounded,
                label: 'Price',
                value: NumberFormat.currency(symbol: 'EGP ', decimalDigits: 2)
                    .format(session.price),
                valueColor: colorScheme.tertiary,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 16),

              // ── Notes ────────────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notes',
                            style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SelectableText(
                            session.notes.isEmpty
                                ? 'No notes recorded for this session.'
                                : session.notes,
                            style: textTheme.bodyMedium?.copyWith(
                              color: session.notes.isEmpty
                                  ? colorScheme.outline
                                  : colorScheme.onSurface,
                              fontStyle: session.notes.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Close button ─────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// Simple label + value row
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? colorScheme.onSurface,
                )),
          ],
        ),
      ],
    );
  }
}
