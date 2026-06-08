import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'call_controller.dart';
import 'call_state.dart';
import 'widgets/camera_view.dart';
import 'widgets/call_controls.dart';

class CallScreen extends ConsumerWidget {
  final String? roomId;       // null = caller (new room)
  final bool isJoining;       // true = callee

  const CallScreen({
    super.key,
    this.roomId,
    this.isJoining = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callControllerProvider);
    final controller = ref.read(callControllerProvider.notifier);

    // Auto-start on screen load
    ref.listen(callControllerProvider, (prev, next) {});

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Remote video (full screen) ──────────────────────────────────
          Positioned.fill(
            child: CameraView(
              stream: state.remoteStream,
              isMirror: false,
            ),
          ),

          // ── Local video (picture-in-picture, top-right) ─────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            width: 100,
            height: 140,
            child: CameraView(
              stream: state.localStream,
              isMirror: true,
              isSmall: true,
            ),
          ),

          // ── Status overlay ───────────────────────────────────────────────
          if (state.status == CallStatus.connecting)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Connecting...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),

          // ── Room ID share card (caller ke liye) ─────────────────────────
          if (state.roomId != null && state.status == CallStatus.connecting)
            Positioned(
              top: MediaQuery.of(context).padding.top + 180,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Room ID share karo:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.roomId!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Error message ────────────────────────────────────────────────
          if (state.status == CallStatus.error)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage ?? 'Kuch error aa gaya',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── Call Controls (bottom) ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CallControls(
              isMicOn: state.isMicOn,
              isCameraOn: state.isCameraOn,
              isSpeakerOn: state.isSpeakerOn,
              onToggleMic: controller.toggleMic,
              onToggleCamera: controller.toggleCamera,
              onToggleSpeaker: controller.toggleSpeaker,
              onSwitchCamera: controller.switchCamera,
              onEndCall: () async {
                await controller.endCall();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
