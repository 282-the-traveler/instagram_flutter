import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  var postLen = 0;
  bool isFollowing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where(
        'uid',
        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
      )
          .get();
      userData = userSnap.data()!;
      postLen = postSnap.docs.length;
      isFollowing = userSnap.data()!['followers'].contains(
        FirebaseAuth.instance.currentUser!.uid,
      );
      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['username'],
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData['photoUrl'],
                      ),
                      radius: 40,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildStatColumn(
                            postLen,
                            'posts',
                          ),
                          buildStatColumn(
                            userData['followers'].length,
                            'followers',
                          ),
                          buildStatColumn(
                            userData['following'].length,
                            'following',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? FollowButton(
                  function: () {},
                  backgroundColor: mobileBackgroundColor,
                  borderColor: Colors.grey,
                  text: 'Edit profile',
                  textColor: primaryColor,
                ): isFollowing? FollowButton(
                  function: () {},
                  backgroundColor: mobileBackgroundColor,
                  borderColor: Colors.grey,
                  text: 'Unfollow',
                  textColor: Colors.black,
                ):FollowButton(
                  function: () {},
                  backgroundColor: mobileBackgroundColor,
                  borderColor: Colors.blue,
                  text: 'Follow',
                  textColor: Colors.white,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData['username'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData['bio'],
                  ),
                ),
                const Divider()
              ],
            ),
          )
        ],
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        )
      ],
    );
  }
}
