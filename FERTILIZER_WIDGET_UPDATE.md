# Fertilizer Widget Update

## Changes needed in `lib/app/pages/iot/tb_auto_mode/tb_auto_mode_page.dart`:

### 1. Replace `_stationFertilizerValveWidget()` method (around line 690-828):

Replace the entire widget with this new implementation that includes dropdown selections for pumps and FilterChips for fertilizer valves.

### 2. Update `_submitIrrigation()` method (around line 1300-1350):

Add fertilizer-specific logic to save iri_pump, fer_pump, fer_valve instead of generic stationRlc:

```dart
// In _submitIrrigation(), for fertilizer mode, replace:
    _editingMode.stationEnabled = _stationEnabled;
    _editingMode.stationRlc.clear();
    for (var index in _stationRlcIndices) {
      if (_stationRlcSelected[index] ?? false) {
        _editingMode.stationRlc.add(index);
      }
    }

// With:
    _editingMode.stationEnabled = _stationEnabled;
    if (_editingMode.modeType == TBModeType.fertilizer) {
      // Fertilizer mode: use specific pump/valve fields
      _editingMode.stationIriPump = _stationIriPumpSelected;
      _editingMode.stationFerPump = _stationFerPumpSelected;
      _editingMode.stationFerValve.clear();
      for (var entry in _stationFerValveSelected.entries) {
        if (entry.value) {
          _editingMode.stationFerValve.add(entry.key);
        }
      }
    } else {
      // Other modes: use legacy rlc list
      _editingMode.stationRlc.clear();
      for (var index in _stationRlcIndices) {
        if (_stationRlcSelected[index] ?? false) {
          _editingMode.stationRlc.add(index);
        }
      }
    }
```

## Expected JSON output:

```json
{
  "moId": 5,
  "name": "Châm phân tự động",
  "modeType": "fertilizer",
  "station": {
    "iri_pump": 15,
    "fer_pump": 14,
    "fer_valve": [11, 12, 13]
  },
  "lotList": [...]
}
```

Note: Field "enable" đã được bỏ khỏi station object vì không cần thiết.

