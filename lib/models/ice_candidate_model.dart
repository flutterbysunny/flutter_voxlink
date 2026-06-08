class IceCandidateModel {
  final String candidate;
  final String sdpMid;
  final int sdpMLineIndex;

  IceCandidateModel({
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });

  Map<String, dynamic> toMap() => {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      };

  factory IceCandidateModel.fromMap(Map<String, dynamic> map) =>
      IceCandidateModel(
        candidate: map['candidate'] ?? '',
        sdpMid: map['sdpMid'] ?? '',
        sdpMLineIndex: map['sdpMLineIndex'] ?? 0,
      );
}
