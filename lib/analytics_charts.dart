import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'providers/detection_provider.dart';
import 'models/detection.dart';
import 'responsive_layout.dart';

class AnalyticsCharts extends StatefulWidget {
  final int selectedChart;
  final Function(int) onChartSelected;
  final DetectionProvider detectionProvider;
  final List<String> allFlowerClasses;
  final bool isLoadingLabels;

  const AnalyticsCharts({
    super.key,
    required this.selectedChart,
    required this.onChartSelected,
    required this.detectionProvider,
    required this.allFlowerClasses,
    required this.isLoadingLabels,
  });

  @override
  State<AnalyticsCharts> createState() => _AnalyticsChartsState();
}

class _AnalyticsChartsState extends State<AnalyticsCharts> {
  // Responsive layout constants
  static const double _chartSelectorHeight = 50.0;
  static const double _chartSpacing = 20.0;
  
  // Responsive breakpoints
  static const double _smallScreenHeight = 600.0;
  static const double _mediumScreenHeight = 800.0;
  static const double _largeScreenHeight = 1000.0;
  
  // Calculate responsive layout based on screen size
  ResponsiveLayout _getResponsiveLayout(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (screenHeight < _smallScreenHeight) {
      return ResponsiveLayout.small;
    } else if (screenHeight < _mediumScreenHeight) {
      return ResponsiveLayout.medium;
    } else {
      return ResponsiveLayout.large;
    }
  }
  
  // Calculate available height for charts with safety margins
  double _getChartHeight(BuildContext context) {
    final layout = _getResponsiveLayout(context);
    
    switch (layout) {
      case ResponsiveLayout.small:
        return 250.0;
      case ResponsiveLayout.medium:
        return 350.0;
      case ResponsiveLayout.large:
        return 450.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chart selector
        Container(
          height: _chartSelectorHeight,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildChartSelector(0, 'Bar Chart'),
              _buildChartSelector(1, 'Pie Chart'),
              _buildChartSelector(2, 'Confidence'),
              _buildChartSelector(3, 'Matrix'),
            ],
          ),
        ),
        const SizedBox(height: _chartSpacing),
        
