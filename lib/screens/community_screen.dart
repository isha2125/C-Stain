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

// import 'package:flutter/material.dart';

// class CommunityScreen extends StatefulWidget {
//   @override
//   _CommunityScreenState createState() => _CommunityScreenState();
// }

// class _CommunityScreenState extends State<CommunityScreen> {
//   // Sample post data (replace this with your Firestore data)
//   final List<Map<String, dynamic>> posts = [
//     {
//       'userName': 'user_1',
//       'caption': 'I reduced my carbon footprint by biking to work!',
//       'likes': 5,
//       'comments': 2,
//       'reposted': 1,
//     },
//     {
//       'userName': 'user_2',
//       'caption': 'Recycled all my plastic bottles this week.',
//       'likes': 10,
//       'comments': 3,
//       'reposted': 0,
//     },
//   ];

//   // Sample function to add a new post (integrate this with Firestore later)
//   void addNewPost(String text) {
//     setState(() {
//       posts.add({
//         'userName': 'user_name',
//         'caption': text,
//         'likes': 0,
//         'comments': 0,
//         'reposted': 0,
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Community'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "What's on your mind today?",
//                 filled: true,
//                 fillColor: Colors.grey[300],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onSubmitted: (text) {
//                 if (text.isNotEmpty) {
//                   addNewPost(text); // Add post to the list
//                 }
//               },
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: posts.length,
//               itemBuilder: (context, index) {
//                 return PostCard(
//                   userName: posts[index]['userName'],
//                   caption: posts[index]['caption'],
//                   likes: posts[index]['likes'],
//                   comments: posts[index]['comments'],
//                   reposted: posts[index]['reposted'],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PostCard extends StatelessWidget {
//   final String userName;
//   final String caption;
//   final int likes;
//   final int comments;
//   final int reposted;

//   const PostCard({
//     required this.userName,
//     required this.caption,
//     required this.likes,
//     required this.comments,
//     required this.reposted,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               userName,
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(caption),
//             SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.thumb_up_alt_outlined),
//                       onPressed: () {
//                         // Like button logic
//                       },
//                     ),
//                     Text(likes.toString()),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.comment_outlined),
//                       onPressed: () {
//                         // Comment button logic
//                       },
//                     ),
//                     Text(comments.toString()),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.share_outlined),
//                       onPressed: () {
//                         // Repost button logic
//                       },
//                     ),
//                     Text(reposted.toString()),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class CommunityScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Community'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             // Back action
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: [
//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "What's your carbon-saving win today?",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {},
//                           child: Text('Text'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[800],
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {},
//                           child: Text('Photos'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[800],
//                           ),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {},
//                           child: Text('Videos'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green[800],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             PostCard(
//               userName: "user_name",
//               caption:
//                   "Presenting to you the thoughts I wanted to present thank you so much everyone for saving carbon emissions to grt level",
//               postedAgo: "Posted minutes ago",
//             ),
//             PostCard(
//               userName: "user_name",
//               caption: "",
//               postedAgo: "Posted minutes ago",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PostCard extends StatelessWidget {
//   final String userName;
//   final String caption;
//   final String postedAgo;

//   const PostCard({
//     required this.userName,
//     required this.caption,
//     required this.postedAgo,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.green[100],
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.green[600],
//                   child:
//                       Text(userName[0].toUpperCase()), // Initials of username
//                 ),
//                 SizedBox(width: 10),
//                 Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
//                 Spacer(),
//                 Icon(Icons.more_vert),
//               ],
//             ),
//             SizedBox(height: 10),
//             if (caption.isNotEmpty) Text(caption),
//             SizedBox(height: 10),
//             Text(postedAgo, style: TextStyle(color: Colors.grey)),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(Icons.thumb_up_outlined),
//                 ),
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(Icons.chat_bubble_outline),
//                 ),
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(Icons.share_outlined),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool showTextField = false; // To toggle the TextField visibility
  final TextEditingController _controller = TextEditingController();

  // Image Picker instance
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> pickImage() async {
    // Request permission to access gallery
    if (await Permission.photos.request().isGranted) {
      // Pick image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Image selected: ${image.path}');
      }
    } else {
      print('Permission denied to access gallery');
    }
  }

  // Function to pick a video
  Future<void> pickVideo() async {
    // Request permission to access gallery
    if (await Permission.videos.request().isGranted) {
      // Pick video
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        print('Video selected: ${video.path}');
      }
    } else {
      print('Permission denied to access gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text('Carbon-Saving Wins'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Show/hide TextField when 'Text' is clicked
            if (showTextField)
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "What's your carbon-saving win today?",
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Text Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showTextField =
                          !showTextField; // Toggle TextField visibility
                    });
                  },
                  child: Text('Text'),
                ),
                // Photos Button
                ElevatedButton(
                  onPressed: () {
                    pickImage(); // Pick image from gallery
                  },
                  child: Text('Photos'),
                ),
                // Videos Button
                ElevatedButton(
                  onPressed: () {
                    pickVideo(); // Pick video from gallery
                  },
                  child: Text('Videos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
