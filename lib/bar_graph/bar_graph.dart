import 'package:expense_tracker/bar_graph/individual_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth; // 0 Jan, 1 Feb, ...

  const MyBarGraph({super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  // hold data for each bar
  List<IndividualBar> barData = [];

  @override
  void initState() {
    super.initState();

    // automatically scroll to the end
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => scrollToEnd);
  }

  // initialize bar data
  void initializeBarData() {
    barData = List.generate(widget.monthlySummary.length,
        (index) => IndividualBar(x: index, y: widget.monthlySummary[index]));
  }

  // calculate max y limit
  double calculateMax() {
    // initially set it at 5.000.000, but adjust if spending past the amount
    double max = 5000000;

    // get the month with highest amount
    widget.monthlySummary.sort(); // small to biggest
    max = widget.monthlySummary.last * 1.1;

    if (max < 5000000) {
      return 5000000;
    } else {
      return max;
    }
  }

  // scroll controller to scroll to the end of bar graph (latest month)
  final ScrollController _scrollController = ScrollController();
  void scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    // initialize upon build
    initializeBarData();

    double barWidth = 20;
    double spaceBetween = 40;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SizedBox(
          width: barWidth * barData.length + spaceBetween * (barData.length - 1),
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: calculateMax(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) =>
                      getBottomTitles(value, meta, widget.startMonth),
                  reservedSize: 25,
                )),
              ),
              barGroups: barData
                  .map((data) => BarChartGroupData(
                        x: data.x,
                        barRods: [
                          BarChartRodData(
                              toY: data.y,
                              width: barWidth,
                              borderRadius: BorderRadius.circular(4),
                              color: Theme.of(context).colorScheme.secondary,
                              backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: calculateMax(),
                                  color: Theme.of(context).colorScheme.onPrimary)
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// bottom tiles
Widget getBottomTitles(double value, TitleMeta meta, int startMonth) {
  const textStyle = TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14);

  int monthIndex = (startMonth + value.toInt() - 1) % 12;

  String text;
  switch (monthIndex) {
    case 0:
      text = 'Jan';
      break;
    case 1:
      text = 'Feb';
      break;
    case 2:
      text = 'Mar';
      break;
    case 3:
      text = 'Apr';
      break;
    case 4:
      text = 'May';
      break;
    case 5:
      text = 'June';
      break;
    case 6:
      text = 'July';
      break;
    case 7:
      text = 'Aug';
      break;
    case 8:
      text = 'Sept';
      break;
    case 9:
      text = 'Oct';
      break;
    case 10:
      text = 'Nov';
      break;
    case 11:
      text = 'Dec';
      break;
    default:
      text = '';
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text, style: textStyle),
  );
}

// bottom titles
// Widget getBottomTitles(double value, TitleMeta meta, int startMonth) {
//   const textStyle = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14);
//
//   // list of month names
//   final List<String> monthNames = [
//     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June',
//     'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
//   ];
//
//   // calculate the correct month index based on startMonth
//   int monthIndex = (startMonth + value.toInt() - 1) % 12;
//
//   return SideTitleWidget(
//     axisSide: meta.axisSide,
//     child: Text(monthNames[monthIndex], style: textStyle),
//   );
// }
