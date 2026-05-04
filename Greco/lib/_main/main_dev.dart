import 'package:flutter/material.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/app/pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies();
  await Session.initialize(Env.dev);

  runApp(const Zen8app());
}
