// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_survey_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomSurveyModelAdapter extends TypeAdapter<CustomSurveyModel> {
  @override
  final int typeId = 4;

  @override
  CustomSurveyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomSurveyModel(
      id: fields[0] as int,
      definitionJson: fields[1] as String,
      synced: fields[2] as bool,
      updatedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomSurveyModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.definitionJson)
      ..writeByte(2)
      ..write(obj.synced)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomSurveyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
