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
//     final contributionsAsyncValue =
//         ref.watch(filteredUserContributionsProvider(dateRange));

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
//                 axisNameWidget: Text('Date'),
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final index = value.toInt();
//                     if (index >= 0 && index < contributions.length) {
//                       return Text(DateFormat.MMMd()
//                           .format(contributions[index].createdAtDateTime));
//                     }
//                     return Text('');
//                   },
//                   interval: interval,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 axisNameWidget: Text('CO2 Saved (kg)'),
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
//                 axisNameWidget: Text('Week'),
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) =>
//                       Text('Week ${value.toInt() + 1}'),
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 axisNameWidget: Text('CO2 Saved (kg)'),
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
//     final monthlyDataAsyncValue = ref.watch(monthlyDataProvider(dateRange));

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
//                 axisNameWidget: Text('Month'),
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
//                 axisNameWidget: Text('CO2 Saved (kg)'),
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

// /*******************************************/

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

// // Updated CO2SavedOverTimeChart
// class CO2SavedOverTimeChart extends ConsumerWidget {
//   final DateTimeRange dateRange;

//   CO2SavedOverTimeChart({required this.dateRange});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contributionsAsyncValue =
//         ref.watch(filteredUserContributionsProvider(dateRange));

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
//             gridData: FlGridData(show: true, drawVerticalLine: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 axisNameWidget: Text('Date'),
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final index = value.toInt();
//                     if (index >= 0 && index < contributions.length) {
//                       return Text(DateFormat.MMMd()
//                           .format(contributions[index].createdAtDateTime));
//                     }
//                     return Text('');
//                   },
//                   interval: interval,
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 axisNameWidget: Text('CO2 Saved (kg)'),
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

// // Updated WeeklyProgressChart
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
//             gridData: FlGridData(show: true, horizontalInterval: 5),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 axisNameWidget: Text('Week'),
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     final weekIndex = value.toInt();
//                     if (weekIndex >= 0 && weekIndex < weeklyData.length) {
//                       return Text('Week ${weekIndex + 1}');
//                     }
//                     return Text('');
//                   },
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 axisNameWidget: Text('CO2 Saved (kg)'),
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: false),
//             barGroups: List.generate(
//               weeklyData.length,
//               (index) => BarChartGroupData(
//                 x: index,
//                 barRods: [
//                   BarChartRodData(
//                     toY: weeklyData.values.elementAt(index),
//                     color: Theme.of(context).primaryColor,
//                     width: 20,
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Updated MonthlyComparisonChart
// class MonthlyComparisonChart extends ConsumerWidget {
//   final DateTimeRange dateRange;

//   MonthlyComparisonChart({required this.dateRange});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final contributionsAsyncValue =
//         ref.watch(filteredUserContributionsProvider(dateRange));

//     return contributionsAsyncValue.when(
//       loading: () => Loader(),
//       error: (error, stack) => Text('Error: $error'),
//       data: (contributions) {
//         if (contributions.isEmpty) {
//           return Center(
//               child: Text('No data available for the selected range.'));
//         }

//         // Create a map for monthly CO2 savings
//         Map<int, double> monthlyData = {};

//         for (var contribution in contributions) {
//           final createdAtDateTime = DateTime.fromMillisecondsSinceEpoch(
//               contribution.created_at.millisecondsSinceEpoch);

//           final month = createdAtDateTime.month; // Extract the month
//           final co2Saved = contribution.co2_saved;

//           // Accumulate CO2 savings by month
//           monthlyData.update(month, (value) => value + co2Saved,
//               ifAbsent: () => co2Saved);
//         }

//         // Convert the monthly data from int to DateTime (1st day of each month)
//         final dataPoints = monthlyData.entries.map((entry) {
//           // Convert month integer to DateTime (Assuming year as 2024)
//           final dateTime = DateTime(2024, entry.key);
//           return FlSpot(
//               dateTime.millisecondsSinceEpoch.toDouble(), entry.value);
//         }).toList();

//         // Sort the data points by DateTime for plotting
//         dataPoints.sort((a, b) => a.x.compareTo(b.x));

