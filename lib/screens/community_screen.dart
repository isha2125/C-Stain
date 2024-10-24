import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/models/comments.dart';
import 'package:cstain/models/post.dart';
import 'package:cstain/providers/providers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

// final postsProvider = StreamProvider<List<PostModel>>((ref) {
//   print('Fetching posts from Firestore...'); // Print to check the function call
//   return FirebaseFirestore.instance
//       .collection('posts')
//       .where('visibility', isEqualTo: 'public')
//       .orderBy('created_at', descending: true) // Order by creation time
//       .snapshots()
//       .map((snapshot) {
//     print(
//         'Documents fetched: ${snapshot.docs.length}'); // Check if documents are fetched
//     final posts = snapshot.docs
//         .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();
//     print('Posts fetched: $posts'); // Add this line for debugging
//     return posts;
//   });
// });

final postsProvider = StreamProvider<List<PostModel>>((ref) {
  print('Fetching posts from Firestore...'); // Print to check the function call
  return FirebaseFirestore.instance
      .collection('posts')
      .where('visibility', isEqualTo: 'public')
      .orderBy('created_at', descending: true) // Order by creation time
      .snapshots()
      .map((snapshot) {
    print(
        'Documents fetched: ${snapshot.docs.length}'); // Check if documents are fetched

    // Modify here to include document ID in the PostModel
    final posts = snapshot.docs.map((doc) {
      // Fetch document data and assign the document ID as post_id
      final postData = doc.data() as Map<String, dynamic>;
      final postId = doc.id;

      // Create PostModel by passing the document ID (postId) and other data
      return PostModel.fromMap(postData).copyWith(post_id: postId);
    }).toList();

    print('Posts fetched: $posts'); // Add this line for debugging
    return posts;
  });
});

Stream<List<CommentsModel>> getComments(String postId) {
  return FirebaseFirestore.instance
      .collection('comments')
      .where('post_id', isEqualTo: postId)
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) =>
              CommentsModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
}

// Define providers
final mediaProvider = StateProvider<File?>((ref) => null);
final mediaTypeProvider = StateProvider<String?>((ref) => null);
final isUploadingProvider = StateProvider<bool>((ref) => false);
final videoPlayerControllerProvider =
    StateProvider<VideoPlayerController?>((ref) => null);

final titleControllerProvider = Provider((ref) => TextEditingController());
final bodyControllerProvider = Provider((ref) => TextEditingController());

