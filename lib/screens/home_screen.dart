import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import 'file_tab/file_tab.dart';
import 'recent_tab/recent_screen.dart';
import 'tool_tab/tool_tab.dart';
import 'settings_tab/settings_tab.dart';
import 'scanner/scanner_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _tabs = [
    FileTab(),
    RecentScreen(),
    ToolTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _tabs,
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'scan_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
              backgroundColor: AppColors.primary,
              elevation: 8,
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
            ).animate().scale(duration: 300.ms)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _DocBubbleNavBar(currentIndex: currentIndex),
    );
  }
}

class _DocBubbleNavBar extends ConsumerWidget {
  final int currentIndex;
  const _DocBubbleNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(index: 0, currentIndex: currentIndex, icon: Icons.folder_rounded, label: 'File'),
              _NavItem(index: 1, currentIndex: currentIndex, icon: Icons.access_time_rounded, label: 'Recent'),
              _NavItem(index: 2, currentIndex: currentIndex, icon: Icons.build_rounded, label: 'Tool'),
              _NavItem(index: 3, currentIndex: currentIndex, icon: Icons.settings_rounded, label: 'Setting'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final String label;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.15 : 1.0,
              child: Icon(
                icon,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
