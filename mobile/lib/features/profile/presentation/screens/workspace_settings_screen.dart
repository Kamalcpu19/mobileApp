import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/locale_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/app_scaffold.dart';

class WorkspaceSettingsScreen extends ConsumerWidget {
  const WorkspaceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Workspace Settings',
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
          child: ListView(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            children: [
              Text('Language', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<Locale>(
                      title: const Text('English'),
                      subtitle: const Text('Left-to-right layout'),
                      value: const Locale('en'),
                      groupValue: locale,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(localeProvider.notifier).setLocale(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<Locale>(
                      title: const Text('Arabic'),
                      subtitle: const Text('Right-to-left layout'),
                      value: const Locale('ar'),
                      groupValue: locale,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(localeProvider.notifier).setLocale(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Theme', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System'),
                      subtitle: const Text('Follow device setting'),
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).setThemeMode(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).setThemeMode(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(themeModeProvider.notifier).setThemeMode(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
