import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Note {
  String title;
  String details;

  Note({required this.title, required this.details});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Not Uygulaması',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [
    Note(title: "Not 1", details: "Bu birinci notun detayları."),
    Note(title: "Not 2", details: "Bu ikinci notun detayları."),
    // ... diğer notlar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notlar'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return _buildNoteItem(notes[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddNotePage();
        },
        tooltip: 'Yeni Not Ekle',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
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
        Divider(color: Colors.grey, height: 1.0),
      ],
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
        title: Text('Yeni Not Ekle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Başlık'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: detailsController,
              decoration: InputDecoration(labelText: 'Detaylar'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveNote(context); // Pass the context here
              },
              child: Text('Notu Kaydet'),
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
        padding: EdgeInsets.all(16.0),
        child: Text(note.details),
      ),
    );
  }
}
