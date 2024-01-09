import "package:flutter/material.dart";

class GardenPreplanScreen extends StatelessWidget{
  const GardenPreplanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Preplan'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: const Center(
        child: Text(
          'This is the Garden Preplanning Screen!',
          style: TextStyle(fontSize: 20),
        ),
        ),
    );
  }
}