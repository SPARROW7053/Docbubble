import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/document_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider);
    final allDocs = ref.watch(documentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(title: 'Folders', showBackButton: true),
          Expanded(
            child: folders.isEmpty
                ? EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'No folders',
                    subtitle: 'Create folders to organise your documents',
                    actionLabel: 'Create Folder',
                    onAction: () => _showCreateFolderDialog(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: folders.length,
                    itemBuilder: (_, i) {
                      final folder = folders[i];
                      final count = allDocs.where((d) => d.folderId == folder.id).length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FolderDetailScreen(folder: folder),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.folder_rounded, color: AppColors.folderBlue, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      folder.name,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '$count files',
                                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateFolderDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.create_new_folder_rounded, color: Colors.white),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Folder name',
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
                ref.read(foldersProvider.notifier).createFolder(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Create', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class FolderDetailScreen extends ConsumerWidget {
  final FolderModel folder;
  const FolderDetailScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsProvider).where((d) => d.folderId == folder.id).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GradientAppBar(title: folder.name, showBackButton: true),
          Expanded(
            child: docs.isEmpty
                ? const EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'Folder is empty',
                    subtitle: 'Move files into this folder from the file list',
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
