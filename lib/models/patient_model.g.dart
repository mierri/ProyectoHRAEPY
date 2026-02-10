// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientModelAdapter extends TypeAdapter<PatientModel> {
  @override
<<<<<<< HEAD
  final int typeId = 2;
=======
  final int typeId = 3;
>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a

  @override
  PatientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatientModel(
<<<<<<< HEAD
      patientId: fields[0] as int,
      name: fields[1] as String,
      gender: fields[2] as String,
      birthDate: fields[3] as DateTime,
      synced: fields[4] as bool,
=======
      id: fields[0] as String,
      name: fields[1] as String,
      dateOfBirth: fields[2] as DateTime,
      gender: fields[3] as Gender,
      createdAt: fields[4] as DateTime?,
>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a
    );
  }

  @override
  void write(BinaryWriter writer, PatientModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
<<<<<<< HEAD
      ..write(obj.patientId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.birthDate)
      ..writeByte(4)
      ..write(obj.synced);
=======
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dateOfBirth)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.createdAt);
>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
<<<<<<< HEAD
=======

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 2;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      case 2:
        return Gender.other;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
      case Gender.other:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a
