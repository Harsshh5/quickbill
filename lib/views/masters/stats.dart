import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbill/config/app_colors.dart';
import 'package:quickbill/views/commons/card_container.dart';
import 'package:quickbill/views/commons/gradient.dart';

import '../commons/page_header.dart';

import 'package:fl_chart/fl_chart.dart';

import '../commons/text_style.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;

  late TabController tabController;

  List<BarChartGroupData> currentBarGroups = [];
  List<String> xLabels = [];

  List<double> animatedValues = [];
  bool animationStarted = false;

  List<double> originalValues = [8, 10, 14, 15, 13, 10, 16];

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      setState(() {
        if (tabController.index == 0) {
          xLabels = getLast7DaysLabels();
          currentBarGroups = generateBarData(xLabels.length);
        } else if (tabController.index == 1) {
          xLabels = getLast6MonthsLabels();
          currentBarGroups = generateBarData(xLabels.length);
        }
      });
    });

    controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    //bar animation
    animatedValues = List.filled(originalValues.length, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startBarAnimation();
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startBarAnimation() async {
    animationStarted = true;
    for (int i = 0; i < originalValues.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      setState(() {
        animatedValues[i] = originalValues[i];
      });
    }
  }

  List<String> getLast7DaysLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return '${date.day}/${date.month}\n${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1]}';
    });
  }

  List<String> getLast6MonthsLabels() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = DateTime(now.year, now.month - (5 - i));
      return [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ][date.month - 1];
    });
  }

  List<String> getYearLabels() {
    final now = DateTime.now();
    return [now.year.toString(), (now.year - 1).toString()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            children: [
              SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: CommonPageHeader(
                    mainHeading: "Statistics",
                    subHeading: "Business Progress and Analysis",
                    onTap: () => Get.back(),
                    icon: Icons.chevron_left_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: CommonCardContainer(
                      height: Get.height / 2.3,
                      width: Get.width,
                      child: barGraph(),
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child:CommonIconCardContainer(
                      height: 50,
                      width: Get.width / 2.5,
                      child: TabBar(
                        controller: tabController,
                        tabs: const [Tab(text: "W"), Tab(text: "M")],
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: EdgeInsets.all(5),
                        splashBorderRadius: BorderRadius.circular(18),
                        dividerColor: Colors.transparent,
                        indicatorAnimation: TabIndicatorAnimation.elastic,
                        labelStyle: appTextStyle(color: Colors.white),
                        unselectedLabelStyle: appTextStyle(color: Colors.black),
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: appGradient1
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget barGraph() {
    double maxValue = barGroups
        .map((e) => e.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxValue * 1.2).ceilToDouble(), // Add some padding (20% extra)
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (
        BarChartGroupData group,
        int groupIndex,
        BarChartRodData rod,
        int rodIndex,
      ) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          appTextStyle(color: AppColors.medium),
        );
      },
    ),
  );

  Widget getTitles(double value, TitleMeta meta) {
    final style = appTextStyle(
      color: AppColors.medium,
      fontSize: 12,
    );

    final index = value.toInt();
    if (index < 0 || index >= xLabels.length) return const SizedBox.shrink();

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(xLabels[index], style: style, textAlign: TextAlign.center),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlBorderData get borderData => FlBorderData(show: false);

  LinearGradient get _barsGradient => LinearGradient(
    colors: [AppColors.dark, AppColors.medium, AppColors.light],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups =>
      List.generate(originalValues.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: animatedValues[index],
              gradient: _barsGradient,
              width: 22,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
          showingTooltipIndicators: [0],
        );
      });

  List<BarChartGroupData> generateBarData(int count) {
    return List.generate(count, (index) {
      final yValue = (5 + index * 2) % 20 + 5;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: yValue.toDouble(), gradient: _barsGradient),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
}
