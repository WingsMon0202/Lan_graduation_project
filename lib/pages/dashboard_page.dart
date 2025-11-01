import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/dashboard_item.dart';
import '../services/api_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardStats?>(
      future: ApiService.instance.fetchDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("❌ Không thể tải dữ liệu"));
        }

        final stats = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          appBar: AppBar(
            title: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  "📊 Dashboard - Attendance Overview",
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  speed: const Duration(milliseconds: 70),
                ),
              ],
              repeatForever: false,
              totalRepeatCount: 1,
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                            ? 3
                            : 2;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      children: [
                        _AnimatedKpiCard(
                          icon: Icons.people_alt_rounded,
                          title: 'Total Students',
                          value: stats.totalStudents.toString(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        _AnimatedKpiCard(
                          icon: Icons.check_circle_rounded,
                          title: 'Today Present',
                          value: stats.todayPresent.toString(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        _AnimatedKpiCard(
                          icon: Icons.cancel_rounded,
                          title: 'Today Absent',
                          value: stats.todayAbsent.toString(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        _AnimatedKpiCard(
                          icon: Icons.class_rounded,
                          title: 'Total Classes',
                          value: stats.totalClasses.toString(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Chart Section
                Text(
                  "Attendance this week",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const _AttendanceChart(),
                ),

                const SizedBox(height: 40),

                // Recent Classes or Events
                Text(
                  "Recent Classes",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _RecentClassesTable(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ======================================================
// KPI Card
// ======================================================
class _AnimatedKpiCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _AnimatedKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_AnimatedKpiCard> createState() => _AnimatedKpiCardState();
}

class _AnimatedKpiCardState extends State<_AnimatedKpiCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _scale = 1.05),
      onExit: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// Chart Component (Attendance Visualization)
// ======================================================
class _AttendanceChart extends StatelessWidget {
  const _AttendanceChart();

  @override
  Widget build(BuildContext context) {
    final data = [5, 7, 6, 8, 9, 4, 7]; // giả lập số học sinh đi học theo ngày
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[val.toInt()],
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].toDouble(),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(6),
                width: 18,
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ======================================================
// Recent Classes Table
// ======================================================
class _RecentClassesTable extends StatelessWidget {
  const _RecentClassesTable();

  @override
  Widget build(BuildContext context) {
    final classes = [
      {
        'class': '10A1',
        'subject': 'Math',
        'teacher': 'Mr. Nam',
        'students': 32
      },
      {
        'class': '11B2',
        'subject': 'Physics',
        'teacher': 'Ms. Linh',
        'students': 30
      },
      {
        'class': '12C3',
        'subject': 'Chemistry',
        'teacher': 'Mr. Huy',
        'students': 29
      },
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DataTable(
        headingRowColor:
            WidgetStateColor.resolveWith((states) => Colors.blue[50]!),
        columns: const [
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Teacher')),
          DataColumn(label: Text('Students')),
        ],
        rows: classes
            .map(
              (c) => DataRow(
                cells: [
                  DataCell(Text(c['class'].toString())),
                  DataCell(Text(c['subject'].toString())),
                  DataCell(Text(c['teacher'].toString())),
                  DataCell(Text(c['students'].toString())),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
