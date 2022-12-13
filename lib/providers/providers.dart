import 'package:bingo/domains/bingo.dart';
import 'package:bingo/domains/bingo_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domains/room.dart';

final roomIdProvider = Provider.autoDispose<String>((_) => throw Exception());

final userIdProvider = Provider.autoDispose<String>((_) => throw Exception());

final firestoreProvider =
    Provider.autoDispose((_) => FirebaseFirestore.instance);

final roomReferenceProvider = Provider.autoDispose.family((ref, String roomId) {
  return ref.watch(firestoreProvider).collection('room').doc(roomId);
});

final roomExistsProvider = FutureProvider.autoDispose.family(
  (ref, String roomId) async {
    final ds = await ref.watch(roomReferenceProvider(roomId)).get();
    return ds.exists;
  },
  dependencies: [
    roomReferenceProvider,
  ],
);

final userReferenceProvider = Provider.autoDispose.family(
  (ref, String userId) {
    final roomId = ref.watch(roomIdProvider);
    return ref
        .watch(roomReferenceProvider(roomId))
        .collection('user')
        .doc(userId);
  },
  dependencies: [
    roomIdProvider,
    roomReferenceProvider,
  ],
);

final userExistsProvider = FutureProvider.autoDispose.family(
  (ref, String userId) async {
    final ds = await ref.read(userReferenceProvider(userId)).get();
    return ds.exists;
  },
  dependencies: [
    userReferenceProvider,
  ],
);

final roomProvider = StreamProvider.autoDispose.family((ref, String roomId) {
  return ref.watch(roomReferenceProvider(roomId)).snapshots().map((doc) {
    return Room.fromFirestore(doc);
  });
}, dependencies: [
  roomReferenceProvider,
]);

final drawnNumbersProvider =
    StreamProvider.autoDispose.family((ref, String roomId) {
  return ref.watch(roomProvider(roomId).stream).map((room) {
    return room.drawnNumbers;
  });
}, dependencies: [
  roomProvider,
]);

/// [userId]
final bingoUserProvider = StreamProvider.autoDispose.family<BINGOUser, String>(
  (ref, userId) {
    return ref.watch(userReferenceProvider(userId)).snapshots().map((event) {
      final bingoUser = BINGOUser.fromFirestore(event);
      return bingoUser;
    });
  },
  dependencies: [
    userReferenceProvider,
  ],
);

final participatingUsersProvider = StreamProvider.autoDispose.family(
  (ref, String roomId) {
    return ref
        .watch(roomReferenceProvider(roomId))
        .collection('user')
        .snapshots()
        .map(
          (event) =>
              event.docs.map((doc) => BINGOUser.fromFirestore(doc)).toList(),
        );
  },
  dependencies: [roomReferenceProvider],
);

final bingoProvider = StreamProvider.autoDispose.family(
  (ref, BINGOUser bingoUser) {
    final roomId = ref.watch(roomIdProvider);
    return ref.watch(roomReferenceProvider(roomId)).snapshots().map((ds) {
      final room = Room.fromFirestore(ds);
      return BINGO(
        myNumbers: bingoUser.myNumbers,
        drawnNumbers: room.drawnNumbers,
      );
    });
  },
  dependencies: [
    roomIdProvider,
    roomReferenceProvider,
  ],
);
