import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cstain/backend/sign_out.dart';
import 'package:cstain/models/comments.dart';
import 'package:cstain/models/post.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_badges.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/providers/action%20providers/providers.dart';
import 'package:cstain/screens/community_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

Stream<int> _getFollowersCount(String profileUserId) {
  return FirebaseFirestore.instance
      .collection('follows')
      .where('following_user_id', isEqualTo: profileUserId)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

Stream<int> _getFollowingCount(String profileUserId) {
  return FirebaseFirestore.instance
      .collection('follows')
      .where('follower_user_id', isEqualTo: profileUserId)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

final userPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, profileUserId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .where('posted_user_id', isEqualTo: profileUserId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            // Convert doc.data() to a Map<String, dynamic> and set post_id directly
            final postData = doc.data() as Map<String, dynamic>;

            // Manually set post_id in the map
            postData['post_id'] = doc.id;

            // Now call fromMap with the modified map
            return PostModel.fromMap(postData);
          }).toList());
});

final profileUserStreamProvider =
    StreamProvider.family<UserModel, String>((ref, profileUserId) {
  return FirebaseFirestore.instance
      .collection('user')
      .doc(profileUserId)
      .snapshots()
      .map((snapshot) {
    final data = snapshot.data(); // Get the data as a Map<String, dynamic>
    if (data != null) {
      return UserModel.fromMap(data); // Pass only the data map, no document ID
    } else {
      throw Exception('User data is null');
    }
  });
});

final ProfileUserBadgesProvider =
    StreamProvider.family<List<UserBadgesModel>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('user_badges') // Replace with your actual collection
      .where('user_id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return UserBadgesModel.fromMap(doc.data()); // Adjust if necessary
    }).toList();
  });
});
final ProfileUserAchievementsWithDetailsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection(
          'user_achievements') // Replace with your actual collection name
      .where('user_id', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>; // Cast to Map
    }).toList();
  });
});

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

class MYProfileScreen extends ConsumerWidget {
  final String profileUserId;

