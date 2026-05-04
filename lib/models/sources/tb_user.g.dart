// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tb_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TBUser _$TBUserFromJson(Map<String, dynamic> json) => TBUser(
      id: TBID.fromJson(json['id'] as Map<String, dynamic>),
      customerId: TBID.fromJson(json['customerId'] as Map<String, dynamic>),
      tenantId: TBID.fromJson(json['tenantId'] as Map<String, dynamic>),
      email: json['email'] as String,
      authority: $enumDecode(_$TBAuthorityEnumMap, json['authority']),
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$TBUserToJson(TBUser instance) => <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'tenantId': instance.tenantId,
      'email': instance.email,
      'authority': _$TBAuthorityEnumMap[instance.authority]!,
      'name': instance.name,
    };

const _$TBAuthorityEnumMap = {
  TBAuthority.customerUser: 'CUSTOMER_USER',
  TBAuthority.tenantAdmin: 'TENANT_ADMIN',
};
