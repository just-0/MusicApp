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
  String? city; // Nueva propiedad
  String? district; // Nueva propiedad
  String? instrument; // Nueva propiedad
  String? studyPlace; // Nueva propiedad
  List<String> eventTypes; // Nueva propiedad // Nueva propiedad
  double? rating; // Nueva propiedad (para las estrellas de calificación)


  // Asegúrate de proporcionar un valor predeterminado para eventTypes
  UserModel({
    this.username,
    this.email,
    this.id,
    this.photoUrl,
    this.signedUpAt,
    this.isOnline,
    this.lastSeen,
    this.bio,
    this.country,
    this.city,
    this.district,
    this.instrument,
    this.studyPlace,
    List<String>? eventTypes, // Hacer este campo opcional
    this.userType,
    this.rating,
  }) : eventTypes = eventTypes ?? []; // Si no se pasa, asigna una lista vacía

  UserModel.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        email = json['email'],
        country = json['country'],
        photoUrl = json['photoUrl'],
        signedUpAt = json['signedUpAt'],
        isOnline = json['isOnline'],
        lastSeen = json['lastSeen'],
        bio = json['bio'],
        id = json['id'],
        city = json['city'],
        district = json['district'],
        instrument = json['instrument'],
        studyPlace = json['studyPlace'],
        eventTypes = json['eventTypes'] != null
            ? List<String>.from(json['eventTypes']) // Convertir a lista de Strings
            : [], // Si es nulo, asigna una lista vacía
        userType = json['userType'],
        rating = json['rating']?.toDouble(); // Convertir a double si es necesario


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
    data['city'] = this.city;
    data['district'] = this.district;
    data['instrument'] = this.instrument;
    data['studyPlace'] = this.studyPlace;
    data['eventTypes'] = this.eventTypes; // Guardar correctamente la lista
    data['userType'] = this.userType;
    data['rating'] = this.rating;

    return data;
  }
}
