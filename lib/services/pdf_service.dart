import 'dart:io';
import 'dart:ui' show Offset, Rect;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';
import 'storage_service.dart';

class PdfService {
  static const _uuid = Uuid();

  static Future<Directory> _getDocsDir() async {
    if (kIsWeb) {
      return Directory('DocBubble');
    }
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory('${appDir.path}/DocBubble');
    if (!docsDir.existsSync()) docsDir.createSync(recursive: true);
    return docsDir;
  }

  /// Merge multiple PDFs into one
  static Future<DocumentModel?> mergePdfs(
    List<String> inputPaths,
    String outputName,
  ) async {
    try {
      final mergedDocument = PdfDocument();
      for (final path in inputPaths) {
        final bytes = File(path).readAsBytesSync();
        final doc = PdfDocument(inputBytes: bytes);
        // Copy pages manually
        for (int i = 0; i < doc.pages.count; i++) {
          final srcPage = doc.pages[i];
          final template = srcPage.createTemplate();
          final newPage = mergedDocument.pages.add();
          newPage.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            srcPage.size,
          );
        }
        doc.dispose();
      }
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_${_uuid.v4().substring(0, 8)}.pdf';
      final bytes = await mergedDocument.save();
      File(outPath).writeAsBytesSync(bytes);
      mergedDocument.dispose();
      return StorageService.addDocument(
        name: outputName,
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Merge error: $e');
      return null;
    }
  }

