import 'dart:developer' as dev;
import 'dart:math';

import 'package:bingo/constants/constants.dart';
import 'package:bingo/domains/bingo_user.dart';
import 'package:bingo/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  DocumentReference get userRef =>
      ref.read(roomReferenceProvider(roomId)).collection('user').doc(userId);

  Future<void> init() async {
    final ds = await userRef.get();
    if (ds.exists) {
      return;
    }

    await userRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'myNumbers': BINGOUser.generateBingoNumbers(),
      'hitNumbers': [],
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
    final bingoUser = ref.watch(bingoUserProvider(userId)).value;
    final room = ref.watch(roomProvider(roomId)).value;
    if (bingoUser == null || room == null) {
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
                  if (room.drawnNumbers.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          '${room.drawnNumbers.reversed.first}',
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
                              ...room.drawnNumbers.reversed.map(
                                (e) {
                                  if (e == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    '$e'.padLeft(2, '0'),
                                  );
                                },
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
                            children: bingoUser.myNumbers
                                .map(
                                  (e) => Material(
                                    color: Colors.blue[300],
                                    child: InkWell(
                                      onTap: (room.drawnNumbers.contains(e) &&
                                              !bingoUser.hitNumbers.contains(e))
                                          ? () {
                                              userRef.update({
                                                'hitNumbers':
                                                    FieldValue.arrayUnion([e]),
                                              });
                                            }
                                          : null,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (e != 0)
                                              Text(
                                                '$e'.padLeft(2, '0'),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                            else
                                              const Text(
                                                'FREE',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            if (bingoUser.hitNumbers
                                                .contains(e))
                                              const Icon(
                                                Icons.star,
                                                color: Constants.secondlyColor,
                                                size: 48,
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        ...bingoUser.checkBINGOLine().map((sets) {
                          final Alignment alignment;
                          final double angle;
                          double scale = 1;
                          double thickness = 8;
                          dev.log(sets.toList().toString());
                          switch (BINGOUser.bingoSetList.indexOf(sets)) {
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
          if (bingoUser.checkBINGO() &&
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
