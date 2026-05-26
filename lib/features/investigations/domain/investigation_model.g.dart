// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investigation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvestigationModelAdapter extends TypeAdapter<InvestigationModel> {
  @override
  final int typeId = 3;

  @override
  InvestigationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvestigationModel(
      id: fields[0] as int,
      investigationName: fields[1] as String,
      formConsent: fields[2] as String,
      surveyTypeIds: (fields[3] as List).cast<int>(),
      participantIdsList: (fields[4] as List).cast<int>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, InvestigationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.investigationName)
      ..writeByte(2)
      ..write(obj.formConsent)
      ..writeByte(3)
      ..write(obj.surveyTypeIds)
      ..writeByte(4)
      ..write(obj.participantIdsList)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvestigationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
