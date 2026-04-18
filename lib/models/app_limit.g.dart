// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_limit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppLimitAdapter extends TypeAdapter<AppLimit> {
  @override
  final int typeId = 3;

  @override
  AppLimit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppLimit(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      dailyLimitSeconds: fields[2] as int,
      usedTodaySeconds: fields[3] as int,
      isEnabled: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppLimit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.dailyLimitSeconds)
      ..writeByte(3)
      ..write(obj.usedTodaySeconds)
      ..writeByte(4)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLimitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
