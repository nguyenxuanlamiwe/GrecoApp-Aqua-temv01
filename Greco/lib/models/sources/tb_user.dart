import 'package:json_annotation/json_annotation.dart';

import 'package:zen8app/models/models.dart';

part 'tb_user.g.dart';

@JsonSerializable()
class TBUser {
  final TBID id;
  final TBID customerId;
  final TBID tenantId;

  final String email;

  final TBAuthority authority;

  @JsonKey(defaultValue: "")
  final String name;

  TBUser({
    required this.id,
    required this.customerId,
    required this.tenantId,
    required this.email,
    required this.authority,
    required this.name,
  });

  factory TBUser.fromJson(Map<String, dynamic> json) => _$TBUserFromJson(json);
  Map<String, dynamic> toJson() => _$TBUserToJson(this);
}
