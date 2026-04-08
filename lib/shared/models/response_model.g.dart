// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResponseModelAdapter extends TypeAdapter<ResponseModel> {
  @override
  final int typeId = 1;

  @override
  ResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResponseModel(
      questionId: fields[0] as int,
      answerValue: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ResponseModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.answerValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
