import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkdion/services/global_methods.dart';
import 'package:linkdion/services/global_variable.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with TickerProviderStateMixin {
  late Animation<double>? _animation;
  late AnimationController? _animationController;
  final _signUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _positionCpFocusNode = FocusNode();

  var _isLoading = false;
  late bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? imageUrl;

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
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    _positionCpFocusNode.dispose();

    super.dispose();
  }


  void _showImageDialog(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('Please choose an option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: (){
                _getFromCamera();

              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.camera,color: Colors.purple,),
                  ),
                  Text('Camera',style: TextStyle(
                    color: Colors.purple,
                  ),)
                ],
              ),
            ),
            InkWell(
              onTap: (){
                _getFromGallery();
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.image,color: Colors.purple,),
                  ),
                  Text('Gallery',style: TextStyle(
                    color: Colors.purple,
                  ),),
                ],
              ),
            ),
          ],
        ),
      );

    });
  }
  void _getFromCamera() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }
  void _cropImage(filePath)async{
    CroppedFile? croppedImage=await ImageCropper().cropImage(sourcePath: filePath,maxWidth:1080 ,maxHeight: 1080);
    if(croppedImage!=null){
      setState(() {
        imageFile=File(croppedImage.path);
      });
    }
  }
  void _submitFromOnSignUp()async{
    final isvalid=_signUpFormKey.currentState!.validate();
    if(isvalid){
      if(imageFile==null){
        GlobalMethod.showErrorDialog(error: 'please pick an image', ctx:context);

        return ;

      }
      setState(() {
        _isLoading=true;

      });
      try{
        await _auth.createUserWithEmailAndPassword(email: _emailTextController.text.trim().toLowerCase(), password: _passwordTextController.text.trim(),
        );
        final User? user=_auth.currentUser;

        final _uid=user!.uid;

        final ref=FirebaseStorage.instance.ref().child('userImages').child(_uid+'.jpg');

        await ref.putFile(imageFile!);

        imageUrl=await ref.getDownloadURL();

        FirebaseFirestore.instance.collection('user').doc(_uid).set({

          'id':_uid,
          'name':_fullNameController.text,
          'email':_emailTextController.text,
          'userImage':imageUrl,
          'phoneNumber':_phoneNumberController.text,
          'location':_locationController.text,
          'createdAt':Timestamp.now(),

        });
        Navigator.canPop(context)? Navigator.of(context):null;

      }catch (error){
        setState(() {
          _isLoading=false;
        });

        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
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
            imageUrl: signUpUrlImage,
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
                Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showImageDialog();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.35,
                            height: MediaQuery.of(context).size.height * 0.20,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.cyanAccent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: imageFile == null
                                  ? Icon(Icons.camera_alt_sharp, color: Colors.cyan, size: 30)
                                  : Image.file(imageFile!, fit: BoxFit.fill),
                            ),
                          ),
                        ),
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.name,
                        controller: _fullNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Full Name/Category Name is required';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Full Name/Category Name',
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
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailTextController,
                        obscureText: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Email is required';
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
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordTextController,
                        obscureText: _obscureText,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Password is required';
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
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        controller: _phoneNumberController,
                        obscureText: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Phone Number is required';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
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
                          FocusScope.of(context).requestFocus(_positionCpFocusNode);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.streetAddress,
                        controller: _locationController,
                        obscureText: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Company Address is required';
                          }
                          return null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Company Address',
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
                      ),
                      SizedBox(height: 10,),
                      MaterialButton(onPressed: _submitFromOnSignUp,
                        color: Colors.cyan,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sign Up',style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),)
                          ],
                        ),
                      ),
                      SizedBox(height: 40,),
                      Center(
                        child: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Already have an account?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )
                                ),
                                TextSpan(
                                  text: '',
                                ),
                                TextSpan(
                                  recognizer: TapGestureRecognizer(
                                  )..onTap=()=>Navigator.canPop(context)?Navigator.pop(context):null,
                                  text: 'Login',style: TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                )
                              ]
                          ),

                        ),
                      )
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