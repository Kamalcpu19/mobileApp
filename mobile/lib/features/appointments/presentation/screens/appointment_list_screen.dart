import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/category_chip_bar.dart';
import '../../../../core/widgets/search_bar_field.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_card.dart';

const _categories = ['All', 'AM', 'PM', 'APP', 'Call In', 'Auto Reminder'];

class AppointmentListScreen extends ConsumerStatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  ConsumerState<AppointmentListScreen> createState() =>
      _AppointmentListScreenState();
}

class _AppointmentListScreenState extends ConsumerState<AppointmentListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(appointmentFilterProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_circle_outlined),
            tooltip: 'Repair Orders',
            onPressed: () => context.push('/repair-orders'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBarField(
              hint: 'Search customer, vehicle, notes...',
              controller: _searchController,
              onChanged: (value) {
                ref.read(appointmentFilterProvider.notifier).state =
                    filter.copyWith(search: value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CategoryChipBar(
              categories: _categories,
              selected: filter.category,
              onSelected: (category) {
                ref.read(appointmentFilterProvider.notifier).state =
                    filter.copyWith(category: category);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: appointmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const Center(child: Text('No appointments found'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(appointmentsProvider),
                  child: ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onTap: () =>
                            context.push('/appointments/${appointment.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-ro'),
        icon: const Icon(Icons.add),
        label: const Text('Create RO'),
      ),
    );
  }
}