  MYProfileScreen({required this.profileUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user =
        ref.watch(userProvider); // Assuming you have a provider for user
    final isCorporate = user?.role == 'corp';
    // Get the current user data from auth provider
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.value;

    // Check if the profile being viewed is the current user's own profile
    final isCurrentUserProfile = currentUser?.uid == profileUserId;

    // Get the profile data for the user whose profile is being viewed
    final userStream = ref.watch(profileUserStreamProvider(profileUserId));

    // Fetch posts for the profile being viewed
    final userPosts = ref.watch(userPostsProvider(profileUserId));

    // Fetch user badges and achievements (optional)
    final userBadges = ref.watch(ProfileUserBadgesProvider(profileUserId));
    final userAchievementsStream =
        ref.watch(ProfileUserAchievementsWithDetailsProvider(profileUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isCurrentUserProfile)
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                    break;
                  case 1:
                    signOut(context, ref);
                    break;
                  case 2:
                    _deleteAccount(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black),
                      SizedBox(width: 10),
                      Text("Settings"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.black),
                      SizedBox(width: 10),
                      Text("Sign Out"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Delete Account"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: userStream.when(
        data: (profileUser) {
          // Ensure you're displaying the profileUser's data (not the current user's)
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage(profileUser.profile_picture_url),
                    ),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileUser
                                .username, // Show the profile user's username
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (profileUser.bio.isNotEmpty) ...[
                            Text(
                              profileUser.bio, // Show the profile user's bio
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 10)
                          ],
                          Row(
                            children: [
                              StreamBuilder<int>(
                                stream: _getFollowersCount(profileUserId),
                                builder: (context, snapshot) {
                                  return Text('${snapshot.data ?? 0} Followers',
                                      style:
                                          TextStyle(color: Color(0xFF237155)));
                                },
                              ),
                              const SizedBox(width: 10),
                              StreamBuilder<int>(
                                stream: _getFollowingCount(profileUserId),
                                builder: (context, snapshot) {
                                  return Text('${snapshot.data ?? 0} Following',
                                      style:
                                          TextStyle(color: Color(0xFF237155)));
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('follows')
                        .where('follower_user_id',
                            isEqualTo: currentUser?.uid) // The current user
                        .where('following_user_id',
                            isEqualTo:
                                profileUserId) // The profile being viewed
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Check if current user is following the profile user
                      bool isFollowing =
                          snapshot.data?.docs.isNotEmpty ?? false;

                      return ElevatedButton(
                        onPressed: () {
                          if (isCurrentUserProfile) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            );
                          } else {
                            _toggleFollow(ref, profileUserId,
                                currentUser!.uid); // Added currentUserId here
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentUserProfile
                              ? Color(
                                  0xFF237155) // Green color for Edit Profile
                              : (isFollowing
                                  ? Colors.grey
                                  : Color(
                                      0xFF237155)), // Grey for Unfollow, Green for Follow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isCurrentUserProfile
                              ? 'Edit Profile'
                              : (isFollowing
                                  ? 'Unfollow'
                                  : 'Follow'), // Dynamic text change
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: Color(0xFF237155),
                          labelColor: Colors.black,
                          tabs: [
                            Tab(text: 'Posts'),
                            Tab(text: isCorporate ? 'Campaigns' : 'Badges'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              userPosts.when(
                                data: (posts) {
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount: posts.length,
                                    itemBuilder: (context, index) {
                                      final post = posts[index];
                                      return PostCard(post: post);
                                    },
                                  );
                                },
                                loading: () =>
                                    Center(child: CircularProgressIndicator()),
                                error: (error, stack) =>
                                    Center(child: Text('Error: $error')),
                              ),
                              isCorporate
                                  ? _buildCampaignsSection(user!.uid)
                                  : userBadges.when(
                                      data: (badges) =>
                                          _buildBadgesList(badges, ref),
                                      loading: () =>
                                          CircularProgressIndicator(),
                                      error: (error, stack) =>
                                          Text('Error loading badges: $error'),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // void _signOut(BuildContext context) {
  //   // Implement sign out logic
  // }

  void _deleteAccount(BuildContext context) {
    // Implement delete account logic
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(child: Text("Settings Page")),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Center(child: Text("Edit Profile Page")),
    );
  }
}

Widget _buildBadgesList(List<UserBadgesModel> userBadges, WidgetRef ref) {
  final allBadges = ref.watch(badgesProvider);
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userBadges.isEmpty)
          Center(
            child: Text(
              'Try to be consistent to earn a badge!',
              style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600]),
            ),
          )
        else
          allBadges.when(
            data: (badges) {
              final badgeMap = {
                for (var badge in badges) badge.badge_id: badge
              };
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: userBadges.map((userBadge) {
                  final badge = badgeMap[userBadge.badge_id];
                  return Tooltip(
                    message: badge?.description ?? 'Unknown badge',
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(badge?.badge_url ??
                                  'https://placeholder.com/60x60'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          badge?.name ?? 'Unknown',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading badges: $error'),
          ),
      ],
    ),
  );
}

class PostCard extends ConsumerWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  Future<DocumentSnapshot?> _getUserData(String userId) async {
    try {
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
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
                  return _buildUserRow(context, 'Loading...', null);
                } else if (snapshot.hasError || !snapshot.data!.exists) {
                  return _buildUserRow(context, 'Anonymous', null);
                } else {
                  var userData =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  return _buildUserRow(
                      context,
                      userData['username'] ?? 'Anonymous',
                      userData['profile_picture_url']);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(post.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(post.body, maxLines: 4, overflow: TextOverflow.ellipsis),
            if (post.media_url != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: post.media_type == 'image'
                      ? Image.network(
                          post.media_url!,
                          width: screenWidth * 0.9,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : VideoPlayerWidget(mediaUrl: post.media_url!),
                ),
              ),
            _buildInteractionRow(context, user, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(
      BuildContext context, String username, String? profileImageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MYProfileScreen(profileUserId: post.posted_user_id),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null ? Icon(Icons.person) : null,
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150),
                child: Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
        Text(
          _getRelativeTime(DateTime.fromMillisecondsSinceEpoch(
              post.created_at.millisecondsSinceEpoch)),
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInteractionRow(BuildContext context, user, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: user != null ? _hasUserLikedPost(user.uid) : Future.value(false),
      builder: (context, snapshot) {
        bool isLiked = snapshot.data ?? false;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () async {
                if (user != null && post.post_id.isNotEmpty) {
                  await toggleLikePost(post.post_id, user.uid);
                  ref.refresh(userStreamProvider);
                }
              },
              icon: Icon(Icons.thumb_up,
                  color: isLiked ? Colors.green : Colors.grey),
            ),
            Text('${post.likes_count}'),
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
    );
  }
}

void _sharePost(PostModel post) {
  String shareText = "${post.title}\n\n${post.body}";
  if (post.media_url != null) {
    shareText += "\n\nCheck this out: ${post.media_url}";
  }

  Share.share(shareText, subject: post.title); // Use the Share package
}

void _toggleFollow(
    WidgetRef ref, String profileUserId, String currentUserId) async {
  final followsRef = FirebaseFirestore.instance.collection('follows');

  // Check if the current user is already following the profile user
  final followDoc = await followsRef
      .where('follower_user_id', isEqualTo: currentUserId)
      .where('following_user_id', isEqualTo: profileUserId)
      .limit(1)
      .get();

  if (followDoc.docs.isEmpty) {
    // Not following, so follow
    await followsRef.add({
      'follower_user_id': currentUserId,
      'following_user_id': profileUserId,
      'created_at': Timestamp.now(),
    });
  } else {
    // Already following, so unfollow
    await followsRef.doc(followDoc.docs[0].id).delete();
  }
}

Widget _buildFollowButton(
    WidgetRef ref, String profileUserId, String currentUserId) {
  final followsRef = FirebaseFirestore.instance.collection('follows');

  return StreamBuilder<QuerySnapshot>(
    stream: followsRef
        .where('follower_user_id', isEqualTo: currentUserId)
        .where('following_user_id', isEqualTo: profileUserId)
        .snapshots(),
    builder: (context, snapshot) {
      bool isFollowing = snapshot.data?.docs.isNotEmpty ?? false;

      return ElevatedButton(
        onPressed: () => _toggleFollow(ref, profileUserId, currentUserId),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.grey : Color(0xFF237155),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
      );
    },
  );
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

Widget _buildCampaignsSection(String corporateUserId) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('campaigns')
        .where('corpUserId', isEqualTo: corporateUserId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No campaigns available'));
      }
      var campaigns = snapshot.data!.docs;
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          var campaign = campaigns[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    campaign['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CO₂ Savings: ${campaign['targetCO2Savings']} kg',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.eco, color: Color(0xFF237155)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