  /// Split PDF by page ranges (0-indexed pages)
  static Future<List<DocumentModel>> splitPdf(
    String inputPath,
    List<List<int>> pageRanges,
    String baseName,
  ) async {
    final results = <DocumentModel>[];
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final dir = await _getDocsDir();
      for (int i = 0; i < pageRanges.length; i++) {
        final source = PdfDocument(inputBytes: bytes);
        final newDoc = PdfDocument();
        for (final pageIndex in pageRanges[i]) {
          if (pageIndex < source.pages.count) {
            final srcPage = source.pages[pageIndex];
            final template = srcPage.createTemplate();
            final newPage = newDoc.pages.add();
            newPage.graphics.drawPdfTemplate(template, const Offset(0, 0), srcPage.size);
          }
        }
        final outPath = '${dir.path}/${baseName}_part${i + 1}_${_uuid.v4().substring(0, 6)}.pdf';
        final outBytes = await newDoc.save();
        File(outPath).writeAsBytesSync(outBytes);
        source.dispose();
        newDoc.dispose();
        final doc = await StorageService.addDocument(
          name: '${baseName}_part${i + 1}',
          path: outPath,
          extension: 'pdf',
        );
        results.add(doc);
      }
    } catch (e) {
      debugPrint('Split error: $e');
    }
    return results;
  }

  /// Compress PDF
  static Future<DocumentModel?> compressPdf(
    String inputPath,
    String outputName,
    double quality,
  ) async {
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      doc.compressionLevel = quality < 0.4
          ? PdfCompressionLevel.best
          : quality < 0.7
              ? PdfCompressionLevel.normal
              : PdfCompressionLevel.none;
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_compressed_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: '${outputName}_compressed',
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Compress error: $e');
      return null;
    }
  }

  /// Lock PDF with password
  static Future<DocumentModel?> lockPdf(
    String inputPath,
    String outputName,
    String password,
  ) async {
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      doc.security.userPassword = password;
      doc.security.ownerPassword = password;
      doc.security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_locked_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: '${outputName}_locked',
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Lock error: $e');
      return null;
    }
  }

  /// Unlock PDF
  static Future<DocumentModel?> unlockPdf(
    String inputPath,
    String outputName,
    String password,
  ) async {
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes, password: password);
      doc.security.userPassword = '';
      doc.security.ownerPassword = '';
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_unlocked_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: '${outputName}_unlocked',
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Unlock error: $e');
      return null;
    }
  }

  /// Add watermark to PDF
  static Future<DocumentModel?> addWatermark(
    String inputPath,
    String outputName,
    String watermarkText,
  ) async {
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      for (int i = 0; i < doc.pages.count; i++) {
        final page = doc.pages[i];
        final graphics = page.graphics;
        graphics.save();
        graphics.setTransparency(0.3);
        final font = PdfStandardFont(PdfFontFamily.helvetica, 48, style: PdfFontStyle.bold);
        final brush = PdfSolidBrush(PdfColor(255, 87, 34));
        graphics.translateTransform(page.size.width / 2, page.size.height / 2);
        graphics.rotateTransform(-45);
        graphics.drawString(
          watermarkText,
          font,
          brush: brush,
          bounds: Rect.fromCenter(center: Offset.zero, width: 400, height: 100),
        );
        graphics.restore();
      }
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_watermarked_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: '${outputName}_watermarked',
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Watermark error: $e');
      return null;
    }
  }

  /// Add page numbers to PDF
  static Future<DocumentModel?> addPageNumbers(
    String inputPath,
    String outputName,
  ) async {
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      final font = PdfStandardFont(PdfFontFamily.helvetica, 10);
      final brush = PdfSolidBrush(PdfColor(100, 100, 100));
      for (int i = 0; i < doc.pages.count; i++) {
        final page = doc.pages[i];
        final text = 'Page ${i + 1} of ${doc.pages.count}';
        page.graphics.drawString(
          text,
          font,
          brush: brush,
          bounds: Rect.fromLTWH(
            page.size.width / 2 - 50,
            page.size.height - 30,
            100,
            20,
          ),
        );
      }
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_numbered_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: '${outputName}_numbered',
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Page numbers error: $e');
      return null;
    }
  }

  /// Get page count
  static int? getPageCount(String pdfPath) {
    try {
      final bytes = File(pdfPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      final count = doc.pages.count;
      doc.dispose();
      return count;
    } catch (e) {
      return null;
    }
  }

  /// Extract text
  static String? extractText(String pdfPath) {
    try {
      final bytes = File(pdfPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(doc);
      final text = extractor.extractText();
      doc.dispose();
      return text;
    } catch (e) {
      debugPrint('Text extraction error: $e');
      return null;
    }
  }

  /// Images to PDF
  static Future<DocumentModel?> imagesToPdf(
    List<String> imagePaths,
    String outputName, {
    String pageSize = 'A4',
  }) async {
    try {
      final doc = PdfDocument();
      final pdfSize = pageSize == 'Letter' ? PdfPageSize.letter : PdfPageSize.a4;
      for (final imgPath in imagePaths) {
        final imgBytes = File(imgPath).readAsBytesSync();
        final image = PdfBitmap(imgBytes);
        final page = doc.pages.add();
        page.graphics.drawImage(
          image,
          Rect.fromLTWH(0, 0, pdfSize.width, pdfSize.height),
        );
      }
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: outputName,
        path: outPath,
        extension: 'pdf',
        pageCount: imagePaths.length,
      );
    } catch (e) {
      debugPrint('Images to PDF error: $e');
      return null;
    }
  }

  /// Rotate pages
  static Future<DocumentModel?> rotatePages(
    String inputPath,
    String outputName,
    List<int> pageIndices,
    int degrees,
  ) async {
    try {
      final bytes = File(inputPath).readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      final rotation = degrees == 90
          ? PdfPageRotateAngle.rotateAngle90
          : degrees == 180
              ? PdfPageRotateAngle.rotateAngle180
              : PdfPageRotateAngle.rotateAngle270;
      for (final idx in pageIndices) {
        if (idx < doc.pages.count) {
          doc.pages[idx].rotation = rotation;
        }
      }
      final dir = await _getDocsDir();
      final outPath = '${dir.path}/${outputName}_rotated_${_uuid.v4().substring(0, 6)}.pdf';
      final outBytes = await doc.save();
      File(outPath).writeAsBytesSync(outBytes);
      doc.dispose();
      return StorageService.addDocument(
        name: '${outputName}_rotated',
        path: outPath,
        extension: 'pdf',
      );
    } catch (e) {
      debugPrint('Rotate error: $e');
      return null;
    }
  }
}
