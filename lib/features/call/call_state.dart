import 'package:flutter_webrtc/flutter_webrtc.dart';

enum CallStatus {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

class CallState {
  final CallStatus status;
  final String? roomId;
  final bool isMicOn;
  final bool isCameraOn;
  final bool isSpeakerOn;
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final String? errorMessage;

  const CallState({
    this.status = CallStatus.idle,
    this.roomId,
    this.isMicOn = true,
    this.isCameraOn = true,
    this.isSpeakerOn = true,
    this.localStream,
    this.remoteStream,
    this.errorMessage,
  });

  CallState copyWith({
    CallStatus? status,
    String? roomId,
    bool? isMicOn,
    bool? isCameraOn,
    bool? isSpeakerOn,
    MediaStream? localStream,
    MediaStream? remoteStream,
    String? errorMessage,
  }) {
    return CallState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      isMicOn: isMicOn ?? this.isMicOn,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
