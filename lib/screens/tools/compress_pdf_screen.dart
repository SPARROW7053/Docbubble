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

class CompressPdfScreen extends ConsumerStatefulWidget {
  const CompressPdfScreen({super.key});

  @override
  ConsumerState<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends ConsumerState<CompressPdfScreen> {
  String? _filePath;
  String? _fileName;
  int _fileSize = 0;
  double _quality = 0.6; // medium
  bool _isCompressing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path!;
        _fileName = result.files.single.name;
        _fileSize = result.files.single.size;
      });
    }
  }



  int get _estimatedSize {
    final factor = _quality <= 0.35 ? 0.3 : _quality <= 0.65 ? 0.55 : 0.8;
    return (_fileSize * factor).round();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Future<void> _compress() async {
    if (_filePath == null) return;
    setState(() => _isCompressing = true);
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Document';
    final result = await PdfService.compressPdf(_filePath!, baseName, _quality);
    setState(() => _isCompressing = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) {
        final savings = _fileSize - result.sizeInBytes;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compressed! Saved ${_formatBytes(savings)}'),
            backgroundColor: AppColors.successGreen,
          ),
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
          const GradientAppBar(title: 'Compress PDF', showBackButton: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_filePath == null)
                  AppCard(
                    onTap: _pickFile,
                    child: const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.upload_file_rounded, size: 48, color: AppColors.primary),
                          SizedBox(height: 12),
                          Text('Tap to select PDF'),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // File info
                  AppCard(
                    child: Row(
                      children: [
                        const FileTypeIcon(extension: 'pdf', size: 48, showLabel: false),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('Original: ${_formatBytes(_fileSize)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        TextButton(onPressed: _pickFile, child: const Text('Change')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quality slider
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Compression Quality', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Low', 'Medium', 'High'].map((label) {
                            final isActive = (label == 'Low' && _quality <= 0.35) ||
                                (label == 'Medium' && _quality > 0.35 && _quality <= 0.65) ||
                                (label == 'High' && _quality > 0.65);
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _quality = label == 'Low' ? 0.3 : label == 'Medium' ? 0.6 : 1.0;
                                }),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primary : AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? Colors.white : AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Original size:', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                            Text(_formatBytes(_fileSize), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated output:', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                            Text(
                              _formatBytes(_estimatedSize),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Savings:', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                            Text(
                              '~${(100 - (_estimatedSize / _fileSize * 100)).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isCompressing ? 'Compressing...' : 'Compress PDF',
                    icon: Icons.compress_rounded,
                    onPressed: _isCompressing ? null : _compress,
                    isLoading: _isCompressing,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
