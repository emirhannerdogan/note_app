import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/note.dart';
import 'package:note_app/note_storage.dart';

class CameraPage extends StatefulWidget {
  final Function()? refreshProfile;
  final Note? note;
  CameraPage({Key? key, this.refreshProfile, this.note}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  File? _capturedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _initializeControllerFuture = _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _captureAndDisplayPhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedImage = File(image.path);
      });
    } catch (e) {
      print('Error capturing photo: $e');
    }
  }

  void _resetCapture() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _openGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _capturedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveAndNavigateToDetails() async {
    try {
      if (_capturedImage != null && widget.note != null) {
        NoteStorage.saveImageToNoteDirectory(
            _capturedImage!, widget.note!.title);

        List<String>? updatedImagePaths =
            await NoteStorage.getImagesInNoteDirectory(widget.note!.title);
        Navigator.pop(context, updatedImagePaths);
      }
    } catch (e) {
      print('Error saving and navigating: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _capturedImage != null
                ? Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover,
                  )
                : FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_cameraController);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
          if (_capturedImage != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _resetCapture();
                  },
                  child: const Text('Back'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _saveAndNavigateToDetails,
                  child: const Text('Add'),
                ),
              ],
            ),
          if (_capturedImage == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _captureAndDisplayPhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('Take Photo'),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _openGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text('Open Gallery'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
