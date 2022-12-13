import 'package:bingo/domains/bingo_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BINGOカードの番号を生成する関数のテスト', () {
    final numbers = BINGOUser.generateBingoNumbers();
    expect(numbers.length, 25);
    expect(numbers[12], 0);
  });
}
