import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Profile',
      showBackButton: false,
      body: _buildBody(context, state, isWide),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state, bool isWide) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading profile...');
    }

    if (state.error != null && state.profile == null) {
      return AppErrorWidget(message: state.error!);
    }

    final profile = state.profile!;
    final automation = state.automationSettings;
    final theme = Theme.of(context);
    final maxWidth = isWide ? 640.0 : double.infinity;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text('@${profile.username}'),
                          Text(profile.role.replaceAll('_', ' ')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Workshop', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(profile.workshopName),
                    subtitle: Text(profile.workshopAddress ?? 'Address not set'),
                  ),
                  if (profile.workshopPhone != null)
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(profile.workshopPhone!),
                    ),
                  if (profile.workshopEmail != null)
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(profile.workshopEmail!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Settings', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('Workspace Settings'),
                    subtitle: const Text('Language and theme'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(RoutePaths.workspaceSettings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Automation Settings', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Managed by workshop admin. Contact admin to change these settings.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            if (automation != null)
              Card(
                child: Column(
                  children: [
                    _AutomationTile(
                      title: 'Vehicle Identification',
                      enabled: automation.vehicleIdentificationEnabled,
                    ),
                    const Divider(height: 1),
                    _AutomationTile(
                      title: 'Complaints AI',
                      enabled: automation.complaintsAiEnabled,
                    ),
                    const Divider(height: 1),
                    _AutomationTile(
                      title: 'AI Quote Agent',
                      enabled: automation.aiQuoteAgentEnabled,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AutomationTile extends StatelessWidget {
  const _AutomationTile({required this.title, required this.enabled});

  final String title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel_outlined,
            color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            enabled ? 'Enabled' : 'Disabled',
            style: theme.textTheme.labelLarge?.copyWith(
              color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
