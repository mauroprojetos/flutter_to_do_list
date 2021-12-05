class Task {
  final int id;
  final int userId;
  final String name;
  final DateTime date;
  final int realized;

  Task({
    required this.id,
    required this.userId,
    required this.name,
    required this.date,
    required this.realized,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json["id"] as int,
        userId: json["userId"] as int,
        name: json["name"] as String,
        date: DateTime.parse(json["date"]),
        realized: json["realized"] as int,
      );
}
