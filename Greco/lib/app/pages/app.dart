import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/router/router.dart';

class Zen8app extends StatefulWidget {
  const Zen8app({Key? key}) : super(key: key);

  @override
  State<Zen8app> createState() => _Zen8appState();
}

class _Zen8appState extends State<Zen8app> {
  final _appRouter = AppRouter();
  final _rxBag = CompositeSubscription();
  @override
  void initState() {
    super.initState();
    Session.logoutEvent.listen((reason) {
      print("----- logout $reason");
      _appRouter.replaceAll([LoginRoute()]);
    }).addTo(_rxBag);
  }

  @override
  void dispose() {
    super.dispose();
    _rxBag.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: defaultThemeData(),
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
