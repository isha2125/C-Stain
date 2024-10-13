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
        title: Text('Dashboard'),
        leading: Icon(Icons.dashboard), // Replaced Image with Icon
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Impact',
                  style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 20),
              _buildDateRangePicker(),
              SizedBox(height: 20),
              SizedBox(
                  height: 200,
                  child: CO2SavedOverTimeChart(dateRange: _dateRange)),
              SizedBox(height: 20),
              SizedBox(
                  height: 200,
                  child: WeeklyProgressChart(dateRange: _dateRange)),
              SizedBox(height: 20),
              SizedBox(
                  height: 200,
                  child: MonthlyComparisonChart(dateRange: _dateRange)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Text('Date Range: '),
        TextButton(
          onPressed: () async {
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
          },
          child: Text(
              '${_dateRange.start.toString().substring(0, 10)} - ${_dateRange.end.toString().substring(0, 10)}'),
        ),
      ],
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
