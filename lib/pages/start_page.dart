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
    return Scaffold(
      body: Container(
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
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final roomId = await InputDialog.show(
                      context,
                      title: 'ルーム名を入力しましょう',
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
                      title: 'ルーム名を入力しましょう',
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
                      title: 'ユーザー名を入力しましょう',
                    );

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
    );
  }
}
