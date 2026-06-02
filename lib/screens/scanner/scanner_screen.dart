import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import 'crop_enhance_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _flashOn = false;
  bool _autoCaptureOn = false;
  int _pageCount = 1;
  bool _isBatchMode = false;
  final List<String> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImages.add(image.path);
        if (!_isBatchMode) {
          _navigateToCropEnhance(image.path);
        } else {
          _pageCount++;
        }
      });
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  void _navigateToCropEnhance(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropEnhanceScreen(
          imagePaths: _capturedImages.isNotEmpty ? _capturedImages : [imagePath],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CropEnhanceScreen(imagePaths: images.map((x) => x.path).toList()),
        ),
      );
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    setState(() => _flashOn = !_flashOn);
    await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isInitialized && _controller != null)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          // Edge detection overlay (animated corner brackets)
          if (_isInitialized) _buildEdgeOverlay(),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: _flashOn ? Colors.yellow : Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                    IconButton(
                      icon: Icon(
                        _autoCaptureOn ? Icons.timer_rounded : Icons.timer_off_rounded,
                        color: _autoCaptureOn ? AppColors.primary : Colors.white,
                      ),
                      onPressed: () => setState(() => _autoCaptureOn = !_autoCaptureOn),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page counter
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Page $_pageCount',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ).animate(key: ValueKey(_pageCount)).scale(duration: 200.ms),
          ),

          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _capturedImages.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(_capturedImages.last), fit: BoxFit.cover),
                            )
                          : const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                  // Capture button
                  GestureDetector(
                    onTap: _capture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 4),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 36),
                    ),
                  ),
                  // Batch mode
                  GestureDetector(
                    onTap: () => setState(() => _isBatchMode = !_isBatchMode),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isBatchMode ? AppColors.primary : Colors.transparent,
                        border: Border.all(color: _isBatchMode ? AppColors.primary : Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.burst_mode_rounded, color: Colors.white, size: 20),
                          Text('Batch', style: GoogleFonts.inter(color: Colors.white, fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Batch capture: "Finish" button
          if (_isBatchMode && _capturedImages.isNotEmpty)
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _navigateToCropEnhance(_capturedImages.first),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Finish (${_capturedImages.length} pages)', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEdgeOverlay() {
    return CustomPaint(painter: _EdgeBracketPainter())
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 0.95, end: 1.0, duration: 1500.ms)
        .fadeIn(duration: 600.ms);
  }
}

class _EdgeBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 50.0;
    const bracketLength = 30.0;

    final rect = Rect.fromLTWH(margin, size.height * 0.2, size.width - margin * 2, size.height * 0.55);

    // Top-left
    canvas.drawLine(Offset(rect.left, rect.top + bracketLength), Offset(rect.left, rect.top), paint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + bracketLength, rect.top), paint);

    // Top-right
    canvas.drawLine(Offset(rect.right - bracketLength, rect.top), Offset(rect.right, rect.top), paint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + bracketLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(rect.left, rect.bottom - bracketLength), Offset(rect.left, rect.bottom), paint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + bracketLength, rect.bottom), paint);

    // Bottom-right
    canvas.drawLine(Offset(rect.right - bracketLength, rect.bottom), Offset(rect.right, rect.bottom), paint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - bracketLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
