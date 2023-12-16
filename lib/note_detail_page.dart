import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:note_app/note.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _detailsController;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController(text: widget.note.details);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _detailsController,
              maxLines: null, // Allow multiple lines for editing
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Note Details',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    String newDetails = _detailsController.text;

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final noteDirectory = Directory('${directory.path}/${widget.note.title}');

      if (!await noteDirectory.exists()) {
        await noteDirectory.create(recursive: true);
      }

      final File noteFile =
          File('${noteDirectory.path}/${widget.note.title}.txt');

      print('Old details: ${widget.note.details}'); // Debug log for old details

      await noteFile.writeAsString(newDetails);

      // Read the content from the file after writing the new details
      String updatedContent = await noteFile.readAsString();
      print(
          'Updated details from file: $updatedContent'); // Debug log for updated details

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved.'),
        ),
      );
      setState(() {
        widget.note.details = newDetails;
      });
      Navigator.pop(context, widget.note);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes.'),
        ),
      );
      print('Error while saving changes: $e');
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
