import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Camera + Mic dono permissions ek saath maango
  static Future<bool> requestCameraAndMic() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    return cameraGranted && micGranted;
  }

  static Future<bool> get isCameraGranted async =>
      await Permission.camera.isGranted;

  static Future<bool> get isMicGranted async =>
      await Permission.microphone.isGranted;

  /// Permission permanently deny ho gayi ho toh settings kholo
  static Future<void> openAppSettings() => openAppSettings();
}
