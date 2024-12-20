import 'package:appflowy_example_app/vo/mention_data.dart';
import 'package:appflowy_example_app/widgets/mention_block.dart';
import 'package:appflowy_example_app/widgets/mention_menu_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double kMentionMenuHeight = 300;
const double kMentionMenuWidth = 250;
const double kItemHeight = 60;
const double kContentHeight = 260;

class MentionHandler extends ConsumerStatefulWidget {
  const MentionHandler({
    super.key,
    required this.editorState,
    required this.items,
    required this.mentionTrigger,
    required this.onDismiss,
    required this.onSelectionUpdate,
    required this.style,
  });

  final EditorState editorState;
  final List<MentionItem> items;
  final String mentionTrigger;
  final VoidCallback onDismiss;
  final VoidCallback onSelectionUpdate;
  final MentionMenuStyle style;

  @override
  ConsumerState<MentionHandler> createState() => _MentionHandlerState();
}

class _MentionHandlerState extends ConsumerState<MentionHandler> {
  final _focusNode = FocusNode(debugLabel: 'mention_handler');
  final _scrollController = ScrollController();

  late List<MentionItem> filteredItems = widget.items;
  int _selectedIndex = 0;
  late int startOffset;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    startOffset = widget.editorState.selection?.endIndex ?? 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
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
          color: widget.style.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.mentionTrigger == '@' ? 'Users' : 'Rooms',
                style: TextStyle(
                  color: widget.style.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No results found',
                        style: TextStyle(color: widget.style.hintColor),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) => _MentionListItem(
                        item: filteredItems[index],
                        isSelected: index == _selectedIndex,
                        style: widget.style,
                        onTap: () => _selectItem(filteredItems[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onDismiss();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.enter:
        if (filteredItems.isNotEmpty) {
          _selectItem(filteredItems[_selectedIndex]);
        }
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowUp:
        setState(() {
          _selectedIndex =
              (_selectedIndex - 1).clamp(0, filteredItems.length - 1);
        });
        _scrollToSelected();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.arrowDown:
        setState(() {
          _selectedIndex =
              (_selectedIndex + 1).clamp(0, filteredItems.length - 1);
        });
        _scrollToSelected();
        return KeyEventResult.handled;

      case LogicalKeyboardKey.backspace:
        if (_search.isEmpty) {
          if (_canDeleteLastCharacter()) {
            widget.editorState.deleteBackward();
          } else {
            // Workaround for editor regaining focus
            widget.editorState.apply(
              widget.editorState.transaction
                ..afterSelection = widget.editorState.selection,
            );
          }
          widget.onDismiss();
        } else {
          widget.onSelectionUpdate();
          widget.editorState.deleteBackward();
          _deleteCharacterAtSelection();
        }

        return KeyEventResult.handled;

      default:
        if (event.character != null &&
            !HardwareKeyboard.instance.isControlPressed &&
            !HardwareKeyboard.instance.isMetaPressed &&
            !HardwareKeyboard.instance.isAltPressed) {
          widget.onSelectionUpdate();
          widget.editorState.insertTextAtCurrentSelection(event.character!);
          _updateSearch();
          return KeyEventResult.handled;
        }
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

    _search = text.substring(startOffset);
    _filterItems(_search);
  }

  void _filterItems(String search) {
    final searchLower = search.toLowerCase();
    setState(() {
      filteredItems = widget.items
          .where((item) =>
              item.id.toLowerCase().contains(searchLower) ||
              item.displayName.toLowerCase().contains(searchLower))
          .toList();
      _selectedIndex = 0;
    });
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
    if (itemPosition < _scrollController.offset) {
      _scrollController.animateTo(
        itemPosition,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else if (itemPosition + kItemHeight >
        _scrollController.offset +
            _scrollController.position.viewportDimension) {
      _scrollController.animateTo(
        itemPosition +
            kItemHeight -
            _scrollController.position.viewportDimension,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteCharacterAtSelection() {
    final selection = widget.editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }

    final node = widget.editorState.getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }

    _search = delta.toPlainText().substring(
          startOffset,
          startOffset - 1 + _search.length,
        );
  }

  bool _canDeleteLastCharacter() {
    final selection = widget.editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return false;
    }

    final delta = widget.editorState.getNodeAtPath(selection.start.path)?.delta;
    if (delta == null) {
      return false;
    }

    return delta.isNotEmpty;
  }
}

class _MentionListItem extends StatelessWidget {
  const _MentionListItem({
    required this.item,
    required this.isSelected,
    required this.style,
    required this.onTap,
  });

  final MentionItem item;
  final bool isSelected;
  final MentionMenuStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: kItemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? style.selectedColor : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.displayName,
              style: TextStyle(
                color: isSelected ? style.selectedTextColor : style.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              item.id,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? style.selectedTextColor.withOpacity(0.7)
                    : style.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
