import 'dart:io';
import 'note.dart';
import 'package:path_provider/path_provider.dart';

class NoteStorage {
  static Future<String> _getNotesDirectoryPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/notes'; // Use 'notes' directory within app documents
  }

  static Future<List<Note>> getNotes() async {
    List<Note> notes = [];
    try {
      String notesDirectory = await _getNotesDirectoryPath();
      Directory directory = Directory(notesDirectory);
      if (await directory.exists()) {
        List<FileSystemEntity> subDirectories = directory.listSync();
        for (FileSystemEntity subDirectory in subDirectories) {
          if (subDirectory is Directory) {
            List<FileSystemEntity> files = subDirectory.listSync();
            String title = subDirectory.uri.pathSegments[
                subDirectory.uri.pathSegments.length -
                    2]; // Extract title from the directory path
            String details =
                ''; // Concatenate details from text files within the directory
            for (FileSystemEntity file in files) {
              if (file is File && file.path.endsWith('.txt')) {
                String fileContent = await file.readAsString();
                details +=
                    '$fileContent\n'; // Adjust content concatenation as needed
              }
            }
            notes.add(Note(title: title, details: details));
          }
        }
      }
    } catch (e) {
      print('Error while retrieving notes: $e');
    }
    print('${notes.length} NOTES RETRIEVED');
    return notes;
  }

  static Future<void> addNote(Note note) async {
    try {
      String directoryPath = await _getNotesDirectoryPath();
      Directory directory = Directory('$directoryPath/${note.title}');
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }

      File noteFile = File('$directoryPath/${note.title}/${note.title}.txt');
      await noteFile.writeAsString(note.details);
      print('NOTE ADDED SUCCESSFULLY');
      print(noteFile.path.toUpperCase());
    } catch (e) {
      print('Error while adding note: $e');
    }
  }

  static Future<void> addOrUpdateNote(Note note) async {
    try {
      String directoryPath = await _getNotesDirectoryPath();
      Directory directory = Directory('$directoryPath/${note.title}');
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }

      File noteFile = File('$directoryPath/${note.title}/${note.title}.txt');
      await noteFile.writeAsString(note.details);
      print('NOTE ADDED/UPDATED SUCCESSFULLY');
      print(noteFile.path.toUpperCase());
    } catch (e) {
      print('Error while adding/updating note: $e');
    }
  }

  static Future<void> deleteNote(Note note) async {
    try {
      String directoryPath = await _getNotesDirectoryPath();
      Directory directory = Directory('$directoryPath/${note.title}');
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      print('Error while deleting note: $e');
    }
  }

  static Future<bool> doesNoteExist(String title) async {
    try {
      String directoryPath = await _getNotesDirectoryPath();
      Directory directory = Directory('$directoryPath/$title');
      return await directory.exists();
    } catch (e) {
      print('Error while checking note existence: $e');
      return false;
    }
  }

  static Future<String> saveImageToNoteDirectory(
      File imageFile, String noteTitle) async {
    try {
      final directoryPath = await _getNotesDirectoryPath();
      final noteDirectory = Directory('$directoryPath/$noteTitle');

      if (!await noteDirectory.exists()) {
        await noteDirectory.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final filePath = '${noteDirectory.path}/$fileName';

      await imageFile.copy(filePath);
      await imageFile.delete();
      print('IMAGE COPIED SUCCESFULLY TO PATH: $filePath');
      return filePath;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  static Future<List<String>?> getImagesInNoteDirectory(
      String noteTitle) async {
    try {
      final directoryPath = await _getNotesDirectoryPath();
      final noteDirectory = Directory('$directoryPath/$noteTitle');

      if (!(await noteDirectory.exists())) {
        print('Note directory does not exist.');
        return null;
      }

      List<String> imagePaths = [];

      final List<FileSystemEntity> files = noteDirectory.listSync();
      for (FileSystemEntity file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
          imagePaths.add(file.path);
        }
      }

      if (imagePaths.isEmpty) {
        print('No images found in note directory.');
        return [];
      }

      return imagePaths;
    } catch (e) {
      print('Error while getting images in note directory: $e');
      return [];
    }
  }
}
