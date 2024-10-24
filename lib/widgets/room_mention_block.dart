import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/vo/mention_state.dart';
import 'package:appflowy_example_app/widgets/mention_block.dart';
import 'package:appflowy_example_app/widgets/mention_content_block.dart';
import 'package:flutter/material.dart';

Node roomMentionNode(String roomId, String? displayName) {
  return paragraphNode(
    delta: Delta(
      operations: [
        TextInsert(
          '${MentionBlockKeys.roomMentionChar}${displayName ?? roomId}',
          attributes: {
            MentionBlockKeys.mention: {
              MentionBlockKeys.type: MentionType.room.name,
              MentionBlockKeys.roomId: roomId,
            },
          },
        ),
      ],
    ),
  );
}

class RoomMentionBlock extends StatefulWidget {
  const RoomMentionBlock({
    super.key,
    required this.editorState,
    required this.roomId,
    required this.displayName,
    required this.blockId,
    required this.node,
    required this.textStyle,
    required this.index,
  });

  final EditorState editorState;
  final String roomId;
  final String? displayName;
  final String? blockId;
  final Node node;
  final TextStyle? textStyle;
  final int index;

  @override
  State<RoomMentionBlock> createState() => _RoomMentionBlockState();
}

class _RoomMentionBlockState extends State<RoomMentionBlock> {
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
            onTap: _handleRoomTap,
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: MentionContentWidget(
                  mentionId: widget.roomId,
                  displayName: widget.displayName,
                  textStyle: widget.textStyle,
                  editorState: widget.editorState,
                  node: widget.node,
                  index: widget.index,
                )),
          )
        : GestureDetector(
            onTap: _handleRoomTap,
            behavior: HitTestBehavior.opaque,
            child: MentionContentWidget(
              mentionId: widget.roomId,
              displayName: widget.displayName,
              textStyle: widget.textStyle,
              editorState: widget.editorState,
              node: widget.node,
              index: widget.index,
            ),
          );
    return content;
  }

  void _handleRoomTap() async {}
}
