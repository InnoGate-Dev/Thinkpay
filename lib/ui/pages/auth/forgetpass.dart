
import 'package:flutter/material.dart';

class ForegetPassword extends StatelessWidget {
  const ForegetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Forget Password"),),
        body: Container(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter valid email',
                ),
              ),
              GestureDetector(onTap: () => {
                Navigator.pushNamed(context, '/home')
              },
                  child: Text("Submit")
              ),
            ],
          ),
        ),
      )
    );
  }
}
