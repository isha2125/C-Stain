import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/providers.dart';
import '../models/user_contribution.dart';
import '../components/loader.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic here
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildDateRangePicker(),
              _buildSummaryCards(),
              _buildChartSection('CO2 Saved Over Time',
                  CO2SavedOverTimeChart(dateRange: _dateRange)),
              _buildChartSection('Weekly Progress',
                  WeeklyProgressChart(dateRange: _dateRange)),
              _buildChartSection('Monthly Comparison',
                  MonthlyComparisonChart(dateRange: _dateRange)),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Impact',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Keep up the great work!',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.date_range, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Text('Date Range:'),
          TextButton(
            onPressed: _selectDateRange,
            child: Text(
              '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  Widget _buildSummaryCards() {
    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSummaryCard('Total CO2 Saved', '1,234 kg', Icons.eco),
          _buildSummaryCard('Actions Taken', '56', Icons.check_circle),
          _buildSummaryCard('Streak', '7 days', Icons.local_fire_department),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(right: 16),
      child: Container(
        width: 160,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, Widget chart) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }
}

class CO2SavedOverTimeChart extends ConsumerWidget {
  final DateTimeRange dateRange;

  CO2SavedOverTimeChart({required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsyncValue =
        ref.watch(filteredUserContributionsProvider(dateRange));

    return contributionsAsyncValue.when(
      loading: () => Loader(),
      error: (error, stack) => Text('Error: $error'),
      data: (contributions) {
        if (contributions.isEmpty) {
          return Center(
              child: Text('No data available for the selected date range.'));
        }

        contributions
            .sort((a, b) => a.createdAtDateTime.compareTo(b.createdAtDateTime));

        final cumulativeCO2Saved = <FlSpot>[];
        double totalCO2Saved = 0;

        for (var i = 0; i < contributions.length; i++) {
          totalCO2Saved += contributions[i].co2_saved;
          cumulativeCO2Saved.add(FlSpot(i.toDouble(), totalCO2Saved));
        }

        final interval = contributions.length > 1
            ? (contributions.length / 5).ceil().toDouble()
            : 1.0;

        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < contributions.length) {
                      return Text(contributions[index]
                          .createdAtDateTime
                          .day
                          .toString());
                    }
                    return Text('');
                  },
                  interval: interval,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: cumulativeCO2Saved.length.toDouble() - 1,
            minY: 0,
            maxY: cumulativeCO2Saved.last.y,
            lineBarsData: [
              LineChartBarData(
                spots: cumulativeCO2Saved,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeeklyProgressChart extends ConsumerWidget {
  final DateTimeRange dateRange;

  WeeklyProgressChart({required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyDataAsyncValue = ref.watch(weeklyDataProvider(dateRange));

    return weeklyDataAsyncValue.when(
      loading: () => Loader(),
      error: (error, stack) => Text('Error: $error'),
      data: (weeklyData) {
        if (weeklyData.isEmpty) {
          return Center(
              child: Text(
                  'No weekly data available for the selected date range.'));
        }

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: weeklyData.values.reduce((a, b) => a > b ? a : b),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) =>
                      Text('Week ${value.toInt() + 1}'),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: weeklyData.entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Theme.of(context).primaryColor,
                    width: 16,
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class MonthlyComparisonChart extends ConsumerWidget {
  final DateTimeRange dateRange;

  MonthlyComparisonChart({required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyDataAsyncValue = ref.watch(monthlyDataProvider(dateRange));

    return monthlyDataAsyncValue.when(
      loading: () => Loader(),
      error: (error, stack) => Text('Error: $error'),
      data: (monthlyData) {
        if (monthlyData.isEmpty) {
          return Center(
              child: Text(
                  'No monthly data available for the selected date range.'));
        }

        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final month = DateTime(dateRange.start.year,
                        dateRange.start.month + value.toInt(), 1);
                    return Text(DateFormat.MMM().format(month));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: monthlyData.length.toDouble() - 1,
            minY: 0,
            maxY: monthlyData.values.reduce((a, b) => a > b ? a : b),
            lineBarsData: [
              LineChartBarData(
                spots: monthlyData.entries
                    .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                    .toList(),
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
            ],
          ),
        );
      },
    );
  }
}
/********************************************************************** */
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../providers/providers.dart';
// import '../models/user_contribution.dart';
// import '../components/loader.dart';
// import 'package:intl/intl.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   String? _selectedCategory;
//   DateTimeRange _dateRange = DateTimeRange(
//     start: DateTime.now().subtract(Duration(days: 30)),
//     end: DateTime.now(),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () => Navigator.pushNamed(context, '/profile'),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           // Implement refresh logic here
//         },
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               _buildDateRangePicker(),
//               _buildSummaryCards(),
//               _buildChartSection('CO2 Saved Over Time',
//                   CO2SavedOverTimeChart(dateRange: _dateRange)),
//               _buildChartSection('Weekly Progress',
//                   WeeklyProgressChart(dateRange: _dateRange)),
//               _buildChartSection('Monthly Comparison',
//                   MonthlyComparisonChart(dateRange: _dateRange)),
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Implement action logging functionality
//         },
//         child: Icon(Icons.add),
//         tooltip: 'Log Action',
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).primaryColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Your Impact',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall!
//                 .copyWith(color: Colors.white),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Keep up the great work!',
//             style: TextStyle(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateRangePicker() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Icon(Icons.date_range, color: Theme.of(context).primaryColor),
//           SizedBox(width: 8),
//           Text('Date Range:'),
//           TextButton(
//             onPressed: _selectDateRange,
//             child: Text(
//               '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: _dateRange,
//     );
//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//     }
//   }

//   Widget _buildSummaryCards() {
//     return Container(
//       height: 100,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         children: [
//           _buildSummaryCard('Total CO2 Saved', '1,234 kg', Icons.eco),
//           _buildSummaryCard('Actions Taken', '56', Icons.check_circle),
//           _buildSummaryCard('Streak', '7 days', Icons.local_fire_department),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, String value, IconData icon) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.only(right: 16),
//       child: Container(
//         width: 160,
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Icon(icon, color: Theme.of(context).primaryColor),
//             Text(title,
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//             Text(value,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryPicker() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Icon(Icons.category, color: Theme.of(context).primaryColor),
//           SizedBox(width: 8),
//           Text('Select Category:'),
//           Consumer(
//             builder: (context, ref, _) {
//               final categoriesAsyncValue = ref.watch(categoriesProvider);
//               return categoriesAsyncValue.when(
//                 loading: () => CircularProgressIndicator(),
//                 error: (error, _) => Text('Error: $error'),
//                 data: (categories) {
//                   List<String> categoryNames = [
//                     'All' +
//                         categories
//                             .map((c) => c.category_name)
//                             .where((name) => name != null)
//                             .cast<String>()
//                             .toSet()
//                             .toList()
//                   ];
//                   return DropdownButton<String>(
//                     value: _selectedCategory ?? 'All',
//                     items: categoryNames
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedCategory = newValue == 'All' ? null : newValue;
//                       });
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartSection(String title, Widget chart) {
//     return Card(
//       margin: EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: Theme.of(context).textTheme.titleLarge),
//             SizedBox(height: 16),
//             SizedBox(height: 200, child: chart),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CO2SavedOverTimeChart extends ConsumerWidget {
//   final DateTimeRange dateRange;

//   CO2SavedOverTimeChart({required this.dateRange});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contributionsAsyncValue = ref.watch(filteredUserContributionsProvider(
//         FilterParams(dateRange: dateRange, category: _selectedCategory)));

//     return contributionsAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (contributions) {
//         if (contributions.isEmpty) {
//           return Center(
//               child: Text('No data available for the selected date range.'));
//         }

//         contributions
//             .sort((a, b) => a.createdAtDateTime.compareTo(b.createdAtDateTime));

//         final cumulativeCO2Saved = <FlSpot>[];
//         double totalCO2Saved = 0;

//         for (var i = 0; i < contributions.length; i++) {
//           totalCO2Saved += contributions[i].co2_saved;
//           cumulativeCO2Saved.add(FlSpot(i.toDouble(), totalCO2Saved));
//         }

//         final interval = contributions.length > 1
//             ? (contributions.length / 5).ceil().toDouble()
//             : 1.0;

//         return LineChart(
//           LineChartData(
//             gridData: FlGridData(show: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final index = value.toInt();
//                     if (index >= 0 && index < contributions.length) {
//                       return Text(contributions[index]
//                           .createdAtDateTime
//                           .day
//                           .toString());
//                     }
//                     return Text('');
//                   },
//                   interval: interval,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             minX: 0,
//             maxX: cumulativeCO2Saved.length.toDouble() - 1,
//             minY: 0,
//             maxY: cumulativeCO2Saved.last.y,
//             lineBarsData: [
//               LineChartBarData(
//                 spots: cumulativeCO2Saved,
//                 isCurved: true,
//                 color: Theme.of(context).primaryColor,
//                 barWidth: 3,
//                 dotData: FlDotData(show: false),
//                 belowBarData: BarAreaData(
//                     show: true,
//                     color: Theme.of(context).primaryColor.withOpacity(0.3)),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class WeeklyProgressChart extends ConsumerWidget {
//   final DateTimeRange dateRange;

//   WeeklyProgressChart({required this.dateRange});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final weeklyDataAsyncValue = ref.watch(weeklyDataProvider(dateRange));

//     return weeklyDataAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (weeklyData) {
//         if (weeklyData.isEmpty) {
//           return Center(
//               child: Text(
//                   'No weekly data available for the selected date range.'));
//         }

//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: weeklyData.values.reduce((a, b) => a > b ? a : b),
//             barTouchData: BarTouchData(enabled: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) =>
//                       Text('Week ${value.toInt() + 1}'),
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: false),
//             barGroups: weeklyData.entries.map((entry) {
//               return BarChartGroupData(
//                 x: entry.key,
//                 barRods: [
//                   BarChartRodData(
//                     toY: entry.value,
//                     color: Theme.of(context).primaryColor,
//                     width: 16,
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

// class MonthlyComparisonChart extends ConsumerWidget {
//   final DateTimeRange dateRange;

//   MonthlyComparisonChart({required this.dateRange});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contributionsAsyncValue =
//         ref.watch(monthlyContributionsProvider(dateRange));
//     return monthlyDataAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (monthlyData) {
//         if (monthlyData.isEmpty) {
//           return Center(
//               child: Text(
//                   'No monthly data available for the selected date range.'));
//         }

//         return LineChart(
//           LineChartData(
//             gridData: FlGridData(show: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final month = DateTime(dateRange.start.year,
//                         dateRange.start.month + value.toInt(), 1);
//                     return Text(DateFormat.MMM().format(month));
//                   },
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             minX: 0,
//             maxX: monthlyData.length.toDouble() - 1,
//             minY: 0,
//             maxY: monthlyData.values.reduce((a, b) => a > b ? a : b),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: monthlyData.entries
//                     .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
//                     .toList(),
//                 isCurved: true,
//                 color: Theme.of(context).primaryColor,
//                 barWidth: 3,
//                 dotData: FlDotData(show: true),
//                 belowBarData: BarAreaData(
//                     show: true,
//                     color: Theme.of(context).primaryColor.withOpacity(0.3)),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//************************************************************* */

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../providers/providers.dart';
// import '../models/user_contribution.dart';
// import '../components/loader.dart';
// import 'package:intl/intl.dart';
// import 'package:tuple/tuple.dart';

// class DashboardScreen extends ConsumerStatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen> {
//   DateTimeRange _dateRange = DateTimeRange(
//     start: DateTime.now().subtract(Duration(days: 30)),
//     end: DateTime.now(),
//   );

//   String? _selectedCategory; // Added missing state variable

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Dashboard',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Theme.of(context).primaryColor,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () => Navigator.pushNamed(context, '/profile'),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           // Implement refresh logic here
//           // Example: ref.refresh(actionsProvider);
//           // Add any additional providers you need to refresh
//         },
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               _buildDateRangePicker(),
//               _buildCategoryPicker(), // Added category picker to the UI
//               _buildSummaryCards(),
//               _buildChartSection(
//                 'CO2 Saved Over Time',
//                 CO2SavedOverTimeChart(
//                   dateRange: _dateRange,
//                   category: _selectedCategory,
//                 ),
//               ),
//               _buildChartSection(
//                 'Weekly Progress',
//                 WeeklyProgressChart(
//                   dateRange: _dateRange,
//                   category: _selectedCategory,
//                 ),
//               ),
//               _buildChartSection(
//                 'Monthly Comparison',
//                 MonthlyComparisonChart(
//                   dateRange: _dateRange,
//                   category: _selectedCategory,
//                 ),
//               ),
//               _buildActionsList(), // Added actions list to the UI
//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Implement action logging functionality
//           Navigator.pushNamed(context, '/logAction');
//         },
//         child: Icon(Icons.add),
//         tooltip: 'Log Action',
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).primaryColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Your Impact',
//             style: Theme.of(context)
//                 .textTheme
//                 .headlineSmall!
//                 .copyWith(color: Colors.white),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'Keep up the great work!',
//             style: TextStyle(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateRangePicker() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Icon(Icons.date_range, color: Theme.of(context).primaryColor),
//           SizedBox(width: 8),
//           Text('Date Range:'),
//           TextButton(
//             onPressed: _selectDateRange,
//             child: Text(
//               '${DateFormat('MMM d, y').format(_dateRange.start)} - ${DateFormat('MMM d, y').format(_dateRange.end)}',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       initialDateRange: _dateRange,
//     );
//     if (picked != null) {
//       setState(() {
//         _dateRange = picked;
//       });
//       // Optionally, trigger a data refresh here
//     }
//   }

//   Widget _buildCategoryPicker() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Icon(Icons.category, color: Theme.of(context).primaryColor),
//           SizedBox(width: 8),
//           Text('Select Category:'),
//           SizedBox(width: 8),
//           Expanded(
//             child: Consumer(
//               builder: (context, ref, _) {
//                 final categoriesAsyncValue = ref.watch(categoriesProvider);
//                 return categoriesAsyncValue.when(
//                   loading: () => CircularProgressIndicator(),
//                   error: (error, _) => Text('Error: $error'),
//                   data: (categories) {
//                     List<String> categoryNames = ['All'];
//                     categoryNames.addAll(
//                       categories
//                           .map((c) => c.category_name ?? 'Unknown')
//                           .toSet()
//                           .toList(),
//                     );
//                     return DropdownButton<String>(
//                       isExpanded: true,
//                       value: _selectedCategory ?? 'All',
//                       items: categoryNames
//                           .map<DropdownMenuItem<String>>((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedCategory =
//                               newValue == 'All' ? null : newValue;
//                         });
//                         // Optionally, trigger a data refresh here
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCards() {
//     return Container(
//       height: 120, // Adjusted height to fit the content
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         children: [
//           _buildSummaryCard('Total CO2 Saved', '1,234 kg', Icons.eco),
//           _buildSummaryCard('Actions Taken', '56', Icons.check_circle),
//           _buildSummaryCard('Streak', '7 days', Icons.local_fire_department),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, String value, IconData icon) {
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.only(right: 16),
//       child: Container(
//         width: 160,
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center, // Centered content
//           children: [
//             Icon(icon, color: Theme.of(context).primaryColor),
//             SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // // Define the actionsProvider
// // final actionsProvider = FutureProvider<List<UserContributionModel>>((ref) async {
// //   final firestoreService = ref.watch(firestoreServiceProvider); // Assuming you have a Firestore service provider
// //   final actions = await firestoreService.getActions(); // Assuming this method fetches the list of actions
// //   return actions;
// // });

//   Widget _buildActionsList() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Consumer(
//         builder: (context, ref, _) {
//           final userId = ref
//               .watch(userStreamProvider)
//               .value
//               ?.uid; // Fetch the user ID from auth state
//           if (userId == null) {
//             return Center(child: Text('User not authenticated.'));
//           }
//           final actionsAsyncValue =
//               ref.watch(userContributionsProvider(userId).future);
//           return FutureBuilder<List<UserContributionModel>>(
//             future: ref.watch(userContributionsProvider(userId)
//                 .future), // Fetch the contributions
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Loader(); // Show loading widget
//               } else if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return Center(
//                   child:
//                       Text('No actions available for the selected category.'),
//                 );
//               }

//               // Filter the contributions based on selected category if needed
//               final contributions = snapshot.data!;
//               final filteredContributions = _selectedCategory != null
//                   ? contributions
//                       .where((contribution) =>
//                           contribution.category == _selectedCategory)
//                       .toList()
//                   : contributions;

//               return ListView.builder(
//                 itemCount: filteredContributions.length,
//                 itemBuilder: (context, index) {
//                   final contribution = filteredContributions[index];
//                   return ListTile(
//                     title: Text(contribution.action),
//                     subtitle: Text('CO2 Saved: ${contribution.co2_saved} kg'),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildChartSection(String title, Widget chart) {
//     return Card(
//       margin: EdgeInsets.all(16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: Theme.of(context).textTheme.titleLarge),
//             SizedBox(height: 16),
//             SizedBox(height: 200, child: chart),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Add this package to use Tuple2
// class CO2SavedOverTimeChart extends ConsumerWidget {
//   final DateTimeRange dateRange;
//   final String? category;

//   CO2SavedOverTimeChart({
//     required this.dateRange,
//     this.category,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch the filteredUserContributionsProvider and pass only the dateRange
//     final contributionsAsyncValue = ref.watch(
//       filteredUserContributionsProvider(dateRange),
//     );

//     return contributionsAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (contributions) {
//         // Apply category filtering after receiving the contributions
//         final filteredContributions = category != null
//             ? contributions
//                 .where((contribution) => contribution.category == category)
//                 .toList()
//             : contributions;

//         // Check if any contributions exist after filtering
//         if (filteredContributions.isEmpty) {
//           return Center(
//             child: Text(
//                 'No data available for the selected date range or category.'),
//           );
//         }

//         // Sort the contributions by their createdAtDateTime
//         filteredContributions
//             .sort((a, b) => a.createdAtDateTime.compareTo(b.createdAtDateTime));

//         final cumulativeCO2Saved = <FlSpot>[];
//         double totalCO2Saved = 0;

//         // Create data points for the chart
//         for (var i = 0; i < filteredContributions.length; i++) {
//           totalCO2Saved += filteredContributions[i].co2_saved;
//           cumulativeCO2Saved.add(FlSpot(i.toDouble(), totalCO2Saved));
//         }

//         // Determine the interval for displaying the data points on the chart
//         final interval = filteredContributions.length > 5
//             ? (filteredContributions.length / 5).ceilToDouble()
//             : 1.0;

//         // Build the chart
//         return LineChart(
//           LineChartData(
//             gridData: FlGridData(show: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final index = value.toInt();
//                     if (index >= 0 && index < filteredContributions.length) {
//                       final date =
//                           filteredContributions[index].createdAtDateTime;
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 4.0),
//                         child: Text(DateFormat.Md().format(date)),
//                       );
//                     }
//                     return Text('');
//                   },
//                   interval: interval,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             minX: 0,
//             maxX: (cumulativeCO2Saved.length - 1).toDouble(),
//             minY: 0,
//             maxY: cumulativeCO2Saved.last.y,
//             lineBarsData: [
//               LineChartBarData(
//                 spots: cumulativeCO2Saved,
//                 isCurved: true,
//                 color: Theme.of(context).primaryColor,
//                 barWidth: 3,
//                 dotData: FlDotData(show: false),
//                 belowBarData: BarAreaData(
//                   show: true,
//                   color: Theme.of(context).primaryColor.withOpacity(0.3),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class WeeklyProgressChart extends ConsumerWidget {
//   final DateTimeRange dateRange;
//   final String? category;

//   WeeklyProgressChart({
//     required this.dateRange,
//     this.category,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Use the dateRange directly
//     final weeklyDataAsyncValue = ref.watch(weeklyDataProvider(dateRange));

//     return weeklyDataAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (weeklyData) {
//         if (weeklyData.isEmpty) {
//           return Center(
//             child:
//                 Text('No weekly data available for the selected date range.'),
//           );
//         }

//         final maxY =
//             weeklyData.values.reduce((a, b) => a > b ? a : b).toDouble();

//         return BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: maxY * 1.1, // Added padding
//             barTouchData: BarTouchData(enabled: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) =>
//                       Text('Week ${value.toInt() + 1}'),
//                   interval: 1,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: false),
//             barGroups: weeklyData.entries.map((entry) {
//               return BarChartGroupData(
//                 x: entry.key,
//                 barRods: [
//                   BarChartRodData(
//                     toY: entry.value.toDouble(),
//                     color: Theme.of(context).primaryColor,
//                     width: 16,
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
// }

// class MonthlyComparisonChart extends ConsumerWidget {
//   final DateTimeRange dateRange;
//   final String? category;

//   MonthlyComparisonChart({
//     required this.dateRange,
//     this.category,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final monthlyDataAsyncValue = ref.watch(
//       monthlyContributionsProvider(
//           dateRange), // Ensure the provider returns the expected data
//     );

//     return monthlyDataAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (monthlyData) {
//         if (monthlyData.isEmpty) {
//           return Center(
//             child:
//                 Text('No monthly data available for the selected date range.'),
//           );
//         }

//         // Extract the maximum value from the list of maps
//         final maxY = monthlyData
//             .map((dataPoint) => dataPoint['value']
//                 as double) // Adjust based on your data structure
//             .reduce((a, b) => a > b ? a : b);

//         return LineChart(
//           LineChartData(
//             gridData: FlGridData(show: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final monthIndex = value.toInt();
//                     if (monthIndex >= 0 && monthIndex < monthlyData.length) {
//                       final month = DateTime(
//                         dateRange.start.year,
//                         dateRange.start.month + monthIndex,
//                         1,
//                       );
//                       return Padding(
//                         padding: const EdgeInsets.only(top: 4.0),
//                         child: Text(DateFormat.MMM().format(month)),
//                       );
//                     }
//                     return Text('');
//                   },
//                   interval: 1,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             minX: 0,
//             maxX: (monthlyData.length - 1).toDouble(),
//             minY: 0,
//             maxY: maxY * 1.1, // Added padding
//             lineBarsData: [
//               LineChartBarData(
//                 spots: monthlyData
//                     .asMap() // Create a map from the list to access indices
//                     .entries
//                     .map((entry) {
//                   final index = entry.key;
//                   final value = entry.value['value']
//                       as double; // Adjust based on your data structure
//                   return FlSpot(index.toDouble(), value);
//                 }).toList(),
//                 isCurved: true,
//                 color: Theme.of(context).primaryColor,
//                 barWidth: 3,
//                 dotData: FlDotData(show: true),
//                 belowBarData: BarAreaData(
//                   show: true,
//                   color: Theme.of(context).primaryColor.withOpacity(0.3),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
