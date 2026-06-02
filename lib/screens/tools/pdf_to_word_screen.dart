import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class PdfToWordScreen extends ConsumerStatefulWidget {
  const PdfToWordScreen({super.key});
  @override
  ConsumerState<PdfToWordScreen> createState() => _PdfToWordScreenState();
}

class _PdfToWordScreenState extends ConsumerState<PdfToWordScreen> {
  String? _filePath, _fileName;
  int _pageCount = 0;
  bool _isConverting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result?.files.single.path != null) {
      setState(() {
        _filePath = result!.files.single.path;
        _fileName = result.files.single.name;
        _pageCount = PdfService.getPageCount(_filePath!) ?? 0;
      });
    }
  }

  Future<void> _convert() async {
    if (_filePath == null) return;
    setState(() => _isConverting = true);
    // Extract text and save as .txt (true .docx requires external conversion)
    final text = PdfService.extractText(_filePath!);
    setState(() => _isConverting = false);
    if (text != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text extracted. Full Word export coming soon!'), backgroundColor: AppColors.warningOrange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        const GradientAppBar(title: 'PDF to Word', showBackButton: true),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_filePath == null)
            AppCard(onTap: _pickFile, child: const Padding(padding: EdgeInsets.all(32), child: Column(children: [Icon(Icons.description_rounded, size: 48, color: AppColors.docBlue), SizedBox(height: 12), Text('Tap to select PDF')])))
          else ...[
            AppCard(child: Row(children: [
              const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('$_pageCount pages', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ])),
              TextButton(onPressed: _pickFile, child: const Text('Change')),
            ])),
            const SizedBox(height: 16),
            AppCard(child: Column(children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.docBlueBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description_rounded, color: AppColors.docBlue)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Output format', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
                  Text('.docx (Word Document)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ]),
              ]),
              const SizedBox(height: 12),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _InfoChip(Icons.auto_stories_rounded, '$_pageCount Pages'),
                const _InfoChip(Icons.text_fields_rounded, 'Text + Layout'),
              ]),
            ])),
            const SizedBox(height: 24),
            PrimaryButton(label: _isConverting ? 'Converting...' : 'Convert to Word', icon: Icons.description_rounded, onPressed: _isConverting ? null : _convert, isLoading: _isConverting),
          ],
          const SizedBox(height: 80),
        ])),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}
