import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CryptoBarChart extends StatelessWidget {
  final List<double> prices;

  CryptoBarChart({required this.prices});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: prices.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barsSpace:
                4, // This is how you can set the space between bars (though may not exist in latest versions)
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: Colors.blue,
                width: 16,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: prices.reduce((a, b) => a > b ? a : b),
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: prices.isEmpty
                  ? 1
                  : (prices.reduce((a, b) => a > b ? a : b) / 5),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(2)}',
                TextStyle(color: Colors.white),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (barTouchResponse != null && barTouchResponse.spot != null) {
              final touchedSpot = barTouchResponse.spot!;
              final xValue = touchedSpot.touchedBarGroup.x;
              final yValue = touchedSpot
                  .touchedRodData.toY; // Accessing via touchedRodData
              print('Touched spot: x=$xValue, y=$yValue');
            }
          },
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
