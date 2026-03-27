import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TransactionTrendChart extends StatelessWidget {
  final List<TransactionData> data;

  const TransactionTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('No expense data available'));
    }

    final spots = data
        .map((d) => FlSpot(d.month.toDouble(), d.amount))
        .toList(growable: false);

    final minY = spots.map((s) => s.y).reduce(min);
    final maxY = spots.map((s) => s.y).reduce(max);
    final yPadding = (maxY - minY) * 0.2;

    return LineChart(
      LineChartData(
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: (minY - yPadding).clamp(0, double.infinity),
        maxY: maxY + yPadding,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: (maxY - minY) / 4),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text('M${value.toInt()}'),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

class TransactionData {
  final int month;
  final double amount;

  const TransactionData(this.month, this.amount);
}
