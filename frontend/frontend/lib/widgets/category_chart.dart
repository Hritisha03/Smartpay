import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategorySpendingChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategorySpendingChart({Key? key, required this.categoryData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty) {
      return Center(child: Text('No category data available'));
    }

    final colors = {
      'food': Colors.redAccent,
      'shopping': Colors.purpleAccent,
      'travel': Colors.greenAccent,
      'rent': Colors.blueAccent,
      'utilities': Colors.grey,
      'entertainment': Colors.orangeAccent,
    };

    final sections = categoryData.entries.map((entry) {
      final value = entry.value;
      final category = entry.key;
      final color = colors[category.toLowerCase()] ?? Theme.of(context).primaryColor;

      return PieChartSectionData(
        value: value,
        title: '${category[0].toUpperCase()}${category.substring(1)}\n₹${value.toStringAsFixed(0)}',
        color: color,
        radius: 90,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
