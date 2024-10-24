import 'dart:async';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/utils.dart';
import 'package:appflowy_example_app/vo/mention_state.dart';
import 'package:appflowy_example_app/widgets/mention_block.dart';
import 'package:flutter/material.dart';

AppFlowyEditorHTMLCodec defaultHtmlCodec = const AppFlowyEditorHTMLCodec(
  encodeParsers: [
    HTMLTextNodeParser(),
    HTMLBulletedListNodeParser(),
    HTMLNumberedListNodeParser(),
    HTMLTodoListNodeParser(),
    HTMLQuoteNodeParser(),
    HTMLHeadingNodeParser(),
    HtmlTableNodeParser(),
  ],
);
AppFlowyEditorMarkdownCodec defaultMarkdownCodec =
    const AppFlowyEditorMarkdownCodec(
  encodeParsers: [
    TextNodeParser(),
    BulletedListNodeParser(),
    NumberedListNodeParser(),
    TodoListNodeParser(),
    QuoteNodeParser(),
    CodeBlockNodeParser(),
    HeadingNodeParser(),
    ImageNodeParser(),
    TableNodeParser(),
  ],
);

extension ActerEditorStateHelpers on EditorState {
  String intoHtml({
    AppFlowyEditorHTMLCodec? codec,
  }) {
    return (codec ?? defaultHtmlCodec).encode(document);
  }

  String intoMarkdown({
    AppFlowyEditorMarkdownCodec? codec,
  }) {
    return (codec ?? defaultMarkdownCodec).encode(document);
  }
}

extension ActerDocumentHelpers on Document {
  static Document? _fromHtml(
    String content, {
    AppFlowyEditorHTMLCodec? codec,
  }) {
    if (content.isEmpty) {
      return null;
    }

    Document document = (codec ?? defaultHtmlCodec).decode(content);
    if (document.isEmpty) {
      return null;
    }
    return document;
  }

  static Document _fromMarkdown(
    String content, {
    AppFlowyEditorMarkdownCodec? codec,
  }) {
    return (codec ?? defaultMarkdownCodec).decode(content);
  }

  static Document parse(
    String content, {
    String? htmlContent,
    AppFlowyEditorMarkdownCodec? codec,
  }) {
    if (htmlContent != null) {
      final document = ActerDocumentHelpers._fromHtml(htmlContent);
      if (document != null) {
        return document;
      }
    }
    // fallback: parse from markdown
    return ActerDocumentHelpers._fromMarkdown(content);
  }

  // static Document fromMsgContent(MsgContent msgContent) {
  //   return ActerDocumentHelpers.parse(
  //     msgContent.body(),
  //     htmlContent: msgContent.formattedBody(),
  //   );
  // }
}

typedef ExportCallback = Function(String, String?);

class HtmlEditor extends StatefulWidget {
  static const saveEditKey = Key('html-editor-save');
  static const cancelEditKey = Key('html-editor-cancel');

  final Widget? header;
  final Widget? footer;
  final bool autoFocus;
  final bool editable;
  final bool shrinkWrap;
  final EditorState? editorState;
  final EdgeInsets? editorPadding;
  final TextStyleConfiguration? textStyleConfiguration;
  final ExportCallback? onSave;
  final ExportCallback? onChanged;
  final Function()? onCancel;
  const HtmlEditor({
    super.key,
    this.editorState,
    this.onSave,
    this.onChanged,
    this.onCancel,
    this.textStyleConfiguration,
    this.autoFocus = true,
    this.editable = false,
    this.shrinkWrap = false,
    this.editorPadding = const EdgeInsets.all(10),
    this.header,
    this.footer,
  });

  @override
  HtmlEditorState createState() => HtmlEditorState();
}

class HtmlEditorState extends State<HtmlEditor> {
  final desktopPlatforms = [
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows
  ];
  late EditorState editorState;
  late EditorScrollController editorScrollController;
  final TextDirection _textDirection = TextDirection.ltr;
  // we store this to the stream stays alive
  StreamSubscription<(TransactionTime, Transaction)>? _changeListener;

  @override
  void initState() {
    super.initState();
    updateEditorState(widget.editorState ?? EditorState.blank());
  }

  void updateEditorState(EditorState newEditorState) {
    setState(() {
      editorState = newEditorState;

      if (widget.editable && widget.autoFocus) {
        editorState.updateSelectionWithReason(
          Selection.single(
            path: [0],
            startOffset: 0,
          ),
          reason: SelectionUpdateReason.uiEvent,
        );
      }

      editorScrollController = EditorScrollController(
        editorState: editorState,
        shrinkWrap: widget.shrinkWrap,
      );

      _changeListener?.cancel();
      widget.onChanged?.map((cb) {
        _changeListener = editorState.transactionStream.listen(
          (data) => _triggerExport(cb),
          onError: (e, s) {
            throw ('tx stream errored', e, s);
          },
          onDone: () {
            throw 'tx stream ended';
          },
        );
      });
    });
  }

