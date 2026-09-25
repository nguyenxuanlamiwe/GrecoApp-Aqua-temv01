import 'dart:convert';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:dio/dio.dart';

class TBService {
  Stream<(TBCredential, TBUser)> login(String username, String password) {
    return Session.tbPublicClient.ex
        .postStream(
          "/api/auth/login",
          data: {
            "username": username,
            "password": password,
          },
        )
        .decode((json) => TBCredential.fromJson(json))
        .switchMap(
          (credential) {
            return Session.tbPublicClient.ex
                .getStream(
                  '/api/auth/user',
                  options: Options(
                    headers: {
                      'X-Authorization': 'Bearer ${credential.token}',
                    },
                  ),
                )
                .decode((json) => TBUser.fromJson(json))
                .map((user) => (credential, user));
          },
        );
  }

  Stream<dynamic> logout() {
    return Session.tbClient.ex
        .postStream('/api/auth/logout')
        .map((res) => res.data);
  }

  Stream<List<TBFarm>> getFarms({required TBUser user}) {
    var path = switch (user.authority) {
      TBAuthority.customerUser => '/api/customer/${user.customerId.id}/assets',
      TBAuthority.tenantAdmin => '/api/tenant/assets'
    };

    return Session.tbClient.ex.getStream(path, queryParameters: {
      'type': 'farm',
      'pageSize': 10000,
      'page': 0,
      'sortProperty': 'name'
    }).decodeList(
      keyPath: 'data',
      (json) => TBFarm.fromJson(json),
    );
  }

  Stream<List<TBControlSystem>> getFarmConfig(String assetId) {
    return Session.tbClient.ex.getStream(
      "/api/plugins/telemetry/ASSET/$assetId/values/attributes",
      queryParameters: {"keys": "farmConfig"},
    ).decode(
      (json) => (json[0]["value"] as List)
          .map((e) => TBControlSystem.fromJson(e))
          .toList(),
    );
  }

  Stream<List<TBAttribute>> getFarmStatuses(String assetId) {
    return Session.tbClient.ex.getStream(
      "/api/plugins/telemetry/ASSET/$assetId/values/attributes",
      queryParameters: {
        "keys": "statusDevice,statusAuto,statusWeather,warningLevel"
      },
    ).decodeList((json) => TBAttribute.fromJson(json));
  }

  Stream<TBATSystem> getATSystem(String deviceId) {
    return Session.tbClient.ex.getStream(
        "/api/plugins/telemetry/DEVICE/$deviceId/values/attributes",
        queryParameters: {
          "keys": "ATsys"
        }).decode((json) => TBATSystem.fromJson(json[0]["value"]));
  }

  Stream<List<TBATMode>> getATModes(String deviceId) {
    // return Stream.value(
    //   [
    //     TBATMode(
    //       moId: 1,
    //       name: 'Mode 1',
    //       steps: [
    //         TBATStep(
    //           id: 1,
    //           name: 'Step 1',
    //           action: TBAssignBooleanAction(
    //             value: true,
    //             variable: 'rlc1',
    //           ),
    //         ),
    //         TBATStep(
    //           id: 2,
    //           name: 'Step 2',
    //           action: TBAssignFloatAction(
    //             value: 1.2,
    //             variable: 'rlc1',
    //           ),
    //         ),
    //         TBATStep(
    //           id: 3,
    //           name: 'Step 3',
    //           action: TBCompareAction(
    //             operator: TBCompareOperator.greaterThanOrEqual,
    //             value: 1.2,
    //             variable: 'rlc1',
    //           ),
    //         ),
    //         TBATStep(
    //           id: 4,
    //           name: 'Step 4',
    //           action: TBTimerAction(;
    //             value: DateTime(2023, 9, 6, 12, 30, 30),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ],
    // ).delay(Duration(seconds: 1));

    return Session.tbClient.ex.getStream(
        "/api/plugins/telemetry/DEVICE/$deviceId/values/attributes",
        queryParameters: {"keys": "ATmode"}).decode((json) {
      try {
        return (json[0]["value"] as List)
            .map((e) => TBATMode.fromJson(e))
            .toList();
      } catch (e) {
        return [];
      }
    });
  }

