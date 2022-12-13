import 'package:flutter/material.dart';

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
