import 'package:flutter/material.dart';

import 'widgets/chatbubble.dart';

class ChathomeMain extends StatelessWidget {
  const ChathomeMain({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: CircleAvatar(
                maxRadius: 23,
                backgroundImage: NetworkImage(
                    "https://media.istockphoto.com/id/1221348467/vector/chat-bot-ai-and-customer-service-support-concept-vector-flat-person-illustration-smiling.jpg?s=612x612&w=0&k=20&c=emMSOYb4jWIVQQBVpYvP9LzGwPXXhcmbpZHlE6wgR78="),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  Chatbubble(
                    isSentByME: true,
                    message: "Hai",
                  ),
                  Chatbubble(message: "Hello HOw are U", isSentByME: false),
                  Chatbubble(message: "I am fine & U", isSentByME: true),
                  Chatbubble(
                      message: "fine Whats about today", isSentByME: false)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            // icon: Icon(Icons.mic,color: Colors.grey,),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  print("Speak to me");
                                },
                                icon: const Icon(Icons.mic)),
                            prefixIcon: const Icon(
                              Icons.face,
                              color: Colors.grey,
                            ),
                            hintText: "Message",
                            hintStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                borderSide:
                                    BorderSide(color: Colors.blueAccent))),
                      ),
                    ),
                    /* IconButton(
                        onPressed: () {
                          print("Speak to me");
                        },
                        icon: const Icon(
                          Icons.mic,
                          color: Colors.grey,
                        ))*/
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
