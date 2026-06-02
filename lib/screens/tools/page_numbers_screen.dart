import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class PageNumbersScreen extends ConsumerStatefulWidget {
  const PageNumbersScreen({super.key});
  @override
  ConsumerState<PageNumbersScreen> createState() => _PageNumbersScreenState();
}

class _PageNumbersScreenState extends ConsumerState<PageNumbersScreen> {
  String? _filePath, _fileName;
  bool _isAdding = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result?.files.single.path != null) {
      setState(() {
        _filePath = result!.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _addPageNumbers() async {
    if (_filePath == null) return;
    setState(() => _isAdding = true);
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Document';
    final result = await PdfService.addPageNumbers(_filePath!, baseName);
    setState(() => _isAdding = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Page numbers added: ${result.name}'), backgroundColor: AppColors.successGreen),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        const GradientAppBar(title: 'Add Page Numbers', showBackButton: true),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_filePath == null)
            AppCard(
              onTap: _pickFile,
              child: const Padding(
                padding: EdgeInsets.all(32),
                child: Column(children: [
                  Icon(Icons.format_list_numbered_rounded, size: 48, color: AppColors.xlsGreen),
                  SizedBox(height: 12),
                  Text('Tap to select PDF'),
                ]),
              ),
            )
          else ...[
            AppCard(child: Row(children: [
              const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
              const SizedBox(width: 12),
              Expanded(child: Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: _pickFile, child: const Text('Change')),
            ])),
            const SizedBox(height: 16),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Page Number Style', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.looks_one_rounded, color: AppColors.primary),
                title: Text('Page X of Y', style: GoogleFonts.inter()),
                trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ),
              Text('Numbers appear centered at the bottom of each page', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            ])),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isAdding ? 'Adding...' : 'Add Page Numbers',
              icon: Icons.format_list_numbered_rounded,
              onPressed: _isAdding ? null : _addPageNumbers,
              isLoading: _isAdding,
            ),
          ],
          const SizedBox(height: 80),
        ])),
      ]),
    );
  }
}
