import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/document_model.dart';
import '../../providers/app_providers.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';

class RecentScreen extends ConsumerStatefulWidget {
  const RecentScreen({super.key});

  @override
  ConsumerState<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends ConsumerState<RecentScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docs = ref.watch(documentsProvider);
    final filtered = _searchQuery.isEmpty
        ? docs
        : docs.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(context, docs.length),
          _buildSearchBar(),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.access_time_rounded,
                    title: _searchQuery.isNotEmpty ? 'No results' : 'No documents yet',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Scan your first document to get started',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final doc = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: Key(doc.id),
                          background: _swipeBackground(
                            color: AppColors.errorRed,
                            icon: Icons.delete_rounded,
                            alignment: Alignment.centerLeft,
                          ),
                          secondaryBackground: _swipeBackground(
                            color: AppColors.primary,
                            icon: Icons.star_rounded,
                            alignment: Alignment.centerRight,
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              ref.read(documentsProvider.notifier).delete(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${doc.name} moved to trash'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => StorageService.restoreDocument(doc.id),
                                  ),
                                ),
                              );
                            }
                          },
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              ref.read(documentsProvider.notifier).toggleBookmark(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    doc.isBookmarked
                                        ? '${doc.name} removed from favorites'
                                        : '${doc.name} added to favorites',
                                  ),
                                ),
                              );
                              return false; // don't dismiss
                            }
                            return true;
                          },
                          child: FileListTile(
                            doc: doc,
                            onTap: () => _openFile(context, doc),
                            onBookmarkTap: () =>
                                ref.read(documentsProvider.notifier).toggleBookmark(doc.id),
                            onLongPress: () => _showFileOptions(context, doc),
                          ),
                        ).animate(delay: (i * 40).ms).fadeIn(duration: 300.ms),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int count) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Files',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sort_rounded, color: Colors.white),
                    onPressed: () => _showSortOptions(context),
                  ),
                ],
              ),
              Text(
                '$count Files',
                style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search files...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _swipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  void _openFile(BuildContext context, DocumentModel doc) {
    if (doc.extension.toLowerCase() == 'pdf') {
      Navigator.pushNamed(context, '/pdf-viewer', arguments: doc);
    }
  }

  void _showFileOptions(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _buildOptionsSheet(context, doc),
    );
  }

  Widget _buildOptionsSheet(BuildContext context, DocumentModel doc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text(doc.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.open_in_new_rounded),
            title: Text('Open', style: GoogleFonts.inter()),
            onTap: () { Navigator.pop(context); _openFile(context, doc); },
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: Text('Share', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(doc.path)], text: doc.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline_rounded),
            title: Text('Rename', style: GoogleFonts.inter()),
            onTap: () { Navigator.pop(context); _showRenameDialog(context, doc); },
          ),
          ListTile(
            leading: Icon(
              doc.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: AppColors.primary,
            ),
            title: Text(doc.isBookmarked ? 'Remove Favorite' : 'Add to Favorites', style: GoogleFonts.inter()),
            onTap: () {
              ref.read(documentsProvider.notifier).toggleBookmark(doc.id);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
            title: Text('Delete', style: GoogleFonts.inter(color: AppColors.errorRed)),
            onTap: () {
              ref.read(documentsProvider.notifier).delete(doc.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, DocumentModel doc) {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...['Date (newest)', 'Date (oldest)', 'Name A-Z', 'Name Z-A', 'Size'].map(
              (s) => ListTile(
                title: Text(s, style: GoogleFonts.inter()),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
