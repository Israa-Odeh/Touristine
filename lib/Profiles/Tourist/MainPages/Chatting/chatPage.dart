import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatPage extends StatefulWidget {
  final String adminName;
  final String adminImage;

  const ChatPage(
      {super.key, required this.adminName, required this.adminImage});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  List<String> messages = [];
  ScrollController scrollController = ScrollController();
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFF1E889E),
          leading: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 15),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.angleLeft),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.adminImage),
                ),
                const SizedBox(width: 10),
                Text(widget.adminName),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              trackVisibility: true,
              controller: scrollController,
              child: AnimatedList(
                key: listKey,
                controller: scrollController,
                initialItemCount: messages.length,
                itemBuilder: (context, index, animation) {
                  return buildMessageItem(index, animation);
                },
              ),
            ),
          ),
          const Divider(
            thickness: 1.5,
          ),
          buildInputField(),
        ],
      ),
    );
  }

  Widget buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(
                fontSize: 20,
              ),
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message',
                hintStyle: TextStyle(fontSize: 20),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1E889E), width: 1.5),
                ),
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.paperPlane,
              color: Color(0xFF1E889E),
            ),
            onPressed: () {
              sendMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget buildMessageItem(int index, Animation<double> animation) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 120, top: 8.0, bottom: 0),
      child: Card(
        color: const Color.fromARGB(255, 169, 216, 225),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(messages[index], style: const TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }

  void sendMessage() {
    String message = messageController.text;
    if (message.isNotEmpty) {
      messageController.clear();
      messages.add(message);

      listKey.currentState?.insertItem(messages.length - 1);

      // Scroll to the end.
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }
  }
}
