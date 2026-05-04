import 'package:json_annotation/json_annotation.dart';

part 'tb_credential.g.dart';

@JsonSerializable()
class TBCredential {
  String token;
  String refreshToken;
  TBCredential({
    required this.token,
    required this.refreshToken,
  });

  factory TBCredential.fromJson(Map<String, dynamic> json) =>
      _$TBCredentialFromJson(json);
  Map<String, dynamic> toJson() => _$TBCredentialToJson(this);
}
