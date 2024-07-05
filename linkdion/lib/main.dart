
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'user_state.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}
 class MyApp extends StatelessWidget {
  final Future<FirebaseApp>_initialization=Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _initialization, builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting){
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('iJob clone app is being initialized',
                color: Colors.cyan,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
       else if(snapshot.hasError)
        {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('An error has been occured',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }
       return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iJob clone App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.blue,
        ),
        home: UserState(),
      );
    });
  }
}

