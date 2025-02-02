import 'package:assistrends/view/core/constant.dart';
import 'package:assistrends/widgets/customwidgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kheight20,
                const  Center(
                  child: CustomCircleAvatar(),
                ),
                kheight30,
                TextField(
                  minLines: 1,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: "Type something",
                      hintStyle: TextStyle(color: Colors.grey[700], fontSize: 20),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color:Color(0xFF2B4DFC)))),
                ),
                kheight20,
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: const Color(0xFF2B4DFC))),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon(
                            //   Icons.volume_up_sharp ,
                            //   color: Colors.white,
                            // ),
                            Icon(
                              FontAwesomeIcons.volumeHigh,
                              color: Colors.white,
                            ),
        
                            kwidth10,
                            Text(
                              "Audio",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2B4DFC).withOpacity(0.7),
                        child: const Icon(
                          Icons.add,
                          size: 25 ,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                kheight20,
                kheight20,
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: const Color(0xFF2B4DFC))),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter,
                              color: Colors.white,
                            ),
                            kwidth10,
                            Text(
                              "Image",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2B4DFC).withOpacity(0.7),
                        child: const Icon(
                          Icons.add,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                kheight20,
                kheight20,
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: const Color(0xFF2B4DFC))),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.clapperboard,
                              color: Colors.white,
                            ),
                            kwidth10,
                            Text(
                              "Video",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2B4DFC).withOpacity(0.7),
                        child: const Icon(
                          Icons.add,
                          size: 25 ,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B4DFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        "Upload",
                        style: TextStyle(color: Colors.white, fontSize: 23),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            BottomAppBar(
              color: Colors.black,
              shape: const CircularNotchedRectangle(),
              notchMargin: 6, 
              child: SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, 
                  children: [
                    const Icon(Icons.home_outlined,
                        size: 30, color: Color.fromARGB(255, 82, 78, 78)),
                    const Icon(Icons.search,
                        size: 30, color: Color.fromARGB(255, 82, 78, 78)),
                    const SizedBox(width: 50),
                    Image.asset(
                      "assets/images/choice (1) 2_64@2x.png",
                      height: 30,
                      width: 30, 
                      color: const Color.fromARGB(255, 213, 205,
                          205), 
                    ),
                    const Icon(Icons.notifications_none,
                        size: 30, color: Color.fromARGB(255, 82, 78, 78)),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: const Color(0xFF2B4DFC).withOpacity(0.8),
                  padding: const EdgeInsets.all(12), 
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
