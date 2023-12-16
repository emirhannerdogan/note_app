import 'package:flutter/material.dart';
import 'package:note_app/note_storage.dart';
import 'package:note_app/note.dart';
import 'package:note_app/note_detail_page.dart';
import 'package:note_app/add_note_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NotezApp',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late List<Note> notes;

  @override
  void initState() {
    super.initState();
    notes = [];
    _loadNotes();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadNotes();
    }
  }

  Future<void> _loadNotes() async {
    List<Note> loadedNotes = await NoteStorage.getNotes();
    setState(() {
      notes = loadedNotes;
    });
  }

  Widget _buildDismissibleNoteItem(Note note) {
    return Dismissible(
      key: Key(note.title), // unique key for each item
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        // Notu listeden kaldırma işlemini burada gerçekleştirin
        setState(() {
          notes.remove(note);
        });

        // Kullanıcıya silindiğine dair bir geri bildirim yapabilirsiniz
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${note.title} deleted.'),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(note.details.length > 100
                  ? '${note.details.substring(0, 100)}...'
                  : note.details),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailPage(note: note),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey, height: 1.0),
        ],
      ),
    );
  }

  void _navigateToAddNotePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage()),
    );

    if (result != null && result is Note) {
      setState(() {
        notes.add(result);
      });
      NoteStorage.addNote(result); // Yeni notu yerel depolamada sakla
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if notes is null or empty, and show a loading indicator if needed
    if (notes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToAddNotePage();
          },
          tooltip: 'Add new note',
          child: const Icon(Icons.add),
        ),
      );
    } else {
      // Build the ListView.builder once notes are loaded
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
        ),
        body: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return _buildDismissibleNoteItem(notes[index]);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToAddNotePage();
          },
          tooltip: 'Add new note',
          child: const Icon(Icons.add),
        ),
      );
    }
  }
}
