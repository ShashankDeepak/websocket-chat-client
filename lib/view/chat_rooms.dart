import 'package:flutter/material.dart';
import 'package:websocket_chat_app/model/chat_model.dart';
import 'package:websocket_chat_app/model/message_model.dart';
import 'package:websocket_chat_app/service/stomp_service.dart';
import 'package:websocket_chat_app/view/chat_page.dart';

class ChatRoom extends StatefulWidget {
  final StompService service;
  const ChatRoom({super.key, required this.service});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late StompService ss;
  late ChatModel chatModel;
  late List<MessageModel> messages = [];
  TextEditingController newChatRoomTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    ss = widget.service;
    chatModel = ChatModel(name: "Public", endpoint: '/topic/public');
    Future.delayed(const Duration(seconds: 2))
        .then((value) => ss.getChatRoom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ss.createChatRooms("Shashank${i++}");
      //   },
      // ),
      body: StreamBuilder(
        stream: ss.chatRoomsStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (ss.chatModels.isNotEmpty) {
            return Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.2,
                        child: TextFormField(
                          controller: newChatRoomTextController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () {
                            ss.createChatRooms(newChatRoomTextController.text
                                .replaceAll(" ", ""));
                          },
                          child: const Text("Create new room")),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.8,
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      child: ListView.builder(
                        itemCount: ss.chatModels.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              ss.messages.clear();
                              messages.clear();
                              print(messages);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ChatPage(
                              //             chatModel: ss.chatModels[index],
                              //             service: ss)));
                              chatModel = ss.chatModels[index];
                              setState(() {});
                            },
                            title: Text(
                              ss.chatModels[index].name,
                            ),
                            subtitle: Text(ss.chatModels[index].endpoint),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: KeyedSubtree(
                    key: UniqueKey(),
                    child: ChatPage(
                      messages: messages,
                      chatModel: chatModel,
                      service: ss,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
