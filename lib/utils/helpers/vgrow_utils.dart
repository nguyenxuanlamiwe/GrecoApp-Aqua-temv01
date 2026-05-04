import 'package:flutter/material.dart';

Future<T?> showModalBottomScrollableSheet<T>({
  required BuildContext context,
  WidgetBuilder? headerBuilder,
  required ScrollableWidgetBuilder bodyBuilder,
  Color? backgroundColor,
  bool isDismissible = true,
  bool enableDrag = true,
  double initialChildSize = 0.5,
  double minChildSize = 0.25,
  double maxChildSize = 0.9,
  EdgeInsets contentInsets =
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  bool snap = false,
  List<double>? snapSizes,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.0),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: backgroundColor,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) {
      if (headerBuilder != null) {
        return Padding(
          padding: contentInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerBuilder(context),
              Flexible(
                child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: initialChildSize,
                  minChildSize: minChildSize,
                  maxChildSize: maxChildSize,
                  snap: snap,
                  snapSizes: snapSizes,
                  builder: bodyBuilder,
                ),
              )
            ],
          ),
        );
      } else {
        return Padding(
          padding: contentInsets,
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            snap: snap,
            snapSizes: snapSizes,
            builder: bodyBuilder,
          ),
        );
      }
    },
  );
}
