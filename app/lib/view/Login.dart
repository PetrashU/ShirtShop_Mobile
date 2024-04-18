import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:Tshirt/view/Register.dart";
import "package:Tshirt/view/ShirtView.dart";
import "package:Tshirt/view_model/LoginViewModel.dart";
import "package:Tshirt/view_model/ShirtViewModel.dart";
import "package:tuple/tuple.dart";

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final loginViewModel = Get.put(LoginViewModel());
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isKeyboardVisible) ...[
                const SizedBox(height: 70.0),
                const Column(
                  children: [
                    Text(
                      "Welcome to our shop!",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      "Here you can check what we have in stock before coming",
                      style: TextStyle(fontSize: 16.0, color: Colors.deepPurple,),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            const SizedBox(height: 70.0),
            ],
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Get.to(const Register());
                  },
                  child: Text(
                    'Register',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                String username = usernameController.text.trim();
                String password = passwordController.text.trim();
                showDialog(
                  context: context,
                  builder: (context) => FutureBuilder<Tuple2<bool, bool>>(
                    future: loginViewModel.authenticate(username, password),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const SizedBox (
                            height: 50.0,
                            width: 50.0,
                            child: Center(child: CircularProgressIndicator(),),);
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            bool isAuthenticated = snapshot.data!.item1;
                            bool isAdmin = snapshot.data!.item2;

                            if (isAuthenticated) {
                              usernameController.text = "";
                              passwordController.text = "";

                              ShirtViewModel shirtViewModel = Get.put(ShirtViewModel(isAdmin: isAdmin));
                              shirtViewModel.updateAdmin(isAdmin);
                              
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Get.offAll(ShirtView(shirtViewModel: shirtViewModel));
                               });
                              return Container();
                            } else {
                              return Container();
                            }
                          }
                        default:
                          return Container();
                      }
                    },
                  ),
                );
              },
              child: const Text('Log in'),
            ),

            const SizedBox(height: 20.0),
            const Row(
              children: <Widget>[
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("or", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20.0),
          
            ElevatedButton.icon(icon: Image.asset('images/google-logo.png', height: 24.0),
             label: Text('Sign in with Google'),
             onPressed: (){
              loginViewModel.loginWithGoogle();
            },),
          ],
        ),
      ),
      ),
    );
  }
}