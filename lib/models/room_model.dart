class RoomModel {
  final String roomId;
  final String offer;
  final String? answer;
  final DateTime createdAt;

  RoomModel({
    required this.roomId,
    required this.offer,
    this.answer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'roomId': roomId,
        'offer': offer,
        'answer': answer,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(
        roomId: map['roomId'] ?? '',
        offer: map['offer'] ?? '',
        answer: map['answer'],
        createdAt: DateTime.parse(map['createdAt']),
      );
}
