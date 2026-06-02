import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../tools/merge_pdf_screen.dart';
import '../tools/split_pdf_screen.dart';
import '../tools/compress_pdf_screen.dart';
import '../tools/image_to_pdf_screen.dart';
import '../tools/signature_screen.dart';
import '../tools/lock_pdf_screen.dart';
import '../tools/unlock_pdf_screen.dart';
import '../tools/ocr_screen.dart';
import '../tools/pdf_to_word_screen.dart';
import '../tools/watermark_screen.dart';
import '../tools/page_numbers_screen.dart';
import '../tools/rotate_pages_screen.dart';

class ToolTab extends ConsumerWidget {
  const ToolTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreviewToggle(context, ref, settings.previewPdf),
                const SizedBox(height: 20),
                ..._buildAllSections(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                'Tools',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewToggle(BuildContext context, WidgetRef ref, bool value) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.visibility_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview PDF',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Preview using the icon',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) => ref.read(settingsProvider.notifier).setPreviewPdf(v),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllSections(BuildContext context) {
    final sections = _getToolSections(context);
    return sections.asMap().entries.map((entry) {
      final i = entry.key;
      final section = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (i > 0) const SizedBox(height: 24),
          Text(
            section.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: section.tools.asMap().entries.map((te) {
              final ti = te.key;
              final tool = te.value;
              return ToolIconButton(
                label: tool.label,
                icon: tool.icon,
                gradient: tool.gradient,
                onTap: tool.onTap,
              ).animate(delay: ((i * 4 + ti) * 30).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8));
            }).toList(),
          ),
        ],
      );
    }).toList();
  }

  List<_ToolSection> _getToolSections(BuildContext context) {
    return [
      _ToolSection('Convert', [
        _ToolItem('Image to PDF', Icons.image_rounded, AppColors.toolGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageToPdfScreen()))),
        _ToolItem('Merge PDF', Icons.merge_type_rounded, AppColors.toolBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MergePdfScreen()))),
        _ToolItem('Convert Text', Icons.text_fields_rounded, AppColors.toolOrange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScreen()))),
        _ToolItem('Split PDF', Icons.call_split_rounded, AppColors.toolPurple,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SplitPdfScreen()))),
      ]),
      _ToolSection('Edit', [
        _ToolItem('PDF to Image', Icons.photo_library_rounded, AppColors.toolTeal,
            () => _showComingSoon(context, 'PDF to Image')),
        _ToolItem('Signature', Icons.draw_rounded, AppColors.toolPink,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignatureScreen()))),
        _ToolItem('Lock PDF', Icons.lock_rounded, AppColors.toolBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LockPdfScreen()))),
        _ToolItem('Unlock PDF', Icons.lock_open_rounded, AppColors.toolGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UnlockPdfScreen()))),
      ]),
      _ToolSection('Output', [
        _ToolItem('Print', Icons.print_rounded, AppColors.toolOrange,
            () => _showComingSoon(context, 'Print')),
        _ToolItem('Compress PDF', Icons.compress_rounded, AppColors.toolRed,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompressPdfScreen()))),
        _ToolItem('Watermark', Icons.branding_watermark_rounded, AppColors.toolPurple,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WatermarkScreen()))),
        _ToolItem('Redact', Icons.remove_red_eye_outlined, AppColors.toolDark,
            () => _showComingSoon(context, 'Redact')),
      ]),
      _ToolSection('Annotate', [
        _ToolItem('Highlight', Icons.highlight_rounded, AppColors.toolYellow,
            () => _showComingSoon(context, 'Highlight')),
        _ToolItem('Add Text', Icons.text_increase_rounded, AppColors.toolBlue,
            () => _showComingSoon(context, 'Add Text')),
        _ToolItem('Draw', Icons.brush_rounded, AppColors.toolPink,
            () => _showComingSoon(context, 'Draw')),
        _ToolItem('Page Numbers', Icons.format_list_numbered_rounded, AppColors.toolGreen,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PageNumbersScreen()))),
      ]),
      _ToolSection('Organise', [
        _ToolItem('Reorder Pages', Icons.reorder_rounded, AppColors.toolBlue,
            () => _showComingSoon(context, 'Reorder Pages')),
        _ToolItem('Rotate Pages', Icons.rotate_90_degrees_ccw_rounded, AppColors.toolOrange,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RotatePagesScreen()))),
        _ToolItem('Delete Pages', Icons.delete_sweep_rounded, AppColors.toolRed,
            () => _showComingSoon(context, 'Delete Pages')),
        _ToolItem('Extract Pages', Icons.file_copy_rounded, AppColors.toolTeal,
            () => _showComingSoon(context, 'Extract Pages')),
      ]),
      _ToolSection('Advanced', [
        _ToolItem('OCR Extract', Icons.document_scanner_rounded, AppColors.toolPurple,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OcrScreen()))),
        _ToolItem('PDF to Word', Icons.description_rounded, AppColors.toolBlue,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfToWordScreen()))),
        _ToolItem('Page Resize', Icons.photo_size_select_large_rounded, AppColors.toolOrange,
            () => _showComingSoon(context, 'Page Resize')),
        _ToolItem('Page Size', Icons.aspect_ratio_rounded, AppColors.toolGreen,
            () => _showComingSoon(context, 'Page Size Adjust')),
      ]),
    ];
  }

  void _showComingSoon(BuildContext context, String toolName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.construction_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(toolName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'This feature is coming soon in the next update!',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Got it', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ToolSection {
  final String title;
  final List<_ToolItem> tools;
  const _ToolSection(this.title, this.tools);
}

class _ToolItem {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  const _ToolItem(this.label, this.icon, this.gradient, this.onTap);
}
