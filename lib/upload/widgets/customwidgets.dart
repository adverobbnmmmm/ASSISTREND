import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFF2B4DFC).withOpacity(0.7),
      child: ClipOval(
        child: Image.asset(
          "assets/images/questicon.png",
          width: 28 ,
          height: 28,
          fit: BoxFit.cover,
        ),
      ),
      // child: const Icon(
      //   FontAwesomeIcons.question,
      //   size: 30,
      //   color: Colors.white,
      // ),
    );
  }
}
