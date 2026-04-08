import 'package:hive/hive.dart';
part 'response_model.g.dart';

@HiveType(typeId: 1)
class ResponseModel extends HiveObject{

  @HiveField(0)
  int questionId;
  @HiveField(1)
  int answerValue;


  ResponseModel({
    required this.questionId,
    required this.answerValue,
  });

  // Métodos para sincronización con backend
  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'answer_value': answerValue,
  };

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
    questionId: json['question_id'],
    answerValue: json['answer_value'],
  );
}

