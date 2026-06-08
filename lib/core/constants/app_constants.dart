class AppConstants {
  AppConstants._();

  static const String appName = 'VoxLink';

  // Google Free STUN Server - no cost
  static const List<Map<String, dynamic>> iceServers = [
    {
      'urls': [
        'stun:stun.l.google.com:19302',
        'stun:stun1.l.google.com:19302',
      ]
    },
  ];

  static const Map<String, dynamic> peerConnectionConfig = {
    'iceServers': iceServers,
    'sdpSemantics': 'unified-plan',
  };

  // Firestore collection names
  static const String roomsCollection = 'rooms';
  static const String callerCandidates = 'callerCandidates';
  static const String calleeCandidates = 'calleeCandidates';
}
