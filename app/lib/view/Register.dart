import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:Tshirt/view_model/RegisterViewModel.dart";

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

    @override
    State<Register> createState() => _RegisterState();
  }

  class _RegisterState extends State<Register> {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final registerViewModel = Get.put(RegisterViewModel());


  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
         child: Padding(
        padding: EdgeInsets.only(
          top: isKeyboardVisible ? 20.0 : 190.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  registerViewModel.registerUser(emailController.text.trim(),usernameController.text.trim(),passwordController.text.trim());
                },
                child: Text('Register'),
              ),
            ],
          ),
        )
      ),
      )
    );
  }
}
