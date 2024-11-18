import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ionicons/ionicons.dart';
import 'package:chivero/chats/recent_chats.dart';
import 'package:chivero/models/post.dart';
import 'package:chivero/utils/constants.dart';
import 'package:chivero/utils/firebase.dart';
import 'package:chivero/widgets/indicators.dart';
import 'package:chivero/widgets/story_widget.dart';
import 'package:chivero/widgets/userpost.dart';

class Feeds extends StatefulWidget {
  @override
  _FeedsState createState() => _FeedsState();
}

class _FeedsState extends State<Feeds> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int page = 5;
  bool loadingMore = false;
  ScrollController scrollController = ScrollController();

  List<String> friendsIds = []; // Aquí guardaremos los IDs de los amigos

  @override
  void initState() {
    super.initState();
    fetchFriends(); // Llamada para obtener la lista de amigos
    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        setState(() {
          page += 5;
          loadingMore = true;
        });
      }
    });
  }

  Future<void> fetchFriends() async {
    final String currentUserId = firebaseAuth.currentUser!.uid;
    print("currentId: ");
    print(currentUserId);

    // Obtén los IDs de los amigos desde la colección 'userFollowing'
    var friendsSnapshot = await followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .get();

    setState(() {
      friendsIds = friendsSnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(Constants.appName, style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Ionicons.chatbubble_ellipses, size: 30.0),
            onPressed: () {
              Navigator.push(context, CupertinoPageRoute(builder: (_) => Chats()));
            },
          ), 
          SizedBox(width: 20.0),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.secondary,
        onRefresh: fetchFriends,
        child: SingleChildScrollView(
          child: Column(
            children: [
              StoryWidget(),
              Container(
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder<List<PostModel>>(
                  future: getFriendsPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return circularProgress(context);
                    } else if (snapshot.hasData) {
                      List<PostModel> posts = snapshot.data!;
                      return ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: scrollController,
                        itemCount: posts.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: UserPost(post: posts[index]),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No Feeds',
                          style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<PostModel>> getFriendsPosts() async {
    if (friendsIds.isEmpty) return [];

    var postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('ownerId', whereIn: friendsIds)
        .orderBy('timestamp', descending: true)
        .limit(page)
        .get();

    return postsSnapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();
  }

  @override
  bool get wantKeepAlive => true;
}
