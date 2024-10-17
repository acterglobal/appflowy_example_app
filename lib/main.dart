import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_example_app/shortcuts/mention_shortcut_event.dart';
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

// Riverpod provider for users
final usersProvider = Provider<List<String>>(
    (ref) => ['Alice', 'Bob', 'Charlie', 'David', 'Eve']);

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageConsumerState();
}

class _EditorPageConsumerState extends ConsumerState<EditorPage> {
  EditorState editorState = EditorState.blank();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppFlowy Editor with Mentions')),
      body: AppFlowyEditor(
        editorState: editorState,
        characterShortcutEvents: [
          mentionShortcutEvent,
        ],
      ),
    );
  }
}
