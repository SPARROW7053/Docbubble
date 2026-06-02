import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../services/storage_service.dart';

// ─── Documents ───────────────────────────────────────────────────────────────

class DocumentsNotifier extends StateNotifier<List<DocumentModel>> {
  DocumentsNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getAllDocuments();
  }

  void refresh() => _load();

  Future<void> toggleBookmark(String id) async {
    await StorageService.toggleBookmark(id);
    _load();
  }

  Future<void> delete(String id) async {
    await StorageService.softDelete(id);
    _load();
  }

  Future<void> rename(String id, String newName) async {
    await StorageService.renameDocument(id, newName);
    _load();
  }

  Future<void> moveToFolder(String docId, String folderId) async {
    await StorageService.moveToFolder(docId, folderId);
    _load();
  }

  List<DocumentModel> getByType(String ext) {
    return state.where((d) => d.extension.toLowerCase() == ext.toLowerCase()).toList();
  }

  List<DocumentModel> getBookmarked() {
    return state.where((d) => d.isBookmarked).toList();
  }

  List<DocumentModel> getRecent({int limit = 20}) {
    final sorted = [...state]..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return sorted.take(limit).toList();
  }

  List<DocumentModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state.where((d) {
      return d.name.toLowerCase().contains(q) ||
          (d.ocrText?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}

final documentsProvider = StateNotifierProvider<DocumentsNotifier, List<DocumentModel>>(
  (ref) => DocumentsNotifier(),
);

// ─── Folders ─────────────────────────────────────────────────────────────────

class FoldersNotifier extends StateNotifier<List<FolderModel>> {
  FoldersNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getAllFolders();
  }

  Future<void> createFolder(String name) async {
    await StorageService.createFolder(name);
    _load();
  }
}

final foldersProvider = StateNotifierProvider<FoldersNotifier, List<FolderModel>>(
  (ref) => FoldersNotifier(),
);

// ─── Settings ────────────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(StorageService.getSettings());

  Future<void> setPreviewPdf(bool value) async {
    state = AppSettings(
      previewPdf: value,
      isGridView: state.isGridView,
      defaultSaveLocation: state.defaultSaveLocation,
      language: state.language,
      scanQuality: state.scanQuality,
      appLock: state.appLock,
      lockType: state.lockType,
      appPin: state.appPin,
      darkMode: state.darkMode,
    );
    await StorageService.saveSettings(state);
  }

  Future<void> setGridView(bool value) async {
    state = AppSettings(
      previewPdf: state.previewPdf,
      isGridView: value,
      defaultSaveLocation: state.defaultSaveLocation,
      language: state.language,
      scanQuality: state.scanQuality,
      appLock: state.appLock,
      lockType: state.lockType,
      appPin: state.appPin,
      darkMode: state.darkMode,
    );
    await StorageService.saveSettings(state);
  }

  Future<void> setLanguage(String lang) async {
    state = AppSettings(
      previewPdf: state.previewPdf,
      isGridView: state.isGridView,
      defaultSaveLocation: state.defaultSaveLocation,
      language: lang,
      scanQuality: state.scanQuality,
      appLock: state.appLock,
      lockType: state.lockType,
      appPin: state.appPin,
      darkMode: state.darkMode,
    );
    await StorageService.saveSettings(state);
  }

  Future<void> setScanQuality(String quality) async {
    state = AppSettings(
      previewPdf: state.previewPdf,
      isGridView: state.isGridView,
      defaultSaveLocation: state.defaultSaveLocation,
      language: state.language,
      scanQuality: quality,
      appLock: state.appLock,
      lockType: state.lockType,
      appPin: state.appPin,
      darkMode: state.darkMode,
    );
    await StorageService.saveSettings(state);
  }

  Future<void> setAppLock(bool value) async {
    state = AppSettings(
      previewPdf: state.previewPdf,
      isGridView: state.isGridView,
      defaultSaveLocation: state.defaultSaveLocation,
      language: state.language,
      scanQuality: state.scanQuality,
      appLock: value,
      lockType: state.lockType,
      appPin: state.appPin,
      darkMode: state.darkMode,
    );
    await StorageService.saveSettings(state);
  }

  Future<void> setLockType(String type) async {
    state = AppSettings(
      previewPdf: state.previewPdf,
      isGridView: state.isGridView,
      defaultSaveLocation: state.defaultSaveLocation,
      language: state.language,
      scanQuality: state.scanQuality,
      appLock: state.appLock,
      lockType: type,
      appPin: state.appPin,
      darkMode: state.darkMode,
    );
    await StorageService.saveSettings(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

// ─── Search ──────────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<DocumentModel>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final docs = ref.watch(documentsProvider);
  if (query.isEmpty) return docs;
  final q = query.toLowerCase();
  return docs.where((d) {
    return d.name.toLowerCase().contains(q) ||
        (d.ocrText?.toLowerCase().contains(q) ?? false);
  }).toList();
});

// ─── Trash ───────────────────────────────────────────────────────────────────

final trashProvider = Provider<List<DocumentModel>>((ref) {
  ref.watch(documentsProvider); // re-compute on change
  return StorageService.getTrash();
});

// ─── Bottom nav ──────────────────────────────────────────────────────────────

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
