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
    );
  }
}

class ImageSizeModel {
  final int width;
  final int height;

  ImageSizeModel({
    required this.width,
    required this.height,
  });

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
