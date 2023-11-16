// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageModel {
  String sender;
  String content;
  String messageType;
  MessageModel({
    required this.sender,
    required this.content,
    required this.messageType,
  });

  MessageModel copyWith({
    String? sender,
    String? content,
    String? messageType,
  }) {
    return MessageModel(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sender': sender,
      'content': content,
      'messageType': messageType,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      sender: map['sender'] as String,
      content: map['content'] as String,
      messageType: map['messageType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MessageModel(sender: $sender, content: $content, messageType: $messageType)';

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;

    return other.sender == sender &&
        other.content == content &&
        other.messageType == messageType;
  }

  @override
  int get hashCode => sender.hashCode ^ content.hashCode ^ messageType.hashCode;
}
