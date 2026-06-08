import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/webrtc_service.dart';
import '../../services/signaling_service.dart';
import '../../services/permission_service.dart';
import 'call_state.dart';

final callControllerProvider =
    StateNotifierProvider<CallController, CallState>(
  (ref) => CallController(),
);

class CallController extends StateNotifier<CallState> {
  CallController() : super(const CallState());

  final _webrtcService = WebRTCService();
  final _signalingService = SignalingService();

  // ─── CALLER: New room banao ────────────────────────────────────────────────
  Future<String?> startCall() async {
    try {
      final hasPermission = await PermissionService.requestCameraAndMic();
      if (!hasPermission) {
        state = state.copyWith(
          status: CallStatus.error,
          errorMessage: 'Camera aur mic permission chahiye',
        );
        return null;
      }

      state = state.copyWith(status: CallStatus.connecting);

      // Local stream shuru karo
      final localStream = await _webrtcService.initLocalStream();
      state = state.copyWith(localStream: localStream);

      // PeerConnection banao
      final pc = await _webrtcService.initPeerConnection(
        onRemoteStream: (stream) {
          state = state.copyWith(
            remoteStream: stream,
            status: CallStatus.connected,
          );
        },
        onConnectionState: _handleConnectionState,
      );

      // Signaling — room create karo
      final roomId = await _signalingService.createRoom(pc);
      state = state.copyWith(roomId: roomId);

      return roomId;
    } catch (e) {
      state = state.copyWith(
        status: CallStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // ─── CALLEE: Room join karo ───────────────────────────────────────────────
  Future<void> joinCall(String roomId) async {
    try {
      final hasPermission = await PermissionService.requestCameraAndMic();
      if (!hasPermission) {
        state = state.copyWith(
          status: CallStatus.error,
          errorMessage: 'Camera aur mic permission chahiye',
        );
        return;
      }

      state = state.copyWith(status: CallStatus.connecting, roomId: roomId);

      final localStream = await _webrtcService.initLocalStream();
      state = state.copyWith(localStream: localStream);

      final pc = await _webrtcService.initPeerConnection(
        onRemoteStream: (stream) {
          state = state.copyWith(
            remoteStream: stream,
            status: CallStatus.connected,
          );
        },
        onConnectionState: _handleConnectionState,
      );

      await _signalingService.joinRoom(roomId, pc);
    } catch (e) {
      state = state.copyWith(
        status: CallStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ─── Controls ─────────────────────────────────────────────────────────────
  void toggleMic() {
    final newVal = !state.isMicOn;
    _webrtcService.toggleMic(newVal);
    state = state.copyWith(isMicOn: newVal);
  }

  void toggleCamera() {
    final newVal = !state.isCameraOn;
    _webrtcService.toggleCamera(newVal);
    state = state.copyWith(isCameraOn: newVal);
  }

  Future<void> switchCamera() => _webrtcService.switchCamera();

  Future<void> toggleSpeaker() async {
    final newVal = !state.isSpeakerOn;
    await _webrtcService.toggleSpeaker(newVal);
    state = state.copyWith(isSpeakerOn: newVal);
  }

  // ─── Call end karo ────────────────────────────────────────────────────────
  Future<void> endCall() async {
    if (state.roomId != null) {
      await _signalingService.deleteRoom(state.roomId!);
    }
    await _webrtcService.dispose();
    state = const CallState(status: CallStatus.disconnected);
  }

  // ─── ICE connection state handle karo ────────────────────────────────────
  void _handleConnectionState(RTCIceConnectionState iceState) {
    switch (iceState) {
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
        state = state.copyWith(status: CallStatus.connected);
        break;
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        state = state.copyWith(status: CallStatus.disconnected);
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _webrtcService.dispose();
    super.dispose();
  }
}
