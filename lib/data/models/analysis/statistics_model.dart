class StatisticsModel {
  final String id;
  final String analysisId;
  final String createdAt;
  final ImageSizeModel imageSize;
  final ClassesModel classes;
  final int totalPixels;
  final int unmatchedPixels;
  final double pixelAreaM2;
  final double regionAreaM2;
  final SurveyRegionModel? surveyRegion;
  final double? centerXRatio;
  final double? centerYRatio;
  final double? markerXRatio;
  final double? markerYRatio;
  final CurrentAreaAssessmentModel? currentAreaAssessment;

  StatisticsModel({
    required this.id,
    required this.analysisId,
    required this.createdAt,
    required this.imageSize,
    required this.classes,
    required this.totalPixels,
    required this.unmatchedPixels,
    required this.pixelAreaM2,
    required this.regionAreaM2,
    required this.surveyRegion,
    required this.centerXRatio,
    required this.centerYRatio,
    required this.markerXRatio,
    required this.markerYRatio,
    required this.currentAreaAssessment,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      id: json['_id'] ?? json['id'],
      analysisId: json['analysis_id'],
      createdAt: json['created_at'],
      imageSize: ImageSizeModel.fromJson(json['image_size'] ?? {}),
      classes: ClassesModel.fromJson(json['classes'] ?? {}),
      totalPixels: (json['total_pixels'] as num?)?.toInt() ?? 0,
      unmatchedPixels: (json['unmatched_pixels'] as num?)?.toInt() ?? 0,
      pixelAreaM2: (json['pixel_area_m2'] as num?)?.toDouble() ?? 0.0,
      regionAreaM2: (json['region_area_m2'] as num?)?.toDouble() ?? 0.0,
      surveyRegion: SurveyRegionModel.fromJsonOrNull(json['survey_region']),
      centerXRatio: (json['center_x_ratio'] as num?)?.toDouble(),
      centerYRatio: (json['center_y_ratio'] as num?)?.toDouble(),
      markerXRatio: (json['marker_x_ratio'] as num?)?.toDouble(),
      markerYRatio: (json['marker_y_ratio'] as num?)?.toDouble(),
      currentAreaAssessment: CurrentAreaAssessmentModel.fromJsonOrNull(
        json['current_area_assessment'],
      ),
    );
  }
}

class ImageSizeModel {
  final int width;
  final int height;

  ImageSizeModel({required this.width, required this.height});

  factory ImageSizeModel.fromJson(Map<String, dynamic> json) {
    return ImageSizeModel(
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClassesModel {
  final ClassStatsModel? agriculture;
  final ClassStatsModel? barren;
  final ClassStatsModel? forest;
  final ClassStatsModel? rangeland;
  final ClassStatsModel? unknown;
  final ClassStatsModel? urban;
  final ClassStatsModel? water;

  ClassesModel({
    required this.agriculture,
    required this.barren,
    required this.forest,
    required this.rangeland,
    required this.unknown,
    required this.urban,
    required this.water,
  });

  factory ClassesModel.fromJson(Map<String, dynamic> json) {
    return ClassesModel(
      agriculture: ClassStatsModel.fromJsonOrNull(json['agriculture']),
      barren: ClassStatsModel.fromJsonOrNull(json['barren']),
      forest: ClassStatsModel.fromJsonOrNull(json['forest']),
      rangeland: ClassStatsModel.fromJsonOrNull(json['rangeland']),
      unknown: ClassStatsModel.fromJsonOrNull(json['unknown']),
      urban: ClassStatsModel.fromJsonOrNull(json['urban']),
      water: ClassStatsModel.fromJsonOrNull(json['water']),
    );
  }
}

class ClassStatsModel {
  final int pixel_count;
  final double area_km2;
  final double percentage;

  ClassStatsModel({
    required this.pixel_count,
    required this.area_km2,
    required this.percentage,
  });

  factory ClassStatsModel.fromJson(Map<String, dynamic> json) {
    return ClassStatsModel(
      pixel_count: (json['pixel_count'] as num?)?.toInt() ?? 0,
      area_km2: (json['area_km2'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static ClassStatsModel? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return ClassStatsModel.fromJson(value);
    }
    return null;
  }
}

class CurrentAreaAssessmentModel {
  final String suitability;
  final String priority;
  final String summary;
  final List<String> insights;
  final Map<String, double> classPercentages;

  CurrentAreaAssessmentModel({
    required this.suitability,
    required this.priority,
    required this.summary,
    required this.insights,
    required this.classPercentages,
  });

  factory CurrentAreaAssessmentModel.fromJson(Map<String, dynamic> json) {
    final rawPercentages =
        (json['class_percentages'] as Map?)?.cast<String, dynamic>() ?? {};

    return CurrentAreaAssessmentModel(
      suitability: json['suitability']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      insights:
          (json['insights'] as List?)?.map((e) => e.toString()).toList() ?? [],
      classPercentages: rawPercentages.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  static CurrentAreaAssessmentModel? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return CurrentAreaAssessmentModel.fromJson(value);
    }
    return null;
  }
}

class SurveyRegionModel {
  final bool available;
  final String label;
  final String? reason;
  final int componentCount;
  final int pixelCount;
  final double areaKm2;
  final double percentageOfAgriculture;
  final double? centerLat;
  final double? centerLng;
  final double? centerXRatio;
  final double? centerYRatio;
  final double? markerXRatio;
  final double? markerYRatio;

  SurveyRegionModel({
    required this.available,
    required this.label,
    required this.reason,
    required this.componentCount,
    required this.pixelCount,
    required this.areaKm2,
    required this.percentageOfAgriculture,
    required this.centerLat,
    required this.centerLng,
    required this.centerXRatio,
    required this.centerYRatio,
    required this.markerXRatio,
    required this.markerYRatio,
  });

  factory SurveyRegionModel.fromJson(Map<String, dynamic> json) {
    return SurveyRegionModel(
      available: json['available'] == true,
      label: json['label']?.toString() ?? '',
      reason: json['reason']?.toString(),
      componentCount: (json['component_count'] as num?)?.toInt() ?? 0,
      pixelCount: (json['pixel_count'] as num?)?.toInt() ?? 0,
      areaKm2: (json['area_km2'] as num?)?.toDouble() ?? 0.0,
      percentageOfAgriculture:
          (json['percentage_of_agriculture'] as num?)?.toDouble() ?? 0.0,
      centerLat: (json['center_lat'] as num?)?.toDouble(),
      centerLng: (json['center_lng'] as num?)?.toDouble(),
      centerXRatio: (json['center_x_ratio'] as num?)?.toDouble(),
      centerYRatio: (json['center_y_ratio'] as num?)?.toDouble(),
      markerXRatio: (json['marker_x_ratio'] as num?)?.toDouble(),
      markerYRatio: (json['marker_y_ratio'] as num?)?.toDouble(),
    );
  }

  static SurveyRegionModel? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return SurveyRegionModel.fromJson(value);
    }

    if (value is Map && value.isNotEmpty) {
      return SurveyRegionModel.fromJson(Map<String, dynamic>.from(value));
    }

    return null;
  }
}
