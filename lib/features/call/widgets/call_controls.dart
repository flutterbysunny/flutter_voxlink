import 'package:flutter/material.dart';

class CallControls extends StatelessWidget {
  final bool isMicOn;
  final bool isCameraOn;
  final bool isSpeakerOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onSwitchCamera;
  final VoidCallback onEndCall;

  const CallControls({
    super.key,
    required this.isMicOn,
    required this.isCameraOn,
    required this.isSpeakerOn,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleSpeaker,
    required this.onSwitchCamera,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: isMicOn ? Icons.mic : Icons.mic_off,
            label: isMicOn ? 'Mute' : 'Unmute',
            onTap: onToggleMic,
            isActive: isMicOn,
          ),
          _ControlButton(
            icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: isCameraOn ? 'Camera' : 'No Cam',
            onTap: onToggleCamera,
            isActive: isCameraOn,
          ),
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            onTap: onEndCall,
            isActive: false,
            isEndCall: true,
          ),
          _ControlButton(
            icon: isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: 'Speaker',
            onTap: onToggleSpeaker,
            isActive: isSpeakerOn,
          ),
          _ControlButton(
            icon: Icons.flip_camera_ios,
            label: 'Flip',
            onTap: onSwitchCamera,
            isActive: true,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isEndCall;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isActive,
    this.isEndCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEndCall
                  ? Colors.red
                  : isActive
                      ? Colors.white24
                      : Colors.white10,
              border: Border.all(
                color: isEndCall
                    ? Colors.red
                    : isActive
                        ? Colors.white54
                        : Colors.white24,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
