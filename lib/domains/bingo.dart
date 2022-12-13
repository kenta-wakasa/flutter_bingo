import 'package:flutter/foundation.dart';

/// ここではBINGOのコア機能を記述する
class BINGO {
  BINGO({
    required this.myNumbers,
    required this.drawnNumbers,
  });

  /// 与えられた自身のビンゴカードに記された番号
  final List<int> myNumbers;

  /// 抽選機によって引かれた番号
  final List<int> drawnNumbers;

  /// BINGOをカードを生成する
  /// これは25個の数字の配列として表現できる
  static List<int> generateBingoNumbers() {
    /// まずは全部をシャッフルする
    _resourceB.shuffle();
    _resourceI.shuffle();
    _resourceN.shuffle();
    _resourceG.shuffle();
    _resource0.shuffle();

    final bingoNumbers = [
      ..._resourceB.sublist(0, 5),
      ..._resourceI.sublist(0, 5),
      ..._resourceN.sublist(0, 4),
      ..._resourceG.sublist(0, 5),
      ..._resource0.sublist(0, 5),
    ];

    /// 必ず中央は0にする
    bingoNumbers.insert(12, 0);
    return bingoNumbers;
  }

  /// BINGOかどうかをチェックする
  /// BINGOである列のindexのSetを返す
  List<Set<int>> checkBINGOLine() {
    /// まずはヒットしているindexの一覧が必要

    final hitIndexSet = <int>{};
    for (var index = 0; index < 25; index++) {
      if (drawnNumbers.contains(myNumbers[index])) {
        hitIndexSet.add(index);
      }
    }

    return bingoSetList
        .where((element) => hitIndexSet.containsAll(element))
        .toList();
  }

  /// BINGOかどうかをチェックする
  /// BINGOが成立していた場合trueを返す
  bool checkBINGO() {
    return checkBINGOLine().isNotEmpty;
  }

  // TODO(kenta-wakasa): リーチ判定
  // TODO(kenta-wakasa): ビンゴの列判定

  /// BINGOとなるindexの組み合わせ
  static final bingoSetList = [
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

  static final _resourceB = List.generate(15, (index) => index + 1);
  static final _resourceI = List.generate(15, (index) => index + 16);
  static final _resourceN = List.generate(15, (index) => index + 31);
  static final _resourceG = List.generate(15, (index) => index + 46);
  static final _resource0 = List.generate(15, (index) => index + 61);

  BINGO copyWith({
    List<int>? myNumbers,
    List<int>? drawnNumbers,
  }) {
    return BINGO(
      myNumbers: myNumbers ?? this.myNumbers,
      drawnNumbers: drawnNumbers ?? this.drawnNumbers,
    );
  }

  @override
  int get hashCode => myNumbers.hashCode ^ drawnNumbers.hashCode;

  @override
  bool operator ==(Object other) {
    return other is BINGO &&
        listEquals(myNumbers, other.myNumbers) &&
        listEquals(drawnNumbers, other.drawnNumbers);
  }
}
