import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/vo/mention_data.dart';
import 'package:appflowy_example_app/widgets/mention_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double kMentionMenuHeight = 300;
const double kMentionMenuWidth = 250;
const double kContentHeight = 260;
const double kItemHeight = 50;

final mentionUsersProvider = FutureProvider<List<MentionItem>>((ref) async {
  final users = <MentionItem>[];
  final userData = await MentionDataService.fetchUsers();
  for (final userId in userData.keys) {
    users.add(MentionItem(
      id: userId,
      displayName: userData[userId]?['displayName'] as String,
    ));
  }
  return users;
});

final mentionRoomsProvider = FutureProvider<List<MentionItem>>((ref) async {
  final rooms = <MentionItem>[];
  final roomData = await MentionDataService.fetchRooms();
  for (final roomId in roomData.keys) {
    rooms.add(MentionItem(
      id: roomId,
      displayName: roomData[roomId]?['displayName'] as String,
    ));
  }
  return rooms;
});

class MentionItem {
  final String id;
  final String displayName;

  MentionItem({
    required this.id,
    required this.displayName,
  });
}

class MentionMenuService {
  OverlayEntry? _overlayEntry;

  void showMenu({
    required BuildContext context,
    required EditorState editorState,
    required String mentionTrigger,
    required List<MentionItem> items,
  }) {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 50,
        child: MentionHandler(
          editorState: editorState,
          onDismiss: () => _overlayEntry?.remove(),
          onSelectionUpdate: () {
            // Handle selection updates
          },
          mentionTrigger: mentionTrigger,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

class MentionHandler extends ConsumerStatefulWidget {
  const MentionHandler({
    super.key,
    required this.editorState,
    required this.mentionTrigger,
    required this.onDismiss,
    required this.onSelectionUpdate,
  });

  final EditorState editorState;
  final String mentionTrigger;
  final VoidCallback onDismiss;
  final VoidCallback onSelectionUpdate;

  @override
  ConsumerState<MentionHandler> createState() => _MentionHandlerState();
}

class _MentionHandlerState extends ConsumerState<MentionHandler> {
  final _focusNode = FocusNode(debugLabel: 'mention_handler');
  final _scrollController = ScrollController();

  late List<MentionItem> items = [];
  String _search = '';
  int _selectedIndex = 0;
  late int startOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _loadInitialData();
    });

    startOffset = widget.editorState.selection?.endIndex ?? 0;
  }

  Future<void> _loadInitialData() async {
    // Load initial items based on type
    List<MentionItem> data = [];
    switch (widget.mentionTrigger) {
      case '@':
        data = await ref.read(mentionUsersProvider.future);
        break;
      case '#':
        data = await ref.read(mentionRoomsProvider.future);
        break;
      default:
        break;
    }

    setState(() {
      items = data;
    });
  }

  void _filterItems(String search) {
    _search = search.toLowerCase();

    final filteredItems = items
        .where((entry) =>
            entry.id.toLowerCase().contains(_search) ||
            (entry.displayName).toLowerCase().contains(_search))
        .map((entry) => MentionItem(
              id: entry.id,
              displayName: entry.displayName,
            ))
        .toList();

    setState(() {
      items = filteredItems;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: kMentionMenuHeight,
          maxWidth: kMentionMenuWidth,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _MentionItem(
              item: item,
              isSelected: index == _selectedIndex,
              onTap: () => _selectItem(item),
            );
          },
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onDismiss();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.enter:
        if (items.isNotEmpty) {
          _selectItem(items[_selectedIndex]);
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowUp:
        setState(() {
          _selectedIndex = (_selectedIndex - 1).clamp(0, items.length - 1);
        });
        _scrollToSelected();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowDown:
        setState(() {
          _selectedIndex = (_selectedIndex + 1).clamp(0, items.length - 1);
        });
        _scrollToSelected();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.backspace:
        if (_search.isEmpty) {
          widget.editorState.deleteBackward();
          widget.onDismiss();
        } else {
          widget.onSelectionUpdate();
          widget.editorState.deleteBackward();
          _updateSearch();
        }
        return KeyEventResult.handled;

      default:
        // if (event.character != null &&
        //     !event. &&
        //     !event.isMetaPressed) {
        //   widget.onSelectionUpdate();
        //   widget.editorState.insertTextAtCurrentSelection(event.character!);
        //   _updateSearch();
        //   return KeyEventResult.handled;
        // }
        return KeyEventResult.ignored;
    }
  }

  void _updateSearch() {
    final selection = widget.editorState.selection;
    if (selection == null) return;

    final node = widget.editorState.getNodeAtPath(selection.end.path);
    if (node == null) return;

    final text = node.delta?.toPlainText() ?? '';
    if (text.length < startOffset) return;

    final search = text.substring(startOffset);
    _filterItems(search);
  }

  void _selectItem(MentionItem item) {
    final selection = widget.editorState.selection;
    if (selection == null) return;

    final transaction = widget.editorState.transaction;
    final node = widget.editorState.getNodeAtPath(selection.end.path);
    if (node == null) return;

    // Delete the search text and trigger character
    transaction.deleteText(
      node,
      startOffset - 1,
      selection.end.offset - startOffset + 1,
    );

    // Insert the mention
    transaction.insertText(
      node,
      startOffset - 1,
      item.displayName,
      attributes: {
        MentionBlockKeys.mention: {
          MentionBlockKeys.type: widget.mentionTrigger == '@'
              ? MentionType.user.name
              : MentionType.room.name,
          if (widget.mentionTrigger == '@')
            MentionBlockKeys.userId: item.id
          else
            MentionBlockKeys.roomId: item.id,
        },
      },
    );

    widget.editorState.apply(transaction);
    widget.onDismiss();
  }

  void _scrollToSelected() {
    final itemPosition = _selectedIndex * kItemHeight;
    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;

    if (itemPosition < scrollOffset) {
      _scrollController.animateTo(
        itemPosition,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else if (itemPosition + kItemHeight > scrollOffset + viewportHeight) {
      _scrollController.animateTo(
        itemPosition + kItemHeight - viewportHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _MentionItem extends StatelessWidget {
  const _MentionItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final MentionItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          height: kItemHeight,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.id,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
