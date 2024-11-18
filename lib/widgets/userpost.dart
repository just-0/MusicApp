import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chivero/chats/conversation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:chivero/components/custom_card.dart';
import 'package:chivero/components/custom_image.dart';
import 'package:chivero/models/post.dart';
import 'package:chivero/models/user.dart';
import 'package:chivero/pages/profile.dart';
import 'package:chivero/screens/comment.dart';
import 'package:chivero/screens/view_image.dart';
import 'package:chivero/services/post_service.dart';
import 'package:chivero/utils/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:audioplayers/audioplayers.dart';

class UserPost extends StatefulWidget {
  final PostModel? post;

  UserPost({this.post});

  @override
  _UserPostState createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final PostService services = PostService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  bool isPlaying = false;
  
  void toggleAudio() async {
  if(mounted) {
    if (isPlaying) {
      await _audioPlayer.pause();
      _animationController.stop(); // Detener animación al pausar
      if(mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    } else {
      await _audioPlayer.play(UrlSource(widget.post?.audioUrl ?? ''));
      _animationController.forward(); // Iniciar animación al reproducir
      if(mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    }
  }
}


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (isPlaying) {
        _audioPlayer.pause();
        _animationController.stop();
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    _animationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.repeat();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: CustomCard(
        
          onTap: () {},
          borderRadius: BorderRadius.circular(10.0),
          child: OpenContainer(
  openBuilder: (BuildContext context, VoidCallback _) {
  // Vista ampliada con imagen, título, descripción y botón "Aplicar"
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
              widget.post?.mediaUrl ?? 'https://via.placeholder.com/150',
              height: 500,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16.0),

          // Título
          Text(
            widget.post?.titulo ?? 'Título no disponible',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),

          // Descripción
          Text(
            widget.post?.description ?? 'Descripción no disponible',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          Spacer(),

          // Botón "Aplicar" (visible solo si audioUrl no es null)
          if (widget.post?.audioUrl == null)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final user1 = FirebaseAuth.instance.currentUser?.uid;
                  final user2 = widget.post!.ownerId;

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
            )
        ],
      ),
    ),
  );
},
closedElevation: 0.0,
closedShape: const RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(10.0),
  ),
),
            onClosed: (v) {},
            closedColor: Theme.of(context).cardColor,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 50),
                      GestureDetector(
                        onTap: widget.post?.audioUrl != null ? toggleAudio : null, // Solo permite hacer tap si hay un audio
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Si hay audioUrl, mostramos la imagen en un círculo con rotación
                            widget.post?.audioUrl != null
                                ? RotationTransition(
                                    turns: _animationController,
                                    child: ClipOval(
                                      child: CustomImage(
                                        imageUrl: widget.post?.mediaUrl ?? '',
                                        height: 250.0,
                                        width: 250.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 250.0, // Dimensiones del cuadrado
                                    width: 250.0,
                                    child: CustomImage(
                                      imageUrl: widget.post?.mediaUrl ?? '',
                                      height: 250.0,
                                      width: 250.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                            // Si hay audioUrl, mostramos el ícono de reproducir/pausar
                            widget.post?.audioUrl != null
                                ? Icon(
                                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    size: isPlaying ? 0.0 : 100.0,
                                    color: Colors.black.withOpacity(0.6),
                                  )
                                : SizedBox.shrink(), // No mostrar nada si no hay audio
                          ],
                        ),
                      ),

                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 3.0, vertical: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Row(
                                children: [
                                  buildLikeButton(),
                                  SizedBox(width: 5.0),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(10.0),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (_) => Comments(post: widget.post),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      CupertinoIcons.chat_bubble,
                                      size: 25.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: StreamBuilder(
                                      stream: likesRef
                                          .where('postId', isEqualTo: widget.post!.postId)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (snapshot.hasData) {
                                          QuerySnapshot snap = snapshot.data!;
                                          List<DocumentSnapshot> docs = snap.docs;
                                          return buildLikesCount(
                                              context, docs.length ?? 0);
                                        } else {
                                          return buildLikesCount(context, 0);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5.0),
                                StreamBuilder(
                                  stream: commentRef
                                      .doc(widget.post!.postId!)
                                      .collection("comments")
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot snap = snapshot.data!;
                                      List<DocumentSnapshot> docs = snap.docs;
                                      return buildCommentsCount(
                                          context, docs.length ?? 0);
                                    } else {
                                      return buildCommentsCount(context, 0);
                                    }
                                  },
                                ),
                              ],
                            ),
                            Visibility(
                              visible: widget.post!.description != null &&
                                  widget.post!.description.toString().isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0, top: 3.0),
                                child: Text(
                                  '${widget.post?.titulo ?? ""}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 15.0,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            SizedBox(height: 3.0),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                timeago.format(widget.post!.timestamp!.toDate()),
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ),
                            // SizedBox(height: 5.0),
                          ],
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 50.0,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: toggleAudio,
                    ),
                  ),
                  buildUser(context),
                ],
              );
            },
          ),
      ),
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': currentUserId(),
                'postId': widget.post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              services.removeLikeFromNotification(
                  widget.post!.ownerId!, widget.post!.postId!, currentUserId());
              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25.0,
            circleColor:
                CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: BubblesColor(
                dotPrimaryColor: Color(0xffFFA500),
                dotSecondaryColor: Color(0xffd8392b),
                dotThirdColor: Color(0xffFF69B4),
                dotLastColor: Color(0xffff8c00)),
            likeBuilder: (bool isLiked) {
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black
                    : Colors.red,
                size: 25,
              );
            },
          );
        }
        return Container();
      },
    );
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      services.addLikesToNotification(
        "like",
        user!.username!,
        currentUserId(),
        widget.post!.postId!,
        widget.post!.mediaUrl!,
        widget.post!.ownerId!,
        user!.photoUrl!,
      );
    }
  }

  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        '-   $count comments',
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  buildUser(BuildContext context) {
  bool isMe = currentUserId() == widget.post!.ownerId;
  return StreamBuilder(
    stream: usersRef.doc(widget.post!.ownerId).snapshots(),
    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasData) {
        DocumentSnapshot snap = snapshot.data!;
        UserModel user = UserModel.fromJson(snap.data() as Map<String, dynamic>);
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage: user.photoUrl!.isEmpty
                        ? null
                        : CachedNetworkImageProvider(user.photoUrl!),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: user.photoUrl!.isEmpty
                        ? Text(
                            '${user.username![0].toUpperCase()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 5.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.username}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.post?.location ?? 'ChiveroApp'}',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Color(0xff4D4D4D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    },
  );
}
String getUser(String user1, String user2) {
    user1 = user1.substring(0, 5);
    user2 = user2.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();
    var chatId = "${list[0]}-${list[1]}";
    return chatId;
  }

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
