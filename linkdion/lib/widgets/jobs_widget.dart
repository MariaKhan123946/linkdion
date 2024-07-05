import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkdion/jobs/jobs_detail.dart';
import 'package:linkdion/services/global_methods.dart';
class JobsWidget extends StatefulWidget {
  final String jobTitle;
  final String jobDescription;
  final String jobId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;
  final String categoryId;
  final VoidCallback onDelete;
  const JobsWidget({
    Key? key,
    required this.jobTitle,
    required this.jobDescription,
    required this.jobId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location,
    required this.categoryId,
    required this.onDelete,
  }) : super(key: key);

  @override
  _JobsWidgetState createState() => _JobsWidgetState();
}

class _JobsWidgetState extends State<JobsWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _deleteJobAndCategory() async {
    try {
      // Implement your delete logic here
      // For demonstration purposes, let's simulate the deletion
      widget.onDelete();
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white24,
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetail(
                uploadedBy: widget.uploadedBy,
                jobId: widget.jobId,
              ),
            ),
          );
        },
        onLongPress: () {
          _showDeleteConfirmationDialog();
        },
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 70,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                width: 1,
                color: Colors.white,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: _isValidImageUrl(widget.userImage)
                ? Image.network(
              widget.userImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : Container(),
          ),
        ),
        title: Text(
          widget.jobTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4),
            Text(
              widget.jobDescription.isNotEmpty ? widget.jobDescription : 'No Description',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.keyboard_arrow_right, size: 30),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme("http") || uri.isScheme("https"));
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this job and its category?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteJobAndCategory();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
