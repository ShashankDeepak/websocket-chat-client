import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:websocket_chat_app/model/chat_model.dart';
import 'package:websocket_chat_app/model/message_model.dart';

class StompService {
  Map<String, dynamic> chatRooms = HashMap();
  List<ChatModel> chatModels = [];
  List<MessageModel> messages = [];
  List<StompClient> stompClients = [];
  String username = "";
  StompFrame? frame;
  final streamController = StreamController<MessageModel>();
  final chatRoomsStreamController = StreamController<Map<String, dynamic>>();
  bool isConnected = false;
  late StompClient client = StompClient(
    config: StompConfig(
        url: 'ws://localhost:9090/ws',
        onConnect: (stomp) {
          connectToPublic();
        }),
  );

  late StompClient chatRoomClient = StompClient(
    config: StompConfig(
      url: 'ws://localhost:9090/ws',
      onConnect: (stomp) {
        frame = stomp;
        // listen(stomp);
        listenToAllChatRooms(stomp);
        listenToCreatedRooms(stomp);
      },
    ),
  );

  void connectToPublic() {
    client.send(destination: "/app/createRoom/public");
    isConnected = true;
  }


  void createChatRooms(String name) {
    chatRoomClient.send(destination: "/app/createRoom/$name");
  }

  void dispose() {
    client.deactivate();
  }

  // void listenToChatRoom(
  //   StompFrame frame, {
  //   required String roomEndpoint,
  //   required StreamController<MessageModel> streamController,
  //   required List<MessageModel> messages,
  // }) {
  //   print(
  //       "Inside listen to chat room + /topic/${roomEndpoint.split("/").last}");
  //   chatRoomClient.subscribe(
  //     destination: "/topic/${roomEndpoint.split("/").last}",
  //     callback: (message) {
  //       print("Specific =" + message.body!);
  //       streamController.add(MessageModel.fromJson(message.body!));
  //       print("Chat room = " + MessageModel.fromJson(message.body!).toString());
  //       messages.add(MessageModel.fromJson(message.body!));
  //     },
  //   );
  // }

  // void listenToPublic(StompFrame frame) {
  //   print("Inside Listen to public");
  //   connectToPublic();
  //   client.subscribe(
  //     destination: '/topic/public',
  //     callback: (message) {
  //       print(message.body);
  //       streamController.add(MessageModel.fromJson(message.body!));
  //       print(MessageModel.fromJson(message.body!));
  //       messages.add(MessageModel.fromJson(message.body!));
  //     },
  //   );
  // }

  void getChatRoom() {
    chatRooms.clear();
    chatModels.clear();
    chatRoomClient.send(destination: "/app/chatRooms");
  }

  void listenToCreatedRooms(StompFrame frame) {
    print("Inside created chat rooms");
    chatRoomClient.subscribe(
        destination: "/list/createdRooms",
        callback: (message) {
          String json = "${message.body}";
          print(json);
          Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
          chatRooms.addAll(map);
          chatRoomsStreamController.add(chatRooms);
          chatModels
              .add(ChatModel(name: map.keys.first, endpoint: map.values.first));
        });
  }

  void listenToAllChatRooms(StompFrame frame) {
    print("Inside listen to all chat rooms\n");
    chatRoomClient.subscribe(
        destination: '/list/allRooms',
        callback: (messages) {
          String json = "${messages.body}";
          Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
          chatRoomsStreamController
              .add(jsonDecode(json) as Map<String, dynamic>);
          chatRooms = map;
          chatModels.clear();
          map.forEach((key, value) {
            chatModels.add(ChatModel(name: key, endpoint: value));
          });
        });
  }

  void sendMessage(
      {required String username,
      required String message,
      required String topic}) {
    String topicName = topic.split("/").last;
    print("$topicName $topic");

    final messageModel =
        MessageModel(content: message, sender: username, messageType: "CHAT");
    client.send(destination: "/app/sendMessage", body: messageModel.toJson());
  }
}
