import 'package:bingo/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String roomId;
  final List<int> drawnNumbers;
  final List<int> randomNumbers;
  final List<String> bingoUsers;

  Room({
    required this.roomId,
    required this.drawnNumbers,
    required this.randomNumbers,
    required this.bingoUsers,
  });

  factory Room.fromFirestore(DocumentSnapshot<Map<String, dynamic>> ds) {
    final data = ds.data()!;
    return Room(
      roomId: ds.id,
      randomNumbers: dynamicToList<int>(data['randomNumbers']),
      drawnNumbers: dynamicToList<int>(data['drawnNumbers']),
      bingoUsers: dynamicToList<String>(data['bingoUsers']),
    );
  }
}
