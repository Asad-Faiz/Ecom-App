import 'package:amazone_clone/common/widgets/loader.dart';
import 'package:amazone_clone/features/admin/model/sales.dart';
import 'package:amazone_clone/features/admin/services/admin_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AdminServices adminServices = AdminServices();
  int? totalSales;
  List<Sales>? earnings;
  @override
  void initState() {
    super.initState();
    getEarning();
  }

  void getEarning() async {
    var earningData = await adminServices.getEarnings(context);
    print(earningData);
    totalSales = earningData['totalEarnings'];
    earnings = earningData['sales'];

    setState(() {});
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          switch (value.toInt()) {
            case 0:
              text = earnings![0].label;
              break;
            case 1:
              text = earnings![1].label;
              break;
            case 2:
              text = earnings![2].label;
              break;
            case 3:
              text = earnings![3].label;
              break;
            case 4:
              text = earnings![4].label;
              break;
          }

          return Text(text);
        },
      );

  @override
  Widget build(BuildContext context) {
    return earnings == null || totalSales == null
        ? const Loader()
        : Column(
            children: [
              Text(
                '\$${totalSales}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0).copyWith(right: 8),
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(
                        border: Border.all(width: 1),
                      ),
                      groupsSpace: double.parse(earnings!.length.toString()),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                        // leftTitles: AxisTitles(
                        //     sideTitles: SideTitles(showTitles: true)),
                        // topTitles: AxisTitles(
                        //     sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: [
                        for (int i = 0; i < earnings!.length; i++) ...{
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: double.parse(
                                    earnings![i].earning.toString()),
                                width: 15,
                                fromY: 0,
                                color: Colors.orange,
                              )
                            ],
                          ),
                        }
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}
