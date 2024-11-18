import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chivero/auth/register/profile_pic.dart';
import 'package:chivero/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String? username, email, country, city, district, password, cPassword;
  String? userType; // Nueva variable para el tipo de usuario
  String? instrument; // Para músicos
  String? studyPlace; // Lugar de estudio para músicos
  List<String> eventTypes = []; // Lista de tipos de eventos para contratistas

  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode countryFN = FocusNode();
  FocusNode cityFN = FocusNode();
  FocusNode districtFN = FocusNode();
  FocusNode passFN = FocusNode();
  FocusNode cPassFN = FocusNode();
  AuthService auth = AuthService();

  register(BuildContext context) async {
    FormState form = formKey.currentState!;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar(
          'Please fix the errors in red before submitting.', context);
    } else {
      if (password == cPassword) {
        loading = true;
        notifyListeners();
        try {
          bool success = await auth.createUser(
            name: username,
            email: email,
            password: password,
            country: country,
            city: city, 
            district: district, 
            userType: userType, // Pasar el tipo de usuario al servicio de autenticación
            instrument: userType == 'Musico' ? instrument : null, // Instrumento si es músico
            studyPlace: userType == 'Musico' ? studyPlace : null, // Lugar de estudio si es músico
            eventTypes: userType == 'Contratista' ? eventTypes : null, // Eventos si es contratista
          );
          print(success);
          if (success) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (_) => ProfilePicture(),
              ),
            );
          }
        } catch (e) {
          loading = false;
          notifyListeners();
          print(e);
          showInSnackBar(
              '${auth.handleFirebaseAuthError(e.toString())}', context);
        }
        loading = false;
        notifyListeners();
      } else {
        showInSnackBar('The passwords do not match', context);
      }
    }
  }

  // Métodos para gestionar los datos básicos
  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  setName(val) {
    username = val;
    notifyListeners();
  }

  setConfirmPass(val) {
    cPassword = val;
    notifyListeners();
  }

  setCountry(val) {
    country = val;
    notifyListeners();
  }

  setCity(val) {
    city = val;
    notifyListeners();
  }

  setDistrict(val) {
    district = val;
    notifyListeners();
  }

  setUserType(val) {
    userType = val;
    notifyListeners();
  }

  // Métodos específicos para músicos
  setInstrument(val) {
    instrument = val;
    notifyListeners();
  }

  setStudyPlace(val) {
    studyPlace = val;
    notifyListeners();
  }

  // Métodos específicos para contratistas
  toggleEventType(String eventType) {
    if (eventTypes.contains(eventType)) {
      eventTypes.remove(eventType);
    } else {
      eventTypes.add(eventType);
    }
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
