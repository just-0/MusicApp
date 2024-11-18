import 'package:cached_network_image/cached_network_image.dart';
import 'package:chivero/auth/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:chivero/auth/register/register.dart';
import 'package:chivero/components/stream_grid_wrapper.dart';
import 'package:chivero/models/post.dart';
import 'package:chivero/models/user.dart';
import 'package:chivero/screens/edit_profile.dart';
import 'package:chivero/screens/list_posts.dart';
import 'package:chivero/screens/settings.dart';
import 'package:chivero/utils/firebase.dart';
import 'package:chivero/widgets/post_tiles.dart';

class Profile extends StatefulWidget {
  final profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isFollowing = false;
  UserModel? users;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();

  currentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ChiveroApp'),
        actions: [
          widget.profileId == firebaseAuth.currentUser!.uid
    ? Center(
        child: Padding(
          padding: const EdgeInsets.only(right: 25.0),
          child: GestureDetector(
            onTap: () async {
              // Limpiar el estado local
              setState(() {
                user = null;
                isLoading = false;
                postCount = 0;
                followersCount = 0;
              followingCount = 0;
              isFollowing = false;
              });

              // Limpiar cualquier controlador de texto o de estado
              controller.dispose(); // Si tienes un controlador de scroll

              // Cerrar sesión de Firebase
              await firebaseAuth.signOut();

              // Redirigir a la pantalla de login sin animación
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => Login(),
                ),
                (route) => false,  // Elimina todas las rutas anteriores
              );
            },
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15.0,
              ),
            ),
          ),
        ),
      )
    : SizedBox()
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 5.0,
            collapsedHeight: 6.0,
            expandedHeight: 420.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: usersRef.doc(widget.profileId).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(
                      snapshot.data!.data() as Map<String, dynamic>,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(user.photoUrl!)
                                : null,
                            backgroundColor: Colors.grey.shade300,
                            child: user.photoUrl == null || user.photoUrl!.isEmpty
                                ? Text(
                                    user.username![0].toUpperCase(),
                                    style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ),
                        // Nombre y correo en un container centrado
                        Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                user.username ?? '',
                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.email ?? '',
                                style: TextStyle(fontSize: 16.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Datos específicos según el tipo de usuario
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                          children: [
                            // Fila con el logo de ubicación (país, ciudad, distrito) a la izquierda y el texto a la derecha
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icono de ubicación
                                Icon(
                                  Icons.location_on,  // Icono relacionado con la ubicación
                                  size: 24.0,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8.0), // Espacio entre el logo y el texto
                                // Texto del país, ciudad, distrito
                                Text(
                                  '${user.country ?? ''}, ${user.city}, ${user.district ?? ''}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),

                            // Información adicional según el tipo de usuario
                            if (user.userType == 'Musico') ...[
                              // Icono de instrumento musical
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_note,  // Icono relacionado con música
                                    size: 24.0,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8.0), // Espacio entre el logo y el texto
                                  Text(
                                    'Instrumento: ${user.instrument ?? 'No especificado'}',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              // Icono de lugar de estudio
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school,  // Icono relacionado con el lugar de estudio
                                    size: 24.0,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8.0), // Espacio entre el logo y el texto
                                  Text(
                                    'Estudió en: ${user.studyPlace ?? 'No especificado'}',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                            ] else if (user.userType == 'Contratista') ...[
                              // Icono de tipo de evento
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event,  // Icono relacionado con eventos
                                    size: 24.0,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8.0), // Espacio entre el logo y el texto
                                  Text(
                                    // Mostrar los eventos o un mensaje si la lista está vacía
                                    'Eventos: ${user.eventTypes.isNotEmpty ? user.eventTypes.join(', ') : 'No especificado'}',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                            ],
                            // Estrellas (calificación) con icono de estrellas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,  // Icono de estrella para calificación
                                  size: 24.0,
                                  color: Colors.yellow,
                                ),
                                SizedBox(width: 8.0), // Espacio entre el logo y el texto
                                buildStarRating(user.rating ?? 0.0),
                              ],
                            ),
                          ],
                        ),

                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 20.0),
                          child: user.bio!.isEmpty
                              ? Container()
                              : Container(
                                  width: 200,
                                  child: Text(
                                    user.bio!,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          height: 50.0,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                StreamBuilder(
                                  stream: postRef
                                      .where('ownerId',
                                          isEqualTo: widget.profileId)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot<Object?>? snap =
                                          snapshot.data;
                                      List<DocumentSnapshot> docs = snap!.docs;
                                      return buildCount(
                                          "PUBLICACIONES", docs.length ?? 0);
                                    } else {
                                      return buildCount("PUBLICACIONES", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.grey,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: followersRef
                                      .doc(widget.profileId)
                                      .collection('userFollowers')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot<Object?>? snap =
                                          snapshot.data;
                                      List<DocumentSnapshot> docs = snap!.docs;
                                      return buildCount(
                                          "SEGUIDORES", docs.length ?? 0);
                                    } else {
                                      return buildCount("SEGUIDORES", 0);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: Container(
                                    height: 50.0,
                                    width: 0.3,
                                    color: Colors.grey,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: followingRef
                                      .doc(widget.profileId)
                                      .collection('userFollowing')
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot<Object?>? snap =
                                          snapshot.data;
                                      List<DocumentSnapshot> docs = snap!.docs;
                                      return buildCount(
                                          "SIGUIENDO", docs.length ?? 0);
                                    } else {
                                      return buildCount("SIGUIENDO", 0);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        buildProfileButton(user),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index > 0) return null;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            'Publicaciones',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () async {
                              DocumentSnapshot doc =
                                  await usersRef.doc(widget.profileId).get();
                              var currentUser = UserModel.fromJson(
                                doc.data() as Map<String, dynamic>,
                              );
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => ListPosts(
                                    userId: widget.profileId,
                                    username: currentUser.username,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Ionicons.grid_outline),
                          )
                        ],
                      ),
                    ),
                    buildPostView()
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // Widget para las estrellas de calificación
  Widget buildStarRating(double rating) {
    // Redondear el rating a un valor entero
    int fullStars = rating.floor(); // Número de estrellas completas
    double fractionalStar = rating - fullStars; // Parte decimal, para las estrellas medias

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          // Estrella completa
          return GestureDetector(
            onTap: () => updateRating(index + 1),
            child: Icon(
              Icons.star,
              color: Colors.yellow,
              size: 30.0,
            ),
          );
        } else if (index == fullStars && fractionalStar > 0) {
          // Estrella media (si tiene una fracción)
          return GestureDetector(
            onTap: () => updateRating(index + 1),
            child: Icon(
              Icons.star_half,
              color: Colors.yellow,
              size: 30.0,
            ),
          );
        } else {
          // Estrella vacía
          return GestureDetector(
            onTap: () => updateRating(index + 1),
            child: Icon(
              Icons.star_border,
              color: Colors.yellow,
              size: 30.0,
            ),
          );
        }
      }),
    );
  }


  // Función para actualizar la calificación
  void updateRating(int newRating) async {
    await usersRef.doc(widget.profileId).update({'rating': newRating});
    setState(() {});
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
        SizedBox(height: 3.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: 'Ubuntu-Regular',
          ),
        )
      ],
    );
  }

  buildProfileButton(user) {
    //if isMe then display "edit profile"
    bool isMe = widget.profileId == firebaseAuth.currentUser!.uid;
    if (isMe) {
      return buildButton(
          text: "Editar Perfil",
          function: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditProfile(
                  user: user,
                ),
              ),
            );
          });
      //if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      //if you are not following the user then "follow"
    } else if (!isFollowing) {
      return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.profileId)
          .get(), // Obtiene el documento de usuario una sola vez
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el documento
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}"); // Muestra un error si ocurre alguno
        } else if (snapshot.hasData) {
          DocumentSnapshot userDoc = snapshot.data!; 
          String? userType = userDoc['userType'];
          final buttonText = userType == 'Musico' ? "Agregar Músico" : "Agregar Contratista";
          
          return buildButton(
            text: buttonText,
            function: handleFollow,
          );
        } else {
          return Text("No data available");
        }
      },
    );
  }
  }

  buildButton({String? text, Function()? function}) {
    return Center(
      child: GestureDetector(
        onTap: function!,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Color(0xff597FDB),
              ],
            ),
          ),
          child: Center(
            child: Text(
              text!,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  handleUnfollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove from notifications feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    setState(() {
      isFollowing = true;
    });
    //updates the followers collection of the followed user
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": users?.username,
      "userId": users?.id,
      "userDp": users?.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildPostView() {
    return buildGridPost();
  }

  buildGridPost() {
    return StreamGridWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      stream: postRef
          .where('ownerId', isEqualTo: widget.profileId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts =
            PostModel.fromJson(snapshot.data() as Map<String, dynamic>);
        return PostTile(
          post: posts,
        );
      },
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: favUsersRef
          .where('postId', isEqualTo: widget.profileId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          return GestureDetector(
            onTap: () {
              if (docs.isEmpty) {
                favUsersRef.add({
                  'userId': currentUserId(),
                  'postId': widget.profileId,
                  'dateCreated': Timestamp.now(),
                });
              } else {
                favUsersRef.doc(docs[0].id).delete();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3.0,
                    blurRadius: 5.0,
                  )
                ],
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  docs.isEmpty
                      ? CupertinoIcons.heart
                      : CupertinoIcons.heart_fill,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
