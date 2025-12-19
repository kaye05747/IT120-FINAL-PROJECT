import 'package:flutter/material.dart';
import 'providers/detection_provider.dart';
import 'responsive_layout.dart';

class AnalyticsSummary extends StatelessWidget {
  final DetectionProvider detectionProvider;

  const AnalyticsSummary({
    super.key,
    required this.detectionProvider,
  });

  // Responsive layout constants
  static const double _summarySpacing = 16.0;
  static const double _bottomPadding = 16.0;
  static const double _sidePadding = 16.0;
  
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_sidePadding),
      child: Column(
        children: [
          _buildSummaryCards(context),
          _buildDetailedStats(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final layout = _getResponsiveLayout(context);
    final totalDetections = detectionProvider.totalDetections;
    final avgConfidence = detectionProvider.averageConfidence;
    final mostDetected = detectionProvider.mostDetectedClass;

    // Responsive container height
    double containerHeight;
    switch (layout) {
      case ResponsiveLayout.small:
        containerHeight = 220.0; // Reduced from 280.0
        break;
      case ResponsiveLayout.medium:
        containerHeight = 200.0; // Reduced from 232.0
        break;
      case ResponsiveLayout.large:
        containerHeight = 180.0; // Reduced from 200.0
        break;
    }

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildSummaryCardsRow(
              context,
              [
                _buildSummaryCard(
                  context,
                  'Total Detections',
                  totalDetections.toString(),
                  Icons.analytics,
                  Colors.pink,
                ),
                _buildSummaryCard(
                  context,
                  'Avg Confidence',
                  '${avgConfidence.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCardsRow(
              context,
              [
                _buildSummaryCard(
                  context,
                  'Most Detected',
                  mostDetected,
                  Icons.favorite,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  context,
                  'Flower Types',
                  detectionProvider.detectionStats.length.toString(),
                  Icons.local_florist,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Total Classes card (full width)
            _buildSummaryCard(
              context,
              'Total Classes Available',
              '10',
              Icons.class_,
              Colors.blue,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsRow(BuildContext context, List<Widget> cards) {
    final layout = _getResponsiveLayout(context);
    
    // Responsive spacing for small screens
    double spacing = layout == ResponsiveLayout.small ? 8.0 : 12.0;
    
    final childrenWithSpacing = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      childrenWithSpacing.add(Expanded(child: cards[i]));
      if (i < cards.length - 1) {
        childrenWithSpacing.add(SizedBox(width: spacing));
      }
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: childrenWithSpacing,
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final layout = _getResponsiveLayout(context);
    
    // Responsive padding and font sizes
    double padding = layout == ResponsiveLayout.small ? 12.0 : 16.0;
    double titleFontSize = layout == ResponsiveLayout.small ? 10.0 : 12.0;
    double valueFontSize = layout == ResponsiveLayout.small ? 16.0 : 18.0;
    double iconSize = layout == ResponsiveLayout.small ? 16.0 : 20.0;
    
    return Container(
      margin: const EdgeInsets.all(2),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: iconSize),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    final layout = _getResponsiveLayout(context);
    final detectionStats = detectionProvider.detectionStats;
    
    if (detectionStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No detection data available',
          style: TextStyle(
            fontSize: layout == ResponsiveLayout.small ? 14.0 : 16.0,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    // Responsive container height
    double containerHeight;
    switch (layout) {
      case ResponsiveLayout.small:
        containerHeight = 200.0;
        break;
      case ResponsiveLayout.medium:
        containerHeight = 250.0;
        break;
      case ResponsiveLayout.large:
        containerHeight = 300.0;
        break;
    }

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detection Details',
              style: TextStyle(
                fontSize: layout == ResponsiveLayout.small ? 16.0 : 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            ...detectionStats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: layout == ResponsiveLayout.small ? 12.0 : 14.0,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: layout == ResponsiveLayout.small ? 12.0 : 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
