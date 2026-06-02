import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final List<_DrawPoint> _points = [];
  Color _selectedColor = const Color(0xFF1A1A2E);
  double _thickness = 4.0;
  final _nameController = TextEditingController();

  final List<Color> _colors = [
    const Color(0xFFEA4335), // Red
    const Color(0xFFFF6B35), // Orange
    const Color(0xFFFFC107), // Yellow
    const Color(0xFF34A853), // Green
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF4285F4), // Blue
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF1A1A2E), // Black
  ];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _points.add(_DrawPoint(
        offset: details.localPosition,
        color: _selectedColor,
        thickness: _thickness,
        isNewStroke: true,
      ));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(_DrawPoint(
        offset: details.localPosition,
        color: _selectedColor,
        thickness: _thickness,
        isNewStroke: false,
      ));
    });
  }

  void _clearCanvas() {
    setState(() => _points.clear());
  }

  Future<void> _saveSignature() async {
    // In production: capture canvas via RepaintBoundary and save as PNG
    if (_points.isEmpty && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw a signature or enter your name')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signature saved!'),
        backgroundColor: AppColors.successGreen,
      ),
    );
    setState(() => _points.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.docBlue,
        foregroundColor: Colors.white,
        title: Text('Signature', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: Colors.white),
            onPressed: _saveSignature,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name input
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Type your name for text signature',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Canvas
          Text('Signatures', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  // Draw area
                  Container(
                    height: 240,
                    color: Colors.white,
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            child: CustomPaint(
                              painter: _SignaturePainter(_points),
                              size: const Size(double.infinity, 240),
                            ),
                          ),
                        ),
                        if (_points.isEmpty)
                          const Center(
                            child: Text(
                              'Draw your signature here',
                              style: TextStyle(color: Color(0xFFB0B3C1), fontSize: 14),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _clearCanvas,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.clear_rounded, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text('Clear', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Color picker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      border: Border(top: BorderSide(color: AppColors.divider)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _colors.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isSelected ? 36 : 30,
                                height: isSelected ? 36 : 30,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(color: Colors.white, width: 2)
                                      : null,
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.line_weight_rounded, size: 16, color: AppColors.textMuted),
                            Expanded(
                              child: Slider(
                                value: _thickness,
                                min: 1,
                                max: 12,
                                activeColor: _selectedColor,
                                thumbColor: AppColors.errorRed,
                                onChanged: (v) => setState(() => _thickness = v),
                              ),
                            ),
                            Text('${_thickness.round()}px', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save Signature',
            icon: Icons.save_rounded,
            onPressed: _saveSignature,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _DrawPoint {
  final Offset offset;
  final Color color;
  final double thickness;
  final bool isNewStroke;

  const _DrawPoint({
    required this.offset,
    required this.color,
    required this.thickness,
    required this.isNewStroke,
  });
}

class _SignaturePainter extends CustomPainter {
  final List<_DrawPoint> points;
  const _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (!points[i + 1].isNewStroke) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeWidth = points[i].thickness
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
