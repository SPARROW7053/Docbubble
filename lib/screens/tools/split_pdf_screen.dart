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

class SplitPdfScreen extends ConsumerStatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  ConsumerState<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends ConsumerState<SplitPdfScreen> {
  String? _filePath;
  String? _fileName;
  int _pageCount = 0;
  bool _isSplitting = false;
  int _splitMode = 0; // 0=range, 1=every N pages, 2=individual
  final _rangeController = TextEditingController(text: '1-3, 4-6');
  int _everyN = 2;
  final Set<int> _selectedPages = {};

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path!;
        _fileName = result.files.single.name;
        _pageCount = PdfService.getPageCount(_filePath!) ?? 0;
        _selectedPages.clear();
      });
    }
  }

  List<List<int>> _buildRanges() {
    if (_splitMode == 0) {
      // Parse range string: "1-3, 5-7"
      final ranges = _rangeController.text.split(',');
      return ranges.map((r) {
        final parts = r.trim().split('-');
        if (parts.length == 2) {
          final start = int.tryParse(parts[0].trim()) ?? 1;
          final end = int.tryParse(parts[1].trim()) ?? start;
          return List.generate(end - start + 1, (i) => start - 1 + i); // 0-indexed
        }
        final page = int.tryParse(parts[0].trim()) ?? 1;
        return [page - 1];
      }).toList();
    } else if (_splitMode == 1) {
      // Every N pages
      final result = <List<int>>[];
      for (int i = 0; i < _pageCount; i += _everyN) {
        result.add(List.generate(
          (_everyN).clamp(0, _pageCount - i),
          (j) => i + j,
        ));
      }
      return result;
    } else {
      // Individual selected pages — each as its own PDF
      return _selectedPages.map((p) => [p]).toList();
    }
  }

  Future<void> _split() async {
    if (_filePath == null) return;
    setState(() => _isSplitting = true);
    final ranges = _buildRanges();
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Split';
    final results = await PdfService.splitPdf(_filePath!, ranges, baseName);
    setState(() => _isSplitting = false);
    ref.read(documentsProvider.notifier).refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created ${results.length} split PDFs'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Split PDF', showBackButton: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_filePath == null)
                  AppCard(
                    onTap: _pickFile,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.upload_file_rounded, color: AppColors.primary, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text('Tap to select PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        Text('Choose a PDF to split', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
                else ...[
                  AppCard(
                    child: Row(
                      children: [
                        const FileTypeIcon(extension: 'pdf', size: 44, showLabel: false),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fileName ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('$_pageCount pages', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        TextButton(onPressed: _pickFile, child: const Text('Change')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mode selector
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Split Mode', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...[
                          const _ModeOption(0, 'By Range', 'Enter custom page ranges like "1-3, 5-7"'),
                          const _ModeOption(1, 'Every N Pages', 'Split into chunks of N pages'),
                          const _ModeOption(2, 'Individual Pages', 'Select specific pages'),
                        ].map((m) => RadioListTile<int>(
                              value: m.value,
                              // ignore: deprecated_member_use
                              groupValue: _splitMode,
                              title: Text(m.label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              subtitle: Text(m.desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                              activeColor: AppColors.primary,
                              // ignore: deprecated_member_use
                              onChanged: (v) => setState(() => _splitMode = v!),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_splitMode == 0)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Page Ranges', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _rangeController,
                            decoration: const InputDecoration(hintText: 'e.g. 1-3, 5-7'),
                          ),
                        ],
                      ),
                    )
                  else if (_splitMode == 1)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pages per chunk: $_everyN', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          Slider(
                            value: _everyN.toDouble(),
                            min: 1,
                            max: (_pageCount > 0 ? _pageCount / 2 : 10).clamp(2, 20).toDouble(),
                            divisions: 19,
                            activeColor: AppColors.primary,
                            onChanged: (v) => setState(() => _everyN = v.round()),
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Pages (${_selectedPages.length} selected)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_pageCount, (i) {
                              final page = i + 1;
                              final selected = _selectedPages.contains(i);
                              return GestureDetector(
                                onTap: () => setState(() {
                                  if (selected) {
                                    _selectedPages.remove(i);
                                  } else {
                                    _selectedPages.add(i);
                                  }
                                }),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.primary : AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$page',
                                      style: GoogleFonts.poppins(
                                        color: selected ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isSplitting ? 'Splitting...' : 'Split PDF',
                    icon: Icons.call_split_rounded,
                    onPressed: _isSplitting ? null : _split,
                    isLoading: _isSplitting,
                  ),
                  const SizedBox(height: 80),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOption {
  final int value;
  final String label;
  final String desc;
  const _ModeOption(this.value, this.label, this.desc);
}
