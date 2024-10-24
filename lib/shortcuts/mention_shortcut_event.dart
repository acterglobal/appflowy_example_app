// import 'package:appflowy_editor/appflowy_editor.dart';
// import 'package:appflowy_example_app/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final mentionsShortcutEvent = CharacterShortcutEvent(
//   key: 'mentions',
//   character: '@',
//   handler: (editorState) async {
//     // Get the current selection
//     final selection = editorState.selection;
//     if (selection == null) return false;

//     // Get the current node
//     final node = editorState.getNodeAtPath(selection.end.path);
//     if (node == null) return false;

//     // Get the selection menu service
//     final selectionMenu = SelectionMenuService.of(editorState);
//     if (selectionMenu == null) return false;

//     // Show mentions menu
//     selectionMenu.showSelectionMenu(
//       selectionMenuItems: [
//         for (final mention in _mentions)
//           SelectionMenuItem(
//             name: mention['name']!,
//             icon: const Icon(Icons.person),
//             keywords: [mention['name']!, mention['id']!],
//             handler: (editorState, _, __) {
//               final transaction = editorState.transaction;
//               transaction.deleteText(node, selection.end.offset - 1, 1); // Delete '@'
//               transaction.insertText(
//                 node,
//                 selection.end.offset - 1,
//                 '${mention['name']} ',
//               );
//               editorState.apply(transaction);
//               return KeyEventResult.handled;
//             },
//           ),
//       ],
//     );

//     return KeyEventResult.handled;
//   },
// );


// Future<String?> _showMentionDialog(BuildContext context, WidgetRef ref) async {
//   final users = ref.read(usersProvider);
//   return showDialog<String>(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Mention a user'),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: users.length,
//           itemBuilder: (context, index) => ListTile(
//             title: Text(users[index]),
//             onTap: () => Navigator.of(context).pop(users[index]),
//           ),
//         ),
//       ),
//     ),
//   );
// }