class CommunityScreen extends ConsumerWidget {
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> pickImage(BuildContext context, WidgetRef ref) async {
    if (await Permission.photos.request().isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        ref.read(mediaProvider.notifier).state = File(image.path);
        ref.read(mediaTypeProvider.notifier).state = 'image';
      }
    } else {
      print('Permission denied to access gallery');
    }
  }

  // Function to pick a video
  Future<void> pickVideo(BuildContext context, WidgetRef ref) async {
    if (await Permission.videos.request().isGranted) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        ref.read(mediaProvider.notifier).state = File(video.path);
        ref.read(mediaTypeProvider.notifier).state = 'video';
        // Initialize the video player
        final videoController = VideoPlayerController.file(File(video.path));
        await videoController.initialize();
        ref.read(videoPlayerControllerProvider.notifier).state =
            videoController;
      }
    } else {
      print('Permission denied to access gallery');
    }
  }

  // Function to upload media to Firebase Storage
  Future<String?> uploadMediaToStorage(
      File file, String mediaType, WidgetRef ref) async {
    ref.read(isUploadingProvider.notifier).state = true;
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.$mediaType';
      Reference storageReference =
          FirebaseStorage.instance.ref().child('community/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() {});
      String downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading media: $e');
      return null;
    } finally {
      ref.read(isUploadingProvider.notifier).state = false;
    }
  }

  // Function to save post data to Firestore
  Future<void> savePost(String mediaUrl, WidgetRef ref) async {
    final bodyController = ref.read(bodyControllerProvider);
    final titleController = ref.read(titleControllerProvider);
    final userStream = ref.watch(userStreamProvider);
    final user = userStream.value;

    if (user != null) {
      await FirebaseFirestore.instance.collection('posts').add({
        'body': bodyController.text,
        'title': titleController.text,
        'created_at': Timestamp.now(),
        'posted_user_id': user.uid,
        'posted_user_username': user.username ?? 'Anonymous',
        'status': 'posted',
        'media_url':
            mediaUrl.isNotEmpty ? mediaUrl : null, // Save null if text-only
        'media_type': mediaUrl.isNotEmpty
            ? ref.read(mediaTypeProvider)
            : 'text', // Mark as 'text' if no media
        'visibility': 'public',
      });

      // Clear fields after posting
      ref.read(mediaProvider.notifier).state = null;
      bodyController.clear();
      titleController.clear();
      ref.read(videoPlayerControllerProvider.notifier).state?.dispose();
    }
  }

  // Show a preview of the media, title, and bio before posting
  void showPreview(BuildContext context, WidgetRef ref) async {
    final selectedMedia = ref.read(mediaProvider);
    final mediaType = ref.read(mediaTypeProvider);
    final videoController = ref.read(videoPlayerControllerProvider);

    // Show preview even if media is not selected (for text-only posts)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview Your Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show media preview if there is media
            if (selectedMedia != null)
              mediaType == 'image'
                  ? Image.file(selectedMedia)
                  : videoController != null &&
                          videoController.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: videoController.value.aspectRatio,
                          child: VideoPlayer(videoController),
                        )
                      : Container(
                          height: 200, child: CircularProgressIndicator()),
            SizedBox(height: 10),
            // Input field for title
            TextField(
              controller: ref.read(titleControllerProvider),
              decoration: InputDecoration(
                labelText: 'Your Post Title',
              ),
            ),
            SizedBox(height: 10),
            // Input field for bio
            TextField(
              controller: ref.read(bodyControllerProvider),
              decoration: InputDecoration(
                labelText: 'Your Post Bio',
              ),
            ),
            SizedBox(height: 10),
            // Loading indicator during upload
            if (ref.watch(isUploadingProvider)) CircularProgressIndicator(),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (ref.read(titleControllerProvider).text.isNotEmpty) {
                // Upload only if there is media
                String? mediaUrl;
                if (selectedMedia != null) {
                  mediaUrl = await uploadMediaToStorage(
                      selectedMedia, mediaType!, ref);
                }
                await savePost(
                    mediaUrl ?? '', ref); // Empty mediaUrl for text-only posts
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Post uploaded successfully!')));
              }
            },
            child: Text('Post'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
    final postsAsyncValue = ref.watch(postsProvider);
    return Scaffold(
        //backgroundColor: Color(0xFFABD5C5),
        appBar: AppBar(
          title: Text(
            'Community',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          leading: Image.asset('assets/Earth black 1.png'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<ProfileScreen>(
                    builder: (context) => ProfileScreen(
                      appBar: AppBar(
                        title: const Text('User Profile'),
                      ),
                      actions: [
                        SignedOutAction((context) {
                          Navigator.of(context).pop();
                        })
                      ],
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset('assets/Earth black 1.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
          automaticallyImplyLeading: false,
        ),
        body: userStream.when(
          data: (data) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: ref.read(bodyControllerProvider),
                  decoration: InputDecoration(
                    labelText: "What's your carbon-saving win today?",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: () =>
                            showPreview(context, ref), // Text-only option
                        child: Text('Text'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                        )),
                    ElevatedButton(
                        onPressed: () => pickImage(context, ref),
                        child: Text('Photos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                        )),
                    ElevatedButton(
                        onPressed: () => pickVideo(context, ref),
                        child: Text('Videos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                        )),
                  ],
                ),
                SizedBox(height: 20),
                if (ref.watch(mediaProvider) != null)
                  TextButton(
                    onPressed: () => showPreview(context, ref),
                    child: Text('Preview Post'),
                  ),
                Expanded(
                  child: postsAsyncValue.when(
                    data: (posts) {
                      print(
                          'Number of posts: ${posts.length}'); // Check if posts are being fetched
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(post: post);
                        },
                      );
                    },
                    loading: () => Center(
                        child:
                            CircularProgressIndicator()), // Make sure you show a loading indicator
                    error: (error, stackTrace) {
                      print('Error: $error'); // Debug errors
                      return Center(
                          child: Text('Error fetching posts: $error'));
                    },
                  ),
                ),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) =>
              Center(child: Text('Error: $error')),
          loading: () => Center(child: CircularProgressIndicator()),
        ));
  }
}

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  Future<DocumentSnapshot?> _getUserData(String userId) async {
    try {
      print('Fetching data for user ID: $userId');
      return await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<bool> _hasUserLikedPost(String userId) async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.post_id)
        .collection('likes')
        .doc(userId)
        .get();
    return likesSnapshot.exists;
  }

  String _getRelativeTime(DateTime postTime) {
    return timeago.format(postTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
    final user = userStream.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot?>(
              future: _getUserData(post.posted_user_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Loading...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else if (snapshot.hasError || !snapshot.data!.exists) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Anonymous',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                } else {
                  var userData =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  String username = userData['username'] ?? 'Anonymous';
                  String? profileImageUrl = userData['profile_picture_url'];

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : null,
                            child: profileImageUrl == null
                                ? Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: Text(
                              username,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _getRelativeTime(DateTime.fromMillisecondsSinceEpoch(
                            post.created_at.millisecondsSinceEpoch)),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            Text(post.title, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(post.body),
            const SizedBox(height: 12),
            if (post.media_url != null && post.media_type == 'image')
              Image.network(post.media_url!),
            if (post.media_url != null && post.media_type == 'video')
              VideoPlayerWidget(mediaUrl: post.media_url!),
            const SizedBox(height: 12),
            FutureBuilder<bool>(
              future: user != null
                  ? _hasUserLikedPost(user.uid)
                  : Future.value(false),
              builder: (context, snapshot) {
                bool isLiked =
                    snapshot.data ?? false; // Default to false while loading

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (user != null && post.post_id.isNotEmpty) {
                              await toggleLikePost(post.post_id, user.uid);
                              ref.refresh(
                                  userStreamProvider); // Refresh user stream to update likes status
                            } else {
                              print('Error: Post ID or user is invalid');
                            }
                          },
                          icon: Icon(
                            Icons.thumb_up,
                            color: isLiked
                                ? Colors.green
                                : Colors
                                    .grey, // Change color based on like status
                          ),
                        ),
                        Text('${post.likes_count}'),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CommentSection(postId: post.post_id);
                          },
                        );
                      },
                      icon: Icon(Icons.comment),
                    ),
                    IconButton(
                      onPressed: () {
                        _sharePost(post);
                      },
                      icon: Icon(Icons.share),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String mediaUrl;

  const VideoPlayerWidget({Key? key, required this.mediaUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.mediaUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : CircularProgressIndicator();
  }
}

void _sharePost(PostModel post) {
  String shareText = "${post.title}\n\n${post.body}";
  if (post.media_url != null) {
    shareText += "\n\nCheck this out: ${post.media_url}";
  }

  Share.share(shareText, subject: post.title); // Use the Share package
}

Future<void> toggleLikePost(String postId, String userId) async {
  if (postId.isEmpty || userId.isEmpty) {
    print('Error: Post ID or user is invalid');
    return;
  }

  // Reference to the post document
  final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

  // Check if the user has already liked the post
  final likesSnapshot = await postRef.collection('likes').doc(userId).get();
  if (likesSnapshot.exists) {
    // User has already liked the post, so remove the like
    await postRef.collection('likes').doc(userId).delete();
  } else {
    // User hasn't liked the post yet, so add a like
    await postRef.collection('likes').doc(userId).set({});
  }

  // Optional: You can update the likes_count field if you want to track likes count in Firestore
  final postSnapshot = await postRef.get();
  final currentLikesCount = postSnapshot.data()?['likes_count'] ?? 0;
  final newLikesCount =
      likesSnapshot.exists ? currentLikesCount - 1 : currentLikesCount + 1;

  await postRef.update({'likes_count': newLikesCount});
}

Future<void> addComment(
    String postId, String userId, String commentText) async {
  if (commentText.isEmpty) return;

  // Creating a unique comment ID
  final commentId = FirebaseFirestore.instance.collection('comments').doc().id;

  // Creating the comment model
  final comment = {
    'comment_id': commentId,
    'comment_text': commentText,
    'commented_user_id': userId,
    'post_id': postId,
    'created_at': Timestamp.now(),
  };

  // Adding the comment to Firestore under the 'comments' collection
  await FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .set(comment);
}

class CommentSection extends ConsumerWidget {
  final String postId;
  const CommentSection({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          // Text Field for adding a comment
          TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final userStream = ref.read(userStreamProvider);
                  final user = userStream.value;
                  if (user != null && commentController.text.isNotEmpty) {
                    await addComment(postId, user.uid, commentController.text);
                    commentController.clear();
                  }
                },
              ),
            ),
          ),
          // Fetching and displaying comments
          StreamBuilder<List<CommentsModel>>(
            stream: getComments(postId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final comments = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Picture
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection(
                                      'user') // Assuming your users are stored in 'user' collection
                                  .doc(comment.commented_user_id)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.grey[300],
                                  );
                                } else if (snapshot.hasError ||
                                    !snapshot.data!.exists) {
                                  return CircleAvatar(
                                    radius: 18,
                                    child:
                                        Icon(Icons.person, color: Colors.grey),
                                    backgroundColor: Colors.grey[200],
                                  );
                                } else {
                                  final userData = snapshot.data!.data()
                                      as Map<String, dynamic>?;
                                  final profilePictureUrl =
                                      userData?['profile_picture_url'];
                                  final username = userData?['username'] ??
                                      'Unknown User'; // Fetching username

                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundImage: profilePictureUrl != null
                                        ? NetworkImage(profilePictureUrl)
                                        : null,
                                    child: profilePictureUrl == null
                                        ? Icon(Icons.person)
                                        : null,
                                  );
                                }
                              },
                            ),
                            const SizedBox(
                                width:
                                    10), // Space between avatar and comment text

                            // Comment and Username
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection(
                                            'user') // Fetch username again
                                        .doc(comment.commented_user_id)
                                        .get(),
                                    builder: (context, snapshot) {
                                      String username =
                                          'Unknown User'; // Default username
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text('Loading...');
                                      } else if (snapshot.hasError ||
                                          !snapshot.data!.exists) {
                                        return Text(username);
                                      } else {
                                        final userData = snapshot.data!.data()
                                            as Map<String, dynamic>?;
                                        username = userData?['username'] ??
                                            username; // Fetching username
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      '$username ', // Displaying Username
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            comment
                                                .comment_text, // Comment Text
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                      height:
                                          4), // Space between comment and timestamp

                                  // Timestamp
                                  Text(
                                    timeago.format(comment.created_at
                                        .toDate()), // Relative time
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < comments.length - 1)
                        Divider(
                            thickness:
                                0.5), // Thin divider except after the last comment
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
