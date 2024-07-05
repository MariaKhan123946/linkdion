import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:linkdion/jobs/jobs_screen.dart';
import 'package:linkdion/jobs/upload_job.dart';
import 'package:linkdion/search/profile_company.dart';
import 'package:linkdion/search/search_screen.dart';
import 'package:linkdion/user_state.dart';
class BottomNavigationBarForApp extends StatelessWidget {
  final int indexNum;

  BottomNavigationBarForApp({required this.indexNum});

  void _logout(context){
    final FirebaseAuth _auth=FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.logout,color: Colors.white,
                  size: 36,
                  
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Sign out ',style: TextStyle(
                  color: Colors.white,
                  fontSize: 28
                ),),
              )
            ],
          ),
          content: Text('Do you want to log out?',style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),),
          actions: [
            TextButton(onPressed: (){
              Navigator.canPop(context)?Navigator.pop(context):null;

            }, child: Text('No',style: TextStyle(
              color: Colors.green,
              fontSize: 18,
            ),)),
            TextButton(
                onPressed: (){
                  _auth.signOut();
                  Navigator.canPop(context)?Navigator.pop(context):null;
                  
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserState(),));
            },

                

                child: Text('Yes',style: TextStyle(
              color: Colors.green,
              fontSize: 18,
            ),))
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.deepOrangeAccent.shade400,
      backgroundColor: Colors.blueAccent,
      buttonBackgroundColor: Colors.deepOrangeAccent.shade200,
      height: 50,
      items: [
        Icon(Icons.list, size: 19, color: Colors.black),
        Icon(Icons.search, size: 19, color: Colors.black),
        Icon(Icons.add, size: 19, color: Colors.black),
        Icon(Icons.person, size: 19, color: Colors.black),
        Icon(Icons.exit_to_app, size: 19, color: Colors.black),
      ],
      animationDuration: Duration(milliseconds: 300),
      animationCurve: Curves.bounceInOut,
      index: indexNum,
      onTap: (index) {
        // Handle navigation based on the selected index
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => JobScreen()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AllWorkScreen()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UploadJobNow()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>ProfileScreen()),
            );
            break;
          case 4:
            _logout(context);
            break;
          default:
            break;
        }
      },
    );
  }
}
