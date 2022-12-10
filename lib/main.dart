import 'package:flutter/material.dart';

void main() {
  generateBingoNumbers();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LotteryPage(),
    );
  }
}

class LotteryPage extends StatefulWidget {
  const LotteryPage({super.key});

  @override
  State<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage> {
  @override
  Widget build(BuildContext context) {
    /// B:01~15
    /// I:16~30
    /// N:31~45
    /// G:46~60
    /// O:61~75
    return Scaffold(
      appBar: AppBar(
        title: const Text('BINGO'),
      ),
      body: Center(
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          children: [
            for (var index = 0; index < 25; index++)
              Center(child: Text('$index')),
          ],
        ),
      ),
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

final resourceB = List.generate(15, (index) => index + 1);
final resourceI = List.generate(15, (index) => index + 16);
final resourceN = List.generate(15, (index) => index + 31);
final resourceG = List.generate(15, (index) => index + 46);
final resource0 = List.generate(15, (index) => index + 61);
