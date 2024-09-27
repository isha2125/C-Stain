//import 'package:cstain/backend/auth_gate.dart';
import 'package:cstain/components/streak_service.dart';
import 'package:cstain/models/achievements.dart';
import 'package:cstain/models/badges.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_badges.dart';
import 'package:cstain/providers/auth_service.dart';
import 'package:cstain/providers/providers.dart';
import 'package:cstain/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'profile_screen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

final achievementsProvider =
    FutureProvider<List<AchievementsModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final achievements = await firestoreService.fetchAchievements();
  print("Fetched ${achievements.length} achievements");
  return achievements;
});
final userStreamProvider = StreamProvider.autoDispose<UserModel>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception('User not authenticated');
  return ref.watch(firestoreServiceProvider).getUserStream(user.uid);
});

//final userProvider = StateProvider<User?>((ref) => User(full_name: "Aditya"));
//final co2SavedProvider = StateProvider<double>((ref) => 100.0);
final achievementProgressProvider = StateProvider<double>((ref) => 0.75);
final tipOfTheDayProvider =
    StateProvider<String>((ref) => 'Save water, save life!');

// class User {
//   final String full_name;
//   User({required this.full_name});
// }

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);
    final achievements = ref.watch(achievementsProvider);
    print("Achievements state: ${achievements.toString()}");
    final userBadges = ref.watch(userBadgesProvider);
    //final myUser = ref.watch(userProvider);
    //final co2Saved = ref.watch(co2SavedProvider);
    //final achievementProgress = ref.watch(achievementProgressProvider);
    final tipOfTheDay = ref.watch(tipOfTheDayProvider);

    return Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/Earth black 1.png'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MYProfileScreen(),
                    // builder: (context) => ProfileScreen(
                    //   appBar: AppBar(
                    //     title: const Text('User Profile'),
                    //   ),
                    //   actions: [
                    //     SignedOutAction((context) {
                    //       Navigator.of(context).pop();
                    //     })
                    //   ],
                    //   children: [
                    //     const Divider(),
                    //     Padding(
                    //       padding: const EdgeInsets.all(2),
                    //       child: AspectRatio(
                    //         aspectRatio: 1,
                    //         child: Image.asset('assets/Earth black 1.png'),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                );
              },
            )
          ],
          automaticallyImplyLeading: false,
        ),
        body: userStream.when(
          data: (myUser) => achievements.when(
            data: (achievementsList) => SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // CO2 Saved Widget
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          //Colors.green.shade800,
                          Color.fromARGB(255, 60, 188, 141),
                          Color(0xFF237155),
                          //Colors.greenAccent.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total CO2 Saved',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${myUser.total_CO2_saved.toStringAsFixed(2)} kg',
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Streak Tracker for a Week
                  StreakWidget(),

                  SizedBox(height: 20),

                  // Achievement Progress
                  _buildAchievementProgress(myUser, achievementsList, ref),

                  SizedBox(height: 10),

                  // Tip of the Day
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.lightbulb_outline,
                          color: Colors.orange, size: 40),
                      title: Text(
                        'Tip of the Day',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        tipOfTheDay,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ), // Badges List
                  userBadges.when(
                    data: (badges) => _buildBadgesList(badges, ref),
                    loading: () => CircularProgressIndicator(),
                    error: (error, stack) =>
                        Text('Error loading badges: $error'),
                  ),
                ],
              ),
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ));
  }

  Widget _buildAchievementProgress(
      UserModel user, List<AchievementsModel> achievements, WidgetRef ref) {
    print("User CO2 saved: ${user.total_CO2_saved}");
    print("Number of achievements: ${achievements.length}");
    // Find the next achievement
    achievements.sort((a, b) => a.co2_threshold.compareTo(b.co2_threshold));
    final nextAchievement = achievements.isNotEmpty
        ? achievements.firstWhere(
            (a) => a.co2_threshold > user.total_CO2_saved,
            orElse: () => achievements.last,
          )
        : null;

    if (nextAchievement == null) {
      print("No next achievement found");
      return Center(child: Text('No achievements available.'));
    }
    final previousAchievement = achievements.lastWhere(
      (a) => a.co2_threshold <= user.total_CO2_saved,
      orElse: () => achievements.first,
    );
    // Check if the user has just completed an achievement
    if (previousAchievement != achievements.first &&
        user.total_CO2_saved >= previousAchievement.co2_threshold) {
      // Store the completed achievement
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final firestoreService = ref.read(firestoreServiceProvider);
        final hasAchievement = await firestoreService.hasUserAchievement(
          user.uid,
          previousAchievement.achievement_id,
        );
        if (!hasAchievement) {
          await firestoreService.storeUserAchievement(
            user.uid,
            previousAchievement.achievement_id,
          );
          print(
              'Achievement ${previousAchievement.name} stored for user ${user.uid}');
        }
      });
    }

    print("Next achievement: ${nextAchievement.name}");

    final progress =
        (user.total_CO2_saved - previousAchievement.co2_threshold) /
            (nextAchievement.co2_threshold - previousAchievement.co2_threshold);
    final cappedProgress = progress.clamp(0.0, 1.0);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              progress >= 1
                  ? "Congratulations! You've reached the highest achievement!"
                  : "Next achievement: ${nextAchievement.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text(
              'Achievement Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 13.0,
              animation: true,
              percent: cappedProgress,
              center: Icon(
                Icons.star,
                size: 50.0,
                color: Color(0xFFE04034),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Color(0xFF237155),
              backgroundColor: Colors.grey[300] ?? Colors.grey,
              footer: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  '${user.total_CO2_saved.toStringAsFixed(2)} kg / ${nextAchievement.co2_threshold.toStringAsFixed(2)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              nextAchievement.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text(
              previousAchievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBadgesList(List<UserBadgesModel> userBadges, WidgetRef ref) {
  final allBadges = ref.watch(badgesProvider);
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Badges',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          if (userBadges.isEmpty)
            Text(
              'Try to be consistent to earn a badge!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
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
                            width: 60,
                            height: 60,
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
                            style: TextStyle(fontSize: 12),
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
    ),
  );
}
