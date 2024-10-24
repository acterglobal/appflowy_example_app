import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/vo/mention_state.dart';
import 'package:appflowy_example_app/widgets/mention_block.dart';
import 'package:appflowy_example_app/widgets/mention_content_block.dart';
import 'package:flutter/material.dart';

Node userMentionNode(String userId, String? displayName) {
  return paragraphNode(
    delta: Delta(
      operations: [
        TextInsert(
          '${MentionBlockKeys.userMentionChar}${displayName ?? userId}',
          attributes: {
            MentionBlockKeys.mention: {
              MentionBlockKeys.type: MentionType.user.name,
              MentionBlockKeys.userId: userId,
            },
          },
        ),
      ],
    ),
  );
}

class UserMentionBlock extends StatefulWidget {
  const UserMentionBlock({
    super.key,
    required this.editorState,
    required this.userId,
    required this.displayName,
    required this.blockId,
    required this.node,
    required this.textStyle,
    required this.index,
  });

  final EditorState editorState;
  final String userId;
  final String? displayName;
  final String? blockId;
  final Node node;
  final TextStyle? textStyle;
  final int index;

  @override
  State<UserMentionBlock> createState() => _UserMentionBlockState();
}

class _UserMentionBlockState extends State<UserMentionBlock> {
  void updateSelection() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.editorState
          .updateSelectionWithReason(widget.editorState.selection),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktopPlatforms = [
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ];

    final Widget content = desktopPlatforms.contains(Theme.of(context).platform)
        ? GestureDetector(
            onTap: _handleUserTap,
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: MentionContentWidget(
                  mentionId: widget.userId,
                  displayName: widget.displayName,
                  textStyle: widget.textStyle,
                  editorState: widget.editorState,
                  node: widget.node,
                  index: widget.index,
                )),
          )
        : GestureDetector(
            onTap: _handleUserTap,
            behavior: HitTestBehavior.opaque,
            child: MentionContentWidget(
              mentionId: widget.userId,
              displayName: widget.displayName,
              textStyle: widget.textStyle,
              editorState: widget.editorState,
              node: widget.node,
              index: widget.index,
            ),
          );
    return content;
  }

  void _handleUserTap() {
    // Implement user tap action (e.g., show profile, start chat)
  }
}
