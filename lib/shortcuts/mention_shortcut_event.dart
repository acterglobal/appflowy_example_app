import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/vo/mention_data.dart';
import 'package:appflowy_example_app/widgets/mention_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const userMentionTrigger = '@';
const roomMentionTrigger = '#';

List<CharacterShortcutEvent> getMentionShortcuts(BuildContext context) {
  return [
    CharacterShortcutEvent(
      character: userMentionTrigger,
      handler: (editorState) => _handleMentionTrigger(
          context: context,
          editorState: editorState,
          triggerChar: userMentionTrigger),
      key: userMentionTrigger,
    ),
    CharacterShortcutEvent(
      character: roomMentionTrigger,
      handler: (editorState) => _handleMentionTrigger(
          context: context,
          editorState: editorState,
          triggerChar: roomMentionTrigger),
      key: roomMentionTrigger,
    ),
  ];
}

Future<bool> _handleMentionTrigger({
  required BuildContext context,
  required EditorState editorState,
  required String triggerChar,
}) async {
  final selection = editorState.selection;
  if (selection == null) return false;

  if (!selection.isCollapsed) {
    await editorState.deleteSelection(selection);
  }
  // Insert the trigger character
  await editorState.insertTextAtPosition(
    triggerChar,
    position: selection.start,
  );

  List<MentionItem> items = [];
  if (context.mounted) {
    final ref = ProviderScope.containerOf(context);
    // Get items (replace with your actual data fetching)
    if (triggerChar == '@') {
      items = await ref.read(mentionUsersProvider.future);
    }
    if (triggerChar == '#') {
      items = await ref.read(mentionRoomsProvider.future);
    }
  }
  // Show menu
  if (context.mounted) {
    final menu = MentionMenu(
        context: context,
        editorState: editorState,
        items: items,
        mentionTrigger: triggerChar,
        style: const MentionMenuStyle.dark());

    menu.show();
  }
  return true;
}
