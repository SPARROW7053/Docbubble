import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 0)
class DocumentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String path;

  @HiveField(3)
  String extension; // pdf, xls, doc, ppt, txt, jpg, png

  @HiveField(4)
  int sizeInBytes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime modifiedAt;

  @HiveField(7)
  bool isBookmarked;

  @HiveField(8)
  bool isDeleted;

  @HiveField(9)
  DateTime? deletedAt;

  @HiveField(10)
  String? folderId;

  @HiveField(11)
  String? thumbnailPath;

  @HiveField(12)
  String? ocrText;

  @HiveField(13)
  int? pageCount;

  @HiveField(14)
  String? folderName;

  DocumentModel({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.sizeInBytes,
    required this.createdAt,
    required this.modifiedAt,
    this.isBookmarked = false,
    this.isDeleted = false,
    this.deletedAt,
    this.folderId,
    this.thumbnailPath,
    this.ocrText,
    this.pageCount,
    this.folderName,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) return '${sizeInBytes}B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)}KB';
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String get displayExtension => extension.toUpperCase();

  DocumentModel copyWith({
    String? id,
    String? name,
    String? path,
    String? extension,
    int? sizeInBytes,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isBookmarked,
    bool? isDeleted,
    DateTime? deletedAt,
    String? folderId,
    String? thumbnailPath,
    String? ocrText,
    int? pageCount,
    String? folderName,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      extension: extension ?? this.extension,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      folderId: folderId ?? this.folderId,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      ocrText: ocrText ?? this.ocrText,
      pageCount: pageCount ?? this.pageCount,
      folderName: folderName ?? this.folderName,
    );
  }
}

@HiveType(typeId: 1)
class FolderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  int fileCount;

  FolderModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.fileCount = 0,
  });
}

@HiveType(typeId: 2)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool previewPdf;

  @HiveField(1)
  bool isGridView;

  @HiveField(2)
  String defaultSaveLocation;

  @HiveField(3)
  String language;

  @HiveField(4)
  String scanQuality; // low, medium, high

  @HiveField(5)
  bool appLock;

  @HiveField(6)
  String lockType; // pin, biometric

  @HiveField(7)
  String? appPin;

  @HiveField(8)
  bool darkMode;

  AppSettings({
    this.previewPdf = false,
    this.isGridView = false,
    this.defaultSaveLocation = '',
    this.language = 'English',
    this.scanQuality = 'high',
    this.appLock = false,
    this.lockType = 'pin',
    this.appPin,
    this.darkMode = false,
  });
}
