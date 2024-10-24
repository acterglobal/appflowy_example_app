import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/widgets/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppFlowy Editor Mention Example With Riverpod',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EditorPage(),
    );
  }
}

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageConsumerState();
}

class _EditorPageConsumerState extends ConsumerState<EditorPage> {
  EditorState editorState = EditorState.blank();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
                child: Text(
              'AppFlowy Editor Example App',
              style: Theme.of(context).textTheme.headlineLarge,
            )),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2.0)),
                  child: HtmlEditor(editorState: editorState, editable: true)),
            ),
          ],
        ),
      ),
    );
  }
}
