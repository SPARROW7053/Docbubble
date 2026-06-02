import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_providers.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Settings', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // General
                const _SectionTitle('General'),
                _buildGeneralCard(context, ref, settings),
                const SizedBox(height: 16),

                // Display
                const _SectionTitle('Display'),
                _buildDisplayCard(context, ref, settings),
                const SizedBox(height: 16),

                // Storage
                const _SectionTitle('Storage'),
                _buildStorageCard(context, ref),
                const SizedBox(height: 16),

                // Security
                const _SectionTitle('Security'),
                _buildSecurityCard(context, ref, settings),
                const SizedBox(height: 16),

                // About
                const _SectionTitle('About'),
                _buildAboutCard(context),
                const SizedBox(height: 16),

                // Danger zone
                const _SectionTitle('Danger Zone'),
                _buildDangerCard(context, ref),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralCard(BuildContext context, WidgetRef ref, settings) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        _SettingTile(
          icon: Icons.folder_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: AppColors.pptOrange,
          title: 'Default Save Location',
          subtitle: settings.defaultSaveLocation.isEmpty ? 'App documents folder' : settings.defaultSaveLocation,
          onTap: () {},
        ),
        _divider(),
        _SettingTile(
          icon: Icons.language_rounded,
          iconBg: const Color(0xFFE8F0FE),
          iconColor: AppColors.docBlue,
          title: 'App Language',
          subtitle: settings.language,
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          onTap: () => _showLanguagePicker(context, ref, settings.language),
        ),
        _divider(),
        _SettingTile(
          icon: Icons.high_quality_rounded,
          iconBg: const Color(0xFFE6F4EA),
          iconColor: AppColors.xlsGreen,
          title: 'Default Scan Quality',
          subtitle: settings.scanQuality.toUpperCase(),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          onTap: () => _showQualityPicker(context, ref, settings.scanQuality),
        ),
      ]),
    );
  }

  Widget _buildDisplayCard(BuildContext context, WidgetRef ref, settings) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        _SettingTile(
          icon: Icons.visibility_rounded,
          iconBg: const Color(0xFFEDE7F6),
          iconColor: AppColors.imgPurple,
          title: 'Preview PDF',
          subtitle: 'Show thumbnail previews',
          trailing: Switch(
            value: settings.previewPdf,
            onChanged: (v) => ref.read(settingsProvider.notifier).setPreviewPdf(v),
            activeThumbColor: AppColors.primary,
          ),
        ),
        _divider(),
        _SettingTile(
          icon: Icons.grid_view_rounded,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: AppColors.pptOrange,
          title: 'Default View',
          subtitle: settings.isGridView ? 'Grid view' : 'List view',
          trailing: Switch(
            value: settings.isGridView,
            onChanged: (v) => ref.read(settingsProvider.notifier).setGridView(v),
            activeThumbColor: AppColors.primary,
          ),
        ),
      ]),
    );
  }

  Widget _buildStorageCard(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Storage Usage', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, int>>(
            future: StorageService.getStorageStats(),
            builder: (context, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final stats = snap.data!;
              return Column(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(children: [
                    Flexible(flex: stats['pdf']! + 1, child: Container(height: 14, color: AppColors.pdfRed)),
                    Flexible(flex: stats['image']! + 1, child: Container(height: 14, color: AppColors.imgPurple)),
                    Flexible(flex: stats['other']! + 1, child: Container(height: 14, color: AppColors.txtGrey)),
                  ]),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _StorageLegend('PDF', AppColors.pdfRed, _formatBytes(stats['pdf']!)),
                  _StorageLegend('Images', AppColors.imgPurple, _formatBytes(stats['image']!)),
                  _StorageLegend('Other', AppColors.txtGrey, _formatBytes(stats['other']!)),
                ]),
              ]);
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await StorageService.clearCache();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
            label: Text('Clear Cache', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, WidgetRef ref, settings) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        _SettingTile(
          icon: Icons.lock_rounded,
          iconBg: const Color(0xFFE8F0FE),
          iconColor: AppColors.docBlue,
          title: 'App Lock',
          subtitle: settings.appLock ? 'Enabled' : 'Disabled',
          trailing: Switch(
            value: settings.appLock,
            onChanged: (v) => ref.read(settingsProvider.notifier).setAppLock(v),
            activeThumbColor: AppColors.primary,
          ),
        ),
        if (settings.appLock) ...[
          _divider(),
          _SettingTile(
            icon: Icons.fingerprint_rounded,
            iconBg: const Color(0xFFE6F4EA),
            iconColor: AppColors.xlsGreen,
            title: 'Lock Type',
            subtitle: settings.lockType == 'biometric' ? 'Biometric' : 'PIN',
            trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            onTap: () => _showLockTypePicker(context, ref, settings.lockType),
          ),
        ],
      ]),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        const _SettingTile(
          icon: Icons.info_outline_rounded,
          iconBg: Color(0xFFFFF3E0),
          iconColor: AppColors.pptOrange,
          title: 'App Version',
          subtitle: '1.0.0 (Build 1)',
        ),
        _divider(),
        _SettingTile(
          icon: Icons.bubble_chart_rounded,
          iconBg: const Color(0xFFFFEBEA),
          iconColor: AppColors.pdfRed,
          title: 'About Bubblesort',
          subtitle: 'Innovative apps for everyone',
          onTap: () {},
        ),
        _divider(),
        _SettingTile(
          icon: Icons.privacy_tip_rounded,
          iconBg: const Color(0xFFE8F0FE),
          iconColor: AppColors.docBlue,
          title: 'Privacy Policy',
          trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textMuted),
          onTap: () => launchUrl(Uri.parse('https://bubblesort.app/privacy')),
        ),
        _divider(),
        _SettingTile(
          icon: Icons.description_outlined,
          iconBg: const Color(0xFFE6F4EA),
          iconColor: AppColors.xlsGreen,
          title: 'Terms of Service',
          trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textMuted),
          onTap: () => launchUrl(Uri.parse('https://bubblesort.app/terms')),
        ),
        _divider(),
        _SettingTile(
          icon: Icons.star_rounded,
          iconBg: const Color(0xFFFFFDE7),
          iconColor: AppColors.favoriteYellow,
          title: 'Rate App',
          subtitle: 'Rate us on Play Store',
          trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textMuted),
          onTap: () => launchUrl(Uri.parse('https://play.google.com/store')),
        ),
      ]),
    );
  }

  Widget _buildDangerCard(BuildContext context, WidgetRef ref) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Danger Zone', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showClearAllDialog(context, ref),
              icon: const Icon(Icons.delete_forever_rounded, color: AppColors.errorRed),
              label: Text('Clear All Files', style: GoogleFonts.poppins(color: AppColors.errorRed, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This will permanently delete all documents. This action cannot be undone.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 60, color: AppColors.divider);

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Select Language', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...['English', 'Hindi', 'Spanish', 'French', 'German', 'Arabic'].map((lang) => ListTile(
            title: Text(lang, style: GoogleFonts.inter()),
            trailing: current == lang ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { ref.read(settingsProvider.notifier).setLanguage(lang); Navigator.pop(context); },
          )),
        ]),
      ),
    );
  }

  void _showQualityPicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Scan Quality', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...['low', 'medium', 'high'].map((q) => ListTile(
            title: Text(q.toUpperCase(), style: GoogleFonts.inter()),
            trailing: current == q ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { ref.read(settingsProvider.notifier).setScanQuality(q); Navigator.pop(context); },
          )),
        ]),
      ),
    );
  }

  void _showLockTypePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Lock Type', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...['pin', 'biometric'].map((type) => ListTile(
            title: Text(type == 'pin' ? 'PIN Lock' : 'Biometric', style: GoogleFonts.inter()),
            trailing: current == type ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
            onTap: () { ref.read(settingsProvider.notifier).setLockType(type); Navigator.pop(context); },
          )),
        ]),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.warning_rounded, color: AppColors.errorRed),
          const SizedBox(width: 8),
          Text('Clear All Files', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
        ]),
        content: Text('This will permanently delete all your documents. This action cannot be undone.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              for (final doc in StorageService.getAllDocuments()) {
                StorageService.permanentDelete(doc.id);
              }
              ref.read(documentsProvider.notifier).refresh();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All files deleted'), backgroundColor: AppColors.errorRed));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: Text('Delete All', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)) : null,
      trailing: trailing,
    );
  }
}

class _StorageLegend extends StatelessWidget {
  final String label;
  final Color color;
  final String size;
  const _StorageLegend(this.label, this.color, this.size);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text('$label\n$size', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
    ]);
  }
}
