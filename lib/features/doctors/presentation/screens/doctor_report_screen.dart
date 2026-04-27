// =============================================================================
//  features/doctors/presentation/screens/doctor_report_screen.dart
//
//  Admin-only screen for generating doctor session reports.
//  Accessible only by admin@laser-clinic.com.
//  Allows selecting a doctor and date range, then shows:
//  - Total number of sessions
//  - Breakdown of each area performed (count)
//  - Total money gained
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../sessions/data/models/session_model.dart';
import '../../../sessions/presentation/providers/session_providers.dart';
import '../providers/doctor_providers.dart';
import '../../../../core/utils/error_formatter.dart';

class DoctorReportScreen extends ConsumerStatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  ConsumerState<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends ConsumerState<DoctorReportScreen> {
  String? _selectedDoctorId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasSearched = false;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _search() {
    if (_selectedDoctorId == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a doctor and both start/end dates.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('End date must be after start date.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _hasSearched = true);

    final effectiveEndDate = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      23,
      59,
      59,
    );

    ref.read(doctorReportParamsProvider.notifier).state = DoctorReportParams(
      doctorId: _selectedDoctorId,
      startDate: _startDate,
      endDate: effectiveEndDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final doctorsAsync = ref.watch(doctorListProvider);
    final reportAsync = ref.watch(doctorReportProvider);

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
            Icon(Icons.analytics_rounded, color: colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'Doctor Session Report',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Controls ──────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search Filters',
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Doctor dropdown
                        Expanded(
                          flex: 3,
                          child: doctorsAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (err, _) => Text(
                              'Failed to load doctors',
                              style: TextStyle(color: colorScheme.error),
                            ),
                            data: (doctors) {
                              return DropdownButtonFormField<String>(
                                initialValue: _selectedDoctorId,
                                decoration: InputDecoration(
                                  labelText: 'Doctor',
                                  prefixIcon:
                                      const Icon(Icons.medical_services_rounded),
                                  filled: true,
                                  fillColor:
                                      colorScheme.surfaceContainerHighest,
                                ),
                                items: doctors.map((doctor) {
                                  return DropdownMenuItem<String>(
                                    value: doctor.id,
                                    child: Text(doctor.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedDoctorId = value);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Start date
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _pickStartDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outline),
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      color: colorScheme.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _startDate != null
                                        ? DateFormat('dd MMM yyyy')
                                            .format(_startDate!)
                                        : 'Start Date',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _startDate != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // End date
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _pickEndDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outline),
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.surfaceContainerHighest,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      color: colorScheme.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _endDate != null
                                        ? DateFormat('dd MMM yyyy')
                                            .format(_endDate!)
                                        : 'End Date',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _endDate != null
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Search button
                        FilledButton.icon(
                          onPressed: _search,
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Search'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Report Results ───────────────────────────────────────────────
            if (!_hasSearched)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.analytics_outlined,
                          size: 72, color: colorScheme.outlineVariant),
                      const SizedBox(height: 16),
                      Text('Select a doctor and date range to generate a report',
                          style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: reportAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: colorScheme.error, size: 48),
                        const SizedBox(height: 12),
                        SelectableText(formatErrorMessage(err),
                            style: TextStyle(color: colorScheme.error)),
                      ],
                    ),
                  ),
                  data: (sessions) {
                    if (sessions == null || sessions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 72, color: colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text('No sessions found for the selected criteria',
                                style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      );
                    }
                    return _ReportResults(sessions: sessions);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Report Results Widget
// =============================================================================
class _ReportResults extends StatelessWidget {
  const _ReportResults({required this.sessions});

  final List<LaserSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Calculate statistics
    final totalSessions = sessions.length;
    final totalMoney = sessions.fold<double>(0, (sum, s) => sum + s.price);
    final totalPulses = sessions.fold<int>(0, (sum, s) => sum + s.pulses);

    // Count each area
    final Map<String, int> areaCounts = {};
    for (final session in sessions) {
      final areas =
          session.laserArea.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      for (final area in areas) {
        areaCounts[area] = (areaCounts[area] ?? 0) + 1;
      }
    }

    // Sort areas by count descending
    final sortedAreas = areaCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Cards ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.event_note_rounded,
                  label: 'Total Sessions',
                  value: '$totalSessions',
                  color: colorScheme.primary,
                  bgColor: colorScheme.primaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Total Revenue',
                  value: NumberFormat.currency(symbol: 'EGP ', decimalDigits: 2)
                      .format(totalMoney),
                  color: colorScheme.tertiary,
                  bgColor: colorScheme.tertiaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.flash_on_rounded,
                  label: 'Total Pulses',
                  value: NumberFormat('#,###').format(totalPulses),
                  color: colorScheme.secondary,
                  bgColor: colorScheme.secondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Area Breakdown ─────────────────────────────────────────────
          Text('Area Breakdown',
              style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Table header
                Container(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Text('Area',
                              style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text('Sessions',
                              style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text('Percentage',
                              style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Area rows
                ...sortedAreas.map((entry) {
                  final percentage =
                      (entry.value / totalSessions * 100).toStringAsFixed(1);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Icon(Icons.my_location_rounded,
                                  size: 16,
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.7)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(entry.key,
                                    style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('${entry.value}',
                              style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: entry.value / totalSessions,
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    color: colorScheme.primary,
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('$percentage%',
                                  style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Session Detail Table ───────────────────────────────────────
          Text('Session Details',
              style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
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
                          child: Text('Area',
                              style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 1,
                          child: Text('Pulses',
                              style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text('Price (EGP)',
                              style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...sessions.map((session) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            DateFormat('dd MMM yyyy')
                                .format(session.sessionDate),
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            session.laserArea,
                            style: textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            session.pulses > 0 ? '${session.pulses}' : '—',
                            style: textTheme.bodyMedium?.copyWith(
                              color: session.pulses > 0
                                  ? colorScheme.tertiary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            NumberFormat.currency(
                                    symbol: 'EGP ', decimalDigits: 2)
                                .format(session.price),
                            style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.tertiary),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Summary Card Widget
// =============================================================================
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(label,
                    style: textTheme.labelLarge?.copyWith(
                        color: color, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
