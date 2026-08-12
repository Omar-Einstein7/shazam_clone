import 'dart:io';

import 'package:flutter_complete_project/src/services/path_service.dart';
import 'package:flutter_complete_project/src/services/permission_service.dart';
import 'package:flutter_complete_project/src/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Local data source that records audio from the device microphone.
///
/// Phase 1 (recording only): captures [recordDuration] of microphone audio,
/// writes it to a temp file and returns the saved file path. It does not
/// recognize or send anything to a server yet.
class AudioLocalDataSource {
  AudioLocalDataSource._();
  static final AudioLocalDataSource instance = AudioLocalDataSource._();

  final AudioRecorder _recorder = AudioRecorder();

  /// Requests the microphone permission via the existing [PermissionService].
  FutureEither<bool> requestMicrophonePermission() {
    return runTask(() async {
      final result = await PermissionService.instance.request(
        Permission.microphone,
      );

      return result.fold(
        (failure) => false,
        (status) => status.isGranted,
      );
    });
  }

  /// Records audio for [duration] and returns the saved file path.
  ///
  /// Returns a [Failure] (such as a permission-denied message) when recording
  /// could not be completed.
  FutureEither<String> record({
    Duration duration = const Duration(seconds: 8),
  }) {
    return runTask(() async {
      final granted = await requestMicrophonePermission();
      final isGranted = granted.fold((failure) => false, (value) => value);
      if (!isGranted) {
        throw const UnknownFailure(
          'Microphone permission was denied. '
          'Enable it in Settings to identify songs.',
        );
      }

      final directoryResult = await PathService.instance.getDocumentsDirectory();
      final directory = directoryResult.fold(
        (failure) => throw failure,
        (dir) => dir,
      );

      final path =
          '${directory.path}${Platform.pathSeparator}'
          'shazam_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // - audioInterruption: none -> do NOT grab audio focus on Android so
      //   music playing on the device keeps playing while we record.
      // - iosConfig: mixWithOthers -> let other apps' audio keep playing on iOS.
      final config = RecordConfig(
        audioInterruption: AudioInterruptionMode.none,
        iosConfig: const IosRecordConfig(
          categoryOptions: [
            IosAudioCategoryOption.mixWithOthers,
            IosAudioCategoryOption.defaultToSpeaker,
            IosAudioCategoryOption.allowBluetooth,
            IosAudioCategoryOption.allowBluetoothA2DP,
          ],
        ),
      );

      await _recorder.start(config, path: path);

      await Future<void>.delayed(duration);

      await _recorder.stop();

      return path;
    });
  }
}