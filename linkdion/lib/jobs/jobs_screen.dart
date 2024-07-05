 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkdion/persistent/persistent.dart';
import 'package:linkdion/search/search_job_screen.dart';
import 'package:linkdion/services/global_methods.dart';
import 'package:linkdion/widgets/bottom_nav_ar.dart';
import 'package:linkdion/widgets/jobs_widget.dart';
 class JobScreen extends StatefulWidget {
  const JobScreen({Key? key}) : super(key: key);
  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? jobCategoryFilter;
  void _onDelete(String jobId, String categoryId) async {
    try {
      // Delete the job document
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();

      // Delete the associated category document
      await FirebaseFirestore.instance.collection('categories').doc(categoryId).delete();

      Fluttertoast.showToast(
        msg: 'Job and associated category have been deleted',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );
    } catch (error) {
      GlobalMethod.showErrorDialog(
        error: 'Failed to delete the job and category: $error',
        ctx: context,
      );
    }
  }

  void _showTaskCategoriesDialog(BuildContext context) {
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
                      jobCategoryFilter = Persistent.JobCategoryList[index];
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right_alt,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
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
                setState(() {
                  jobCategoryFilter = null;
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Cancel Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
   @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        actions: [
          IconButton(
            onPressed: () {
              _showTaskCategoriesDialog(context);
            },
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange.shade300, Colors.blueAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.2, 0.9],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('jobCategory', isEqualTo: jobCategoryFilter)
              .where('recruitment', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching jobs: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  final job = snapshot.data!.docs[index];
                  final data = job.data() as Map<String, dynamic>;

                  return JobsWidget(
                    jobTitle: data['jobTitle'] ?? '',
                    jobDescription: data['jobDescription'] ?? '',
                    jobId: job.id,
                    uploadedBy: data['uploadedBy'] ?? '',
                    userImage: data['userImage'] ?? '',
                    name: data['name'] ?? '',
                    recruitment: data['recruitment'] ?? false,
                    email: data['email'] ?? '',
                    location: data['location'] ?? '',
                    categoryId: data['categoryId'] ?? '', // Pass categoryId
                    onDelete: () {
                      _onDelete(job.id, data['categoryId'] ?? '');
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text('No jobs available.'),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0,),
    );
  }
}
