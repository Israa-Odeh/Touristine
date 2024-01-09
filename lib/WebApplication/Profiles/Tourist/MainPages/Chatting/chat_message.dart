class ChatMessage {
  final String sender;
  final String message;
  final String date;
  final String time;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap(message) {
    return {
      'sender': sender,
      'message': message,
      'date': date,
      'time': time,
    };
  }
}
