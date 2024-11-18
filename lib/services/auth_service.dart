import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chivero/utils/firebase.dart';

class AuthService {
  User getCurrentUser() {
    return firebaseAuth.currentUser!;
  }

  // Crear un usuario en Firebase con tipo de usuario y datos adicionales
  Future<bool> createUser({
    String? name,
    User? user,
    String? email,
    String? country,
    String? city,
    String? district,
    String? password,
    String? userType, // Nuevo parámetro userType
    String? instrument, // Nuevo parámetro para músicos
    String? studyPlace, // Nuevo parámetro para músicos
    List<String>? eventTypes, // Nuevo parámetro para contratistas
  }) async {
    var res = await firebaseAuth.createUserWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );
    if (res.user != null) {
      await saveUserToFirestore(
        name!,
        res.user!,
        email!,
        country!,
        city!,
        district!,
        userType!,
        instrument: instrument,
        studyPlace: studyPlace,
        eventTypes: eventTypes,
      );
      return true;
    } else {
      return false;
    }
  }

  // Guardar los detalles del usuario en Firestore, incluyendo datos adicionales
  saveUserToFirestore(
    String name,
    User user,
    String email,
    String country,
    String district,
    String city,
    String userType, {
    String? instrument, // Parámetro opcional para músicos
    String? studyPlace, // Parámetro opcional para músicos
    List<String>? eventTypes, // Parámetro opcional para contratistas
  }) async {
    final userData = {
      'username': name,
      'email': email,
      'time': Timestamp.now(),
      'id': user.uid,
      'bio': "",
      'country': country,
      'city': city,
      'photoUrl': user.photoURL ?? '',
      'gender': '',
      'userType': userType, // Almacena userType en Firestore
      'rating': 0.0, // Nueva calificación inicial
      'ratingCount': 0, // Número de personas que han calificado
    };

    // Añadir datos específicos según el tipo de usuario
    if (userType == 'Musico') {
      userData['instrument'] = instrument ?? '';
      userData['studyPlace'] = studyPlace ?? '';
    } else if (userType == 'Contratista') {
      userData['eventTypes'] = eventTypes ?? [];
    }

    await usersRef.doc(user.uid).set(userData);
  }

  // Función para iniciar sesión
  Future<bool> loginUser({String? email, String? password}) async {
    var res = await firebaseAuth.signInWithEmailAndPassword(
      email: '$email',
      password: '$password',
    );
    if (res.user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateRating(String userId, double newRating) async {
  DocumentSnapshot userDoc = await usersRef.doc(userId).get();
  
  if (userDoc.exists) {
      double currentRating = userDoc['rating'] ?? 0.0;
      int ratingCount = userDoc['ratingCount'] ?? 0;

      // Calcular nueva calificación promedio
      double updatedRating =
          ((currentRating * ratingCount) + newRating) / (ratingCount + 1);

      // Actualizar en Firestore
      await usersRef.doc(userId).update({
        'rating': updatedRating,
        'ratingCount': ratingCount + 1,
      });
    }
  }

  forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> logOut() async {
    await firebaseAuth.signOut();
  }

  String handleFirebaseAuthError(String e) {
    // Manejo de errores de autenticación
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";
    } else if (e.contains("invalid-email")) {
      return "Invalid Email";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occurred!";
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Invalid credentials.";
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else {
      return e;
    }
  }
}
