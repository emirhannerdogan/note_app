import 'dart:convert';
import 'Note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteStorage {
  static const String _key = 'notes';

  // Notları getir
  static Future<List<Note>> getNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesJson = prefs.getString(_key);
    if (notesJson != null) {
      Iterable decoded = jsonDecode(notesJson);
      return List<Note>.from(decoded.map((note) => Note.fromJson(note)));
    }
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
    String notesJson = jsonEncode(notes);
    prefs.setString(_key, notesJson);
  }
}
