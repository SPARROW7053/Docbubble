import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_providers.dart';
import '../../services/pdf_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/gradient_app_bar.dart';

class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  final List<String> _imagePaths = [];
  String _pageSize = 'A4';
  bool _isConverting = false;
  final _nameController = TextEditingController(text: 'Images_to_PDF');

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _imagePaths.addAll(images.map((x) => x.path)));
    }
  }

  Future<void> _convert() async {
    if (_imagePaths.isEmpty) return;
    setState(() => _isConverting = true);
    final result = await PdfService.imagesToPdf(
      _imagePaths,
      _nameController.text,
      pageSize: _pageSize,
    );
    setState(() => _isConverting = false);
    if (result != null) {
      ref.read(documentsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF created: ${result.name}'), backgroundColor: AppColors.successGreen),
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
          GradientAppBar(
            title: 'Image to PDF',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
                onPressed: _pickImages,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_imagePaths.isEmpty)
                  AppCard(
                    onTap: _pickImages,
                    child: const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primary),
                          SizedBox(height: 12),
                          Text('Tap to add images'),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Name
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Output Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'File name')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Page size
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Page Size', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['A4', 'Letter', 'Fit to Image'].map((size) {
                            final isActive = _pageSize == size;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _pageSize = size),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primary : AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    size,
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
                  const SizedBox(height: 16),
                  // Image grid
                  Text('${_imagePaths.length} images', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imagePaths.length,
                    itemBuilder: (_, i) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(File(_imagePaths[i]), fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _imagePaths.removeAt(i)),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.errorRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _isConverting ? 'Converting...' : 'Convert to PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    onPressed: _isConverting ? null : _convert,
                    isLoading: _isConverting,
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
