import 'package:hive/hive.dart';

class RevisionAttachment {
  String id;
    String topicId;
      int cycleIndex;
        String filePath;
          String type;
            DateTime addedAt;
              String caption;

                RevisionAttachment({
                    required this.id,
                        required this.topicId,
                            required this.cycleIndex,
                                required this.filePath,
                                    required this.type,
                                        required this.addedAt,
                                            required this.caption,
                                              });
                                              }

                                              class RevisionAttachmentAdapter extends TypeAdapter<RevisionAttachment> {
                                                @override
                                                  final int typeId = 4;

                                                    @override
                                                      RevisionAttachment read(BinaryReader reader) {
                                                          final numOfFields = reader.readByte();
                                                              final fields = <int, dynamic>{
                                                                    for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
                                                                        };
                                                                            return RevisionAttachment(
                                                                                  id: fields[0] as String,
                                                                                        topicId: fields[1] as String,
                                                                                              cycleIndex: fields[2] as int,
                                                                                                    filePath: fields[3] as String,
                                                                                                          type: fields[4] as String,
                                                                                                                addedAt: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
                                                                                                                      caption: fields[6] as String,
                                                                                                                          );
                                                                                                                            }

                                                                                                                              @override
                                                                                                                                void write(BinaryWriter writer, RevisionAttachment obj) {
                                                                                                                                    writer
                                                                                                                                          ..writeByte(7)
                                                                                                                                                ..writeByte(0)
                                                                                                                                                      ..write(obj.id)
                                                                                                                                                            ..writeByte(1)
                                                                                                                                                                  ..write(obj.topicId)
                                                                                                                                                                        ..writeByte(2)
                                                                                                                                                                              ..write(obj.cycleIndex)
                                                                                                                                                                                    ..writeByte(3)
                                                                                                                                                                                          ..write(obj.filePath)
                                                                                                                                                                                                ..writeByte(4)
                                                                                                                                                                                                      ..write(obj.type)
                                                                                                                                                                                                            ..writeByte(5)
                                                                                                                                                                                                                  ..write(obj.addedAt.millisecondsSinceEpoch)
                                                                                                                                                                                                                        ..writeByte(6)
                                                                                                                                                                                                                              ..write(obj.caption);
                                                                                                                                                                                                                                }

                                                                                                                                                                                                                                  @override
                                                                                                                                                                                                                                    int get hashCode => typeId.hashCode;

                                                                                                                                                                                                                                      @override
                                                                                                                                                                                                                                        bool operator ==(Object other) =>
                                                                                                                                                                                                                                              identical(this, other) ||
                                                                                                                                                                                                                                                    other is RevisionAttachmentAdapter &&
                                                                                                                                                                                                                                                              runtimeType == other.runtimeType &&
                                                                                                                                                                                                                                                                        typeId == other.typeId;
                                                                                                                                                                                                                                                                        }