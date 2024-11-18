import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:chivero/components/custom_image.dart';
import 'package:chivero/models/user.dart';
import 'package:chivero/utils/firebase.dart';
import 'package:chivero/view_models/auth/posts_view_model.dart';
import 'package:chivero/widgets/indicators.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}


class _CreatePostState extends State<CreatePost> {


  UserModel? currentUser;
  bool isLoading = true;
  Future<void> fetchCurrentUser() async {
  try {
    final userDoc = await usersRef.doc(firebaseAuth.currentUser!.uid).get();
    if (userDoc.exists) {
      setState(() {
        currentUser = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
        isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching user: $e');
    setState(() {
      isLoading = false;
    });
  }
}
@override
void initState() {
  super.initState();
  fetchCurrentUser();
}


  @override
  Widget build(BuildContext context) {
    currentUserId() {
      return firebaseAuth.currentUser!.uid;
    }

    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);
    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetPost();
        return true;
      },
      child: LoadingOverlay(
        progressIndicator: circularProgress(context),
        isLoading: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Ionicons.close_outline),
              onPressed: () {
                viewModel.resetPost();
                Navigator.pop(context);
              },
            ),
            title: Text('ChiveroApp'.toUpperCase()),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadPosts(context, currentUser!.userType ?? "Contratista");
                   if (viewModel.audioFile != null) {
                    Navigator.pop(context);
                    viewModel.resetPost();
                  }
                  //Navigator.pop(context);
                  //viewModel.resetPost();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Publicar'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: isLoading   ? Center(child: CircularProgressIndicator())
          : (currentUser?.userType == 'Musico'
                ? buildMusicoView(viewModel)
                : buildContratistaView(viewModel)),
        ),
      ),
    );
  }
  Widget buildContratistaView(PostsViewModel viewModel) {
    return ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              SizedBox(height: 15.0),
              currentUser != null
                      ? ListTile(
                          leading: CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(currentUser!.photoUrl!),
                          ),
                          title: Text(
                            '${currentUser!.username}' ?? 'Usuario',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(currentUser!.email ?? 'Sin correo'),
                        )
                      : Center(child: Text('No se encontraron datos')),
              InkWell(
                onTap: () => showImageChoices(context, viewModel),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: viewModel.imgLink != null
                      ? CustomImage(
                          imageUrl: viewModel.imgLink,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.cover,
                        )
                      : viewModel.mediaUrl == null
                          ? Center(
                              child: Text(
                                'Subir una Foto',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            )
                          : Image.file(
                              viewModel.mediaUrl!,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width - 30,
                              fit: BoxFit.cover,
                            ),
                ),
              ),
              
             
              SizedBox(height: 20.0),
              Text(
                'Título de la Publicación'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: InputDecoration(
                  hintText: 'Un título atractivo...',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setTitulo(val),
              ),
              SizedBox(height: 20.0),
              Text(
                'Ubicación'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  title: Container(
                    width: 250.0,
                    child: TextFormField(
                      controller: viewModel.locationTEC..text = "Arequipa/Perú",
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0.0),
                        hintText: 'Arequipa/Perú', // Texto de sugerencia (en caso de estar vacío)
                        focusedBorder: UnderlineInputBorder(),
                      ),
                      maxLines: null,
                      onChanged: (val) => viewModel.setLocation(val),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: "Usa tu ubicación actual",
                    icon: Icon(
                      CupertinoIcons.map_pin_ellipse,
                      size: 25.0,
                    ),
                    iconSize: 30.0,
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () => viewModel.getLocation(),
                  ),
                ),
               Text(
                'Descripción de la publicación'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: InputDecoration(
                  hintText: 'Oportunidad de Trabajo en...',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setDescription(val),
              ),
              ExpansionTile(
      title: Text("Tipos de músicos"),
      children: [
        CheckboxListTile(
          title: Text('Guitarrista'),
          value: viewModel.instrumentos.contains('Guitarrista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Guitarrista', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Violinista'),
          value: viewModel.instrumentos.contains('Violinista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Violinista', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Saxofonista'),
          value: viewModel.instrumentos.contains('Saxofonista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Saxofonista', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Percusionista'),
          value: viewModel.instrumentos.contains('Percusionista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Percusionista', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Bajista'),
          value: viewModel.instrumentos.contains('Bajista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Bajista', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Tecladista'),
          value: viewModel.instrumentos.contains('Tecladista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Tecladista', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Cantante'),
          value: viewModel.instrumentos.contains('Cantante'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Cantante', selected!);
          },
        ),
        CheckboxListTile(
          title: Text('Baterista'),
          value: viewModel.instrumentos.contains('Baterista'),
          onChanged: (bool? selected) {
            viewModel.toggleMusician('Baterista', selected!);
          },
        ),
        // Caja de texto para añadir otro instrumento
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (String value) {
              // Aquí puedes manejar el texto ingresado por el usuario
              viewModel.customInstrument = value;  // Guardar el valor en el modelo
            },
            decoration: InputDecoration(
              labelText: 'Otro instrumento (si no está en la lista)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    )
            ],
          );
  }
  
  
  
  Widget buildMusicoView(PostsViewModel viewModel) {
    return ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              SizedBox(height: 15.0),
              currentUser != null
                      ? ListTile(
                          leading: CircleAvatar(
                            radius: 25.0,
                            backgroundImage: NetworkImage(currentUser!.photoUrl!),
                          ),
                          title: Text(
                            '${currentUser!.username}' ?? 'Usuario',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(currentUser!.email ?? 'Sin correo'),
                        )
                      : Center(child: Text('No se encontraron datos')),
              InkWell(
                onTap: () => showImageChoices(context, viewModel),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: viewModel.imgLink != null
                      ? CustomImage(
                          imageUrl: viewModel.imgLink,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width - 30,
                          fit: BoxFit.cover,
                        )
                      : viewModel.mediaUrl == null
                          ? Center(
                              child: Text(
                                'Subir una Foto',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            )
                          : Image.file(
                              viewModel.mediaUrl!,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width - 30,
                              fit: BoxFit.cover,
                            ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Seleccionar Audio'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                title: Text(viewModel.audioFile != null ? "Audio Seleccionado" : "Ningún audio seleccionado"),
                trailing: IconButton(
                  icon: Icon(Ionicons.musical_note_outline),
                  onPressed: () async {
                    await viewModel.pickAudio();
                  },
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Título de la Publicación'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: InputDecoration(
                  hintText: 'Un título atractivo...',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setTitulo(val),
              ),
              SizedBox(height: 20.0),
              Text(
                'Ubicación'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  title: Container(
                    width: 250.0,
                    child: TextFormField(
                      controller: viewModel.locationTEC..text = "Arequipa/Perú",
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0.0),
                        hintText: 'Arequipa/Perú', // Texto de sugerencia (en caso de estar vacío)
                        focusedBorder: UnderlineInputBorder(),
                      ),
                      maxLines: null,
                      onChanged: (val) => viewModel.setLocation(val),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: "Usa tu ubicación actual",
                    icon: Icon(
                      CupertinoIcons.map_pin_ellipse,
                      size: 25.0,
                    ),
                    iconSize: 30.0,
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () => viewModel.getLocation(),
                  ),
                ),
              Text(
                'Descripción de la publicación'.toUpperCase(),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                initialValue: viewModel.description,
                decoration: InputDecoration(
                  hintText: 'Una historia de ...',
                  focusedBorder: UnderlineInputBorder(),
                ),
                maxLines: null,
                onChanged: (val) => viewModel.setDescription(val),
              ),
            ],
          );
  }
  
  
  showImageChoices(BuildContext context, PostsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Ionicons.camera_outline),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage(camera: true);
                },
              ),
              ListTile(
                leading: Icon(Ionicons.image),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
