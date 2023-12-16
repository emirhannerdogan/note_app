import 'package:flutter/material.dart';
import 'package:note_app/note.dart';

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
