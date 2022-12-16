import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/input_dialog.dart';

class NewUserPage extends ConsumerStatefulWidget {
  const NewUserPage({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewUserPageState();
}

class _NewUserPageState extends ConsumerState<NewUserPage> {
  Future<void> init() async {
    var newUserId = '';
    await Future.delayed(const Duration(seconds: 1));
    while (newUserId.isEmpty) {
      newUserId = await InputDialog.show(
            context,
            title: '名前を入力しよう！',
            hintText: 'ユニークな名前にしよう！',
          ) ??
          '';
      if (newUserId.isEmpty) {
        continue;
      }
      context.go('/room/${widget.roomId}/user/$newUserId');
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
