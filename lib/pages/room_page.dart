import 'package:bingo/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/input_dialog.dart';

class RoomPage extends ConsumerWidget {
  const RoomPage({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(roomProvider(roomId)).when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (e, s) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('このルームは存在しません'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final roomId = await InputDialog.show(context,
                        title: 'ルーム名を入力しましょう', hintText: '');
                    if (roomId?.isEmpty ?? true) {
                      return;
                    }

                    final randomNumbers =
                        List.generate(75, (index) => index + 1)..shuffle();

                    /// ルームを作成する
                    // TODO(kenta-wakasa): IDが被っていた場合の処理
                    ref.watch(roomReferenceProvider(roomId!)).set({
                      'randomNumbers': randomNumbers,
                      'drawnNumbers': [0],
                      'createAt': FieldValue.serverTimestamp(),
                    });

                    context.go('/room/$roomId');
                  },
                  child: const Text('新しくルームを作る'),
                ),
              ],
            ),
          );
        },
        data: (room) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Text('ルーム名：$roomId'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (room.randomNumbers.isEmpty) {
                          return;
                        }
                        final number = room.randomNumbers.removeAt(0);
                        ref.watch(roomReferenceProvider(roomId)).update({
                          'drawnNumbers': FieldValue.arrayUnion([number]),
                          'randomNumbers': FieldValue.arrayRemove([number]),
                        });
                      },
                      child: const Text('抽選'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          '${room.drawnNumbers.reversed.first}'.padLeft(2, '0'),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: 400,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 5,
                        children: [
                          ...room.drawnNumbers.reversed.map(
                            (e) {
                              return FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text('$e'.padLeft(2, '0')),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Text('ビンゴ'),
                    Wrap(
                      spacing: 12,
                      children: [
                        ...room.bingoUsers.map((e) => Text(e)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('参加者'),
                    ref.watch(participatingUsersProvider(roomId)).maybeWhen(
                        orElse: () {
                      return const SizedBox.shrink();
                    }, data: (users) {
                      return Wrap(
                        spacing: 12,
                        children: [
                          ...users.map((e) => Text(e.userId)),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
