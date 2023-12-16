import 'dart:io';
import 'note.dart';
import 'package:path_provider/path_provider.dart';

class NoteStorage {
  static Future<String> _getNotesDirectoryPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path +
        '/notes'; // Use 'notes' directory within app documents
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
                details += fileContent +
                    '\n'; // Adjust content concatenation as needed
              }
            }
            notes.add(Note(title: title, details: details));
          }
        }
      }
    } catch (e) {
      print('Error while retrieving notes: $e');
    }
    print(notes.length.toString() + ' NOTES RETRIEVED');
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
}