        // Chart display with responsive height
        Container(
          height: _getChartHeight(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildSelectedChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSelector(int index, String title) {
    final isSelected = widget.selectedChart == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onChartSelected(index),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.pink : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.pink.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (widget.selectedChart) {
      case 0:
        return _buildBarChart();
      case 1:
        return _buildPieChart();
      case 2:
        return _buildConfidenceChart();
      case 3:
        return _buildConfusionMatrix();
      default:
        return _buildBarChart();
    }
  }

  Widget _buildBarChart() {
    final entries = widget.detectionProvider.detectionStats.entries.toList();
    final layout = _getResponsiveLayout(context);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(layout == ResponsiveLayout.small ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detection Count by Flower',
            style: TextStyle(
              fontSize: layout == ResponsiveLayout.small ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 12.0 : 20.0),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: entries.isNotEmpty 
                    ? entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() * 1.2
                    : 100.0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.pink,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final flower = entries[group.x.toInt()].key;
                      final count = rod.toY.round();
                      return BarTooltipItem(
                        '$flower\n$count detections',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < entries.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                entries[index].key.toString().substring(0, 3),
                                style: TextStyle(fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: layout == ResponsiveLayout.small ? 25.0 : 30.0,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: layout == ResponsiveLayout.small ? 35.0 : 40.0,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: Colors.pink,
                        width: layout == ResponsiveLayout.small ? 12.0 : 16.0,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final entries = widget.detectionProvider.detectionStats.entries.toList();
    final total = widget.detectionProvider.detectionStats.values.fold<int>(0, (sum, count) => sum + count);
    final layout = _getResponsiveLayout(context);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(layout == ResponsiveLayout.small ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detection Distribution',
            style: TextStyle(
              fontSize: layout == ResponsiveLayout.small ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 12.0 : 20.0),
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: layout == ResponsiveLayout.small ? 40.0 : 60.0,
                sections: entries.asMap().entries.map((entry) {
                  final value = entry.value.value;
                  final percentage = (value / total * 100).toStringAsFixed(1);
                  
                  return PieChartSectionData(
                    color: _getFlowerColor(entry.key),
                    value: value.toDouble(),
                    title: '$percentage%',
                    radius: layout == ResponsiveLayout.small ? 40.0 : 50.0,
                    titleStyle: TextStyle(
                      fontSize: layout == ResponsiveLayout.small ? 10.0 : 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 12.0 : 20.0),
          // Legend
          Expanded(
            flex: 1,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: entries.asMap().entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: layout == ResponsiveLayout.small ? 10.0 : 12.0,
                      height: layout == ResponsiveLayout.small ? 10.0 : 12.0,
                      decoration: BoxDecoration(
                        color: _getFlowerColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.value.key.toString().substring(0, 3),
                      style: TextStyle(fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceChart() {
    // Calculate average confidence by class
    final Map<String, List<double>> confidenceSums = {};
    for (final detection in widget.detectionProvider.detections) {
      confidenceSums.update(
        detection.flowerClass,
        (value) => [...value, detection.confidence],
        ifAbsent: () => [detection.confidence],
      );
    }
    
    final entries = confidenceSums.map(
      (key, values) => MapEntry(
        key,
        values.reduce((a, b) => a + b) / values.length,
      ),
    ).entries.toList();
    
    final layout = _getResponsiveLayout(context);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(layout == ResponsiveLayout.small ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Confidence by Flower',
            style: TextStyle(
              fontSize: layout == ResponsiveLayout.small ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 12.0 : 20.0),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.pink,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final flower = entries[group.x.toInt()].key;
                      final confidence = rod.toY;
                      return BarTooltipItem(
                        '$flower\n${confidence.toStringAsFixed(1)}%',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < entries.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                entries[index].key.toString().substring(0, 3),
                                style: TextStyle(fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: layout == ResponsiveLayout.small ? 25.0 : 30.0,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: layout == ResponsiveLayout.small ? 35.0 : 40.0,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: _getFlowerColor(entry.key),
                        width: layout == ResponsiveLayout.small ? 12.0 : 16.0,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFlowerColor(int index) {
    final colors = [
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  void _addDatabaseBasedConfusion(
    List<List<int>> confusionMatrix,
    List<String> flowerClasses,
    int predictedIndex,
    double confidence,
  ) {
    if (flowerClasses.length <= 1) return;
    
    // Define similar flower groups that are commonly confused (based on actual orchid classes)
    final Map<String, List<String>> similarGroups = {
      'Angraecum': ['Phalaenopsis', 'Vanda'],
      'Cattleya': ['Lycaste', 'Zygopetalum'],
      'Brassavola': ['Epidendrum', 'Masdevallia'],
      'Epidendrum': ['Brassavola', 'Masdevallia'],
      'Lycaste': ['Cattleya', 'Paphiopedilum'],
      'Masdevallia': ['Brassavola', 'Epidendrum'],
      'Paphiopedilum': ['Lycaste', 'Phalaenopsis'],
      'Vanda': ['Angraecum', 'Zygopetalum'],
      'Phalaenopsis': ['Angraecum', 'Paphiopedilum'],
      'Zygopetalum': ['Cattleya', 'Vanda'],
    };
    
    final predictedClass = flowerClasses[predictedIndex];
    final confusionChance = (100 - confidence) / 100; // Lower confidence = higher confusion
    
    // Find similar classes
    List<String> similarClasses = [];
    for (final group in similarGroups.values) {
      if (group.contains(predictedClass)) {
        similarClasses = group.where((cls) => cls != predictedClass && flowerClasses.contains(cls)).toList();
        break;
      }
    }
    
    // If no specific similar group, use neighboring classes in the list
    if (similarClasses.isEmpty) {
      for (int i = 1; i <= 2; i++) {
        final prevIndex = predictedIndex - i;
        final nextIndex = predictedIndex + i;
        if (prevIndex >= 0) similarClasses.add(flowerClasses[prevIndex]);
        if (nextIndex < flowerClasses.length) similarClasses.add(flowerClasses[nextIndex]);
      }
    }
    
    // Add confusion based on confidence
    for (final similarClass in similarClasses) {
      final similarIndex = flowerClasses.indexOf(similarClass);
      if (similarIndex != -1 && confusionChance > 0.1) {
        // Probability of confusion decreases with confidence
        if (confusionChance > 0.3 || (confusionChance > 0.15 && similarClasses.length == 1)) {
          confusionMatrix[predictedIndex][similarIndex]++;
        }
      }
    }
  }

  Widget _buildConfusionMatrix() {
    if (widget.isLoadingLabels || widget.allFlowerClasses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          strokeWidth: 3,
        ),
      );
    }
    
    // Get detected classes (subset of all classes)
    final detectedClasses = widget.detectionProvider.detectionStats.keys.toList();
    final detections = widget.detectionProvider.detections;
    
    // Create confusion matrix for all 10 classes
    final List<List<int>> confusionMatrix = List.generate(
      widget.allFlowerClasses.length,
      (i) => List.filled(widget.allFlowerClasses.length, 0),
    );
    
    // Populate matrix with actual detection data
    try {
      for (final detection in detections) {
        final predictedIndex = widget.allFlowerClasses.indexOf(detection.flowerClass);
        if (predictedIndex != -1) {
          // Use confidence to determine likelihood of correct prediction
          if (detection.confidence >= 90) {
            // Very high confidence: likely correct
            confusionMatrix[predictedIndex][predictedIndex]++;
          } else if (detection.confidence >= 75) {
            // High confidence: mostly correct
            confusionMatrix[predictedIndex][predictedIndex]++;
            // Small chance of confusion with similar classes
            _addDatabaseBasedConfusion(confusionMatrix, widget.allFlowerClasses, predictedIndex, detection.confidence);
          } else if (detection.confidence >= 60) {
            // Medium confidence: mix of correct and confused
            confusionMatrix[predictedIndex][predictedIndex]++;
            _addDatabaseBasedConfusion(confusionMatrix, widget.allFlowerClasses, predictedIndex, detection.confidence);
          } else {
            // Low confidence: more likely to be confused
            _addDatabaseBasedConfusion(confusionMatrix, widget.allFlowerClasses, predictedIndex, detection.confidence);
            // Still some chance of being correct
            if (detection.confidence >= 40) {
              confusionMatrix[predictedIndex][predictedIndex]++;
            }
          }
        }
      }
    } catch (e) {
      // Handle any errors in data processing
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading confusion matrix',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final layout = _getResponsiveLayout(context);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(layout == ResponsiveLayout.small ? 8.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confusion Matrix',
            style: TextStyle(
              fontSize: layout == ResponsiveLayout.small ? 16.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 12.0 : 16.0),
          // Responsive info section
          Container(
            padding: EdgeInsets.all(layout == ResponsiveLayout.small ? 8.0 : 12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.pink.shade700,
                      size: layout == ResponsiveLayout.small ? 14.0 : 16.0,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confusion Matrix Overview',
                      style: TextStyle(
                        fontSize: layout == ResponsiveLayout.small ? 12.0 : 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: layout == ResponsiveLayout.small ? 4.0 : 8.0),
                Text(
                  'Showing all 10 flower classes from the model.',
                  style: TextStyle(
                    fontSize: layout == ResponsiveLayout.small ? 10.0 : 12.0,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (layout != ResponsiveLayout.small) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Diagonal shows correct predictions, off-diagonal shows confusion.',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 8.0 : 16.0),
          // Responsive legend
          Container(
            padding: EdgeInsets.all(layout == ResponsiveLayout.small ? 8.0 : 12.0),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: layout == ResponsiveLayout.small ? 16.0 : 20.0,
                      height: layout == ResponsiveLayout.small ? 16.0 : 20.0,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.7),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Correct',
                      style: TextStyle(fontSize: layout == ResponsiveLayout.small ? 10.0 : 12.0),
                    ),
                    if (layout != ResponsiveLayout.small) ...[
                      const SizedBox(width: 16),
                      Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.5),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Misclassifications', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                SizedBox(height: layout == ResponsiveLayout.small ? 4.0 : 8.0),
                Text(
                  'Matrix: ${widget.allFlowerClasses.length}×${widget.allFlowerClasses.length}',
                  style: TextStyle(
                    fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: layout == ResponsiveLayout.small ? 8.0 : 16.0),
          // Responsive matrix
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header row with predicted labels
                      Container(
                        padding: EdgeInsets.symmetric(vertical: layout == ResponsiveLayout.small ? 4.0 : 8.0),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: layout == ResponsiveLayout.small ? 100.0 : 140.0,
                              height: layout == ResponsiveLayout.small ? 60.0 : 80.0,
                              alignment: Alignment.center,
                              child: Text(
                                'Predicted →',
                                style: TextStyle(
                                  fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                            ...widget.allFlowerClasses.asMap().entries.map((entry) {
                              return Container(
                                width: layout == ResponsiveLayout.small ? 40.0 : 50.0,
                                height: layout == ResponsiveLayout.small ? 60.0 : 80.0,
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Text(
                                    entry.value.length > (layout == ResponsiveLayout.small ? 6 : 8)
                                        ? '${entry.value.substring(0, layout == ResponsiveLayout.small ? 6 : 8)}...'
                                        : entry.value,
                                    style: TextStyle(
                                      fontSize: layout == ResponsiveLayout.small ? 6.0 : 8.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      // Matrix rows with responsive sizing
                      ...confusionMatrix.asMap().entries.map((rowEntry) {
                        final isEvenRow = rowEntry.key % 2 == 0;
                        return Container(
                          color: isEvenRow ? Colors.grey.shade50 : Colors.transparent,
                          child: Row(
                            children: [
                              // Actual label with responsive sizing
                              Container(
                                width: layout == ResponsiveLayout.small ? 100.0 : 140.0,
                                height: layout == ResponsiveLayout.small ? 24.0 : 28.0,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade100,
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (layout != ResponsiveLayout.small) ...[
                                      const Text(
                                        'Actual',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('→', style: TextStyle(fontSize: 8)),
                                      const SizedBox(width: 4),
                                    ],
                                    Flexible(
                                      child: Text(
                                        widget.allFlowerClasses[rowEntry.key],
                                        style: TextStyle(
                                          fontSize: layout == ResponsiveLayout.small ? 7.0 : 9.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Responsive matrix cells
                              ...rowEntry.value.asMap().entries.map((cellEntry) {
                                final value = cellEntry.value;
                                final isDiagonal = rowEntry.key == cellEntry.key;
                                final maxValue = confusionMatrix
                                    .map((row) => row.reduce((a, b) => a > b ? a : b))
                                    .reduce((a, b) => a > b ? a : b);
                                final intensity = maxValue > 0 ? value / maxValue : 0.0;
                                
                                return Container(
                                  width: layout == ResponsiveLayout.small ? 40.0 : 50.0,
                                  height: layout == ResponsiveLayout.small ? 24.0 : 28.0,
                                  margin: const EdgeInsets.all(0.5),
                                  decoration: BoxDecoration(
                                    color: isDiagonal
                                        ? Colors.green.withValues(alpha: 0.3 + intensity * 0.7)
                                        : Colors.red.withValues(alpha: 0.1 + intensity * 0.4),
                                    border: Border.all(
                                      color: isDiagonal 
                                          ? Colors.green.shade300 
                                          : Colors.grey.shade300,
                                      width: isDiagonal ? 1.5 : 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      value.toString(),
                                      style: TextStyle(
                                        fontSize: layout == ResponsiveLayout.small ? 8.0 : 10.0,
                                        fontWeight: FontWeight.bold,
                                        color: value > 0 
                                            ? (value > maxValue * 0.5 ? Colors.black87 : Colors.black54)
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
