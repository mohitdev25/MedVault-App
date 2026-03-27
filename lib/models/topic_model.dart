import 'package:hive/hive.dart';

class Topic {
  String id;
  String title;
  String markdownNote;
  DateTime nextReviewDate;
  int intervalDays;
  String subject;
  List<String> cycleNotes;
  int totalCycles;
  int completedCycles;
  String cycleType;

  Topic({
    required this.id,
    required this.title,
    required this.markdownNote,
    required this.nextReviewDate,
    this.intervalDays = 1,
    this.subject = 'General',
    this.cycleNotes = const [],
    this.totalCycles = 4,
    this.completedCycles = 0,
    this.cycleType = 'default_4',
  });

  Topic copyWith({
    String? id,
    String? title,
    String? markdownNote,
    DateTime? nextReviewDate,
    int? intervalDays,
    String? subject,
    List<String>? cycleNotes,
    int? totalCycles,
    int? completedCycles,
    String? cycleType,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      markdownNote: markdownNote ?? this.markdownNote,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      intervalDays: intervalDays ?? this.intervalDays,
      subject: subject ?? this.subject,
      cycleNotes: cycleNotes ?? this.cycleNotes,
      totalCycles: totalCycles ?? this.totalCycles,
      completedCycles: completedCycles ?? this.completedCycles,
      cycleType: cycleType ?? this.cycleType,
    );
  }
}

class TopicAdapter extends TypeAdapter<Topic> {
  @override
  final int typeId = 0;

  @override
  Topic read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Topic(
      id: fields[0] as String,
      title: fields[1] as String,
      markdownNote: fields[2] as String,
      nextReviewDate: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      intervalDays: fields[4] as int,
      subject: fields[5] as String,
      cycleNotes: (fields[6] as List).cast<String>(),
      totalCycles: fields[7] as int,
      completedCycles: fields[8] as int,
      cycleType: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Topic obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.markdownNote)
      ..writeByte(3)
      ..write(obj.nextReviewDate.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.intervalDays)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.cycleNotes)
      ..writeByte(7)
      ..write(obj.totalCycles)
      ..writeByte(8)
      ..write(obj.completedCycles)
      ..writeByte(9)
      ..write(obj.cycleType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
