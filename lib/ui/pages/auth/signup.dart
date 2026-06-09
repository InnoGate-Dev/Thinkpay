import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Signup"),),
        body: Container(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'First Name',
                  hintText: 'first name',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Second name',
                  hintText: 'second Name',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter valid email',
                ),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                ),
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: ' Reenter Password',
                  hintText: 'Enter secure password again',
                ),
              ),
              GestureDetector(onTap: () => {
                Navigator.pushNamed(context, '/home')
              },
                  child: Text("Signup")
              ),
              GestureDetector(
                child: Text("Already have account ??"),
                onTap: () => {
                  Navigator.pushNamed(context, "/login")  
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
