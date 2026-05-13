class StatisticsModel {
  final String id;
  final String analysis_id;
  final String created_at;
  final ImageSizeModel image_size;
  final ClassesModel classes;

  StatisticsModel({
    required this.id,
    required this.analysis_id,
    required this.created_at,
    required this.image_size,
    required this.classes,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      id: json['_id'] ?? json['id'],
      analysis_id: json['analysis_id'],
      created_at: json['created_at'],
      image_size: ImageSizeModel.fromJson(json['image_size'] ?? {}),
      classes: ClassesModel.fromJson(json['classes'] ?? {}),
    );
  }
}

class ImageSizeModel {
  final int width;
  final int height;
  final int total_pixels;
  final int unmatched_pixels;
  final double pixel_area_m2;

  ImageSizeModel({
    required this.width,
    required this.height,
    required this.total_pixels,
    required this.unmatched_pixels,
    required this.pixel_area_m2,
  });

  factory ImageSizeModel.fromJson(Map<String, dynamic> json) {
    return ImageSizeModel(
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      total_pixels: (json['total_pixels'] as num?)?.toInt() ?? 0,
      unmatched_pixels: (json['unmatched_pixels'] as num?)?.toInt() ?? 0,
      pixel_area_m2: (json['pixel_area_m2'] as num?)?.toDouble() ?? 0.0,
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
