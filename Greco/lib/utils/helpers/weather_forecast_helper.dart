class WeatherForecastHelper {
  static const Map<int, (String description, String iconPath)> _iconMap = {
    0: ("Nhiều nắng", "http://openweathermap.org/img/wn/01d@2x.png"),
    1: ("Nắng nhiều", "http://openweathermap.org/img/wn/01d@2x.png"),
    2: ("Mây rải rác", "http://openweathermap.org/img/wn/02d@2x.png"),
    3: ("Nhiều mây", "http://openweathermap.org/img/wn/03d@2x.png"),
    45: ("Sương mù", "http://openweathermap.org/img/wn/50d@2x.png"),
    48: ("Sương mù đọng tuyết", "http://openweathermap.org/img/wn/50d@2x.png"),
    51: ("Mưa phùn nhẹ", "http://openweathermap.org/img/wn/09d@2x.png"),
    53: ("Mưa phùn", "http://openweathermap.org/img/wn/09d@2x.png"),
    55: ("Mưa phùn nặng", "http://openweathermap.org/img/wn/09d@2x.png"),
    56: (
      "Mưa phùn đọng lạnh nhẹ",
      "http://openweathermap.org/img/wn/09d@2x.png"
    ),
    57: ("Mưa phùn đọng lạnh", "http://openweathermap.org/img/wn/09d@2x.png"),
    61: ("Mưa nhẹ", "http://openweathermap.org/img/wn/10d@2x.png"),
    63: ("Có mưa", "http://openweathermap.org/img/wn/10d@2x.png"),
    65: ("Mưa lớn", "http://openweathermap.org/img/wn/10d@2x.png"),
    66: ("Mưa đá", "http://openweathermap.org/img/wn/10d@2x.png"),
    67: ("Mưa đá", "http://openweathermap.org/img/wn/10d@2x.png"),
    71: ("Tuyết nhẹ", "http://openweathermap.org/img/wn/13d@2x.png"),
    73: ("Có tuyết", "http://openweathermap.org/img/wn/13d@2x.png"),
    74: ("Tuyết rơi nhiều", "http://openweathermap.org/img/wn/13d@2x.png"),
    77: ("Tuyết hạt nhỏ", "http://openweathermap.org/img/wn/13d@2x.png"),
    80: ("Mưa rào nhẹ", "http://openweathermap.org/img/wn/09d@2x.png"),
    81: ("Mưa rào", "http://openweathermap.org/img/wn/09d@2x.png"),
    82: ("Mưa rào mạnh", "http://openweathermap.org/img/wn/09d@2x.png"),
    85: ("Cơn mưa tuyết", "http://openweathermap.org/img/wn/13d@2x.png"),
    86: ("Cơn mưa tuyết", "http://openweathermap.org/img/wn/13d@2x.png"),
    95: ("Sấm sét", "http://openweathermap.org/img/wn/11d@2x.png"),
    96: ("Sấm sét kèm mưa đá", "http://openweathermap.org/img/wn/11d@2x.png"),
    99: ("Sấm sét kèm mưa đá", "http://openweathermap.org/img/wn/11d@2x.png"),
  };

  static (String description, String iconPath)? getWeatherDescriptionByCode(
          int code) =>
      _iconMap[code];
}
