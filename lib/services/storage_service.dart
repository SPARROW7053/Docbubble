import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';

class StorageService {
  static const String _documentsBox = 'documents';
  static const String _foldersBox = 'folders';
  static const String _settingsBox = 'settings';

  static Box<DocumentModel>? _documentsBoxInstance;
  static Box<FolderModel>? _foldersBoxInstance;
  static Box<AppSettings>? _settingsBoxInstance;

  static const _uuid = Uuid();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DocumentModelAdapter());
    Hive.registerAdapter(FolderModelAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    _documentsBoxInstance = await Hive.openBox<DocumentModel>(_documentsBox);
    _foldersBoxInstance = await Hive.openBox<FolderModel>(_foldersBox);
    _settingsBoxInstance = await Hive.openBox<AppSettings>(_settingsBox);

    // Initialize default settings
    if (_settingsBoxInstance!.isEmpty) {
      String defaultPath = '/';
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        defaultPath = dir.path;
      }
      await _settingsBoxInstance!.put('settings', AppSettings(
        defaultSaveLocation: defaultPath,
      ));
    }
  }

  // Documents
  static Box<DocumentModel> get documentsBox => _documentsBoxInstance!;
  static Box<FolderModel> get foldersBox => _foldersBoxInstance!;
  static Box<AppSettings> get settingsBox => _settingsBoxInstance!;

  static List<DocumentModel> getAllDocuments({bool includeDeleted = false}) {
    final docs = documentsBox.values.toList();
    if (includeDeleted) return docs;
    return docs.where((d) => !d.isDeleted).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  static List<DocumentModel> getDocumentsByType(String ext) {
    return getAllDocuments().where((d) => d.extension.toLowerCase() == ext.toLowerCase()).toList();
  }

  static List<DocumentModel> getBookmarked() {
    return getAllDocuments().where((d) => d.isBookmarked).toList();
  }

  static List<DocumentModel> getTrash() {
    return documentsBox.values.where((d) => d.isDeleted).toList()
      ..sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
  }

  static Future<DocumentModel> addDocument({
    required String name,
    required String path,
    required String extension,
    int? pageCount,
    String? ocrText,
    String? thumbnailPath,
    String? folderId,
  }) async {
    final file = File(path);
    final size = await file.exists() ? await file.length() : 0;
    final now = DateTime.now();
    final doc = DocumentModel(
      id: _uuid.v4(),
      name: name,
      path: path,
      extension: extension,
      sizeInBytes: size,
      createdAt: now,
      modifiedAt: now,
      pageCount: pageCount,
      ocrText: ocrText,
      thumbnailPath: thumbnailPath,
      folderId: folderId,
    );
    await documentsBox.put(doc.id, doc);
    return doc;
  }

  static Future<void> toggleBookmark(String id) async {
    final doc = documentsBox.get(id);
    if (doc != null) {
      doc.isBookmarked = !doc.isBookmarked;
      await doc.save();
    }
  }

  static Future<void> softDelete(String id) async {
    final doc = documentsBox.get(id);
    if (doc != null) {
      doc.isDeleted = true;
      doc.deletedAt = DateTime.now();
      await doc.save();
    }
  }

  static Future<void> restoreDocument(String id) async {
    final doc = documentsBox.get(id);
    if (doc != null) {
      doc.isDeleted = false;
      doc.deletedAt = null;
      await doc.save();
    }
  }

  static Future<void> permanentDelete(String id) async {
    final doc = documentsBox.get(id);
    if (doc != null) {
      try {
        final file = File(doc.path);
        if (await file.exists()) await file.delete();
        if (doc.thumbnailPath != null) {
          final thumb = File(doc.thumbnailPath!);
          if (await thumb.exists()) await thumb.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
      await doc.delete();
    }
  }

  static Future<void> renameDocument(String id, String newName) async {
    final doc = documentsBox.get(id);
    if (doc != null) {
      final file = File(doc.path);
      if (await file.exists()) {
        final dir = file.parent;
        final newPath = '${dir.path}/$newName.${doc.extension}';
        await file.rename(newPath);
        doc.name = newName;
        doc.path = newPath;
        doc.modifiedAt = DateTime.now();
        await doc.save();
      }
    }
  }

  static Future<void> moveToFolder(String docId, String folderId) async {
    final doc = documentsBox.get(docId);
    final folder = foldersBox.get(folderId);
    if (doc != null && folder != null) {
      doc.folderId = folderId;
      doc.folderName = folder.name;
      doc.modifiedAt = DateTime.now();
      await doc.save();
    }
  }

  // Folders
  static List<FolderModel> getAllFolders() {
    return foldersBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<FolderModel> createFolder(String name) async {
    final folder = FolderModel(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await foldersBox.put(folder.id, folder);
    return folder;
  }

  // Settings
  static AppSettings getSettings() {
    return settingsBox.get('settings') ?? AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await settingsBox.put('settings', settings);
  }

  // Storage stats
  static Future<Map<String, int>> getStorageStats() async {
    int pdfSize = 0, imgSize = 0, otherSize = 0;
    for (final doc in getAllDocuments()) {
      final s = doc.sizeInBytes;
      if (doc.extension == 'pdf') {
        pdfSize += s;
      } else if (['jpg', 'jpeg', 'png', 'webp'].contains(doc.extension.toLowerCase())) {
        imgSize += s;
      } else {
        otherSize += s;
      }
    }
    return {'pdf': pdfSize, 'image': imgSize, 'other': otherSize};
  }

  static Future<void> clearCache() async {
    if (kIsWeb) return;
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  // Auto-purge trash older than 30 days
  static Future<void> purgeOldTrash() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final trash = getTrash();
    for (final doc in trash) {
      if (doc.deletedAt != null && doc.deletedAt!.isBefore(thirtyDaysAgo)) {
        await permanentDelete(doc.id);
      }
    }
  }
}
