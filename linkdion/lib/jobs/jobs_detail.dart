import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class JobDetail extends StatefulWidget {
  final String uploadedBy;
  final String jobId;
  const JobDetail({
    Key? key,
    required this.uploadedBy,
    required this.jobId,
  }) : super(key: key);

  @override
  _JobDetailState createState() => _JobDetailState();
}
class _JobDetailState extends State<JobDetail> {
  String? authorName;
  String? userImageUrl;
  String? jobTitle;
  String? locationCompany='';
  void getJobData() async {
    // Fetch user data
    final userDoc = await FirebaseFirestore.instance.collection('user').doc(widget.uploadedBy).get();
    if (userDoc.exists) {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
        locationCompany = userDoc.get('locationCompany');
      });
    }
    // Fetch job data
    final jobDoc = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();
    if (jobDoc.exists) {
      setState(() {
        jobTitle = jobDoc.get('jobTitle'); // Correct field name: 'jobTitle'
      });
    }
  }
   @override
  void initState() {
    super.initState();
    getJobData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Detail'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange.shade300, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 0.9],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle ?? 'Loading...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Display author name and user image
                      if (authorName != null && userImageUrl != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(userImageUrl!),
                            ),
                            SizedBox(width: 20),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    'Posted by: $authorName',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
