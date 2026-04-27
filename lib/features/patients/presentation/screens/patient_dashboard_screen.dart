// =============================================================================
//  features/patients/presentation/screens/patient_dashboard_screen.dart
//
//  Screen 1 — Patient Dashboard.
//  Shows search bar, patient list, and a FAB to add new patients.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/patient_providers.dart';
import '../../data/models/patient_model.dart';
import '../widgets/add_patient_dialog.dart';
import '../../../sessions/presentation/screens/patient_file_screen.dart';
import '../../../sessions/presentation/providers/session_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../core/utils/error_formatter.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() =>
      _PatientDashboardScreenState();
}

class _PatientDashboardScreenState
    extends ConsumerState<PatientDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(patientSearchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(patientSearchQueryProvider.notifier).state = '';
  }

  void _openAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddPatientDialog(),
    );
  }

  void _navigateToPatientFile(BuildContext context, Patient patient) {
    // Set selected patient id before navigating
    ref.read(selectedPatientIdProvider.notifier).state = patient.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientFileScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final patientListAsync = ref.watch(patientListProvider);

    return Scaffold(
      // -----------------------------------------------------------------------
      //  AppBar
      // -----------------------------------------------------------------------
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        title: Row(
          children: [
            Icon(Icons.local_hospital_rounded,
                color: colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            Text(
              'Laser Clinic Manager',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: Center(
              child: Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),

      // -----------------------------------------------------------------------
      //  Body
      // -----------------------------------------------------------------------
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            //  Search bar + patient count row
            // -----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search patients by name or phone number…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Add Patient button (visible on wide screens beside search)
                FilledButton.icon(
                  onPressed: () => _openAddPatientDialog(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Add New Patient'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            //  Section header
            // -----------------------------------------------------------------
            Text(
              'Patients',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // -----------------------------------------------------------------
            //  Patient list
            // -----------------------------------------------------------------
            Expanded(
              child: patientListAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorWidget(message: formatErrorMessage(err)),
                data: (patients) {
                  if (patients.isEmpty) {
                    return _EmptyState(
                      onAddPatient: () => _openAddPatientDialog(context),
                    );
                  }
                  return _PatientDataTable(
                    patients: patients,
                    onRowTap: (p) => _navigateToPatientFile(context, p),
                    onDelete: (p) => ref
                        .read(patientNotifierProvider.notifier)
                        .deletePatient(p.id),
                  );
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
//  Patient Data Table widget
// =============================================================================
class _PatientDataTable extends StatelessWidget {
  const _PatientDataTable({
    required this.patients,
    required this.onRowTap,
    required this.onDelete,
  });

  final List<Patient> patients;
  final void Function(Patient) onRowTap;
  final void Function(Patient) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header
          Container(
            color: colorScheme.primary.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Patient Name',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Phone Number',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Registered On',
                        style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold))),
                const SizedBox(width: 80),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table rows
          Expanded(
            child: ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _PatientRow(
                  patient: patient,
                  onTap: () => onRowTap(patient),
                  onDelete: () => onDelete(patient),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientRow extends StatefulWidget {
  const _PatientRow({
    required this.patient,
    required this.onTap,
    required this.onDelete,
  });

  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_PatientRow> createState() => _PatientRowState();
}

class _PatientRowState extends State<_PatientRow> {
  bool _hovered = false;

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
            ? colorScheme.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    widget.patient.name.isNotEmpty
                        ? widget.patient.name[0].toUpperCase()
                        : '?',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(widget.patient.name,
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(widget.patient.phoneNumber,
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    DateFormat('dd MMM yyyy')
                        .format(widget.patient.createdAt),
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                // Actions
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Tooltip(
                        message: 'View Patient File',
                        child: IconButton(
                          icon: Icon(Icons.folder_open_rounded,
                              color: colorScheme.primary),
                          onPressed: widget.onTap,
                        ),
                      ),
                      Tooltip(
                        message: 'Delete Patient',
                        child: IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: colorScheme.error),
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
        title: const Text('Delete Patient?'),
        content: Text(
            'This will permanently delete "${widget.patient.name}" and all their sessions. This cannot be undone.'),
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
//  Empty state widget
// =============================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPatient});
  final VoidCallback onAddPatient;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 72, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No patients found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Add your first patient to get started.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outlineVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddPatient,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add New Patient'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Error widget
// =============================================================================
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(message,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.error)),
        ],
      ),
    );
  }
}
