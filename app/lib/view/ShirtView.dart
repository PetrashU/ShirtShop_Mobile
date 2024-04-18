import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:Tshirt/view/Login.dart';
import 'package:Tshirt/view/UpdateShirt.dart';
import 'package:Tshirt/view_model/ShirtViewModel.dart';
import 'AddShirt.dart';



class ShirtView extends StatefulWidget {
  final ShirtViewModel shirtViewModel;

  const ShirtView({Key? key, required this.shirtViewModel}) : super(key: key);

  @override
  State<ShirtView> createState() => _ShirtViewState();
}

class _ShirtViewState extends State<ShirtView> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("All Shirts", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.deepPurple, actions: [IconButton(
            onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
              Get.offAll(Login());
              }, icon: Icon(Icons.exit_to_app, color: Colors.white,))],),
          body:Obx(() =>  LoadingOverlay(
            isLoading: widget.shirtViewModel.isLoading.value,
            child: Container(
              margin: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: widget.shirtViewModel.allShirts.length,
                itemBuilder: (context,index){  
                  return InkWell(
                    onTap: (){
                      if (widget.shirtViewModel.isAdmin){
                        Get.to(UpdateShirt(shirtViewModel: widget.shirtViewModel,),
                        arguments: widget.shirtViewModel.allShirts[index]);
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        if (widget.shirtViewModel.allShirts[index].photoUrl != null && widget.shirtViewModel.allShirts[index].photoUrl!.isNotEmpty)
                          Image.network(widget.shirtViewModel.allShirts[index].photoUrl!, width: 120, height: 120,)
                        else
                          const Icon(Icons.image, color: Colors.grey, size: 120),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Available in: ${widget.shirtViewModel.allShirts[index].color!.toLowerCase()}", style: TextStyle(fontSize: 18)), 
                                Text(widget.shirtViewModel.allShirts[index].text!, style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        if (widget.shirtViewModel.isAdmin)
                          InkWell(
                            onTap: (){
                              widget.shirtViewModel.deleteShirt(widget.shirtViewModel.allShirts[index]);
                            },
                            child: Icon(Icons.delete, color: Colors.red, size:20,),),
                      ],
                    ),
                  );
                }
              ),
            ),
          )
          ),
          floatingActionButton: Visibility(visible: widget.shirtViewModel.isAdmin, 
          child: FloatingActionButton(onPressed: (){
            Get.to(AddShirt(shirtViewModel: widget.shirtViewModel,));
          },
          child: Icon(Icons.add),
          ),
        ),
        ),
    );
  }
}


