import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_model.dart';
import '../theme/app_colors.dart';

class FileTypeIcon extends StatelessWidget {
  final String extension;
  final double size;
  final double borderRadius;
  final bool showLabel;

  const FileTypeIcon({
    super.key,
    required this.extension,
    this.size = 40,
    this.borderRadius = 12,
    this.showLabel = true,
  });

  static Color getBgColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return AppColors.pdfRedBg;
      case 'xls':
      case 'xlsx':
        return AppColors.xlsGreenBg;
      case 'doc':
      case 'docx':
        return AppColors.docBlueBg;
      case 'ppt':
      case 'pptx':
        return AppColors.pptOrangeBg;
      case 'txt':
        return AppColors.txtGreyBg;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return AppColors.imgPurpleBg;
      default:
        return AppColors.txtGreyBg;
    }
  }

  static Color getIconColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return AppColors.pdfRed;
      case 'xls':
      case 'xlsx':
        return AppColors.xlsGreen;
      case 'doc':
      case 'docx':
        return AppColors.docBlue;
      case 'ppt':
      case 'pptx':
        return AppColors.pptOrange;
      case 'txt':
        return AppColors.txtGrey;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return AppColors.imgPurple;
      default:
        return AppColors.txtGrey;
    }
  }

  static IconData getIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'gif':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = getBgColor(extension);
    final iconColor = getIconColor(extension);
    final icon = getIcon(extension);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: size * 0.5),
          if (showLabel && size >= 36)
            Text(
              extension.toUpperCase().substring(0, extension.length > 3 ? 3 : extension.length),
              style: GoogleFonts.poppins(
                fontSize: size * 0.16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// File row widget used in lists
class FileListTile extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onLongPress;

  const FileListTile({
    super.key,
    required this.doc,
    this.onTap,
    this.onBookmarkTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            FileTypeIcon(extension: doc.extension, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDate(doc.modifiedAt)} · ${doc.formattedSize}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onBookmarkTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  doc.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: doc.isBookmarked ? AppColors.primary : AppColors.textMuted,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
