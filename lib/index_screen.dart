import 'package:flutter/material.dart';
import 'package:nomeet/main.dart';
import 'package:nomeet/selfie_screen.dart';

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {

  List<Widget> children = [Container(color: Colors.red), Container(), Container(color: Colors.green)];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: children,
        index: currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: (int screen) {
          if(screen == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SelfieScreen()));
          } else {
            setState(() {
              currentIndex = screen;
            });
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('contacts')),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), title: Text('meet')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('profile')),
        ],
      ),
    );
  }
}