  @override
  void didUpdateWidget(covariant HtmlEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editorState != widget.editorState) {
      updateEditorState(widget.editorState ?? EditorState.blank());
    }
  }

  @override
  void dispose() {
    editorScrollController.dispose();
    super.dispose();
  }

  void _triggerExport(ExportCallback exportFn) {
    final plain = editorState.intoMarkdown();
    final htmlBody = editorState.intoHtml();
    exportFn(plain, htmlBody != plain ? htmlBody : null);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = desktopPlatforms.contains(Theme.of(context).platform);
    return isDesktop ? desktopEditor() : mobileEditor();
  }

  Widget? generateFooter() {
    if (widget.footer != null) {
      return widget.footer;
    }
    final List<Widget> children = [];

    if (widget.onCancel != null) {
      children.add(
        OutlinedButton(
          key: HtmlEditor.cancelEditKey,
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
      );
    }
    children.add(
      const SizedBox(
        width: 10,
      ),
    );
    widget.onSave?.map((cb) {
      children.add(
        ElevatedButton(
          key: HtmlEditor.saveEditKey,
          onPressed: () => _triggerExport(cb),
          child: const Text('Save'),
        ),
      );
    });

    if (children.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children,
        ),
      );
    }
    return null;
  }

  Widget desktopEditor() {
    return FloatingToolbar(
      items: [
        paragraphItem,
        ...headingItems,
        ...markdownFormatItems,
        quoteItem,
        bulletedListItem,
        numberedListItem,
        linkItem,
        buildHighlightColorItem(),
      ],
      textDirection: _textDirection,
      editorState: editorState,
      editorScrollController: editorScrollController,
      style: FloatingToolbarStyle(
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarActiveColor: Theme.of(context).colorScheme.tertiary,
      ),
      child: Directionality(
        textDirection: _textDirection,
        child: AppFlowyEditor(
          // widget pass through
          editable: widget.editable,
          shrinkWrap: widget.shrinkWrap,
          autoFocus: widget.autoFocus,
          header: widget.header,
          // local states
          editorScrollController: editorScrollController,
          editorState: editorState,
          editorStyle: desktopEditorStyle(),
          footer: generateFooter(),
        ),
      ),
    );
  }

  Widget mobileEditor() {
    return MobileToolbarV2(
      toolbarItems: [
        textDecorationMobileToolbarItemV2,
        buildTextAndBackgroundColorMobileToolbarItem(
          textColorOptions: [],
        ),
        headingMobileToolbarItem,
        listMobileToolbarItem,
        linkMobileToolbarItem,
        quoteMobileToolbarItem,
      ],
      editorState: editorState,
      child: MobileFloatingToolbar(
        editorScrollController: editorScrollController,
        editorState: editorState,
        toolbarBuilder: (context, anchor, closeToolbar) {
          return AdaptiveTextSelectionToolbar.editable(
            clipboardStatus: ClipboardStatus.pasteable,
            onCopy: () {
              copyCommand.execute(editorState);
              closeToolbar();
            },
            onCut: () => cutCommand.execute(editorState),
            onPaste: () => pasteCommand.execute(editorState),
            onSelectAll: () => selectAllCommand.execute(editorState),
            onLiveTextInput: null,
            onLookUp: null,
            onSearchWeb: null,
            onShare: null,
            anchors: TextSelectionToolbarAnchors(
              primaryAnchor: anchor,
            ),
          );
        },
        child: AppFlowyEditor(
          // widget pass through
          editable: widget.editable,
          shrinkWrap: widget.shrinkWrap,
          autoFocus: widget.autoFocus,
          header: widget.header,
          // local states
          editorState: editorState,
          editorScrollController: editorScrollController,
          editorStyle: mobileEditorStyle(),
          footer: generateFooter(),
        ),
      ),
    );
  }

  EditorStyle desktopEditorStyle() {
    return EditorStyle.desktop(
      padding: widget.editorPadding,
      cursorColor: Theme.of(context).colorScheme.primary,
      selectionColor: Theme.of(context).colorScheme.secondaryContainer,
      textStyleConfiguration: widget.textStyleConfiguration ??
          TextStyleConfiguration(
            text: Theme.of(context).textTheme.bodySmall!,
          ),
      textSpanDecorator: customizeAttributeDecorator,
    );
  }

  EditorStyle mobileEditorStyle() {
    return EditorStyle.mobile(
      padding: widget.editorPadding,
      cursorColor: Theme.of(context).colorScheme.primary,
      selectionColor: Theme.of(context).colorScheme.secondaryContainer,
      textStyleConfiguration: widget.textStyleConfiguration ??
          TextStyleConfiguration(
            text: Theme.of(context).textTheme.bodySmall!,
          ),
      textSpanDecorator: customizeAttributeDecorator,
    );
  }

  InlineSpan customizeAttributeDecorator(
    BuildContext context,
    Node node,
    int index,
    TextInsert text,
    TextSpan before,
    TextSpan after,
  ) {
    final attributes = text.attributes;
    if (attributes == null) {
      return before;
    }

    if (attributes.backgroundColor != null) {
      const color = Colors.green;

      return TextSpan(
        text: before.text,
        style: after.style?.merge(
          const TextStyle(backgroundColor: color),
        ),
      );
    }

    // Inline Mentions (User, Room)
    final mention =
        attributes[MentionBlockKeys.mention] as Map<String, dynamic>?;
    if (mention != null) {
      final type = mention[MentionBlockKeys.type];
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        style: after.style,
        child: MentionBlock(
          key: ValueKey(
            switch (type) {
              MentionType.user => mention[MentionBlockKeys.userId],
              MentionType.room => mention[MentionBlockKeys.roomId],
              _ => MentionBlockKeys.mention,
            },
          ),
          node: node,
          index: index,
          mention: mention,
          editorState: editorState,
          textStyle: after.style,
        ),
      );
    }

    return defaultTextSpanDecoratorForAttribute(
      context,
      node,
      index,
      text,
      before,
      after,
    );
  }
}