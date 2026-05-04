import 'package:json_annotation/json_annotation.dart';

enum TBAuthority {
  @JsonValue('CUSTOMER_USER')
  customerUser,

  @JsonValue('TENANT_ADMIN')
  tenantAdmin;
}
