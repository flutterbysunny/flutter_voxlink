import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../core/constants/app_constants.dart';

class WebRTCService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  RTCPeerConnection? get peerConnection => _peerConnection;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  // ─────────────────────────────────────────────────────────────
  // Local Camera + Mic Stream
  // ─────────────────────────────────────────────────────────────
  Future<MediaStream> initLocalStream() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      },
      'audio': true,
    });

    return _localStream!;
  }

  // ─────────────────────────────────────────────────────────────
  // Peer Connection
  // ─────────────────────────────────────────────────────────────
  Future<RTCPeerConnection> initPeerConnection({
    required Function(MediaStream stream) onRemoteStream,
    required Function(RTCIceConnectionState state) onConnectionState,
  }) async {
    _peerConnection = await createPeerConnection(
      AppConstants.peerConnectionConfig,
    );

    // Add local tracks
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
    }

    // Receive remote stream
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
        onRemoteStream(_remoteStream!);
      }
    };

    // ICE state changes
    _peerConnection!.onIceConnectionState =
        (RTCIceConnectionState state) {
      onConnectionState(state);
    };

    return _peerConnection!;
  }

  // ─────────────────────────────────────────────────────────────
  // Mic On / Off
  // ─────────────────────────────────────────────────────────────
  void toggleMic(bool enabled) {
    if (_localStream == null) return;

    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = enabled;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Camera On / Off
  // ─────────────────────────────────────────────────────────────
  void toggleCamera(bool enabled) {
    if (_localStream == null) return;

    for (final track in _localStream!.getVideoTracks()) {
      track.enabled = enabled;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Switch Front / Back Camera
  // ─────────────────────────────────────────────────────────────
  Future<void> switchCamera() async {
    if (_localStream == null) return;

    final videoTracks = _localStream!.getVideoTracks();

    if (videoTracks.isNotEmpty) {
      await Helper.switchCamera(videoTracks.first);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Speaker On / Off
  // ─────────────────────────────────────────────────────────────
  Future<void> toggleSpeaker(bool speakerOn) async {
    if (_remoteStream == null) return;

    for (final track in _remoteStream!.getAudioTracks()) {
      track.enableSpeakerphone(speakerOn);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Create Offer
  // ─────────────────────────────────────────────────────────────
  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  // ─────────────────────────────────────────────────────────────
  // Create Answer
  // ─────────────────────────────────────────────────────────────
  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  // ─────────────────────────────────────────────────────────────
  // Set Remote Description
  // ─────────────────────────────────────────────────────────────
  Future<void> setRemoteDescription(
      RTCSessionDescription description,
      ) async {
    await _peerConnection?.setRemoteDescription(description);
  }

  // ─────────────────────────────────────────────────────────────
  // Add ICE Candidate
  // ─────────────────────────────────────────────────────────────
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection?.addCandidate(candidate);
  }

  // ─────────────────────────────────────────────────────────────
  // End Call / Cleanup
  // ─────────────────────────────────────────────────────────────
  Future<void> dispose() async {
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        track.stop();
      }

      await _localStream!.dispose();
    }

    await _remoteStream?.dispose();
    await _peerConnection?.close();

    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
  }
}