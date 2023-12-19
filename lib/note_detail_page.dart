import 'dart:io';
import 'package:note_app/camera_page.dart';
import 'package:note_app/note_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:note_app/note.dart';

import 'bluetooth_handler.dart';

class NoteDetailPage extends StatefulWidget {
  final Note note;

  const NoteDetailPage({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _detailsController;
  List<String>? imagePaths;
  BluetoothHandler bluetoothHandler =
      BluetoothHandler(); // Create an instance of BluetoothHandler

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

  void _deleteImage(int index) async {
    setState(() {
      File deletedImage = File(imagePaths![index]);
      deletedImage.deleteSync(); // Deletes the file from storage
      imagePaths!.removeAt(index); // Removes the path from the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              // Bluetooth işlemlerini başlat
              bluetoothHandler.startBluetoothProcess(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _detailsController,
                maxLines: null,
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Images',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imagePaths!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.file(
                                    File(imagePaths![index]),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteImage(index);
                                    },
                                  ),
                                ),
                              ],
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
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? newImagePath = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraPage(
                note: widget.note,
              ),
            ),
          );
          if (newImagePath != null) {
            setState(() {
              imagePaths?.add(newImagePath);
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

      if (imagePaths != null) {
        for (String imagePath in imagePaths!) {
          await NoteStorage.saveImageToNoteDirectory(
              File(imagePath), widget.note.title);
        }
      }

      await noteFile.writeAsString(newDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved.'),
        ),
      );
      setState(() {
        widget.note.details = newDetails;
      });
      Navigator.pop(context, widget.note);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
