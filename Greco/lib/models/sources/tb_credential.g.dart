// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_credential.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBCredential _$TBCredentialFromJson(Map<String, dynamic> json) => TBCredential(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$TBCredentialToJson(TBCredential instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
    };
