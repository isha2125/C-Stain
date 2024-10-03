import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cstain/providers/providers.dart';
import 'package:cstain/models/user.dart';
import 'package:cstain/models/user_contribution.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStream = ref.watch(userStreamProvider);

    return Scaffold(
      appBar: AppBar(
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
        data: (user) => _buildDashboard(context, ref, user),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, UserModel user) {
    final userContributions = ref.watch(userContributionsProvider(user.uid));

    return userContributions.when(
      data: (contributions) => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserSummary(user),
            SizedBox(height: 20),
            _buildCO2SavedChart(contributions),
            SizedBox(height: 20),
            _buildRecentContributions(contributions),
            SizedBox(height: 20),
            _buildStreakInfo(user),
          ],
        ),
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildUserSummary(UserModel user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${user.full_name}!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Total CO2 Saved: ${user.total_CO2_saved.toStringAsFixed(2)} kg',
                style: TextStyle(fontSize: 18)),
            Text('Current Streak: ${user.currentStreak} days',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildCO2SavedChart(List<UserContributionModel> contributions) {
    // Group contributions by date and sum CO2 saved
    final groupedData = groupContributionsByDate(contributions);
    final sortedDates = groupedData.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CO2 Saved Over Time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()} kg');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedDates.length) {
                            return Text(
                                DateFormat('dd/MM').format(sortedDates[index]));
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: sortedDates.length.toDouble() - 1,
                  minY: 0,
                  maxY: groupedData.values.reduce((a, b) => a > b ? a : b),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedDates.asMap().entries.map((entry) {
                        return FlSpot(
                            entry.key.toDouble(), groupedData[entry.value]!);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.green.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, double> groupContributionsByDate(
      List<UserContributionModel> contributions) {
    final groupedData = <DateTime, double>{};
    for (var contribution in contributions) {
      final date = DateTime(
        contribution.createdAtDateTime.year,
        contribution.createdAtDateTime.month,
        contribution.createdAtDateTime.day,
      );
      groupedData[date] = (groupedData[date] ?? 0) + contribution.co2_saved;
    }
    return groupedData;
  }

  Widget _buildRecentContributions(List<UserContributionModel> contributions) {
    final recentContributions = contributions.take(5).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Contributions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recentContributions.length,
              itemBuilder: (context, index) {
                final contribution = recentContributions[index];
                return ListTile(
                  title: Text(contribution.action),
                  subtitle: Text(
                      '${contribution.co2_saved.toStringAsFixed(2)} kg CO2 saved'),
                  trailing: Text(DateFormat('dd/MM/yyyy')
                      .format(contribution.createdAtDateTime)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakInfo(UserModel user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Streak',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakDay('Sun', user.streak_sunday),
                _buildStreakDay('Mon', user.streak_monday),
                _buildStreakDay('Tue', user.streak_tuesday),
                _buildStreakDay('Wed', user.streak_wednesday),
                _buildStreakDay('Thu', user.streak_thursday),
                _buildStreakDay('Fri', user.streak_friday),
                _buildStreakDay('Sat', user.streak_saturday),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakDay(String day, bool isActive) {
    return Column(
      children: [
        Text(day),
        Icon(
          isActive ? Icons.check_circle : Icons.circle_outlined,
          color: isActive ? Colors.green : Colors.grey,
        ),
      ],
    );
  }
}
