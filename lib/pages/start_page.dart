import 'dart:math';

import 'package:bingo/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/input_dialog.dart';

class StartPage extends ConsumerWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = List.generate(100, (_) {
      final random = Random();
      final xPos = (random.nextDouble() * 2) - 1;
      final yPos = (random.nextDouble() * 2) - 1;
      final size = 10 + (random.nextInt(10) * 3);
      final angle = random.nextDouble() * 2;
      return Align(
        alignment: Alignment(xPos, yPos),
        child: Transform.rotate(
          angle: pi * angle,
          child: Icon(
            Icons.ac_unit_rounded,
            size: size.toDouble(),
            color: Colors.white,
          ),
        ),
      );
    });
    return Scaffold(
      body: Stack(
        children: [
          ...circles,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
                minWidth: 320,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  FittedBox(
                    child: Text(
                      'BINGO',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        shadows: [
                          const Shadow(
                              // bottomLeft
                              offset: Offset(-1.5, -1.5),
                              color: Colors.white),
                          const Shadow(
                              // bottomRight
                              offset: Offset(1.5, -1.5),
                              color: Colors.white),
                          const Shadow(
                              // topRight
                              offset: Offset(1.5, 1.5),
                              color: Colors.white),
                          const Shadow(
                              // topLeft
                              offset: Offset(-1.5, 1.5),
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final roomId = await InputDialog.show(
                          context,
                          title: 'ルーム名を入力しよう！',
                          hintText: '簡単なワードにしよう',
                        );
                        if (roomId?.isEmpty ?? true) {
                          return;
                        }

                        final randomNumbers =
                            List.generate(75, (index) => index + 1)..shuffle();

                        /// ルームを作成する
                        // TODO(kenta-wakasa): IDが被っていた場合の処理

                        final roomExits =
                            await ref.watch(roomExistsProvider(roomId!).future);

                        if (roomExits) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('「$roomId」はすでに存在しています'),
                                content: const Text('別のIDをお試しください'),
                              );
                            },
                          );
                          return;
                        }

                        ref.watch(roomReferenceProvider(roomId)).set({
                          'randomNumbers': randomNumbers,
                          'drawnNumbers': [0],
                          'createAt': FieldValue.serverTimestamp(),
                        });

                        context.go('/room/$roomId');

                        /// 新規ルームを作る
                      },
                      child: const Text('新しくはじめる'),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final roomId = await InputDialog.show(
                          context,
                          title: 'ルーム名を入力しよう！',
                          hintText: '主催者に確認しよう',
                        );

                        if (roomId?.isEmpty ?? true) {
                          return;
                        }

                        // TODO(kenta-wakasa): そのルームが存在するかチェック
                        final roomExists =
                            await ref.watch(roomExistsProvider(roomId!).future);

                        if (!roomExists) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('「$roomId」が見つかりませんでした'),
                                content: const Text('ルーム名が間違っていませんか？'),
                              );
                            },
                          );
                          return;
                        }

                        final userId = await InputDialog.show(
                          context,
                          title: '名前を入力しよう！',
                          hintText: 'ユニークな名前にしよう！',
                        );

                        if (userId?.isEmpty ?? true) {
                          return;
                        }

                        context.go('/room/$roomId/user/$userId');
                      },
                      child: const Text('開催中のBINGOに参加する'),
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
