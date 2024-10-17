import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

CharacterShortcutEvent mentionShortcutEvent = CharacterShortcutEvent(
    key: 'User mention',
    character: '@',
    handler: (editorState) async {
      // final transaction = editorState.transaction;
      // final selection = editorState.selection;
      // if (selection == null || !selection.isCollapsed) {
      //   return false;
      // }
      // transaction.deleteText(selection.start, 1); // Delete the '@' character
      // await editorState.apply(transaction);

      // final user = await _showMentionDialog(editorState.document.root.context!,
      //     editorState.document.root.context!);
      // if (user != null) {
      //   final path = selection.start.path;
      //   final node = editorState.getNodeAtPath(path);
      //   if (node == null) false;

      //   final transaction = editorState.transaction;
      //   final delta = node?.delta;
      //   if (delta != null) {
      //     final index = selection.start.offset - 1;
      //     transaction.replaceText(node, index, length, text)
      //     transaction.updateText(
      //       node,
      //       Delta()
      //         ..insert(user, {
      //           'mention': {'type': 'user', 'id': user}
      //         }),
      //       selection.start.offset - 1,
      //     );
      //   }
      //   await editorState.apply(transaction);
      // }
      return true;
    });

Future<String?> _showMentionDialog(BuildContext context, WidgetRef ref) async {
  final users = ref.read(usersProvider);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Mention a user'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(users[index]),
            onTap: () => Navigator.of(context).pop(users[index]),
          ),
        ),
      ),
    ),
  );
}
