// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:flutter/material.dart';

// class CommunityScreen extends StatelessWidget {
//   const CommunityScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Image.asset('assets/Earth black 1.png'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute<ProfileScreen>(
//                   builder: (context) => ProfileScreen(
//                     appBar: AppBar(
//                       title: const Text('User Profile'),
//                     ),
//                     actions: [
//                       SignedOutAction((context) {
//                         Navigator.of(context).pop();
//                       })
//                     ],
//                     children: [
//                       const Divider(),
//                       Padding(
//                         padding: const EdgeInsets.all(2),
//                         child: AspectRatio(
//                           aspectRatio: 1,
//                           child: Image.asset('assets/Earth black 1.png'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           )
//         ],
//         automaticallyImplyLeading: false,
//       ),
//       body: Center(
//           child: Text(
//         '[In Progress]',
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       )),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Sample post data (replace this with your Firestore data)
  final List<Map<String, dynamic>> posts = [
    {
      'userName': 'user_1',
      'caption': 'I reduced my carbon footprint by biking to work!',
      'likes': 5,
      'comments': 2,
      'reposted': 1,
    },
    {
      'userName': 'user_2',
      'caption': 'Recycled all my plastic bottles this week.',
      'likes': 10,
      'comments': 3,
      'reposted': 0,
    },
  ];

  // Sample function to add a new post (integrate this with Firestore later)
  void addNewPost(String text) {
    setState(() {
      posts.add({
        'userName': 'user_name',
        'caption': text,
        'likes': 0,
        'comments': 0,
        'reposted': 0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "What's on your mind today?",
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  addNewPost(text); // Add post to the list
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  userName: posts[index]['userName'],
                  caption: posts[index]['caption'],
                  likes: posts[index]['likes'],
                  comments: posts[index]['comments'],
                  reposted: posts[index]['reposted'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String userName;
  final String caption;
  final int likes;
  final int comments;
  final int reposted;

  const PostCard({
    required this.userName,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.reposted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(caption),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up_alt_outlined),
                      onPressed: () {
                        // Like button logic
                      },
                    ),
                    Text(likes.toString()),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.comment_outlined),
                      onPressed: () {
                        // Comment button logic
                      },
                    ),
                    Text(comments.toString()),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share_outlined),
                      onPressed: () {
                        // Repost button logic
                      },
                    ),
                    Text(reposted.toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
