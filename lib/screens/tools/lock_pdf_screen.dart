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

class LockPdfScreen extends ConsumerStatefulWidget {
  const LockPdfScreen({super.key});
  @override
  ConsumerState<LockPdfScreen> createState() => _LockPdfScreenState();
}

class _LockPdfScreenState extends ConsumerState<LockPdfScreen> {
  String? _filePath, _fileName;
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPass = false, _isLocking = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result?.files.single.path != null) {
      setState(() { _filePath = result!.files.single.path; _fileName = result.files.single.name; });
    }
  }

  Future<void> _lock() async {
    if (_filePath == null) return;
    if (_passCtrl.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a password'))); return; }
    if (_passCtrl.text != _confirmCtrl.text) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'))); return; }
    setState(() => _isLocking = true);
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Document';
    final result = await PdfService.lockPdf(_filePath!, baseName, _passCtrl.text);
    setState(() => _isLocking = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF locked: ${result.name}'), backgroundColor: AppColors.successGreen)); Navigator.pop(context); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        const GradientAppBar(title: 'Lock PDF', showBackButton: true),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_filePath == null) AppCard(onTap: _pickFile, child: const Padding(padding: EdgeInsets.all(32), child: Column(children: [Icon(Icons.lock_rounded, size: 48, color: AppColors.primary), SizedBox(height: 12), Text('Tap to select PDF')])))
          else ...[
            AppCard(child: Row(children: [
              const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
              const SizedBox(width: 12),
              Expanded(child: Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton(onPressed: _pickFile, child: const Text('Change')),
            ])),
            const SizedBox(height: 16),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Set Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, obscureText: !_showPass, decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_outline_rounded), suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _showPass = !_showPass)))),
              const SizedBox(height: 12),
              TextField(controller: _confirmCtrl, obscureText: !_showPass, decoration: const InputDecoration(hintText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline_rounded))),
            ])),
            const SizedBox(height: 24),
            PrimaryButton(label: _isLocking ? 'Locking...' : 'Lock PDF', icon: Icons.lock_rounded, onPressed: _isLocking ? null : _lock, isLoading: _isLocking),
          ],
        ])),
      ]),
    );
  }
}
