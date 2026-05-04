import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/utils/utils.dart';
import 'package:zen8app/core/core.dart';

class LoadingWidget extends StatefulWidget {
  final Stream<bool>? isLoading;
  final Stream<AppError>? error;
  final Widget child;
  const LoadingWidget({
    Key? key,
    this.isLoading,
    this.error,
    required this.child,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  final _rxBag = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    widget.error?.listen((error) {
      _showError(error, context);
    }).addTo(_rxBag);
  }

  @override
  void dispose() {
    super.dispose();
    _rxBag.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      // fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        widget.child,
        StreamBuilder(
          stream: widget.isLoading,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return _loadingIndicator();
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  void _showError(AppError error, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        Widget closeButton = ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEDF4F0),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
          ),
          child: Text(
            "Đóng",
            style: AppTheme.textStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        );

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          title: Text(
            'Có lỗi xảy ra',
            style: AppTheme.textStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            error.toString(),
            style: AppTheme.textStyle(
              fontSize: 16,
              color: AppTheme.$A3A3A3,
            ),
          ),
          actions: [
            closeButton,
          ],
        );
      },
    );
  }

  Widget _loadingIndicator() {
    return Container(
      color: Colors.white.withOpacity(0.1),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: AppTheme.primaryColor,
      ),
    );
  }
}
