import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:chivero/chats/conversation.dart';
import 'package:chivero/models/user.dart';
import 'package:chivero/pages/profile.dart';
import 'package:chivero/utils/constants.dart';
import 'package:chivero/utils/firebase.dart';
import 'package:chivero/widgets/indicators.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {
  User? user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> jobs = [];
  List<DocumentSnapshot> filteredUsers = [];
  List<DocumentSnapshot> filteredJobs = [];
  bool loading = true;
  bool showUsers = true;
  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUsers = doc;
    setState(() {
      loading = false;
    });
  }
 getJobs() async {
  QuerySnapshot snap = await postRef
      .where('audioUrl', isEqualTo: null) // Filtrar por campo nulo
      .get();

  // Filtrar también los documentos donde 'audioUrl' está vacío (es una cadena vacía)
  List<DocumentSnapshot> doc = snap.docs;
  List<DocumentSnapshot> filteredDocs = doc.where((doc) {
    var job = doc.data() as Map<String, dynamic>;
    return job['audioUrl'] == null || job['audioUrl'] == ''; // Verificar si está vacío o nulo
  }).toList();

  jobs = filteredDocs;
  filteredJobs = filteredDocs;

  setState(() {
    loading = false;
  });
}

    search(String query) {
  setState(() {
    if (query.isEmpty) {
      filteredUsers = users;
      filteredJobs = jobs;
    } else {
      // Filtrar usuarios
      filteredUsers = users.where((userSnap) {
        Map user = userSnap.data() as Map<String, dynamic>;
        String userName = user['username'] ?? ''; // Valor por defecto si es nulo
        return userName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Filtrar trabajos
      filteredJobs = jobs.where((jobSnap) {
        Map job = jobSnap.data() as Map<String, dynamic>;
        String jobTitle = job['titulo'] ?? ''; // Valor por defecto si es nulo
        List<dynamic> instruments = job['instrumentos'] ?? []; // Lista de instrumentos
        // Verificar si el título o los instrumentos contienen la consulta
        bool titleMatch = jobTitle.toLowerCase().contains(query.toLowerCase());
        bool instrumentsMatch = instruments.any((instrument) => instrument.toLowerCase().contains(query.toLowerCase()));
        
        // El trabajo se incluye si el título o algún instrumento coincide con la consulta
        return titleMatch || instrumentsMatch;
      }).toList();
    }
  });
}


  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    getJobs();
    super.initState();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          Constants.appName,
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: () => getUsers(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: buildSearch(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showUsers = true; // Mostrar usuarios
                      });
                    },
                    child: Text('Personas'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showUsers = false; // Mostrar trabajos
                      });
                    },
                    child: Text('Trabajos'),
                  ),
                ],
              ),
            ),
            // Muestra el contenido dependiendo de la variable `showUsers`
            showUsers ? buildUsers() : buildJobs(),
          ],
        ),
      ),
    );
  }
  Widget buildJobs() {
  if (!loading) {
    if (filteredJobs.isEmpty) {
      return Center(
        child: Text("No se encontró trabajos", style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: filteredJobs.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot doc = filteredJobs[index];
            Map job = doc.data() as Map<String, dynamic>;
            String jobTitle = job['titulo'] ?? 'Título no disponible'; // Valor por defecto si es nulo
            List<dynamic> instruments = job['instrumentos'] ?? []; // Lista de instrumentos
            String ownerId = job['ownerId'] ?? ''; // ID del propietario del trabajo

            return ListTile(
              title: Text(jobTitle, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar instrumentos debajo del título
                  if (instruments.isNotEmpty)
                    Text(
                      '${instruments.join(', ')}',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Text(
                      'No hay instrumentos asignados',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
              trailing: GestureDetector(
                onTap: () {
                  final user1 = FirebaseAuth.instance.currentUser?.uid;
                  final user2 = ownerId;

                  if (user1 != null && user2.isNotEmpty) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Scaffold(
                            appBar: AppBar(
                              title: Text('Detalles del trabajo'),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      job['mediaUrl'] ?? 'https://via.placeholder.com/150',
                                      height: 500,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 16.0),

                                  // Título
                                  Text(
                                    jobTitle,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),

                                  // Descripción
                                  Text(
                                    job['description'] ?? 'Descripción no disponible',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                  Spacer(),

                                  // Botón "Aplicar"
                                  if (job['audioUrl'] == null) // Solo si no tiene audioUrl
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (user1 != null && user2 != null) {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (_) => StreamBuilder(
                                                  stream: chatIdRef
                                                      .where("users", isEqualTo: getUser(user1, user2))
                                                      .snapshots(),
                                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                    if (snapshot.hasData) {
                                                      var snap = snapshot.data;
                                                      List docs = snap!.docs;
                                                      return docs.isEmpty
                                                          ? Conversation(userId: user2, chatId: 'newChat')
                                                          : Conversation(userId: user2, chatId: docs[0].get('chatId').toString());
                                                    }
                                                    return Conversation(userId: user2, chatId: 'newChat');
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            print("No se pudieron obtener los IDs de usuario.");
                                          }
                                        },
                                        child: Text('Aplicar'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        transitionDuration: Duration(milliseconds: 300),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else {
                    print("No se pudieron obtener los IDs de usuario.");
                  }
                },
                child: Container(
                  height: 30.0,
                  width: 62.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Ver',
                        style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  } else {
    return Center(child: CircularProgressIndicator());
  }
}





  buildSearch() {
    return Row(
      children: [
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width - 50,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: TextFormField(
              controller: searchController,
              textAlignVertical: TextAlignVertical.center,
              maxLength: 10,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              textCapitalization: TextCapitalization.sentences,
              onChanged: (query) {
                search(query);
              },
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    searchController.clear();
                  },
                  child: Icon(
                    Ionicons.close_outline,
                    size: 15.0,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                // contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                border: InputBorder.none,
                counterText: '',
                hintText: 'Buscar...',
                hintStyle: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

 buildUsers() {
    if (!loading) {
      if (filteredUsers.isEmpty) {
        return Center(
          child: Text("No se encontró usuarios", style: TextStyle(fontWeight: FontWeight.bold)),
        );
      } else {
        // Aplicar el Timer al inicio para que no aparezca el usuario
        List<DocumentSnapshot> displayUsers = List.from(filteredUsers);
        if (displayUsers.isNotEmpty && displayUsers[0].id == currentUserId()) {
          // Eliminar al usuario actual directamente
          displayUsers.removeAt(0);
        }

        return Expanded(
          child: Container(
            child: ListView.builder(
              itemCount: displayUsers.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot doc = displayUsers[index];
                UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
                return ListTile(
                  onTap: () => showProfile(context, profileId: user.id!),
                  leading: user.photoUrl!.isEmpty
                      ? CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: Center(
                            child: Text(
                              '${user.username![0].toUpperCase()}',
                              style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w900),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 20.0,
                          backgroundImage: CachedNetworkImageProvider('${user.photoUrl}'),
                        ),
                  title: Text(user.username!, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user.email!),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => StreamBuilder(
                            stream: chatIdRef
                                .where("users", isEqualTo: getUser(firebaseAuth.currentUser!.uid, doc.id))
                                .snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                var snap = snapshot.data;
                                List docs = snap!.docs;
                                return docs.isEmpty
                                    ? Conversation(userId: doc.id, chatId: 'newChat')
                                    : Conversation(userId: doc.id, chatId: docs[0].get('chatId').toString());
                              }
                              return Conversation(userId: doc.id, chatId: 'newChat');
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 30.0,
                      width: 62.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Mensaje',
                            style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }


  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }

  //get concatenated list of users
  //this will help us query the chat id reference in other
  // to get the correct user id

  String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]}-${list[1]}";
    return chatId;
  }

  @override
  bool get wantKeepAlive => true;
}
