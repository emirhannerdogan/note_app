import 'package:flutter/material.dart';
import 'package:note_app/note.dart';
import 'package:note_app/note_storage.dart';

class AddNotePage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  AddNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveNote(context); // Pass the context here
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote(BuildContext context) async {
    String title = titleController.text;
    String details = detailsController.text;

    if (title.isNotEmpty && details.isNotEmpty) {
      bool noteExists = await NoteStorage.doesNoteExist(title);
      if (noteExists) {
        // Show dialog to notify the user that the note already exists
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Note Already Exists'),
              content: Text('A note with this title already exists.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Create a new note and navigate back with it
        Note newNote = Note(title: title, details: details);
        Navigator.pop(context, newNote);
      }
    } else {
      // Show dialog to notify the user that details and/or title is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Empty Fields'),
            content: Text('Please enter both title and details.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
