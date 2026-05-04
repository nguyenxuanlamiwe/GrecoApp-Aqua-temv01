// ignore_for_file: public_member_api_docs, sort_constructors_first
enum Env { dev, stg, prod }

class Config {
  String vgBaseUrl;
  String tbBaseUrl;
  String mqttServer;
  Config({
    required this.vgBaseUrl,
    required this.tbBaseUrl,
    required this.mqttServer,
  });

  factory Config.env(Env env) {
    switch (env) {
      case Env.dev:
        return dev;
      case Env.stg:
        return stg;
      case Env.prod:
        return prod;
    }
  }

  static Config get dev => Config(
        vgBaseUrl: 'https://vgrowlocal.try0.xyz/api/v1',
        tbBaseUrl: 'http://platform.grcvn.com:8080',
        mqttServer: "platform.grcvn.com",
      );

  static Config get stg => Config(
        vgBaseUrl: 'https://vgrowlocal.try0.xyz/api/v1',
        tbBaseUrl: 'http://platform.grcvn.com:8080',
        mqttServer: "platform.grcvn.com",
      );

  static Config get prod => Config(
        vgBaseUrl: 'https://vgrow.try0.xyz/api/v1',
        tbBaseUrl: 'http://platform.grcvn.com:8080',
        mqttServer: "platform.grcvn.com",
      );
}
