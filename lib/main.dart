import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Not Uygulaması',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Note> notes;

  @override
  void initState() {
    super.initState();
    notes = []; // Initialize the notes list to an empty list
    _loadNotes();
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
            content: Text('${note.title} silindi.'),
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
    if (notes == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Notlar'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Build the ListView.builder once notes are loaded
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notlar'),
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
          tooltip: 'Yeni Not Ekle',
          child: const Icon(Icons.add),
        ),
      );
    }
  }
}

class AddNotePage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  AddNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Not Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Detaylar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveNote(context); // Pass the context here
              },
              child: const Text('Notu Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote(BuildContext context) {
    String title = titleController.text;
    String details = detailsController.text;

    if (title.isNotEmpty && details.isNotEmpty) {
      Note newNote = Note(title: title, details: details);
      Navigator.pop(context, newNote);
    } else {
      // Handle case where title or details is empty
      // You can show an error message or take appropriate action.
    }
  }
}

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(note.details),
      ),
    );
  }
}

class NoteStorage {
  static const String _key = 'notes';

  // Notları getir
  static Future<List<Note>> getNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesJson = prefs.getString(_key);
    if (notesJson != null) {
      debugPrint('Notes available: $notesJson' );
      Iterable decoded = jsonDecode(notesJson);
      List<Note> loadedNotes =
          List<Note>.from(decoded.map((note) => Note.fromJson(note)));
      return loadedNotes;
    }
    debugPrint('Notes returning: $notesJson' );
    return [];
  }

  // Not ekle
  static Future<void> addNote(Note note) async {
    List<Note> notes = await getNotes();
    notes.add(note);
    saveNotes(notes);
  }

  // Not sil
  static Future<void> deleteNote(Note note) async {
    List<Note> notes = await getNotes();
    notes.remove(note);
    saveNotes(notes);
  }

  // Notları kaydet
  static Future<void> saveNotes(List<Note> notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String notesJson = jsonEncode(notes.map((note) => note.toJson()).toList());
    prefs.setString(_key, notesJson);
  }
}

class Note {
  String title;
  String details;

  Note({required this.title, required this.details});

  // Dönüştürme metodu not objesini harici bir veri türüne çevirir
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] ?? '',
      details: json['details'] ?? '',
    );
  }


  // Convert Note object to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'details': details,
    };
  }

  // Create a Note object from a JSON map


  // Fabrika metodu harici bir veri türünü not objesine çevirir
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      details: map['details'],
    );
  }
}
