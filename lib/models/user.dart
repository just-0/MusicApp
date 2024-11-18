import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? username;
  String? email;
  String? photoUrl;
  String? country;
  String? bio;
  String? id;
  String? userType;
  Timestamp? signedUpAt;
  Timestamp? lastSeen;
  bool? isOnline;

  UserModel(
      {this.username,
      this.email,
      this.id,
      this.photoUrl,
      this.signedUpAt,
      this.isOnline,
      this.lastSeen,
      this.bio,
      this.country,
      this.userType
      
      }
      );

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    email = json['email'];
    country = json['country'];
    photoUrl = json['photoUrl'];
    signedUpAt = json['signedUpAt'];
    isOnline = json['isOnline'];
    lastSeen = json['lastSeen'];
    bio = json['bio'];
    id = json['id'];
    userType = json['userType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['country'] = this.country;
    data['email'] = this.email;
    data['photoUrl'] = this.photoUrl;
    data['bio'] = this.bio;
    data['signedUpAt'] = this.signedUpAt;
    data['isOnline'] = this.isOnline;
    data['lastSeen'] = this.lastSeen;
    data['id'] = this.id;
    data['userType'] = this.userType;
    return data;
  }
}
