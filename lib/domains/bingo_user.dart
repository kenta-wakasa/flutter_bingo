import 'package:bingo/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BINGOUser {
  BINGOUser({
    required this.myNumbers,
    required this.userId,
  });
  final List<int> myNumbers;
  final String userId;

  factory BINGOUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> ds) {
    final data = ds.data()!;
    return BINGOUser(
      myNumbers: dynamicToList<int>(data['myNumbers']),
      userId: ds.id,
    );
  }
}
