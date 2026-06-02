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

class WatermarkScreen extends ConsumerStatefulWidget {
  const WatermarkScreen({super.key});
  @override
  ConsumerState<WatermarkScreen> createState() => _WatermarkScreenState();
}

class _WatermarkScreenState extends ConsumerState<WatermarkScreen> {
  String? _filePath, _fileName;
  final _textCtrl = TextEditingController(text: 'CONFIDENTIAL');
  bool _isApplying = false;

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

  Future<void> _apply() async {
    if (_filePath == null || _textCtrl.text.isEmpty) return;
    setState(() => _isApplying = true);
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Document';
    final result = await PdfService.addWatermark(_filePath!, baseName, _textCtrl.text);
    setState(() => _isApplying = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Watermark applied!'), backgroundColor: AppColors.successGreen),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Add Watermark', showBackButton: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_filePath == null)
                  AppCard(
                    onTap: _pickFile,
                    child: const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(children: [
                        Icon(Icons.branding_watermark_rounded, size: 48, color: AppColors.imgPurple),
                        SizedBox(height: 12),
                        Text('Tap to select PDF'),
                      ]),
                    ),
                  )
                else ...[
                  AppCard(
                    child: Row(children: [
                      const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _fileName ?? '',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(onPressed: _pickFile, child: const Text('Change')),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Watermark Text', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _textCtrl,
                          decoration: const InputDecoration(hintText: 'e.g. CONFIDENTIAL, DRAFT'),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Transform.rotate(
                              angle: -0.785,
                              child: Text(
                                _textCtrl.text.isEmpty ? 'Preview' : _textCtrl.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isApplying ? 'Applying...' : 'Apply Watermark',
                    icon: Icons.branding_watermark_rounded,
                    onPressed: _isApplying ? null : _apply,
                    isLoading: _isApplying,
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
