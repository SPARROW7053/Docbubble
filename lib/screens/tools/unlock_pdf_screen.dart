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

class UnlockPdfScreen extends ConsumerStatefulWidget {
  const UnlockPdfScreen({super.key});
  @override
  ConsumerState<UnlockPdfScreen> createState() => _UnlockPdfScreenState();
}

class _UnlockPdfScreenState extends ConsumerState<UnlockPdfScreen> {
  String? _filePath, _fileName;
  final _passCtrl = TextEditingController();
  bool _showPass = false, _isUnlocking = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result?.files.single.path != null) {
      setState(() { _filePath = result!.files.single.path; _fileName = result.files.single.name; });
    }
  }

  Future<void> _unlock() async {
    if (_filePath == null) return;
    if (_passCtrl.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the PDF password'))); return; }
    setState(() => _isUnlocking = true);
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Document';
    final result = await PdfService.unlockPdf(_filePath!, baseName, _passCtrl.text);
    setState(() => _isUnlocking = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF unlocked: ${result.name}'), backgroundColor: AppColors.successGreen)); Navigator.pop(context); }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong password or file is not encrypted'), backgroundColor: AppColors.errorRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        const GradientAppBar(title: 'Unlock PDF', showBackButton: true),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_filePath == null) AppCard(onTap: _pickFile, child: const Padding(padding: EdgeInsets.all(32), child: Column(children: [Icon(Icons.lock_open_rounded, size: 48, color: AppColors.xlsGreen), SizedBox(height: 12), Text('Tap to select locked PDF')])))
          else ...[
            AppCard(child: Row(children: [
              const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
              const SizedBox(width: 12),
              Expanded(child: Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: _pickFile, child: const Text('Change')),
            ])),
            const SizedBox(height: 16),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Enter Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, obscureText: !_showPass, decoration: InputDecoration(hintText: 'PDF Password', prefixIcon: const Icon(Icons.lock_open_rounded), suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPass = !_showPass)))),
            ])),
            const SizedBox(height: 24),
            PrimaryButton(label: _isUnlocking ? 'Unlocking...' : 'Unlock PDF', icon: Icons.lock_open_rounded, onPressed: _isUnlocking ? null : _unlock, isLoading: _isUnlocking),
          ],
        ])),
      ]),
    );
  }
}
