import 'dart:typed_data';

import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportExportService {
  Future<Uint8List> buildPdfReport({
    required StatisticsModel stats,
    required String? segmentationId,
    required DateTime analysisDate,
    required double? lat,
    required double? lng,
    required double cloudCoverage,
    required double calculatedArea,
    required String? sentinelImageUrl,
    required String? segmentationImageUrl,
    ComparisonModel? comparisonResult,
  }) async {
    final pdf = pw.Document();

    final sentinelBytes = await _loadNetworkImageBytes(sentinelImageUrl);
    final segmentationBytes = await _loadNetworkImageBytes(
      segmentationImageUrl,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Text(
              'FarmLens Land Cover Analysis Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Analysis ID: ${segmentationId ?? '-'}'),
            pw.Text(
              'Location: ${lat?.toStringAsFixed(5) ?? '-'}, ${lng?.toStringAsFixed(5) ?? '-'}',
            ),
            pw.Text('Analysis date: ${_formatDate(analysisDate)}'),
            pw.Text('Cloud cover: ${cloudCoverage.toStringAsFixed(1)}%'),
            pw.Text('Area: ${calculatedArea.toStringAsFixed(2)} ha'),
            pw.SizedBox(height: 18),

            pw.Text(
              'Satellite and Segmentation Result',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            if (sentinelBytes != null) ...[
              pw.Text('Sentinel Image'),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(sentinelBytes),
                  height: 280,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            if (segmentationBytes != null) ...[
              pw.Text('Segmentation Image'),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(segmentationBytes),
                  height: 280,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 18),
            ],

            pw.Text(
              'Land Cover Statistics',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildStatsTable(stats),

            pw.SizedBox(height: 18),
            pw.Text(
              'Automatic Interpretation',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(_generateInterpretation(stats)),

            if (comparisonResult != null) ...[
              pw.SizedBox(height: 18),
              pw.Text(
                'Change Detection Summary',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Unit: km2'),
              pw.SizedBox(height: 8),
              _buildChangeDetectionTable(comparisonResult),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List?> _loadNetworkImageBytes(String? url) async {
    if (url == null || url.trim().isEmpty) return null;

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    return null;
  }

  pw.Widget _buildStatsTable(StatisticsModel stats) {
    final rows = [
      _statsRow('Agriculture', stats.classes.agriculture),
      _statsRow('Barren', stats.classes.barren),
      _statsRow('Forest', stats.classes.forest),
      _statsRow('Rangeland', stats.classes.rangeland),
      _statsRow('Urban', stats.classes.urban),
      _statsRow('Water', stats.classes.water),
      _statsRow('Unknown', stats.classes.unknown),
    ];

    return pw.Table.fromTextArray(
      headers: ['Class', 'Percentage', 'Area'],
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  List<String> _statsRow(String label, ClassStatsModel? stats) {
    if (stats == null) {
      return [label, '-', '-'];
    }

    return [
      label,
      '${stats.percentage.toStringAsFixed(2)}%',
      '${stats.area_km2.toStringAsFixed(3)} km2',
    ];
  }

  String _generateInterpretation(StatisticsModel stats) {
    final agriculture = stats.classes.agriculture?.percentage ?? 0;
    final forest = stats.classes.forest?.percentage ?? 0;
    final water = stats.classes.water?.percentage ?? 0;
    final urban = stats.classes.urban?.percentage ?? 0;
    final rangeland = stats.classes.rangeland?.percentage ?? 0;

    final buffer = StringBuffer();

    if (agriculture >= 50) {
      buffer.writeln(
        'Agriculture land occupies the largest proportion of the selected area, indicating that the region is mainly used for agricultural activities.',
      );
    }

    if (forest >= 15) {
      buffer.writeln(
        'Forest land accounts for a notable proportion, which may contribute to ecological balance and environmental stability.',
      );
    }

    if (water < 5) {
      buffer.writeln(
        'Water surface is relatively limited in the selected area.',
      );
    }

    if (urban >= 20) {
      buffer.writeln(
        'Urban land has a significant presence, suggesting possible residential or infrastructure development.',
      );
    }

    if (rangeland > 0) {
      buffer.writeln(
        'Rangeland is detected and may represent grassland or sparse vegetation areas.',
      );
    }

    if (buffer.isEmpty) {
      buffer.writeln(
        'The selected area contains multiple land cover types with no single class dominating strongly.',
      );
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  List<String> _comparisonClassOrder() {
    return [
      'agriculture',
      'barren',
      'forest',
      'rangeland',
      'unknown',
      'urban',
      'water',
    ];
  }

  double _getComparisonArea(ComparisonClasses classes, String key) {
    switch (key) {
      case 'agriculture':
        return classes.agriculture?.areaKm2 ?? 0.0;
      case 'barren':
        return classes.barren?.areaKm2 ?? 0.0;
      case 'forest':
        return classes.forest?.areaKm2 ?? 0.0;
      case 'rangeland':
        return classes.rangeland?.areaKm2 ?? 0.0;
      case 'unknown':
        return classes.unknown?.areaKm2 ?? 0.0;
      case 'urban':
        return classes.urban?.areaKm2 ?? 0.0;
      case 'water':
        return classes.water?.areaKm2 ?? 0.0;
      default:
        return 0.0;
    }
  }

  pw.Widget _buildChangeDetectionTable(ComparisonModel comparison) {
    final timeline = comparison.timeline;

    if (timeline.length < 2) {
      return pw.Text('Not enough timeline data to compare.');
    }

    final first = timeline[0];
    final second = timeline[1];

    final rows = _comparisonClassOrder().map((key) {
      final value1 = _getComparisonArea(first.classes, key);
      final value2 = _getComparisonArea(second.classes, key);
      final delta = value2 - value1;

      return [
        key,
        value1.toStringAsFixed(3),
        value2.toStringAsFixed(3),
        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(3)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: ['Class', first.date, second.date, 'Change'],
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }
}