  Stream<dynamic> updateATMode(TBATMode mode, String deviceId) {
    final data = jsonEncode({
      "method": "setATmode",
      "params": mode,
      "timeout": 3000,
    });

    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/twoway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<dynamic> updateATSys(TBATSystem system, String deviceId) {
    final data = jsonEncode({
      "method": "setATsys",
      "params": system,
      "timeout": 3000,
    });
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/twoway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<dynamic> deleteATMode(int modeId, String deviceId) {
    final data = jsonEncode({
      "method": "deleteATmode",
      "params": {
        "moId": modeId,
      },
      "timeout": 3000,
    });
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/twoway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<Map<String, dynamic>> getDeviceAttributes(
      String deviceId, List<String>? keys) {
    var queryParams = <String, dynamic>{};
    if (keys != null) {
      queryParams["keys"] = keys.join(",");
    }
    return Session.tbClient.ex
        .getStream("/api/plugins/telemetry/DEVICE/$deviceId/values/attributes",
            queryParameters: queryParams)
        .map(
          (res) => {for (var e in res.data) e["key"]: e},
        );
  }

  Stream<List<TBComponent>> getDeviceConfig(String deviceId) {
    // Get deviceConfig from device attributes (same endpoint as ATsys/ATmode)
    return Session.tbClient.ex.getStream(
      "/api/plugins/telemetry/DEVICE/$deviceId/values/attributes",
      queryParameters: {"keys": "deviceConfig"},
    ).decode((json) {
      try {
        if (json.isEmpty) return [];
        
        final deviceConfigValue = json[0]["value"];
        
        if (deviceConfigValue is! Map) return [];
        
        List<TBComponent> components = [];
        
        // Parse relay devices (actuators)
        if (deviceConfigValue.containsKey('relay') && 
            deviceConfigValue['relay'] is Map &&
            deviceConfigValue['relay']['devices'] is List) {
          final relayDevices = deviceConfigValue['relay']['devices'] as List;
          for (var device in relayDevices) {
            if (device is Map) {
              components.add(TBComponent(
                variable: 'rlc${device['id']}',
                nameDevice: device['device_name'] ?? 'Relay ${device['id']}',
                type: 'actuator',
                dataType: 'boolean',
                unit: null,
                relayType: device['relay_type'] as int?,
              ));
            }
          }
        }
        
        // Parse timer devices (sensors)
        if (deviceConfigValue.containsKey('timer') && 
            deviceConfigValue['timer'] is Map &&
            deviceConfigValue['timer']['timers'] is List) {
          final timers = deviceConfigValue['timer']['timers'] as List;
          for (var timer in timers) {
            if (timer is Map) {
              components.add(TBComponent(
                variable: 'tIriAuto${timer['id']}',
                nameDevice: timer['device_name'] ?? 'Timer ${timer['id']}',
                type: 'sensor',
                dataType: 'float',
                unit: 'phút',
              ));
            }
          }
        }
        
        // Parse analog input sensors
        if (deviceConfigValue.containsKey('analog_input') && 
            deviceConfigValue['analog_input'] is Map &&
            deviceConfigValue['analog_input']['inputs'] is List) {
          final analogInputs = deviceConfigValue['analog_input']['inputs'] as List;
          for (var input in analogInputs) {
            if (input is Map) {
              components.add(TBComponent(
                variable: 'ai${input['id']}',
                nameDevice: input['device_name'] ?? 'Analog ${input['id']}',
                type: 'sensor',
                dataType: 'float',
                unit: null,
              ));
            }
          }
        }
        
        // Parse digital input sensors
        if (deviceConfigValue.containsKey('digital_input') && 
            deviceConfigValue['digital_input'] is Map &&
            deviceConfigValue['digital_input']['inputs'] is List) {
          final digitalInputs = deviceConfigValue['digital_input']['inputs'] as List;
          for (var input in digitalInputs) {
            if (input is Map) {
              components.add(TBComponent(
                variable: 'di${input['id']}',
                nameDevice: input['device_name'] ?? 'Digital ${input['id']}',
                type: 'sensor',
                dataType: 'float',
                unit: null,
              ));
            }
          }
        }
        
        // Parse modbus sensors
        if (deviceConfigValue.containsKey('modbus') && 
            deviceConfigValue['modbus'] is Map &&
            deviceConfigValue['modbus']['parameters'] is List) {
          final modbusParams = deviceConfigValue['modbus']['parameters'] as List;
          for (var param in modbusParams) {
            if (param is Map) {
              components.add(TBComponent(
                variable: 'modbus${param['cid']}',
                nameDevice: param['param_name'] ?? 'Modbus ${param['cid']}',
                type: 'sensor',
                dataType: 'float',
                unit: param['unit'],
              ));
            }
          }
        }
        
        return components;
      } catch (e) {
        print('Error parsing deviceConfig: $e');
        return [];
      }
    });
  }

  Stream<Map<String, dynamic>> getSensorValues(
      String deviceId, List<String>? keys) {
    var queryParams = <String, dynamic>{
      "orderBy": "DESC",
      "limit": 1,
    };
    if (keys != null) {
      queryParams["keys"] = keys.join(",");
    }
    return Session.tbClient.ex
        .getStream("/api/plugins/telemetry/DEVICE/$deviceId/values/timeseries",
            queryParameters: queryParams)
        .map((res) {
      var results = <String, dynamic>{};
      for (var entry in (res.data as Map<String, dynamic>).entries) {
        if (entry.value.isNotEmpty) {
          results[entry.key] = entry.value[0];
        }
      }
      return results;
    });
  }

  Stream<List<TBTimeseriesValue>> getTimeseriesValues({
    required String deviceId,
    required String key,
    required int startTs,
    required int endTs,
    required int? interval,
    required String agg,
  }) {
    // var limit = max((endTs - startTs) ~/ (5 * 1000 * 60), 5000);
    return Session.tbClient.ex.getStream(
      '/api/plugins/telemetry/DEVICE/$deviceId/values/timeseries',
      queryParameters: {
        'keys': key,
        'startTs': startTs,
        'endTs': endTs,
        if (interval != null) 'interval': interval,
        'agg': agg,
        'limit': 525600,
      },
    ).decodeList(keyPath: key, (json) => TBTimeseriesValue.fromJson(json));
  }

  Stream<Map<String, dynamic>> setValue(
      String deviceId, String variable, bool value,
      [int timeout = 3000]) {
    final data = jsonEncode({
      "method": "setValue",
      "params": {
        variable: value,
      },
      "timeout": timeout,
    });
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/twoway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<dynamic> setValueOneWay(
      String deviceId, String variable, bool value) {
    final data = jsonEncode({
      "method": "setValue",
      "params": {
        variable: value,
      },
    });
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/oneway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<dynamic> restartSystem(String deviceId) {
    final data = jsonEncode({
      "method": "setValue",
      "params": {
        "systemRestart": true,
      },
      "timeout": 3000,
      "persistent": false,
    });
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/oneway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<dynamic> renewCameraIp(String deviceId) {
    final data = jsonEncode({
      "method": "setValue",
      "params": {
        "getPublicIp": true,
      },
      "timeout": 3000,
      "persistent": false,
    });
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/rpc/twoway/$deviceId",
          data: data,
        )
        .map((res) => res.data);
  }

  Stream<Map<String, String>> getCameraUrl(
      String deviceId, List<String> cameraKeys) {
    return Session.tbClient.ex.getStream(
        "/api/plugins/telemetry/DEVICE/$deviceId/values/attributes",
        queryParameters: {
          "keys": cameraKeys.join(",")
        }).map((res) => {for (var e in res.data) e["key"]: e["value"]});
  }

  Stream<Map<String, String>> getRtspLinks(
      String deviceId, List<String> cameraKeys) {
    return renewCameraIp(deviceId)
        .switchMap((_) => getCameraUrl(deviceId, cameraKeys));
  }

  Stream<Map<String, String>> getAllRtspLinks(String deviceId) {
    return renewCameraIp(deviceId).switchMap((_) => Session.tbClient.ex
        .getStream(
            "/api/plugins/telemetry/DEVICE/$deviceId/values/attributes")
        .map((res) => {
              for (var e in res.data as List)
                if (e["value"] is String &&
                    (e["value"] as String).startsWith("rtsp://"))
                  e["key"] as String: e["value"] as String
            }));
  }

  Stream<List<TBWeather>> getWeatherForNext10Days(String deviceId) {
    return Session.tbClient.ex.getStream(
        "/api/plugins/telemetry/DEVICE/$deviceId/values/attributes",
        queryParameters: {"keys": "forCastOpenMeteo10day"}).map((res) {
      return TbWeatherForNext10Days.fromJson(res.data[0]['value']);
    }).map(
      (tbWeatherForNext10Days) {
        var DailyUnits(
          temperature2mMax: temperatureUnit,
          rainSum: rainSumUnit,
          precipitationProbabilityMax: precipitationUnit,
          windspeed10MMax: windSpeedUnit
        ) = tbWeatherForNext10Days.dailyUnits;
        var HourlyUnits(:relativehumidity2m) =
            tbWeatherForNext10Days.hourlyUnits;
        var Daily(
          :time,
          :weathercode,
          :temperature2mMax,
          :temperature2mMin,
          :rainSum,
          :precipitationProbabilityMax,
          :windspeed10MMax,
          :humidity2m,
        ) = tbWeatherForNext10Days.daily;

        return [
          for (var i = 0; i < time.length; i++)
            if ((
              time[i].ex.asDateTime(DatePattern.yyyyMMdd),
              WeatherForecastHelper.getWeatherDescriptionByCode(weathercode[i]),
            )
                case (
                  DateTime date,
                  (String, String) description,
                ))
              TBWeather(
                date: date,
                temperatureUnit: temperatureUnit,
                windSpeedUnit: windSpeedUnit,
                rainSumUnit: rainSumUnit,
                precipitationUnit: precipitationUnit,
                humidityUnit: relativehumidity2m,
                minTemperature: temperature2mMin[i],
                maxTemperature: temperature2mMax[i],
                rainSum: rainSum[i],
                windSpeed: windspeed10MMax[i],
                precipitation: precipitationProbabilityMax[i],
                humidity: humidity2m[i],
                iconPath: description.$2,
                weatherDescription: description.$1,
              ),
        ];
      },
    ).onErrorReturn([]);
  }

  Stream<void> saveFarmConfig(
      String assetId, List<TBControlSystem> config) {
    return Session.tbClient.ex
        .postStream(
          "/api/plugins/telemetry/ASSET/$assetId/SERVER_SCOPE",
          data: jsonEncode(
              {"farmConfig": config.map((e) => e.toJson()).toList()}),
        )
        .map((_) => null);
  }
}
