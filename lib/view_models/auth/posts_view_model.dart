import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chivero/models/post.dart';
import 'package:chivero/screens/mainscreen.dart';
import 'package:chivero/services/post_service.dart';
import 'package:chivero/services/user_service.dart';
import 'package:chivero/utils/constants.dart';
import 'package:chivero/utils/firebase.dart';
import 'package:file_picker/file_picker.dart';

class PostsViewModel extends ChangeNotifier {
  //Services
  UserService userService = UserService();
  PostService postService = PostService();

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Variables
  bool loading = false;
  String? username;
  File? mediaUrl;
  final picker = ImagePicker();
  String? location;
  Position? position;
  Placemark? placemark;
  String? bio;
  String? description;
  String? email;
  String? commentData;
  String? ownerId;
  String? userId;
  String? type;
  File? userDp;
  String? imgLink;
  bool edit = false;
  String? id;
  File? audioFile;
  String? audioUrl;
  String? titulo;
  String customInstrument = "";
  List<String> instrumentos = [];
  //controllers
  TextEditingController locationTEC = TextEditingController();

  // Este método agrega o quita músicos de la lista
  void toggleMusician(String musician, bool isSelected) {
    if (isSelected) {
      
      instrumentos.add(musician);  // Agregar músico
    } else {
      instrumentos.remove(musician);  // Quitar músico
    }
    print(instrumentos);
    notifyListeners();  // Notificar a los widgets que depende de este valor
  }
  //Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setPost(PostModel post) {
    if (post != null) {
      description = post.description;
      imgLink = post.mediaUrl;
      location = post.location;
      edit = true;
      edit = false;
      notifyListeners();
    } else {
      edit = false;
      notifyListeners();
    }
  }
  setTitulo(String val) {
    print('SetTitulo $val');
    titulo = val;
    notifyListeners();
  }
  setUsername(String val) {
    print('SetName $val');
    username = val;
    notifyListeners();
  }

  setDescription(String val) {
    print('SetDescription $val');
    description = val;
    notifyListeners();
  }

  setLocation(String val) {
    print('SetCountry $val');
    location = val;
    notifyListeners();
  }
  
  setBio(String val) {
    print('SetBio $val');
    bio = val;
    notifyListeners();
  }
  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      audioFile = File(result.files.single.path!);
      notifyListeners();
    }
  }


  //Functions
  pickImage({bool camera = false, BuildContext? context}) async {
    loading = true;
    notifyListeners();
    try {
      final ImagePicker picker = ImagePicker();
      XFile? pickedFile = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Constants.lightAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedFile != null) {
          mediaUrl = File(croppedFile.path);
        }
      }
      loading = false;
      notifyListeners();
    }  catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Cancelled', context);
    }
  }

  getLocation() async {
    loading = true;
    notifyListeners();
    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission rPermission = await Geolocator.requestPermission();
      print(rPermission);
      await getLocation();
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position!.latitude, position!.longitude);
      placemark = placemarks[0];
      location = " ${placemarks[0].locality}, ${placemarks[0].country}";
      locationTEC.text = location!;
      print(location);
    }
    loading = false;
    notifyListeners();
  }

 uploadPosts(BuildContext context, String typeUser) async {
  instrumentos.add(customInstrument);
  if (audioFile == null && typeUser == "Musico") {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Por favor selecciona un audio para continuar.")),
    );
    return;
  }

  // Verificación de nulidad de instrumentos
  if (instrumentos == null || instrumentos.isEmpty && typeUser == "Contratista") {
    print(instrumentos);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Por favor selecciona al menos un músico.")),
    );
    return;
  }

  try {
    loading = true;
    notifyListeners();

    // Llamada al servicio de publicación
    await postService.uploadPost(
      mediaUrl ?? File(''),  // Verificación para no pasar 'null'
      location ?? "Desconocida",  // Valor por defecto si es null
      description ?? "",  // Valor por defecto si es null
      instrumentos,
      titulo,
      audioFile: audioFile,

    );

    loading = false;
    resetPost();
    notifyListeners();

    // Mostrar el mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("¡Publicación subida con éxito!")),
    );

    // Regresar a la pantalla anterior
   // Navigator.pop(context);

  } catch (e) {
    print(e);
    loading = false;
    resetPost();
    showInSnackBar('Ocurrió un error al publicar.', context);
    notifyListeners();
  }
}





  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please select an image', context);
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
            mediaUrl!, firebaseAuth.currentUser!);
        loading = false;
        Navigator.of(context)
            .pushReplacement(CupertinoPageRoute(builder: (_) => TabScreen()));
        notifyListeners();
      } catch (e) {
        print(e);
        loading = false;
        showInSnackBar('Uploaded successfully!', context);
        notifyListeners();
      }
    }
  }

  resetPost() {
    mediaUrl = null;
    description = null;
    location = null;
    edit = false;
    notifyListeners();
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  
}
