import 'package:flutter/material.dart';
import 'package:linkdion/widgets/bottom_nav_ar.dart';

class AllWorkScreen extends StatefulWidget {
  const AllWorkScreen({super.key});

  @override
  State<AllWorkScreen> createState() => _AllWorkScreenState();
}

class _AllWorkScreenState extends State<AllWorkScreen> {
  @override
  Widget build(BuildContext context) {
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
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1,),
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: Text('All works screen'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade300, Colors.blueAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [0.2, 0.9],
              ),
            ),
          ),

        ),
      ),

    );
  }
}