//         return LineChart(
//           LineChartData(
//             gridData: FlGridData(show: true, drawVerticalLine: false),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 axisNameWidget: Text('Month'),
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     // Convert back from timestamp to DateTime
//                     final date =
//                         DateTime.fromMillisecondsSinceEpoch(value.toInt());
//                     // Format the month name (e.g., Jan, Feb)
//                     return Text(DateFormat.MMM().format(date));
//                   },
//                 ),
//               ),
//               leftTitles: AxisTitles(
//                 axisNameWidget: Text('CO2 Saved (kg)'),
//                 sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             minX: dataPoints.first.x,
//             maxX: dataPoints.last.x,
//             minY: 0,
//             maxY: dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: dataPoints,
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

//******************************/
import 'package:cstain/providers/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tuple/tuple.dart';
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
        title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w400)),
        leading: Image.asset('assets/Earth black 1.png'),
        //backgroundColor: Theme.of(context).primaryColor,
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
              _buildChartSection('Category Breakdown',
                  CategoryContributionPieChart(dateRange: _dateRange)),
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
    final user = ref.watch(userStreamProvider).value;
    if (user == null) return Center(child: Text('Not authenticated'));

    final contributionsAsyncValue = ref.watch(filteredUserContributionsProvider(
        _dateRange)); // Pass only the _dateRange
// Pass user UID and date range

    return contributionsAsyncValue.when(
      data: (contributions) {
        // Calculate total values based on the filtered contributions
        final totalCO2Saved = contributions
            .fold<double>(0, (sum, item) => sum + item.co2_saved)
            .toStringAsFixed(2);
        final totalActionsTaken = contributions.length;
        final streak = user
            .currentStreak; // Implement streak calculation based on contributions

        return SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSummaryCard(
                  'Total CO2 Saved', '$totalCO2Saved kg', Icons.eco),
              _buildSummaryCard(
                  'Actions Taken', '$totalActionsTaken', Icons.check_circle),
              _buildSummaryCard(
                  'Streak', '$streak days', Icons.local_fire_department),
            ],
          ),
        );
      },
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      loading: () => Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(right: 16, bottom: 6),
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

