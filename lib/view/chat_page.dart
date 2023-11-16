import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:websocket_chat_app/model/chat_model.dart';
import 'package:websocket_chat_app/model/message_model.dart';
import 'package:websocket_chat_app/service/stomp_service.dart';

class ChatPage extends StatefulWidget {
  ChatModel chatModel;
  final StompService service;
  List<MessageModel> messages = [];
  ChatPage(
      {super.key,
      required this.chatModel,
      required this.service,
      required this.messages});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  late final StompService ss;
  late final ChatModel chatModel;

  StreamController<MessageModel> chatStreamController =
      StreamController<MessageModel>();

  late StompClient client = StompClient(
    config: StompConfig(
      url: 'ws://localhost:9090/ws',
      onConnect: listenToChatRoom,
    ),
  );

  void listenToChatRoom(
    StompFrame frame,
  ) {
    String topicName = chatModel.endpoint.split("/").last;
    // var topicName = "public";
    print(topicName.length);
    client.subscribe(
      destination: '/topic/$topicName',
      callback: (message) {
        print("Topic + ${message.body!}");
        chatStreamController.add(MessageModel.fromJson(message.body!));
        // print("Chat room = " + MessageModel.fromJson(message.body!).toString());
        widget.messages.add(MessageModel.fromJson(message.body!));
        print("New message = ${message.body!}");
        print(widget.messages);
      },
    );
  }

  void sendMessage(
      {required String username,
      required String message,
      required String topic}) {
    String topicName = topic.split("/").last;
    // var topicName = "public";
    final messageModel =
        MessageModel(content: message, sender: username, messageType: "CHAT");
    client.send(
      destination: "/app/sendMessage/$topicName",
      body: messageModel.toJson(),
    );
  }

  @override
  void initState() {
    client.activate();
    ss = widget.service;
    chatModel = widget.chatModel;
    super.initState();
    // ss.listenToChatRoom(
    //   ss.frame!,
    //   roomEndpoint: chatModel.endpoint,
    //   streamController: chatStreamController,
    //   widget.messages: widget.messages,
    // );
  }

  @override
  void dispose() {
    ss.dispose();
    client.deactivate();
    messageController.dispose();
    // ss.chatStreamController.done;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room -> ${chatModel.name}"),
      ),
      body: StreamBuilder<Object>(
          stream: chatStreamController.stream,
          builder: (context, snapshot) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    controller: messageController,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.8,
                  width: MediaQuery.sizeOf(context).width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ListView.builder(
                      itemCount: widget.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.messages[index].sender ==
                                      ss.username
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.deepPurple[300],
                                            borderRadius: const BorderRadius
                                                .only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(0))),
                                        constraints: const BoxConstraints(
                                            minHeight: 40, minWidth: 60),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "~${widget.messages[index].sender}",
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                ),
                                              ),
                                              Text(
                                                widget.messages[index].content,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  : Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(10))),
                                        constraints: const BoxConstraints(
                                            minHeight: 40, minWidth: 60),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "~${widget.messages[index].sender}",
                                                style: const TextStyle(
                                                  fontSize: 8,
                                                ),
                                              ),
                                              Text(
                                                widget.messages[index].content,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (messageController.text.trim() != "") {
            // ss.sendMessage(
            //   username: "shashank",
            //   message: messageController.text.trim(),
            //   topic: chatModel.endpoint,
            // );
            sendMessage(
              username: ss.username,
              message: messageController.text.trim(),
              topic: chatModel.endpoint,
            );
          }
          messageController.clear();
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
