// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:zen8app/core/core.dart';
import 'package:zen8app/router/router.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/widgets/widgets.dart';

import 'bottom_sheet_picker_vm.dart';

class BottomSheetPickerPage<E> extends StatefulWidget {
  final ListLoader<E> loader;
  final bool singleChoice;
  final Set<E> selectedElements;
  final ScrollController? controller;
  final Widget Function(E, bool, VoidCallback)? itemBuilder;
  final String? title;
  const BottomSheetPickerPage({
    Key? key,
    required this.loader,
    this.singleChoice = true,
    this.selectedElements = const {},
    this.controller,
    this.itemBuilder,
    this.title,
  }) : super(key: key);

  @override
  State<BottomSheetPickerPage<E>> createState() =>
      _BottomSheetPickerPageState<E>();
}

class _BottomSheetPickerPageState<E> extends State<BottomSheetPickerPage<E>>
    with MVVMBinding<BottomSheetPickerVM<E>, BottomSheetPickerPage<E>> {
  var _elements = <E>[];
  late var _selectedElements = Set<E>.from(widget.selectedElements);
  late final _singleChoice = widget.singleChoice;

  @override
  BottomSheetPickerVM<E> onCreateVM() => BottomSheetPickerVM(widget.loader);

  @override
  void onBindingVM(CompositeSubscription subscription) {
    vm.output.elements.listen((newElements) {
      setState(() {
        _elements = newElements;
      });
    }).addTo(subscription);

    vm.input.reload.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      error: vm.errorTracker.asAppError(),
      isLoading: vm.activityTracker.isRunningAny(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFDADADA),
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: AppTheme.textStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
                letterSpacing: -0.20,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: ListView.separated(
              controller: widget.controller,
              itemBuilder: (context, index) {
                var anElement = _elements[index];
                var isSelected = _selectedElements.contains(anElement);

                onTap() {
                  setState(() {
                    if (_singleChoice) {
                      _selectedElements = {anElement};
                    } else {
                      if (_selectedElements.contains(anElement)) {
                        _selectedElements.remove(anElement);
                      } else {
                        _selectedElements.add(anElement);
                      }
                    }
                  });

                  if (_singleChoice) {
                    context.router.pop(_selectedElements);
                  }
                }

                if (widget.itemBuilder != null) {
                  return widget.itemBuilder!(anElement, isSelected, onTap);
                }
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    anElement.toString(),
                    style: AppTheme.textStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? Image.asset(
                          'images/ic_check.png',
                          width: 16,
                          height: 16,
                        )
                      : null,
                  onTap: onTap,
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _elements.length,
            ),
          ),
          if (!_singleChoice)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16)),
                child: Text(
                  'Áp dụng',
                  style: AppTheme.textStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  context.router.pop(_selectedElements);
                },
              ),
            ),
        ],
      ),
    );
  }
}
