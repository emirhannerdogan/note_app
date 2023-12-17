import 'dart:io';
import 'package:note_app/camera_page.dart';
import 'package:note_app/note_storage.dart';
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
  List<String>? imagePaths;

  @override
  void initState() {
    super.initState();
    _detailsController = TextEditingController(text: widget.note.details);
    _loadImagesInNoteDirectory();
  }

  Future<void> _loadImagesInNoteDirectory() async {
    List<String>? paths =
        await NoteStorage.getImagesInNoteDirectory(widget.note.title);
    setState(() {
      imagePaths = paths;
    });
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
              decoration: const InputDecoration(
                labelText: 'Note Details',
                border: OutlineInputBorder(),
              ),
            ),
            if (imagePaths != null && imagePaths!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    height: 200, // Set the container height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagePaths!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Image.file(
                              File(imagePaths![index]),
                              width: 200, // Adjust the width as needed
                              height: 200, // Adjust the height as needed
                              fit: BoxFit
                                  .contain, // Show images without cropping
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<String>? updatedImagePaths = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraPage(
                note: widget.note,
              ),
            ),
          );
          if (updatedImagePaths != null) {
            setState(() {
              imagePaths = updatedImagePaths;
            });
          } // Navigate to CameraPage
        },
        child: const Icon(Icons.camera), // Camera icon
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
