import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          pageBuilder: ((context, state) =>
              const NoTransitionPage(child: StartPage()))),
      GoRoute(
          path: '/room/:rid',
          pageBuilder: ((context, state) {
            return NoTransitionPage(
                child: RoomPage(roomId: state.params['rid']!));
          }),
          routes: [
            GoRoute(
              path: 'user/:uid',
              pageBuilder: ((context, state) {
                return NoTransitionPage(
                  child: LotteryPage(
                    roomId: state.params['rid']!,
                    userId: state.params['uid']!,
                  ),
                );
              }),
            ),
          ]),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.roomId});

  final String roomId;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('room')
              .doc(widget.roomId)
              .snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('このルームは存在しません'),
                    const SizedBox(height: 24),
                    ElevatedButton(
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
                        await FirebaseFirestore.instance
                            .collection('room')
                            .doc(roomId)
                            .set({
                          'randomNumbers': randomNumbers,
                          'createAt': FieldValue.serverTimestamp(),
                        });

                        if (!mounted) {
                          return;
                        }
                        context.go('/room/$roomId');
                      },
                      child: const Text('新しくルームを作る'),
                    ),
                  ],
                ),
              );
            }
            final randomNumbers = (data['randomNumbers'] as List? ?? [])
                .map((e) => e as int)
                .toList();
            final drawnNumbers = (data['drawnNumbers'] as List? ?? [])
                .map((e) => e as int)
                .toList();
            final bingoUsers = (data['bingoUsers'] as List? ?? [])
                .map((e) => e as String)
                .toList();
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    children: [
                      Text('ルーム名：${widget.roomId}'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (randomNumbers.isEmpty) {
                            return;
                          }
                          final number = randomNumbers.removeAt(0);
                          snapshot.data!.reference.update({
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
                            '${drawnNumbers.reversed.first}'.padLeft(2, '0'),
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
                            ...drawnNumbers.reversed.map(
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
                          ...bingoUsers.map((e) => Text(e)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('参加者'),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('room')
                            .doc(widget.roomId)
                            .collection('user')
                            .snapshots(),
                        builder: ((context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          return Wrap(
                            spacing: 12,
                            children: [
                              ...docs.map((e) => Text(e.id)),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(
                'BINGO',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(
                height: 64,
              ),
              ElevatedButton(
                onPressed: () async {
                  final roomId = await InputDialog.show(
                    context,
                    title: 'ルーム名を入力しましょう',
                  );
                  if (roomId?.isEmpty ?? true) {
                    return;
                  }

                  final randomNumbers = List.generate(75, (index) => index + 1)
                    ..shuffle();

                  /// ルームを作成する
                  // TODO(kenta-wakasa): IDが被っていた場合の処理
                  await FirebaseFirestore.instance
                      .collection('room')
                      .doc(roomId)
                      .set({
                    'randomNumbers': randomNumbers,
                    'drawnNumbers': [0],
                    'createAt': FieldValue.serverTimestamp(),
                  });

                  if (!mounted) {
                    return;
                  }
                  context.go('/room/$roomId');

                  /// 新規ルームを作る
                },
                child: const Text('新しくビンゴを始める'),
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () async {
                  final roomId = await InputDialog.show(
                    context,
                    title: 'ルーム名を入力しましょう',
                  );

                  if (roomId?.isEmpty ?? true) {
                    return;
                  }

                  // TODO(kenta-wakasa): そのルームが存在するかチェック
                  final snapshot = await FirebaseFirestore.instance
                      .collection('room')
                      .doc(roomId)
                      .get();

                  if (!snapshot.exists) {
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

                  if (!mounted) {
                    return;
                  }

                  final userId = await InputDialog.show(
                    context,
                    title: 'ユーザー名を入力しましょう',
                  );

                  if (userId?.isEmpty ?? true) {
                    return;
                  }

                  final userSnapshot = await FirebaseFirestore.instance
                      .collection('room')
                      .doc(roomId)
                      .collection('user')
                      .doc(userId)
                      .get();
                  if (userSnapshot.exists) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('「$userId」さんがすでにいました'),
                            content: const Text('もう一度ユーザー名を入力してください'),
                          );
                        });
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('room')
                      .doc(roomId)
                      .collection('user')
                      .doc(userId)
                      .set({
                    'createdAt': FieldValue.serverTimestamp(),
                    'myNumbers': generateBingoNumbers(),
                  });

                  if (!mounted) {
                    return;
                  }

                  context.go('/room/$roomId/user/$userId');
                },
                child: const Text('開催中のビンゴに参加する'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputDialog extends StatefulWidget {
  const InputDialog({super.key, required this.title});

  final String title;

  static Future<String?> show(BuildContext context,
      {required String title}) async {
    final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return InputDialog(title: title);
        });
    return result;
  }

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextFormField(
        autofocus: true,
        controller: controller,
        decoration: const InputDecoration(hintText: '簡単なワードにしましょう'),
        onFieldSubmitted: (text) {
          if (text.isEmpty) {
            Navigator.of(context).pop();
            return;
          }
          Navigator.of(context).pop(text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (controller.text.isEmpty) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pop(controller.text);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class LotteryPage extends StatefulWidget {
  const LotteryPage({
    super.key,
    required this.roomId,
    required this.userId,
  });

  final String userId;
  final String roomId;

  @override
  State<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage> {
  /// 抽選された番号
  final drawnNumbers = [0];

  /// 1~75までのランダムな番号
  final numberResource = List.generate(75, (index) => index + 1)..shuffle();

  /// 番号の抽選
  /// numberResourceの先頭からひとつ取り出し
  /// drawnNumbersの先頭に追加する
  void drawNumber() {
    if (numberResource.isEmpty) {
      return;
    }
    drawnNumbers.insert(0, numberResource.removeAt(0));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('room')
              .doc(widget.roomId)
              .collection('user')
              .doc(widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final data = snapshot.data?.data();

            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('「${widget.userId}」は存在しません'),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/');
                        },
                        child: const Text('あらためてユーザーをつくる'),
                      ),
                    ),
                  ],
                ),
              );
            }

            final myNumbers = (data['myNumbers'] as List? ?? [])
                .map((e) => e as int)
                .toList();

            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('room')
                    .doc(widget.roomId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();

                  if (data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final drawnNumbers = (data['drawnNumbers'] as List? ?? [])
                      .map((e) => e as int)
                      .toList();
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (drawnNumbers.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                '${drawnNumbers.first}',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  alignment: WrapAlignment.start,
                                  spacing: 8,
                                  children: [
                                    ...drawnNumbers.map(
                                      (e) => Text('$e'.padLeft(2, '0')),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 400,
                          child: GridView.count(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 5,
                            children: myNumbers
                                .map(
                                  (e) => Container(
                                    alignment: Alignment.center,
                                    color: drawnNumbers.contains(e)
                                        ? Colors.amber
                                        : Colors.blue[300],
                                    child: Text(
                                      '$e',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (checkBINGO(myNumbers, drawnNumbers))
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  FirebaseFirestore.instance
                                      .collection('room')
                                      .doc(widget.roomId)
                                      .update({
                                    'bingoUsers':
                                        FieldValue.arrayUnion([widget.userId]),
                                  });
                                },
                                child: Text(
                                  'BINGOを宣言',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                });
          }),
    );
  }
}

/// BINGOをカードを生成する
/// これは25個の数字の配列として表現できる
List<int> generateBingoNumbers() {
  /// まずは全部をシャッフルする
  resourceB.shuffle();
  resourceI.shuffle();
  resourceN.shuffle();
  resourceG.shuffle();
  resource0.shuffle();

  final bingoNumbers = [
    ...resourceB.sublist(0, 5),
    ...resourceI.sublist(0, 5),
    ...resourceN.sublist(0, 4),
    ...resourceG.sublist(0, 5),
    ...resource0.sublist(0, 5),
  ];

  /// 必ず中央は0になる
  bingoNumbers.insert(12, 0);
  return bingoNumbers;
}

/// BINGOかどうかをチェックする
bool checkBINGO(List<int> myNumbers, List<int> drawnNumbers) {
  final bingoSetList = [
    /// たてが揃うindexのパターン
    {0, 1, 2, 3, 4},
    {5, 6, 7, 8, 9},
    {10, 11, 12, 13, 14},
    {15, 16, 17, 18, 19},
    {20, 21, 22, 23, 24},

    /// よこが揃うindexのパターン
    {0, 5, 10, 15, 20},
    {1, 6, 11, 16, 21},
    {2, 7, 12, 17, 22},
    {3, 8, 13, 18, 23},
    {4, 9, 14, 19, 24},

    /// ななめが揃うindexのパターン
    {0, 6, 12, 18, 24},
    {4, 8, 12, 16, 20},
  ];

  /// まずはヒットしているindexの一覧が必要

  final hitIndexSet = <int>{};
  for (var index = 0; index < 24; index++) {
    if (drawnNumbers.contains(myNumbers[index])) {
      hitIndexSet.add(index);
    }
  }

  return bingoSetList
      .where((element) => hitIndexSet.containsAll(element))
      .isNotEmpty;
}

final resourceB = List.generate(15, (index) => index + 1);
final resourceI = List.generate(15, (index) => index + 16);
final resourceN = List.generate(15, (index) => index + 31);
final resourceG = List.generate(15, (index) => index + 46);
final resource0 = List.generate(15, (index) => index + 61);
