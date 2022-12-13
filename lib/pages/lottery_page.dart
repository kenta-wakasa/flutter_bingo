import 'dart:developer' as dev;
import 'dart:math';

import 'package:bingo/constants/constants.dart';
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 320,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.start,
                            spacing: 4,
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
                    width: 320,
                    height: 320,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      children: [
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
                        ...bingo.checkBINGOLine().map((sets) {
                          final Alignment alignment;
                          final double angle;
                          double scale = 1;
                          double thickness = 8;
                          dev.log(sets.toList().toString());
                          switch (BINGO.bingoSetList.indexOf(sets)) {
                            case 0:
                              alignment = const Alignment(0, 0.8);
                              angle = pi / 2;
                              break;
                            case 1:
                              alignment = const Alignment(0, 0.4);
                              angle = pi / 2;
                              break;
                            case 2:
                              alignment = const Alignment(0, 0);
                              angle = pi / 2;
                              break;
                            case 3:
                              alignment = const Alignment(0, -0.4);
                              angle = pi / 2;
                              break;
                            case 4:
                              alignment = const Alignment(0, -0.8);
                              angle = pi / 2;
                              break;
                            case 5:
                              alignment = const Alignment(0, -.8);
                              angle = 0;
                              break;
                            case 6:
                              alignment = const Alignment(0, -.4);
                              angle = 0;
                              break;
                            case 7:
                              alignment = const Alignment(0, 0);
                              angle = 0;
                              break;
                            case 8:
                              alignment = const Alignment(0, .4);
                              angle = 0;
                              break;
                            case 9:
                              alignment = const Alignment(0, .8);
                              angle = 0;
                              break;
                            case 10:
                              alignment = const Alignment(0, 0);
                              angle = pi / 4;
                              scale = 1.414;
                              thickness = thickness / scale;
                              break;
                            case 11:
                              alignment = const Alignment(0, 0);
                              angle = -pi / 4;
                              scale = 1.414;
                              thickness = thickness / scale;
                              break;
                            default:
                              alignment = const Alignment(0, 0);
                              angle = 0;
                          }
                          return Transform.scale(
                            scale: scale,
                            child: Transform.rotate(
                              angle: angle,
                              child: Align(
                                alignment: alignment,
                                child: Container(
                                  width: double.infinity,
                                  height: thickness,
                                  color: Constants.accentColor.withOpacity(0.8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (bingo.checkBINGO() &&
              ref
                      .watch(roomProvider(roomId))
                      .value
                      ?.bingoUsers
                      .contains(userId) ==
                  false)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: SizedBox(
                width: 340,
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
            ),
        ],
      ),
    );
  }
}
