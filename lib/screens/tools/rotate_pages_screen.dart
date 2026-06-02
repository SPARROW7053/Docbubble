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

class RotatePagesScreen extends ConsumerStatefulWidget {
  const RotatePagesScreen({super.key});
  @override
  ConsumerState<RotatePagesScreen> createState() => _RotatePagesScreenState();
}

class _RotatePagesScreenState extends ConsumerState<RotatePagesScreen> {
  String? _filePath, _fileName;
  int _pageCount = 0;
  int _degrees = 90;
  final Set<int> _selectedPages = {};
  bool _allPages = true;
  bool _isRotating = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result?.files.single.path != null) {
      setState(() {
        _filePath = result!.files.single.path;
        _fileName = result.files.single.name;
        _pageCount = PdfService.getPageCount(_filePath!) ?? 0;
      });
    }
  }

  Future<void> _rotate() async {
    if (_filePath == null) return;
    setState(() => _isRotating = true);
    final pages = _allPages
        ? List.generate(_pageCount, (i) => i)
        : _selectedPages.toList();
    final baseName = _fileName?.replaceAll('.pdf', '') ?? 'Document';
    final result = await PdfService.rotatePages(_filePath!, baseName, pages, _degrees);
    setState(() => _isRotating = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pages rotated: ${result.name}'), backgroundColor: AppColors.successGreen),
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
        const GradientAppBar(title: 'Rotate Pages', showBackButton: true),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          if (_filePath == null)
            AppCard(
              onTap: _pickFile,
              child: const Padding(
                padding: EdgeInsets.all(32),
                child: Column(children: [
                  Icon(Icons.rotate_90_degrees_ccw_rounded, size: 48, color: AppColors.pptOrange),
                  SizedBox(height: 12),
                  Text('Tap to select PDF'),
                ]),
              ),
            )
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
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rotation Angle', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [90, 180, 270].map((deg) {
                final isSelected = _degrees == deg;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _degrees = deg),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Icon(Icons.rotate_90_degrees_ccw_rounded, color: isSelected ? Colors.white : AppColors.textSecondary),
                      const SizedBox(height: 4),
                      Text('$deg°', style: GoogleFonts.poppins(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ));
              }).toList()),
            ])),
            const SizedBox(height: 12),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SwitchListTile(
                title: Text('Rotate all pages', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                value: _allPages,
                activeThumbColor: AppColors.primary,
                onChanged: (v) => setState(() => _allPages = v),
              ),
              if (!_allPages) ...[
                const SizedBox(height: 8),
                Text('Select pages:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_pageCount, (i) {
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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text('${i + 1}', style: GoogleFonts.poppins(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 11))),
                      ),
                    );
                  }),
                ),
              ],
            ])),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isRotating ? 'Rotating...' : 'Rotate Pages',
              icon: Icons.rotate_90_degrees_ccw_rounded,
              onPressed: _isRotating ? null : _rotate,
              isLoading: _isRotating,
            ),
          ],
          const SizedBox(height: 80),
        ])),
      ]),
    );
  }
}
