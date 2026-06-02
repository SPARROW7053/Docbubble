import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../models/document_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';
import 'favorites_screen.dart';
import 'folder_screen.dart';

class FileTab extends ConsumerStatefulWidget {
  const FileTab({super.key});

  @override
  ConsumerState<FileTab> createState() => _FileTabState();
}

class _FileTabState extends ConsumerState<FileTab> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(documentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context),
          if (_showSearch) _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(documentsProvider.notifier).refresh();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStorageCard(docs),
                  const SizedBox(height: 20),
                  _buildCategoryGrid(context, docs),
                  const SizedBox(height: 20),
                  _buildRecentFiles(context, docs),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All Documents',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _showSearch = !_showSearch);
                  if (!_showSearch) {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => ref.read(documentsProvider.notifier).refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
                onPressed: () => _showPremiumDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.gradientEnd,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search documents...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
      ),
    );
  }

  Widget _buildStorageCard(List<DocumentModel> docs) {
    const totalGb = 128.0;
    const usedGb = 6.9;
    const percent = usedGb / totalGb;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${usedGb}GB / ${totalGb.toInt()}GB',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available storage',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _storageChip('PDF', AppColors.pdfRed, docs.where((d) => d.extension == 'pdf').length),
                    const SizedBox(width: 8),
                    _storageChip('Images', AppColors.imgPurple, docs.where((d) => ['jpg','jpeg','png'].contains(d.extension)).length),
                    const SizedBox(width: 8),
                    _storageChip('Other', AppColors.txtGrey, docs.where((d) => !['pdf','jpg','jpeg','png'].contains(d.extension)).length),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularPercentIndicator(
            radius: 45,
            lineWidth: 8,
            percent: percent,
            center: Text(
              '${(percent * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.divider,
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _storageChip(String label, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(
            '$label ($count)',
            style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<DocumentModel> docs) {
    final categories = [
      const _CategoryItem('All Files', Icons.folder_open_rounded, AppColors.primary, AppColors.pptOrangeBg, null),
      const _CategoryItem('PDF', Icons.picture_as_pdf_rounded, AppColors.pdfRed, AppColors.pdfRedBg, 'pdf'),
      const _CategoryItem('PPT', Icons.slideshow_rounded, AppColors.pptOrange, AppColors.pptOrangeBg, 'ppt'),
      const _CategoryItem('XLS', Icons.table_chart_rounded, AppColors.xlsGreen, AppColors.xlsGreenBg, 'xls'),
      const _CategoryItem('DOC', Icons.description_rounded, AppColors.docBlue, AppColors.docBlueBg, 'doc'),
      const _CategoryItem('TXT', Icons.text_snippet_rounded, AppColors.txtGrey, AppColors.txtGreyBg, 'txt'),
      const _CategoryItem('Favorite', Icons.star_rounded, AppColors.favoriteYellow, Color(0xFFFFFDE7), 'fav'),
      const _CategoryItem('Folder', Icons.folder_rounded, AppColors.folderBlue, Color(0xFFE3F2FD), 'folder'),
    ];

    return Column(
      children: [
        const SectionHeader(title: 'Categories'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: categories.length,
          itemBuilder: (ctx, i) {
            final cat = categories[i];
            int count = 0;
            if (cat.filter == null) {
              count = docs.length;
            } else if (cat.filter == 'fav') {
              count = docs.where((d) => d.isBookmarked).length;
            } else if (cat.filter == 'folder') {
              count = ref.read(foldersProvider).length;
            } else {
              count = docs.where((d) => d.extension.toLowerCase().startsWith(cat.filter!)).length;
            }

            return GestureDetector(
              onTap: () => _navigateToCategory(context, cat),
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cat.bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.label,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      '($count)',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
            );
          },
        ),
      ],
    );
  }

  void _navigateToCategory(BuildContext context, _CategoryItem cat) {
    if (cat.filter == 'fav') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
    } else if (cat.filter == 'folder') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FolderScreen()));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilteredFilesScreen(
            title: cat.label,
            filter: cat.filter,
          ),
        ),
      );
    }
  }

  Widget _buildRecentFiles(BuildContext context, List<DocumentModel> docs) {
    final recent = docs.take(6).toList();
    return Column(
      children: [
        SectionHeader(
          title: 'Recent Files',
          actionText: 'See All',
          onAction: () {
            ref.read(bottomNavIndexProvider.notifier).state = 1;
          },
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const EmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No documents yet',
            subtitle: 'Tap the camera button to scan your first document',
          )
        else
          ...recent.asMap().entries.map((entry) {
            final doc = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FileListTile(
                doc: doc,
                onTap: () => _openFile(context, doc),
                onBookmarkTap: () => ref.read(documentsProvider.notifier).toggleBookmark(doc.id),
                onLongPress: () => _showFileOptions(context, doc),
              ),
            ).animate(delay: (entry.key * 60).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
          }),
      ],
    );
  }

  void _openFile(BuildContext context, DocumentModel doc) {
    if (doc.extension.toLowerCase() == 'pdf') {
      Navigator.pushNamed(context, '/pdf-viewer', arguments: doc);
    } else {
      Navigator.pushNamed(context, '/file-viewer', arguments: doc);
    }
  }

  void _showFileOptions(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FileOptionsSheet(doc: doc, ref: ref),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text('DocBubble Pro', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Unlock unlimited scans, advanced OCR, and premium tools.\n\nAll features are currently free!',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? filter;

  const _CategoryItem(this.label, this.icon, this.color, this.bgColor, this.filter);
}

class _FileOptionsSheet extends StatelessWidget {
  final DocumentModel doc;
  final WidgetRef ref;

  const _FileOptionsSheet({required this.doc, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doc.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          ...[ 
            _OptionItem(Icons.open_in_new_rounded, 'Open', () {
              Navigator.pop(context);
              if (doc.extension == 'pdf') {
                Navigator.pushNamed(context, '/pdf-viewer', arguments: doc);
              }
            }),
            _OptionItem(Icons.share_rounded, 'Share', () {
              Navigator.pop(context);
              // share_plus integration
            }),
            _OptionItem(Icons.drive_file_rename_outline_rounded, 'Rename', () {
              Navigator.pop(context);
              _showRenameDialog(context);
            }),
            _OptionItem(
              doc.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              doc.isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
              () {
                ref.read(documentsProvider.notifier).toggleBookmark(doc.id);
                Navigator.pop(context);
              },
            ),
            _OptionItem(Icons.delete_outline_rounded, 'Delete', () {
              ref.read(documentsProvider.notifier).delete(doc.id);
              Navigator.pop(context);
            }, color: AppColors.errorRed),
          ].map((o) => ListTile(
            leading: Icon(o.icon, color: o.color ?? AppColors.textPrimary),
            title: Text(o.label, style: GoogleFonts.inter(color: o.color ?? AppColors.textPrimary)),
            onTap: o.onTap,
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: doc.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(documentsProvider.notifier).rename(doc.id, ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Rename', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _OptionItem(this.icon, this.label, this.onTap, {this.color});
}

// Filtered files screen (for category taps)
class FilteredFilesScreen extends ConsumerWidget {
  final String title;
  final String? filter;

  const FilteredFilesScreen({super.key, required this.title, this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDocs = ref.watch(documentsProvider);
    final docs = filter == null
        ? allDocs
        : allDocs.where((d) => d.extension.toLowerCase().startsWith(filter!)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientAppBar(title: title, showBackButton: true),
          Expanded(
            child: docs.isEmpty
                ? const EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'No files found',
                    subtitle: 'This category is empty',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: FileListTile(
                        doc: docs[i],
                        onTap: () {
                          if (docs[i].extension == 'pdf') {
                            Navigator.pushNamed(context, '/pdf-viewer', arguments: docs[i]);
                          }
                        },
                        onBookmarkTap: () =>
                            ref.read(documentsProvider.notifier).toggleBookmark(docs[i].id),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
