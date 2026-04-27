// =============================================================================
//  features/sessions/presentation/screens/patient_file_screen.dart
//
//  Screen 2 — Patient File & Session History.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../features/patients/data/models/patient_model.dart';
import '../providers/session_providers.dart';
import '../../data/models/session_model.dart';
import '../widgets/add_session_dialog.dart';
import '../widgets/session_detail_dialog.dart';

class PatientFileScreen extends ConsumerWidget {
  const PatientFileScreen({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sessionListAsync = ref.watch(sessionListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Dashboard',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(patient.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(patient.phoneNumber,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          sessionListAsync.when(
            data: (sessions) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(Icons.history_rounded,
                    size: 18, color: colorScheme.onSecondaryContainer),
                label: Text('${sessions.length} session(s)'),
                backgroundColor: colorScheme.secondaryContainer,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          sessionListAsync.when(
            data: (sessions) {
              final total =
                  sessions.fold<double>(0, (sum, s) => sum + s.price);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  avatar: Icon(Icons.attach_money_rounded,
                      size: 18, color: colorScheme.onTertiaryContainer),
                  label: Text(
                      NumberFormat.currency(symbol: 'EGP ').format(total)),
                  backgroundColor: colorScheme.tertiaryContainer,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text('Session History',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _openAddSessionDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Session'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sessionListAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          color: colorScheme.error, size: 48),
                      const SizedBox(height: 12),
                      SelectableText('Error: $err',
                          style: TextStyle(color: colorScheme.error)),
                    ],
                  ),
                ),
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return _EmptySessionState(
                        onAddSession: () =>
                            _openAddSessionDialog(context, ref));
                  }
                  return _SessionDataTable(
                    sessions: sessions,
                    onDelete: (s) => ref
                        .read(sessionNotifierProvider.notifier)
                        .deleteSession(s.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddSessionDialog(patientId: patient.id),
    );
  }
}

// =============================================================================
//  Session Data Table
// =============================================================================
class _SessionDataTable extends StatelessWidget {
  const _SessionDataTable({required this.sessions, required this.onDelete});

  final List<LaserSession> sessions;
  final void Function(LaserSession) onDelete;

  /// Returns the 1-based session number for [current] among sessions
  /// that share the same laserArea, sorted chronologically.
  int _sessionNumber(LaserSession current) {
    final sameArea = sessions
        .where((s) => s.laserArea == current.laserArea)
        .toList()
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
    return sameArea.indexWhere((s) => s.id == current.id) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Table header ──────────────────────────────────────────────────
          Container(
            color: colorScheme.primary.withValues(alpha: 0.12),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Laser Area',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Power',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Price (EGP)',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text('Notes',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                const SizedBox(width: 96),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Data rows ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _SessionRow(
                  session: session,
                  sessionNumber: _sessionNumber(session),
                  onDelete: () => onDelete(session),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Session Row
// =============================================================================
class _SessionRow extends StatefulWidget {
  const _SessionRow({
    required this.session,
    required this.sessionNumber,
    required this.onDelete,
  });

  final LaserSession session;
  final int sessionNumber;
  final VoidCallback onDelete;

  @override
  State<_SessionRow> createState() => _SessionRowState();
}

class _SessionRowState extends State<_SessionRow> {
  bool _hovered = false;

  void _openDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SessionDetailDialog(session: widget.session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered
            ? colorScheme.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // ── Date ───────────────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 14,
                          color: colorScheme.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(widget.session.sessionDate),
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // ── Laser Area + session number in parentheses ─────────────
                Expanded(
                  flex: 3,
                  child: _AreaBadge(
                    area: widget.session.laserArea,
                    sessionNumber: widget.sessionNumber,
                  ),
                ),

                // ── Laser Power ─────────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: widget.session.laserPower.isEmpty
                      ? Text('—',
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outlineVariant))
                      : Row(
                          children: [
                            Icon(Icons.bolt_rounded,
                                size: 14, color: colorScheme.secondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.session.laserPower,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.secondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),

                // ── Price ───────────────────────────────────────────────────
                Expanded(
                  flex: 2,
                  child: Text(
                    NumberFormat.currency(symbol: 'EGP ', decimalDigits: 2)
                        .format(widget.session.price),
                    style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.tertiary),
                  ),
                ),

                // ── Notes (truncated) ───────────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.session.notes.isEmpty ? '—' : widget.session.notes,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ── Actions ─────────────────────────────────────────────────
                SizedBox(
                  width: 96,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'View Details',
                        child: IconButton(
                          icon: Icon(Icons.visibility_rounded,
                              color: colorScheme.primary, size: 20),
                          onPressed: () => _openDetail(context),
                        ),
                      ),
                      Tooltip(
                        message: 'Delete Session',
                        child: IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: colorScheme.error, size: 20),
                          onPressed: () => _confirmDelete(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Session?'),
        content: const Text(
            'This session record will be permanently deleted. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Area Badge — shows area name + session number in parentheses
// =============================================================================
class _AreaBadge extends StatelessWidget {
  const _AreaBadge({required this.area, required this.sessionNumber});

  final String area;
  final int sessionNumber;

  Color _colorForArea(ColorScheme cs) {
    // Use the first area in a multi-area string to pick a color
    final primary = area.split(',').first.trim().toLowerCase();
    switch (primary) {
      case 'face':
        return cs.primaryContainer;
      case 'full body':
        return cs.secondaryContainer;
      case 'underarms':
        return cs.tertiaryContainer;
      case 'legs':
        return cs.errorContainer;
      default:
        return cs.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Truncate long multi-area strings for display in the badge
    final displayArea = area.length > 24 ? '${area.substring(0, 22)}…' : area;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _colorForArea(cs),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              displayArea,
              style: textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($sessionNumber)',
            style: textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Empty state
// =============================================================================
class _EmptySessionState extends StatelessWidget {
  const _EmptySessionState({required this.onAddSession});
  final VoidCallback onAddSession;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note_rounded,
              size: 72, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No sessions recorded yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Record the first session for this patient.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outlineVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddSession,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Session'),
          ),
        ],
      ),
    );
  }
}
