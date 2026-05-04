import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/utils/utils.dart';

mixin MVVMBinding<VM extends BaseVM, Widget extends StatefulWidget>
    on State<Widget> {
  late final VM vm = onCreateVM();
  final _subscription = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onBindingVM(_subscription);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.dispose();
    vm.dispose();
  }

  VM onCreateVM();

  void onBindingVM(CompositeSubscription subscription);
}
