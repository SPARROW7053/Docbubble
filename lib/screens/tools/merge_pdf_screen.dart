import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class MergePdfScreen extends ConsumerStatefulWidget {
  const MergePdfScreen({super.key});

  @override
  ConsumerState<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends ConsumerState<MergePdfScreen> {
  final List<Map<String, dynamic>> _files = [];
  bool _isMerging = false;
  final _nameController = TextEditingController(text: 'Merged_Document');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        for (final file in result.files) {
          if (file.path != null) {
            final pageCount = PdfService.getPageCount(file.path!);
            _files.add({
              'path': file.path!,
              'name': file.name,
              'size': file.size,
              'pages': pageCount ?? 0,
            });
          }
        }
      });
    }
  }

  Future<void> _merge() async {
    if (_files.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 2 PDF files')),
      );
      return;
    }
    setState(() => _isMerging = true);
    final paths = _files.map((f) => f['path'] as String).toList();
    final result = await PdfService.mergePdfs(paths, _nameController.text);
    setState(() => _isMerging = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merged PDF saved: ${result.name}'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merge failed. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientAppBar(
            title: 'Merge PDF',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: _pickFiles,
              ),
            ],
          ),
          Expanded(
            child: _files.isEmpty
                ? EmptyState(
                    icon: Icons.merge_type_rounded,
                    title: 'No PDFs added',
                    subtitle: 'Tap + to add PDF files to merge',
                    actionLabel: 'Add PDF Files',
                    onAction: _pickFiles,
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Output name
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Output Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter output file name',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // File list
                      Text(
                        '${_files.length} files to merge',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _files.length,
                        onReorder: (oldIdx, newIdx) {
                          setState(() {
                            if (newIdx > oldIdx) newIdx--;
                            final item = _files.removeAt(oldIdx);
                            _files.insert(newIdx, item);
                          });
                        },
                        itemBuilder: (_, i) {
                          final file = _files[i];
                          return Container(
                            key: Key(file['path'] as String),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
                              ],
                            ),
                            child: ListTile(
                              leading: const FileTypeIcon(extension: 'pdf', size: 40, showLabel: false),
                              title: Text(
                                file['name'] as String,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${file['pages']} pages · ${_formatSize(file['size'] as int)}',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 20),
                                    onPressed: () => setState(() => _files.removeAt(i)),
                                  ),
                                ],
                              ),
                            ),
                          ).animate(delay: (i * 50).ms).fadeIn();
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _files.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isMerging ? null : _merge,
              backgroundColor: AppColors.primary,
              icon: _isMerging
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.merge_type_rounded, color: Colors.white),
              label: Text(_isMerging ? 'Merging...' : 'Merge PDFs',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
