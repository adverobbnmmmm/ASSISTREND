import 'package:flutter/material.dart';

class PostBottomBar extends StatelessWidget {
  const PostBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Colors.white,
            ),
            label: const Text(
              '2000',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Image(
              image: AssetImage('assets/comment.png'),
              color: Colors.white,
              width: 20,
              height: 20,
            ),
            label: const Text(
              '20',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.file_upload_outlined,
              color: Colors.white,
            ),
            label: const Text(
              '20',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.bookmark_border_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
