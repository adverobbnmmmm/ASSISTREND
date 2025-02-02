import 'package:assistrend/drawer/widgets/devider.dart';
import 'package:assistrend/drawer/widgets/listilesrawer.dart';
import 'package:flutter/material.dart';

class DrawerList extends StatelessWidget {
  const DrawerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://media.istockphoto.com/id/1221348467/vector/chat-bot-ai-and-customer-service-support-concept-vector-flat-person-illustration-smiling.jpg?s=612x612&w=0&k=20&c=emMSOYb4jWIVQQBVpYvP9LzGwPXXhcmbpZHlE6wgR78="),
            ),
            title: Text(
              "ASSISTREND",
              style: TextStyle(color: Colors.white),
            ),
          ),
          DividerDrawer(),
          const ListtileDrawer(title: "BUDDY"),
          DividerDrawer(),
          const ListtileDrawer(title: "Rahul"),
          DividerDrawer(),
          const ListtileDrawer(title: "Arun"),
          const Center(
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              title: Text(
                "See More",
                style: TextStyle(color: Colors.white),
              ),
              children: [
                ListtileDrawer(title: "Devi"),
                ListtileDrawer(title: "Raji"),
                ListtileDrawer(title: "gopika")
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 50),
            child: ListTile(
              title: Text(
                "Community",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          ListtileDrawer(title: "Meenakshi")
        ],
      ),
    );
  }
}
