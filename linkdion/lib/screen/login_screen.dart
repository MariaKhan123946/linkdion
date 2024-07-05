import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkdion/pages/signup_pae.dart';
import 'package:linkdion/services/global_methods.dart';
import 'package:linkdion/services/global_variable.dart';

import '../ForgotPassword/forgot_password_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController? _animationController;

  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  var _isLoading=false;
  late bool _obscureText = true;

  final FirebaseAuth _auth=FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with a duration of 20 seconds
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );

    // Create a curved animation using the animation controller
    _animation = _animationController!.drive(
      Tween<double>(begin: 0.0, end: 1.0),
    );

    // Add a listener to the animation
    _animationController!.addListener(() {
      setState(() {
        // Rebuild the widget when animation value changes
      });
    });

    // Reset and forward the animation controller to start the animation
    _animationController!.repeat();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }
  void  _submitFormOnLogin()async{
    final isvalid=_loginFormKey.currentState!.validate();
    if(isvalid){
      setState(() {
        _isLoading=true;

      });
      try{
        await _auth.createUserWithEmailAndPassword(
          email: _emailTextController.text.trim().toLowerCase(),
          password: _passwordTextController.text.trim()
            
        );
        Navigator.canPop(context)?Navigator.pop(context):null;
      }catch(error){
        setState(() {
          _isLoading=false;
        });
        GlobalMethod.showErrorDialog(error:error.toString(), ctx: context);
        print('error occured $error');

      }
    }
    setState(() {
    _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: loginUrlImage,
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
            color: Colors.black.withOpacity(0.5), // Semi-transparent black overlay
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 80, right: 80),
                  child: Image.asset('images/img_5.png'),
                ),
                SizedBox(height: 15),
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailTextController,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid Email address';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordTextController,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedErrorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: (){
                         Navigator.push(context,MaterialPageRoute(builder: (context) => ForgotPassword(),));
                          },
                          child: Text('Forget password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontStyle: FontStyle.italic,
                              
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      MaterialButton(onPressed: _submitFormOnLogin,
                        color: Colors.cyan,
                        elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Login',style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),)
                          ],
                        ),
                      ),
                      SizedBox(height: 40,),
                      Center(
                        child: RichText(text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Do not have an account?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )
                            ),
                            TextSpan(
                              text: ''
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                  ..onTap=()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpPage())),
                              text: 'SignUp',style: TextStyle(
                              color: Colors.cyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            ),
                          ]
                        )),
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