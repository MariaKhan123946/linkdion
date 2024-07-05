import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkdion/persistent/persistent.dart';
import 'package:linkdion/services/global_methods.dart';
import 'package:linkdion/services/global_variable.dart';
import 'package:linkdion/widgets/bottom_nav_ar.dart';
import 'package:uuid/uuid.dart'; // Corrected import
class UploadJobNow extends StatefulWidget {
  const UploadJobNow({Key? key}) : super(key: key); // Added required 'key' argument
  @override
  State<UploadJobNow> createState() => _UploadJobNowState();
}

class _UploadJobNowState extends State<UploadJobNow> {
  TextEditingController _jobCategoryController = TextEditingController(text: 'Select job category');
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _jobDescriptionController = TextEditingController();
  TextEditingController _jobDeadlineController = TextEditingController(text: 'Job Deadline Date');

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
   Timestamp? deadlineDateTimeStamp;
   bool _isLoading = false;
   void  dispose(){
    super.dispose();
    _jobCategoryController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _jobDeadlineController.dispose();
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: fct,
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value is required';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: TextStyle(
            color: Colors.white,
          ),
          maxLines: valueKey == 'JobDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

   _showTaskCategoriesDialog({required Size size}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Text(
            'Job Category',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: Persistent.JobCategoryList.length,
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _jobCategoryController.text = Persistent.JobCategoryList[index];
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right_alt,
                        color: Colors.white,
                      ),
                      Text(
                        Persistent.JobCategoryList[index],
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _pickedDateDialog() async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _jobDeadlineController.text = '${picked!.year}-${picked!.month}-${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMillisecondsSinceEpoch(picked!.millisecondsSinceEpoch);
      });
    }
  }

  void _uploadTask() async {
    final jobId = Uuid().v4();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final _uid = user.uid;

    if (_formKey.currentState!.validate()) {
      if (_jobDeadlineController.text == 'Job Deadline Date' || _jobCategoryController.text == 'Select job category') {
        GlobalMethod.showErrorDialog(error: 'Please select job category and deadline', ctx: context);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('jobs').doc(jobId).set({
          'jobId': jobId,
          'uploadedBy': _uid,
          'email': user.email,
          'jobTitle': _jobTitleController.text,
          'jobDescription': _jobDescriptionController.text,
          'deadlineDate': _jobDeadlineController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp,
          'jobCategory': _jobCategoryController.text,
          'jobComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name':name,
          'userImage':userImage,
           'location':location,

          'applicants':0,

          // Add your additional fields like 'name', 'userImage', 'location', 'applicants' here
        });

        Fluttertoast.showToast(
          msg: 'The task has been uploaded',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0,
        );

        _jobTitleController.clear();
        _jobDescriptionController.clear();

        GlobalMethod.showErrorDialog(error: 'The task has been uploaded', ctx: context);
      } catch (error) {
        print('Error: $error');
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      } finally {
        setState(() {
          _isLoading = false;
        });

      }
    }
  }
  void getMyData()async{
    final DocumentSnapshot userDoc=await FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid).get();

    setState(() {
      name=userDoc.get('name');
      userImage=  userDoc.get('userImage');
      location=userDoc.get('location');
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade300, Colors.blueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.2, 0.9],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.white10,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Please fill all fields',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 1),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textTitles(label: 'Job Category:'),
                          _textFormFields(
                            valueKey: 'JobCategory',
                            controller: _jobCategoryController,
                            enabled: false,
                            fct: () {
                              _showTaskCategoriesDialog(size: size);
                            },
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Title:'),
                          _textFormFields(
                            valueKey: 'JobTitle',
                            controller: _jobTitleController,
                            enabled: true,
                            fct: () {},
                            maxLength: 100,
                          ),
                          _textTitles(label: 'Job Description:'),
                          _textFormFields(
                            valueKey: 'JobDescription',
                            controller: _jobDescriptionController,
                            enabled: true,
                            fct: () {},
                            maxLength: 300,
                          ),
                          _textTitles(label: 'Job Deadline Date:'),
                          _textFormFields(
                            valueKey: 'Deadline',
                            controller: _jobDeadlineController,
                            enabled: false,
                            fct: _pickedDateDialog,
                            maxLength: 100,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : MaterialButton(
                          onPressed: _uploadTask,
                          color: Colors.black,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Post Now',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 9),
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

