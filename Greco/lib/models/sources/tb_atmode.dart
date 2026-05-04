// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'tb_action.dart';

class TBATMode {
  int moId;
  String name;
  List<TBATStep> steps;

  TBATMode({
    required this.moId,
    required this.name,
    required this.steps,
  });

  TBATMode copy() => TBATMode(
        moId: moId,
        name: name,
        steps: [for (var e in steps) e.copy()],
      );

  factory TBATMode.fromJson(Map<String, dynamic> json) => TBATMode(
        moId: json['moId'] as int,
        name: json['name'] as String,
        steps: [
          for (var actionJson in json['actionList'])
            TBATStep.fromJson(actionJson)
        ],
      );

  Map<String, dynamic> toJson() => {
        'moId': moId,
        'name': name,
        'actionList': [for (var step in steps) step.toJson()],
      };

  bool validate() {
    return moId >= 0 && name.isNotEmpty && !steps.any((e) => !e.validate());
  }
}
