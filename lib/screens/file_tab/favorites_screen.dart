import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/file_type_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsProvider).where((d) => d.isBookmarked).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GradientAppBar(
            title: 'Favorite Files',
            showBackButton: true,
          ),
          Expanded(
            child: docs.isEmpty
                ? const EmptyState(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'No favorites yet',
                    subtitle: 'Bookmark files to access them here quickly',
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
