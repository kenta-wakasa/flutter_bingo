import 'package:bingo/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domains/bingo.dart';

class LotteryPage extends ConsumerStatefulWidget {
  const LotteryPage({
    super.key,
    required this.roomId,
    required this.userId,
  });
  final String userId;
  final String roomId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LotteryPageState();
}

class _LotteryPageState extends ConsumerState<LotteryPage> {
  String get userId => widget.userId;
  String get roomId => widget.roomId;

  Future<void> init() async {
    final ds = await ref
        .read(roomReferenceProvider(roomId))
        .collection('user')
        .doc(userId)
        .get();
    if (ds.exists) {
      return;
    }

    await ref
        .watch(roomReferenceProvider(roomId))
        .collection('user')
        .doc(userId)
        .set({
      'createdAt': FieldValue.serverTimestamp(),
      'myNumbers': BINGO.generateBingoNumbers(),
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(bingoUserProvider(userId));
    final bingoUser = asyncValue.value;
    if (bingoUser == null) {
      return const Scaffold();
    }
    final bingo = ref.watch(bingoProvider(bingoUser)).value;
    if (bingo == null) {
      return const Scaffold();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bingo.drawnNumbers.isNotEmpty)
                Column(
                  children: [
                    Text(
                      '${bingo.drawnNumbers.reversed.first}',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        children: [
                          ...bingo.drawnNumbers.reversed.map(
                            (e) => Text('$e'.padLeft(2, '0')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              SizedBox(
                height: 320,
                width: 320,
                child: GridView.count(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 5,
                  children: bingo.myNumbers
                      .map(
                        (e) => Container(
                          alignment: Alignment.center,
                          color: bingo.drawnNumbers.contains(e)
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
              if (bingo.checkBINGO())
                Column(
                  children: [
                    SizedBox(
                      width: 320,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          ref.read(roomReferenceProvider(roomId)).update(
                            {
                              'bingoUsers': FieldValue.arrayUnion([userId]),
                            },
                          );
                        },
                        child: FittedBox(
                          child: Text(
                            'BINGOを宣言',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
