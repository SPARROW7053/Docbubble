// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 0;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      name: fields[1] as String,
      path: fields[2] as String,
      extension: fields[3] as String,
      sizeInBytes: fields[4] as int,
      createdAt: fields[5] as DateTime,
      modifiedAt: fields[6] as DateTime,
      isBookmarked: fields[7] as bool,
      isDeleted: fields[8] as bool,
      deletedAt: fields[9] as DateTime?,
      folderId: fields[10] as String?,
      thumbnailPath: fields[11] as String?,
      ocrText: fields[12] as String?,
      pageCount: fields[13] as int?,
      folderName: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.extension)
      ..writeByte(4)
      ..write(obj.sizeInBytes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.modifiedAt)
      ..writeByte(7)
      ..write(obj.isBookmarked)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.deletedAt)
      ..writeByte(10)
      ..write(obj.folderId)
      ..writeByte(11)
      ..write(obj.thumbnailPath)
      ..writeByte(12)
      ..write(obj.ocrText)
      ..writeByte(13)
      ..write(obj.pageCount)
      ..writeByte(14)
      ..write(obj.folderName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FolderModelAdapter extends TypeAdapter<FolderModel> {
  @override
  final int typeId = 1;

  @override
  FolderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FolderModel(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      fileCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FolderModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.fileCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      previewPdf: fields[0] as bool,
      isGridView: fields[1] as bool,
      defaultSaveLocation: fields[2] as String,
      language: fields[3] as String,
      scanQuality: fields[4] as String,
      appLock: fields[5] as bool,
      lockType: fields[6] as String,
      appPin: fields[7] as String?,
      darkMode: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.previewPdf)
      ..writeByte(1)
      ..write(obj.isGridView)
      ..writeByte(2)
      ..write(obj.defaultSaveLocation)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.scanQuality)
      ..writeByte(5)
      ..write(obj.appLock)
      ..writeByte(6)
      ..write(obj.lockType)
      ..writeByte(7)
      ..write(obj.appPin)
      ..writeByte(8)
      ..write(obj.darkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
