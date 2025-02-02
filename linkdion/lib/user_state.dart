import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkdion/jobs/jobs_screen.dart';
import 'package:linkdion/screen/login_screen.dart';
class UserState extends StatelessWidget {
  const UserState({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (ctx, userSnapshot){
      if(userSnapshot.data==null){
        print('user is not logged in yet');
        return Login();
      }
      else if(userSnapshot.hasData){
        print('user is already logged in yet');

        return JobScreen();
      }
      else if(userSnapshot.hasError){
        return Scaffold(
          body: Center(
            child: Text('An error has been occured. Try again later'),
          ),
        );
      }
      else if(userSnapshot.connectionState== ConnectionState.waiting){
      return Scaffold(
      body: Center(
      child: CircularProgressIndicator(),
      ),
      );
      }
      return Scaffold(
        body: Center(
          child: Text('Something went wrong'),

        ),
      );
    });
  }
}
