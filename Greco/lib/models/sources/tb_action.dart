// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:zen8app/utils/utils.dart';

class TBCompareOperator {
  static const greaterThanOrEqual = '>=';
  static const lessThanOrEqual = '<=';
  static const equal = '==';
  static const different = '!=';
}

class TBActionType {
  static const compare = 'compare';
  static const timer = 'timer';
  static const assignBoolean = 'assignBoolean';
  static const assignFloat = 'assignFloat';
}

class TBATStep {
  int id;
  String name;
  TBAction action;

  TBATStep({
    required this.id,
    this.name = '',
    required this.action,
  });

  factory TBATStep.fromJson(Map<String, dynamic> json) => TBATStep(
        id: json['id'] as int,
        name: json['name'] as String,
        action: TBAction.fromJson(
          json['action'],
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'action': action.toJson(),
      };

  TBATStep copy() => TBATStep(
        id: id,
        name: name,
        action: action.copy(),
      );

  bool validate() => name.isNotEmpty && action.validate();
}

sealed class TBAction {
  static TBAction fromJson(Map<String, dynamic> json) {
    var type = json['type'] as String;
    return switch (type) {
      TBActionType.compare => TBCompareAction.fromJson(json),
      TBActionType.assignBoolean => TBAssignBooleanAction.fromJson(json),
      TBActionType.assignFloat => TBAssignFloatAction.fromJson(json),
      TBActionType.timer => TBTimerAction.fromJson(json),
      _ => throw AppError(description: 'Unsupported action $type'),
    };
  }

  Map<String, dynamic> toJson();

  TBAction copy();

  bool validate();
}

class TBCompareAction extends TBAction {
  double? value;
  String operator;
  String? variable;

  TBCompareAction({
    this.value,
    this.operator = TBCompareOperator.equal,
    this.variable,
  });

  factory TBCompareAction.fromJson(Map<String, dynamic> json) =>
      TBCompareAction(
        value: (json["value"] as num).toDouble(),
        operator: json["operator"] as String,
        variable: json["variable"] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': TBActionType.compare,
        'value': value,
        'operator': operator,
        'variable': variable,
      };

  @override
  TBAction copy() => TBCompareAction(
        value: value,
        operator: operator,
        variable: variable,
      );

  @override
  bool validate() {
    return variable != null && value != null;
  }
}

class TBAssignBooleanAction extends TBAction {
  bool value;
  String? variable;
  TBAssignBooleanAction({
    this.value = false,
    this.variable,
  });

  factory TBAssignBooleanAction.fromJson(Map<String, dynamic> json) =>
      TBAssignBooleanAction(
        value: json["value"] as bool,
        variable: json["variable"] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': TBActionType.assignBoolean,
        'value': value,
        'variable': variable,
      };

  @override
  TBAction copy() => TBAssignBooleanAction(
        value: value,
        variable: variable,
      );

  @override
  bool validate() {
    return variable != null;
  }
}

class TBAssignFloatAction extends TBAction {
  double? value;
  String? variable;
  TBAssignFloatAction({
    this.value,
    this.variable,
  });

  factory TBAssignFloatAction.fromJson(Map<String, dynamic> json) =>
      TBAssignFloatAction(
        value: (json["value"] as num).toDouble(),
        variable: json["variable"] as String,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': TBActionType.assignFloat,
        'value': value,
        'variable': variable,
      };

  @override
  TBAction copy() => TBAssignFloatAction(
        value: value,
        variable: variable,
      );

  @override
  bool validate() {
    return variable != null && value != null;
  }
}

class TBTimerAction extends TBAction {
  DateTime value;
  TBTimerAction({
    required this.value,
  });

  factory TBTimerAction.fromJson(Map<String, dynamic> json) {
    var value = json['value'] as List;
    return TBTimerAction(
      value: DateTime(
        value[0],
        value[1],
        value[2],
        value[3],
        value[4],
        value[5],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': TBActionType.timer,
      'value': [
        value.year,
        value.month,
        value.day,
        value.hour,
        value.minute,
        value.second,
      ],
    };
  }

  @override
  TBAction copy() => TBTimerAction(value: value);

  @override
  bool validate() => true;
}
