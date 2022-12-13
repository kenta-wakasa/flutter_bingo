import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({
    super.key,
    required this.title,
    required this.hintText,
  });

  final String title;
  final String hintText;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hintText,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return InputDialog(
          title: title,
          hintText: hintText,
        );
      },
    );
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
        decoration: InputDecoration(
          hintText: widget.hintText,
        ),
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
