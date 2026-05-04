import 'package:json_annotation/json_annotation.dart';

part 'tb_component.g.dart';

@JsonSerializable()
class TBComponent {
  String variable;

  String nameDevice;

  String? type;
  String? unit;
  String? dataType;
  int? icon;

  TBComponent({
    required this.variable,
    required this.nameDevice,
    this.type,
    this.unit,
    this.dataType,
    this.icon,
  });

  factory TBComponent.fromJson(Map<String, dynamic> json) =>
      _$TBComponentFromJson(json);

  Map<String, dynamic> toJson() => _$TBComponentToJson(this);

  // Icon ID mapping for different sensor/actuator types
  static const Map<String, int> defaultIconForType = {
    'temperature': 8,    // thermometer + sun
    'temp': 8,
    'do': 7,             // water waves (dissolved oxygen)
    'oxygen': 7,
    'sat': 13,           // three arrows up (saturation)
    'saturation': 13,
    'ph': 14,            // flask/beaker
    'fan': 9,            // wind swirl
    'quạt': 9,
    'blower': 15,        // circular arrows
    'máy_thổi': 15,
    'pump': 10,          // motor/pump
    'valve': 11,         // tap/faucet
    'van': 11,
    'relay': 10,
    'light': 4,          // sun
    'humidity': 2,       // cloud
    'pressure': 3,       // gauge
    'wind': 5,           // wind flag
    'rain': 1,           // water drop
  };

  bool isBooleanComponent() => dataType == 'boolean';
  
  /// Get icon ID with validation
  /// Returns icon ID 1-18, or defaults based on variable/device name if icon is null
  int? getValidIconId() {
    if (icon != null && icon! >= 1 && icon! <= 18) {
      return icon;
    }
    // Try to infer from variable or device name
    final searchStr = (variable ?? nameDevice).toLowerCase();
    for (final entry in defaultIconForType.entries) {
      if (searchStr.contains(entry.key)) {
        return entry.value;
      }
    }
    // Fallback to icons based on type
    if (type == 'sensor') return 8; // default sensor icon
    if (type == 'actuator' && dataType == 'boolean') return 10; // motor icon
    return null; // No icon
  }

  @override
  String toString() => nameDevice;

  String? iconName() {
    final validId = getValidIconId();
    return validId != null ? 'images/ic_component_$validId.png' : null;
  }
}
