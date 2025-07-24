import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isAnonymous = false;
  String callDuration = '00:05';

  // Chat function
  void onChatPressed() {
    print('Chat button pressed');
    // Add your chat functionality here
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
  }

  // Mute function
  void onMutePressed() {
    setState(() {
      isMuted = !isMuted;
    });
    print('Mute toggled: $isMuted');
    // Add your mute/unmute functionality here
  }

  // Tag function
  void onTagPressed() {
    print('Tag button pressed');
    // Add your tag functionality here
    // Example: Show dialog to add tags or notes
  }

  // End call function
  void onEndCallPressed() {
    print('End call button pressed');
    // Add your end call functionality here
    // Example: Navigator.pop(context) or Navigator.pushReplacement to end call screen
  }

  // Anonymous toggle function
  void onAnonymousPressed() {
    setState(() {
      isAnonymous = !isAnonymous;
    });
    print('Anonymous toggled: $isAnonymous');
    // Add your anonymous functionality here
  }

  // Speaker toggle function
  void onSpeakerPressed() {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    print('Speaker toggled: $isSpeakerOn');
    // Add your speaker functionality here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Main content area - Upper section with different background
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF34495E), // Slightly lighter blue-grey
                      Color(0xFF2C3E50), // Darker blue-grey
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile picture
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage('https://via.placeholder.com/120'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Name
                      Text(
                        'Shyam Dheeraj',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Call duration
                      Text(
                        '00:05',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom controls area - Darker section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF1A252F), // Much darker blue-grey for bottom section
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Main action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Chat button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onChatPressed,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      // Mute button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onMutePressed,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isMuted ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isMuted ? Icons.mic_off : Icons.mic_off_outlined,
                                color: isMuted ? Colors.red : Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Mute',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      // Tag button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onTagPressed,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tag',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      // End call button
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onEndCallPressed,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'End',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Bottom button row
                  Row(
                    children: [
                      // Anonymous button
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: EdgeInsets.only(right: 9),
                          child: ElevatedButton(
                            onPressed: onAnonymousPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAnonymous 
                                  ? Colors.blue.withOpacity(0.3) 
                                  : Colors.white.withOpacity(0.15),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: isAnonymous ? Colors.blue : Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Anonymous',
                                  style: TextStyle(
                                    color: isAnonymous ? Colors.blue : Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Speaker button
                      Expanded(
                        child: Container(
                          height: 48,
                          margin: EdgeInsets.only(left: 12),
                          child: ElevatedButton(
                            onPressed: onSpeakerPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSpeakerOn 
                                  ? Colors.green.withOpacity(0.3) 
                                  : Colors.white.withOpacity(0.15),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSpeakerOn ? Icons.volume_up : Icons.volume_up_outlined,
                                  color: isSpeakerOn ? Colors.green : Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Speaker',
                                  style: TextStyle(
                                    color: isSpeakerOn ? Colors.green : Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}