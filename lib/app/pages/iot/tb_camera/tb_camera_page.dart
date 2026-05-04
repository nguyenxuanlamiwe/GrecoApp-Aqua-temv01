import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zen8app/app/pages/iot/tb_camera/tb_camera_vm.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:zen8app/widgets/widgets.dart';

class TBCameraPage extends StatefulWidget {
  final TBControlSystem system;
  const TBCameraPage({
    super.key,
    required this.system,
  });

  @override
  State<TBCameraPage> createState() => _TBCameraPageState();
}

class _TBCameraPageState extends State<TBCameraPage> {
  late final _player = Player();
  late final _videoController = VideoController(_player);
  TBCamera? _currentCamera;

  Map<String, String> _rtspLinks = {};
  var _vm = TBCameraVM();
  final _rxBag = CompositeSubscription();

  @override
  void initState() {
    super.initState();
    _bindViewModel();
  }

  _bindViewModel() {
    _vm.output.rtspLinks.listen((links) {
      setState(() {
        _rtspLinks = links;
        if (_currentCamera == null) {
          final first = widget.system.camera.isNotEmpty
              ? widget.system.camera.first
              : (_rtspLinks.isNotEmpty
                  ? TBCamera(nameDevice: _rtspLinks.keys.first, cameraUrl: _rtspLinks.keys.first)
                  : null);
          _startCamera(first);
        }
      });
    }).addTo(_rxBag);

    _vm.input.reload.add(widget.system);
  }

  _startCamera(TBCamera? camera) {
    _currentCamera = camera;
    final rtsp = camera == null ? null
        : (_rtspLinks[camera.cameraUrl] ?? _rtspLinks[camera.nameDevice]);
    if (rtsp != null) {
      _player.open(Media(rtsp));
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _player.dispose();
    _vm.dispose();
    _rxBag.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        error: _vm.errorTracker.asAppError(),
        isLoading: _vm.activityTracker.isRunningAny(),
        child: ListView(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 3 / 4,
              child: Video(
                controller: _videoController,
                aspectRatio: 4 / 3,
              ),
            ),
            ...ListTile.divideTiles(
              tiles: [
                if (widget.system.camera.isNotEmpty)
                  for (var c in widget.system.camera) _cameraItemWidget(c)
                else
                  for (var key in _rtspLinks.keys)
                    _cameraItemWidget(TBCamera(nameDevice: key, cameraUrl: key))
              ],
              color: AppTheme.$E1E1E1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraItemWidget(TBCamera c) {
    bool isRunning = c == _currentCamera;
    return ListTile(
      horizontalTitleGap: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      minLeadingWidth: 24,
      leading: isRunning
          ? const Icon(
              Icons.play_arrow,
              color: AppTheme.primaryColor,
            )
          : const SizedBox(
              width: 24,
              height: 24,
            ),
      title: Text(
        c.nameDevice,
        style: AppTheme.textStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isRunning ? AppTheme.primaryColor : AppTheme.$3A3A3A,
        ),
      ),
      onTap: () {
        setState(() {
          _startCamera(c);
        });
      },
    );
  }
}
