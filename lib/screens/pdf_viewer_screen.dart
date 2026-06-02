import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/document_model.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final DocumentModel document;
  const PdfViewerScreen({super.key, required this.document});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final PdfViewerController _viewerController = PdfViewerController();
  bool _showToolbar = true;
  int _totalPages = 0;
  int _currentPage = 1;

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final file = File(doc.path);

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: GestureDetector(
        onTap: () => setState(() => _showToolbar = !_showToolbar),
        child: Stack(
          children: [
            // PDF Viewer
            if (file.existsSync())
              SfPdfViewer.file(
                file,
                controller: _viewerController,
                onPageChanged: (PdfPageChangedDetails details) {
                  setState(() {
                    _currentPage = details.newPageNumber;
                  });
                },
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    _totalPages = details.document.pages.count;
                  });
                },
              )
            else
              _buildFallback(doc),

            // App bar overlay
            AnimatedOpacity(
              opacity: _showToolbar ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          doc.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          doc.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          color: doc.isBookmarked ? Colors.yellow : Colors.white,
                        ),
                        onPressed: () => ref.read(documentsProvider.notifier).toggleBookmark(doc.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.white),
                        onPressed: () => Share.shareXFiles([XFile(doc.path)], text: doc.name),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Page indicator
            if (_showToolbar && _totalPages > 0)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page $_currentPage of $_totalPages',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(DocumentModel doc) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 80, color: AppColors.pdfRed),
            const SizedBox(height: 16),
            Text(doc.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(doc.formattedSize, style: GoogleFonts.inter(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('File not found at path', style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
