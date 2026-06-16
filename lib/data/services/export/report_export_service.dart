import 'dart:typed_data';

import 'package:farmlens_app/data/models/analysis/comparison_model.dart';
import 'package:farmlens_app/data/models/analysis/statistics_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const primaryGreen = PdfColor.fromInt(0xFF2E7D32);
const darkGreen = PdfColor.fromInt(0xFF1B5E20);
const lightGreen = PdfColor.fromInt(0xFFE8F5E9);
const softGray = PdfColor.fromInt(0xFFF1F3F4);
const borderGray = PdfColor.fromInt(0xFFDADCE0);
const textDark = PdfColor.fromInt(0xFF263238);
const textMuted = PdfColor.fromInt(0xFF546E7A);
const warningOrange = PdfColor.fromInt(0xFFF57C00);
const dangerRed = PdfColor.fromInt(0xFFC62828);

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

    // Cần font Unicode để hiển thị tiếng Việt
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final sentinelBytes = await _loadNetworkImageBytes(sentinelImageUrl);
    final segmentationBytes = await _loadNetworkImageBytes(
      segmentationImageUrl,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        build: (context) {
          return [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: lightGreen,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: primaryGreen, width: 1),
              ),
              child: pw.Text(
                'BÁO CÁO PHÂN TÍCH LỚP PHỦ ĐẤT - FARMLENS',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: darkGreen,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 12),

            pw.Text('Mã phân tích: ${segmentationId ?? '-'}'),
            pw.Text(
              'Vị trí: ${lat?.toStringAsFixed(5) ?? '-'}, ${lng?.toStringAsFixed(5) ?? '-'}',
            ),
            pw.Text('Ngày phân tích: ${_formatDate(analysisDate)}'),
            pw.Text('Độ che phủ mây: ${cloudCoverage.toStringAsFixed(1)}%'),
            pw.Text(
              'Diện tích khu vực: ${calculatedArea.toStringAsFixed(2)} km²',
            ),

            pw.SizedBox(height: 18),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                color: softGray,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                '1. ẢNH VỆ TINH VÀ KẾT QUẢ PHÂN ĐOẠN',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
            pw.SizedBox(height: 8),

            if (sentinelBytes != null) ...[
              pw.Text(
                'Ảnh Sentinel-2',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(sentinelBytes),
                  height: 260,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            if (segmentationBytes != null) ...[
              pw.Text(
                'Ảnh kết quả phân đoạn',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(segmentationBytes),
                  height: 260,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 18),
            ],

            pw.Text(
              '2. THỐNG KÊ LỚP PHỦ ĐẤT',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildStatsTable(stats),

            pw.SizedBox(height: 18),
            pw.Text(
              '3. NHẬN XÉT TỰ ĐỘNG',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF8FBF8),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderGray, width: 0.8),
              ),
              child: pw.Text(
                _generateInterpretation(stats),
                style: const pw.TextStyle(
                  color: textDark,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),

            if (comparisonResult != null) ...[
              pw.SizedBox(height: 18),
              pw.Text(
                '4. SO SÁNH BIẾN ĐỘNG THEO THỜI GIAN',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Đơn vị: km²'),
              pw.SizedBox(height: 8),
              _buildChangeDetectionTable(comparisonResult),

              pw.SizedBox(height: 18),
              pw.Text(
                '5. HỖ TRỢ RA QUYẾT ĐỊNH',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildDecisionSupportSection(comparisonResult),
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
      _statsRow('Đất nông nghiệp', stats.classes.agriculture),
      _statsRow('Đất trống', stats.classes.barren),
      _statsRow('Rừng', stats.classes.forest),
      _statsRow('Đồng cỏ', stats.classes.rangeland),
      _statsRow('Đô thị', stats.classes.urban),
      _statsRow('Mặt nước', stats.classes.water),
      _statsRow('Không xác định', stats.classes.unknown),
    ];

    return pw.Table.fromTextArray(
      headers: ['Lớp phủ', 'Tỷ lệ', 'Diện tích'],
      data: rows,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: darkGreen,
      ),
      cellStyle: const pw.TextStyle(color: textDark, fontSize: 10.5),
      headerDecoration: const pw.BoxDecoration(color: lightGreen),
      border: pw.TableBorder.all(color: borderGray, width: 0.6),
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
      '${stats.area_km2.toStringAsFixed(3)} km²',
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
        'Đất nông nghiệp chiếm tỷ lệ lớn nhất trong khu vực phân tích, cho thấy khu vực có đặc trưng sản xuất nông nghiệp rõ rệt.',
      );
    }

    if (forest >= 15) {
      buffer.writeln(
        'Diện tích rừng chiếm tỷ lệ đáng kể, góp phần duy trì cân bằng sinh thái cho khu vực.',
      );
    }

    if (water < 5) {
      buffer.writeln('Diện tích mặt nước trong khu vực ở mức thấp.');
    }

    if (urban >= 20) {
      buffer.writeln(
        'Đất đô thị chiếm tỷ lệ đáng kể, cho thấy khu vực có khả năng chịu tác động của hoạt động xây dựng hoặc hạ tầng.',
      );
    }

    if (rangeland > 0) {
      buffer.writeln(
        'Hệ thống phát hiện vùng đồng cỏ hoặc thảm thực vật thưa trong khu vực phân tích.',
      );
    }

    if (buffer.isEmpty) {
      buffer.writeln(
        'Khu vực phân tích bao gồm nhiều loại lớp phủ đất và không có lớp nào chiếm ưu thế tuyệt đối.',
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

  String _comparisonLabel(String key) {
    switch (key) {
      case 'agriculture':
        return 'Đất nông nghiệp';
      case 'barren':
        return 'Đất trống';
      case 'forest':
        return 'Rừng';
      case 'rangeland':
        return 'Đồng cỏ';
      case 'unknown':
        return 'Không xác định';
      case 'urban':
        return 'Đô thị';
      case 'water':
        return 'Mặt nước';
      default:
        return key;
    }
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
      return pw.Text('Không đủ dữ liệu thời gian để so sánh.');
    }

    final first = timeline[0];
    final second = timeline[1];

    final rows = _comparisonClassOrder().map((key) {
      final value1 = _getComparisonArea(first.classes, key);
      final value2 = _getComparisonArea(second.classes, key);
      final delta = value2 - value1;

      return [
        _comparisonLabel(key),
        value1.toStringAsFixed(3),
        value2.toStringAsFixed(3),
        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(3)}',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: ['Lớp phủ', first.date, second.date, 'Chênh lệch'],
      data: rows,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: darkGreen,
      ),
      cellStyle: const pw.TextStyle(color: textDark, fontSize: 10.5),
      headerDecoration: const pw.BoxDecoration(color: lightGreen),
      border: pw.TableBorder.all(color: borderGray, width: 0.6),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  pw.Widget _buildDecisionSupportSection(ComparisonModel comparison) {
    final farmland = comparison.farmlandTracking;
    final abnormality = comparison.abnormality;
    final recommendation = comparison.recommendation;

    final rows = <List<String>>[];

    if (farmland != null) {
      rows.add([
        'Đất canh tác hiện tại',
        '${farmland.currentAgricultureAreaKm2.toStringAsFixed(3)} km²',
      ]);
      rows.add([
        'Biến động đất canh tác',
        '${farmland.agricultureRelativeChangePercentage >= 0 ? '+' : ''}${farmland.agricultureRelativeChangePercentage.toStringAsFixed(2)}%',
      ]);
    }

    if (abnormality != null) {
      rows.add(['Trạng thái', abnormality.label]);
      rows.add(['Đánh giá', abnormality.reason]);
    }

    if (recommendation != null) {
      rows.add(['Khuyến nghị', recommendation.summary]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Table.fromTextArray(
          headers: ['Nội dung', 'Giá trị'],
          data: rows,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: darkGreen,
          ),
          cellStyle: const pw.TextStyle(color: textDark, fontSize: 10.5),
          headerDecoration: const pw.BoxDecoration(color: lightGreen),
          border: pw.TableBorder.all(color: borderGray, width: 0.6),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding: const pw.EdgeInsets.all(6),
        ),
        if (recommendation != null && recommendation.actions.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            'Hành động đề xuất:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          ...recommendation.actions.map(
            (action) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• '),
                  pw.Expanded(child: pw.Text(action)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
