import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_providers.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/gradient_app_bar.dart';

class CropEnhanceScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  const CropEnhanceScreen({super.key, required this.imagePaths});

  @override
  ConsumerState<CropEnhanceScreen> createState() => _CropEnhanceScreenState();
}

class _CropEnhanceScreenState extends ConsumerState<CropEnhanceScreen> {
  late List<String> _images;
  final int _currentIndex = 0;
  String _filter = 'Auto'; // Original, Auto, Magic Color, Grayscale, B&W
  double _brightness = 0.5;
  double _contrast = 0.5;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Crop & Enhance', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => _navigateToSave(context),
            child: Text('Continue →', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main image preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColorFiltered(
                  colorFilter: _getColorFilter(),
                  child: Image.file(
                    File(_images[_currentIndex]),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Filter strip
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['Original', 'Auto', 'Magic Color', 'Grayscale', 'B&W'].map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: ColorFiltered(
                                colorFilter: _getColorFilterFor(f),
                                child: Image.file(File(_images[_currentIndex]), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isActive ? AppColors.primary : Colors.white70,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Sliders
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildSlider('Brightness', Icons.brightness_6_rounded, _brightness, (v) => setState(() => _brightness = v)),
                _buildSlider('Contrast', Icons.contrast_rounded, _contrast, (v) => setState(() => _contrast = v)),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Retake', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // In production: navigate back to add more pages
                    },
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                    label: Text('Add Page', style: GoogleFonts.poppins(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, IconData icon, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
        Expanded(
          child: Slider(
            value: value,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  ColorFilter _getColorFilter() => _getColorFilterFor(_filter);

  ColorFilter _getColorFilterFor(String filter) {
    switch (filter) {
      case 'Grayscale':
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'B&W':
        return const ColorFilter.matrix([
          3, -1.5, -1.5, 0, 0,
          -1.5, 3, -1.5, 0, 0,
          -1.5, -1.5, 3, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      default:
        return const ColorFilter.mode(Colors.transparent, BlendMode.overlay);
    }
  }

  void _navigateToSave(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaveScanScreen(imagePaths: _images),
      ),
    );
  }
}

class SaveScanScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  const SaveScanScreen({super.key, required this.imagePaths});

  @override
  ConsumerState<SaveScanScreen> createState() => _SaveScanScreenState();
}

class _SaveScanScreenState extends ConsumerState<SaveScanScreen> {
  late List<String> _images;
  final _nameController = TextEditingController(text: 'Scan_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}');
  String _quality = 'high';
  bool _saveAsPdf = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.imagePaths);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    if (_saveAsPdf) {
      final result = await PdfService.imagesToPdf(_images, _nameController.text.trim());
      if (result != null) {
        ref.read(documentsProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF saved: ${result.name}'), backgroundColor: AppColors.successGreen),
          );
          Navigator.popUntil(context, (r) => r.isFirst);
        }
      }
    } else {
      // Save as images (just add each image to documents)
      for (int i = 0; i < _images.length; i++) {
        ref.read(documentsProvider.notifier);
        // In production: copy images to app folder and register
      }
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientAppBar(
            title: 'Save Scan',
            showBackButton: true,
            actions: [
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isSaving ? 'Saving...' : 'Save', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Page thumbnails
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_images[i]), width: 90, height: 120, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(i)),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                                child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // File name
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('File Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Enter file name')),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Quality
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quality', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['low', 'medium', 'high'].map((q) {
                          final isActive = _quality == q;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _quality = q),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  q.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Save as PDF / Images
                AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _saveAsPdf = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _saveAsPdf ? AppColors.primary : AppColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(children: [
                              Icon(Icons.picture_as_pdf_rounded, color: _saveAsPdf ? Colors.white : AppColors.pdfRed),
                              Text('Save as PDF', style: GoogleFonts.inter(color: _saveAsPdf ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _saveAsPdf = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_saveAsPdf ? AppColors.primary : AppColors.inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(children: [
                              Icon(Icons.image_rounded, color: !_saveAsPdf ? Colors.white : AppColors.imgPurple),
                              Text('Save as Images', style: GoogleFonts.inter(color: !_saveAsPdf ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: _isSaving ? 'Saving...' : 'Save Document',
                  icon: Icons.save_rounded,
                  onPressed: _isSaving ? null : _save,
                  isLoading: _isSaving,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
