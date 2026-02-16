// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurveyModelAdapter extends TypeAdapter<SurveyModel> {
  @override
  final int typeId = 0;

  @override
  SurveyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurveyModel(
      surveyId: fields[0] as int,
      responses: (fields[2] as List).cast<ResponseModel>(),
      surveyType: fields[4] as int,
      patientId: fields[3] as int?,
      synced: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SurveyModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.surveyId)
      ..writeByte(1)
      ..write(obj.synced)
      ..writeByte(2)
      ..write(obj.responses)
      ..writeByte(3)
      ..write(obj.patientId)
      ..writeByte(4)
      ..write(obj.surveyType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
