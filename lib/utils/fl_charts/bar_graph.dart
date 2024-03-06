import 'package:book_charm/utils/fl_charts/bar_data.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatelessWidget {
  final List<double> monthlySummary;

  const MyBarGraph({
    Key? key,
    required this.monthlySummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize Bar Data structure
    BarData myBarData = BarData(
      sunAmount: monthlySummary[0],
      monAmount: monthlySummary[1],
      tuesAmount: monthlySummary[2],
      wedAmount: monthlySummary[3],
      thursAmount: monthlySummary[4],
      friAmount: monthlySummary[5],
      satAmount: monthlySummary[6],
    );
    myBarData.initialize();
    const style = TextStyle(
      fontSize: 12,
      color: AppColors.secondaryColor,
    );
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 10,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, title) {
                switch (value.toInt()) {
                  case 0:
                    return const Text("0", style: style);
                  case 2:
                    return const Text("2", style: style);
                  case 4:
                    return const Text("4", style: style);
                  case 6:
                    return const Text("6", style: style);
                  case 8:
                    return const Text("8", style: style);
                  case 10:
                    return const Text("10", style: style);
                  default:
                    return const Text("");
                }
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
              reservedSize: 30,
            ),
          ),
        ),
        barGroups: myBarData.barData
            .map(
              (data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                    toY: data.y,
                    color: AppColors.primaryColor,
                    width: 15,
                    borderRadius: BorderRadius.circular(5),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      color: Colors.grey[200],
                      toY: 8,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  final style = TextStyle(
    fontSize: 11.5,
    color: Colors.grey.shade500,
  );
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = Text("Su", style: style);
      break;

    case 1:
      text = Text("Mo", style: style);
      break;

    case 2:
      text = Text("Tu", style: style);

      break;

    case 3:
      text = Text("We", style: style);

      break;
    case 4:
      text = Text("Th", style: style);

      break;
    case 5:
      text = Text("Fr", style: style);

      break;
    case 6:
      text = Text("Sa", style: style);

      break;
    default:
      text = Text("", style: style);

      break;
  }

  return SideTitleWidget(axisSide: meta.axisSide, child: text);
}
