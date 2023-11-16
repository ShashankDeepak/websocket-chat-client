import 'package:flutter/material.dart';
import 'package:websocket_chat_app/service/stomp_service.dart';
import 'package:websocket_chat_app/view/chat_rooms.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key, required this.service});
  final TextEditingController textEditingController = TextEditingController();
  final StompService service;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.6,
              width: size.width * 0.8,
              child: Center(
                child: SizedBox(
                  width: size.width * 0.5,
                  child: TextFormField(
                    controller: textEditingController,
                    onChanged: (value) {
                      service.username = value;
                    },
                    decoration:
                        const InputDecoration(hintText: "Enter Username"),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatRoom(service: service)),
                    (route) => false);
              },
              child: const Text("Start"),
            )
          ],
        ),
      ),
    );
  }
}
