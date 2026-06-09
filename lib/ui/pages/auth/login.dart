import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Login"),),
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
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                ),
              ),
              GestureDetector(onTap: () => {
                Navigator.pushNamed(context, '/home')
              },
                  child: Text("Login")
              ),
              GestureDetector(
                onTap: () => {
                  Navigator.pushNamed(context, '/forgetpass')
                },
                child: Text("Forgot Password?")
              ),
              GestureDetector(
                child: Text("Don't have account ??"),
                onTap: () => {
                  Navigator.pushNamed(context, "/signup")
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
