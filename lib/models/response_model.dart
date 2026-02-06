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
}