import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../providers/app_providers.dart';
import '../../services/pdf_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({super.key});
  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  String? _filePath, _fileName;
  String? _extractedText;
  bool _isExtracting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result?.files.single.path != null) {
      setState(() {
        _filePath = result!.files.single.path;
        _fileName = result.files.single.name;
        _extractedText = null;
      });
    }
  }

  Future<void> _extract() async {
    if (_filePath == null) return;
    setState(() => _isExtracting = true);
    final text = await Future(() => PdfService.extractText(_filePath!));
    setState(() {
      _extractedText = text ?? 'No text found in this PDF.';
      _isExtracting = false;
    });
  }

  Future<void> _saveAsTxt() async {
    if (_extractedText == null) return;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving files is not supported on web.'), backgroundColor: AppColors.pdfRed),
      );
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final docDir = Directory('${dir.path}/DocBubble');
    if (!docDir.existsSync()) docDir.createSync(recursive: true);
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'extracted';
    final outPath = '${docDir.path}/${baseName}_text.txt';
    File(outPath).writeAsStringSync(_extractedText!);
    await StorageService.addDocument(
      name: '${baseName}_text',
      path: outPath,
      extension: 'txt',
    );
    ref.read(documentsProvider.notifier).refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved as ${baseName}_text.txt'), backgroundColor: AppColors.successGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        const GradientAppBar(title: 'OCR Extract Text', showBackButton: true),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_filePath == null)
            AppCard(onTap: _pickFile, child: const Padding(padding: EdgeInsets.all(32), child: Column(children: [Icon(Icons.document_scanner_rounded, size: 48, color: AppColors.imgPurple), SizedBox(height: 12), Text('Tap to select PDF')])))
          else ...[
            AppCard(child: Row(children: [
              const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
              const SizedBox(width: 12),
              Expanded(child: Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: _pickFile, child: const Text('Change')),
            ])),
            const SizedBox(height: 16),
            PrimaryButton(
              label: _isExtracting ? 'Extracting...' : 'Extract Text',
              icon: Icons.text_snippet_rounded,
              onPressed: _isExtracting ? null : _extract,
              isLoading: _isExtracting,
            ),
            if (_extractedText != null) ...[
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Extracted Text', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                Row(children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy'),
                    onPressed: () {
                      // copy to clipboard
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.save_alt_rounded, size: 16),
                    label: const Text('Save .txt'),
                    onPressed: _saveAsTxt,
                  ),
                ]),
              ]),
              const SizedBox(height: 8),
              AppCard(
                child: SelectableText(
                  _extractedText!,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.6),
                ),
              ).animate().fadeIn(),
            ],
          ],
          const SizedBox(height: 80),
        ])),
      ]),
    );
  }
}
