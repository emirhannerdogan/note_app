

class Note {
  String title;
  String details;

  Note({required this.title, required this.details});

  // Dönüştürme metodu not objesini harici bir veri türüne çevirir
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] ?? '',
      details: json['details'] ?? '',
    );
  }

  // Fabrika metodu harici bir veri türünü not objesine çevirir
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      details: map['details'],
    );
  }
}