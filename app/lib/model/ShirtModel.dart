class ShirtModel{
  int? id;
  String? color;
  String? text;
  String? photoUrl;

  ShirtModel({this.id,this.color,this.text,this.photoUrl=''});

  factory ShirtModel.fromJson(Map<String, dynamic> json){
    return ShirtModel(
      id: json['id'],
      color: json['color'],
      text: json['text'],  
      photoUrl: json['photoUrl'],  
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'id':id,
      'color':color,
      'text':text,
      'photoUrl':photoUrl,
    };
  }
}
