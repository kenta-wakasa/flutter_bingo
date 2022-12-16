import 'package:bingo/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../constants/constants.dart';
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
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: FittedBox(
                                  child: SizedBox(
                                    height: 320,
                                    width: 320,
                                    child: QrImage(
                                        foregroundColor: Colors.white,
                                        data:
                                            'https://flutter-univ-bingo.web.app/room/$roomId/new'),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text('ルーム名：$roomId をQRで共有'),
                    ),
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
                          room.drawnNumbers.reversed.first == 0
                              ? ''
                              : '${room.drawnNumbers.reversed.first}'
                                  .padLeft(2, '0'),
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
                                  child: e == 0
                                      ? const Text('')
                                      : Text('$e'.padLeft(2, '0')),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Text('[ビンゴ]'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 4,
                        children: [
                          ...room.bingoUsers.map((e) => Text(e)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('[参加者]'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 4,
                        children: [
                          ...(ref
                                      .watch(participatingUsersProvider(roomId))
                                      .value ??
                                  [])
                              .map((u) {
                            return InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('${u.userId}のカード'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FittedBox(
                                              child: SizedBox(
                                                height: 320,
                                                width: 320,
                                                child: GridView.count(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  crossAxisCount: 5,
                                                  children: u.myNumbers
                                                      .map(
                                                        (e) => Material(
                                                          color:
                                                              Colors.blue[300],
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                if (e != 0)
                                                                  Text(
                                                                    '$e'.padLeft(
                                                                        2, '0'),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  )
                                                                else
                                                                  const Text(
                                                                    'FREE',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                if (u.hitNumbers
                                                                    .contains(
                                                                        e))
                                                                  const Icon(
                                                                    Icons.star,
                                                                    color: Constants
                                                                        .secondlyColor,
                                                                    size: 48,
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Text(u.userId),
                            );
                          })
                        ],
                      ),
                    ),
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
