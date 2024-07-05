import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkdion/screen/login_screen.dart';
import 'package:linkdion/services/global_variable.dart';
// Assuming you have this for `forgetUrlImage
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}
class _ForgotPasswordState extends State<ForgotPassword>
    with TickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController? _animationController;
  final FirebaseAuth _auth =FirebaseAuth.instance;

  final TextEditingController _forgotpassTextController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    _animation = _animationController!.drive(
      Tween<double>(begin: 0.0, end: 1.0),
    );
    _animationController!.addListener(() {
      setState(() {});
    });

    _animationController!.repeat();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }
  void _forgotPassSubmitForm()async{
    try{
      await _auth.sendPasswordResetEmail(email: _forgotpassTextController.text,
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
    }catch(error){
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: forgetUrlImage, // Ensure forgetUrlImage is defined
            placeholder: (context, url) => Image.asset(
              'images/img.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment(_animation!.value, 0.0),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: ListView(
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Email Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _forgotpassTextController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200]?.withOpacity(0.5),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
               MaterialButton(onPressed: (){
                 _forgotPassSubmitForm();
               },
                 color: Colors.cyan,
                 elevation: 8,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(13),
                 ),
                 child: Text('Reset now',style: TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontSize: 20,
                 ),),
               ),
               Container(
                 width: 40,
                 height: 40,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child:Column(
                   children: [
                     Container(
                       width: 40,
                       height: 40,
                     ),
                     TextField(
                       decoration: InputDecoration(

                       ),
                     ),
                   ],
                 ),
               ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