// Updated CO2SavedOverTimeChart
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
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameWidget: Text('Date'),
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < contributions.length) {
                      return Text(DateFormat.MMMd()
                          .format(contributions[index].createdAtDateTime));
                    }
                    return Text('');
                  },
                  interval: interval,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text('CO2 Saved (kg)'),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value
                          .toInt()
                          .toString(), // Convert value to integer and convert to string
                      style: TextStyle(
                          color:
                              Colors.black), // Optional: customize text style
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Container(
                      margin: EdgeInsets.only(
                          right: 0), // Add some margin on the right
                      child: Text(
                        value
                            .toInt()
                            .toString(), // Convert the right y value to an integer
                        style: TextStyle(
                            color:
                                Colors.black), // Customize the style if needed
                      ),
                    );
                  },
                ),
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
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Updated WeeklyProgressChart
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
            gridData: FlGridData(show: true, horizontalInterval: 5),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameWidget: Text('Week'),
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final weekIndex = value.toInt();
                    if (weekIndex >= 0 && weekIndex < weeklyData.length) {
                      return Text('Week ${weekIndex + 1}');
                    }
                    return Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text('CO2 Saved (kg)'),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value
                          .toInt()
                          .toString(), // Convert value to integer and convert to string
                      style: TextStyle(
                          color:
                              Colors.black), // Optional: customize text style
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(
              weeklyData.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: weeklyData.values.elementAt(index),
                    color: Theme.of(context).primaryColor,
                    width: 20,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Updated MonthlyComparisonChart
class MonthlyComparisonChart extends ConsumerWidget {
  final DateTimeRange dateRange;

  MonthlyComparisonChart({required this.dateRange});

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
              child: Text('No data available for the selected range.'));
        }

        // Create a map for monthly CO2 savings
        Map<int, double> monthlyData = {};

        for (var contribution in contributions) {
          final createdAtDateTime = DateTime.fromMillisecondsSinceEpoch(
              contribution.created_at.millisecondsSinceEpoch);

          final month = createdAtDateTime.month; // Extract the month
          final co2Saved = contribution.co2_saved;

          // Accumulate CO2 savings by month
          monthlyData.update(month, (value) => value + co2Saved,
              ifAbsent: () => co2Saved);
        }

        // Convert the monthly data from int to DateTime (1st day of each month)
        final dataPoints = monthlyData.entries.map((entry) {
          // Convert month integer to DateTime (Assuming year as 2024)
          final dateTime = DateTime(2024, entry.key);
          return FlSpot(
              dateTime.millisecondsSinceEpoch.toDouble(), entry.value);
        }).toList();

        // Sort the data points by DateTime for plotting
        dataPoints.sort((a, b) => a.x.compareTo(b.x));

        return LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameWidget: Text('Month'),
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    // Convert back from timestamp to DateTime
                    final date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    // Format the month name (e.g., Jan, Feb)
                    return Text(DateFormat.MMM().format(date));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text('CO2 Saved (kg)'),
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              topTitles: AxisTitles(
                // Add this part to remove top titles
                sideTitles: SideTitles(showTitles: false), // Disable top titles
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: dataPoints.first.x,
            maxX: dataPoints.last.x,
            minY: 0,
            maxY: dataPoints.map((e) => e.y).reduce((a, b) => a > b ? a : b),
            lineBarsData: [
              LineChartBarData(
                spots: dataPoints,
                isCurved: true,
                color: Theme.of(context).primaryColor,
                barWidth: 3,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryContributionPieChart extends ConsumerWidget {
  final DateTimeRange dateRange;

  CategoryContributionPieChart({required this.dateRange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsyncValue =
        ref.watch(filteredUserContributionsProvider(dateRange));

    return contributionsAsyncValue.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
      data: (contributions) {
        if (contributions.isEmpty) {
          return Center(
              child: Text('No data available for the selected date range.'));
        }

        // Group contributions by category and sum CO2 saved per category
        Map<String, double> categoryData = {};
        for (var contribution in contributions) {
          categoryData.update(
            contribution.category,
            (value) => value + contribution.co2_saved,
            ifAbsent: () => contribution.co2_saved,
          );
        }

        // Create PieChart sections
        List<PieChartSectionData> pieSections = [];
        categoryData.forEach((category, co2Saved) {
          pieSections.add(
            PieChartSectionData(
              color: _getCategoryColor(category),
              value: co2Saved,
              title: '',
              showTitle: false,
              radius: 60,
            ),
          );
        });

        return Stack(
          children: [
            PieChart(
              PieChartData(
                sections: pieSections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    if (event is FlTapUpEvent &&
                        pieTouchResponse != null &&
                        pieTouchResponse.touchedSection != null) {
                      int index =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                      _showTooltip(context, index, categoryData);
                    }
                  },
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 6,
              child: _buildLegend(categoryData),
            ),
          ],
        );
      },
    );
  }

  void _showTooltip(BuildContext context, int touchedSectionIndex,
      Map<String, double> categoryData) {
    if (touchedSectionIndex < 0 || touchedSectionIndex >= categoryData.length)
      return;

    // Get the category and co2Saved using the index
    final category = categoryData.keys.elementAt(touchedSectionIndex);
    final co2Saved = categoryData[category]!;

    // Show a tooltip with the category and contribution amount
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$category: ${(co2Saved).toStringAsFixed(1)} kg',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the tooltip after a delay
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Widget _buildLegend(Map<String, double> categoryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryData.keys.map((category) {
        return Row(
          children: [
            Container(
              //padding: EdgeInsets.all(8),
              width: 12,
              height: 12,
              color: _getCategoryColor(category),
            ),
            SizedBox(width: 8),
            Text(
              category,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Vehicle':
        return Colors.green.shade800;
      case 'Electricity':
        return Colors.green.shade200;
      case 'Waste':
        return Colors.green.shade100;
      case 'Food':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
