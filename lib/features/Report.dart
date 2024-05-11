import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Entry {
  final DateTime date;
  final int count;

  Entry(this.date, this.count);
}

List<ChartSeries<Entry, DateTime>> _createDailyData() {
  final dailyData = [
    Entry(DateTime(2024, 1, 4, 8), 100),
    Entry(DateTime(2024, 1, 4, 10), 120),
    Entry(DateTime(2024, 1, 4, 12), 80),
    Entry(DateTime(2024, 1, 4, 14), 150),
    Entry(DateTime(2024, 1, 4, 16), 130),
  ];

  return <ChartSeries<Entry, DateTime>>[
    SplineSeries<Entry, DateTime>(
      dataSource: dailyData,
      xValueMapper: (Entry entry, _) => entry.date,
      yValueMapper: (Entry entry, _) => entry.count,
      color: Color(0xFF2D2689), // Set custom line color
    ),
    SplineAreaSeries<Entry, DateTime>(
      dataSource: dailyData,
      xValueMapper: (Entry entry, _) => entry.date,
      yValueMapper: (Entry entry, _) => entry.count,
      color:Color(0xFF2D2689).withOpacity(0.5), // Set custom area fill color
    ),
  ];
}

List<ChartSeries<Entry, DateTime>> _createMonthlyData() {
  final monthlyData = [
    Entry(DateTime(2024, 1, 1, 8), 3000),
    Entry(DateTime(2024, 1, 1, 10), 3200),
    Entry(DateTime(2024, 1, 1, 12), 2800),
    Entry(DateTime(2024, 1, 1, 14), 3400),
    Entry(DateTime(2024, 1, 1, 16), 2900),
  ];

  return <ChartSeries<Entry, DateTime>>[
    SplineSeries<Entry, DateTime>(
      dataSource: monthlyData,
      xValueMapper: (Entry entry, _) => entry.date,
      yValueMapper: (Entry entry, _) => entry.count,
      color: Color(0xFF2D2689), // Set custom line color
    ),
    SplineAreaSeries<Entry, DateTime>(
      dataSource: monthlyData,
      xValueMapper: (Entry entry, _) => entry.date,
      yValueMapper: (Entry entry, _) => entry.count,
      color:Color(0xFF2D2689).withOpacity(0.5), // Set custom area fill color
    ),
  ];
}

class Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0.0, // Remove shadow
          iconTheme: IconThemeData(color: Color (0xFFE3AC96)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.lightBlue[200]!, // Light blue ombre
                Colors.orange[200]! // Light orange
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildChartSection("Daily Report", _createDailyData()),
              _buildChartSection("Monthly Report", _createMonthlyData()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(String title, List<ChartSeries<Entry, DateTime>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "People who entered the laboratory",
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(height: 20),
        Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              interval: 2,
              intervalType: DateTimeIntervalType.hours,
              majorTickLines: MajorTickLines(size: 0),
              minorTickLines: MinorTickLines(size: 0),
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
              interval: 100,
              borderColor: Colors.transparent,
              borderWidth: 0,
            ),
            series: data.cast<CartesianSeries<dynamic, dynamic>>(),
            margin: EdgeInsets.all(0),
            borderWidth: 0,
            borderColor: Colors.transparent,
            plotAreaBorderWidth: 0,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}