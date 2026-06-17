class ComparisonModel {
  final String id;
  final double lat;
  final double lng;
  final List<String> dates;
  final double cloudCover;
  final String createdAt;
  final List<ComparisonTimelineItem> timeline;
  final FarmlandTrackingModel? farmlandTracking;
  final AbnormalityModel? abnormality;
  final RecommendationModel? recommendation;

  ComparisonModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.dates,
    required this.cloudCover,
    required this.createdAt,
    required this.timeline,
    required this.farmlandTracking,
    required this.abnormality,
    required this.recommendation,
  });

  factory ComparisonModel.fromJson(Map<String, dynamic> json) {
    return ComparisonModel(
      id: json['_id'] ?? json['id'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      dates: (json['dates'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cloudCover: (json['cloud_cover'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      timeline:
          (json['timeline'] as List?)
              ?.map(
                (item) => ComparisonTimelineItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      farmlandTracking: FarmlandTrackingModel.fromJsonOrNull(
        json['farmland_tracking'],
      ),
      abnormality: AbnormalityModel.fromJsonOrNull(json['abnormality']),
      recommendation: RecommendationModel.fromJsonOrNull(
        json['recommendation'],
      ),
    );
  }
}

class ComparisonTimelineItem {
  final String date;
  final Map<String, dynamic> imageSize;
  final int totalPixels;
  final double regionAreaM2;
  final double pixelAreaM2;
  final ComparisonClasses classes;

  ComparisonTimelineItem({
    required this.date,
    required this.classes,
    required this.imageSize,
    required this.totalPixels,
    required this.regionAreaM2,
    required this.pixelAreaM2,
  });

  factory ComparisonTimelineItem.fromJson(Map<String, dynamic> json) {
    return ComparisonTimelineItem(
      date: json['date']?.toString() ?? '',
      imageSize: (json['image_size'] as Map?)?.cast<String, dynamic>() ?? {},
      totalPixels: (json['total_pixels'] as num?)?.toInt() ?? 0,
      regionAreaM2: (json['region_area_m2'] as num?)?.toDouble() ?? 0.0,
      pixelAreaM2: (json['pixel_area_m2'] as num?)?.toDouble() ?? 0.0,
      classes: ComparisonClasses.fromJson(
        (json['classes'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
    );
  }
}

class ComparisonClasses {
  final ComparisonClassArea? agriculture;
  final ComparisonClassArea? barren;
  final ComparisonClassArea? forest;
  final ComparisonClassArea? rangeland;
  final ComparisonClassArea? unknown;
  final ComparisonClassArea? urban;
  final ComparisonClassArea? water;

  ComparisonClasses({
    required this.agriculture,
    required this.barren,
    required this.forest,
    required this.rangeland,
    required this.unknown,
    required this.urban,
    required this.water,
  });

  factory ComparisonClasses.fromJson(Map<String, dynamic> json) {
    return ComparisonClasses(
      agriculture: ComparisonClassArea.fromJsonOrNull(json['agriculture']),
      barren: ComparisonClassArea.fromJsonOrNull(json['barren']),
      forest: ComparisonClassArea.fromJsonOrNull(json['forest']),
      rangeland: ComparisonClassArea.fromJsonOrNull(json['rangeland']),
      unknown: ComparisonClassArea.fromJsonOrNull(json['unknown']),
      urban: ComparisonClassArea.fromJsonOrNull(json['urban']),
      water: ComparisonClassArea.fromJsonOrNull(json['water']),
    );
  }
}

class ComparisonClassArea {
  final double areaKm2;

  ComparisonClassArea({required this.areaKm2});

  factory ComparisonClassArea.fromJson(Map<String, dynamic> json) {
    return ComparisonClassArea(
      areaKm2: (json['area_km2'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static ComparisonClassArea? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return ComparisonClassArea.fromJson(value);
    }
    return null;
  }
}

class FarmlandTrackingModel {
  final double previousAgricultureAreaKm2;
  final double currentAgricultureAreaKm2;
  final double previousAgriculturePercentage;
  final double currentAgriculturePercentage;
  final double agricultureChangeKm2;
  final double agricultureChangePercentagePoints;
  final double agricultureRelativeChangePercentage;

  FarmlandTrackingModel({
    required this.previousAgricultureAreaKm2,
    required this.currentAgricultureAreaKm2,
    required this.previousAgriculturePercentage,
    required this.currentAgriculturePercentage,
    required this.agricultureChangeKm2,
    required this.agricultureChangePercentagePoints,
    required this.agricultureRelativeChangePercentage,
  });

  factory FarmlandTrackingModel.fromJson(Map<String, dynamic> json) {
    return FarmlandTrackingModel(
      previousAgricultureAreaKm2:
          (json['previous_agriculture_area_km2'] as num?)?.toDouble() ?? 0.0,
      currentAgricultureAreaKm2:
          (json['current_agriculture_area_km2'] as num?)?.toDouble() ?? 0.0,
      previousAgriculturePercentage:
          (json['previous_agriculture_percentage'] as num?)?.toDouble() ?? 0.0,
      currentAgriculturePercentage:
          (json['current_agriculture_percentage'] as num?)?.toDouble() ?? 0.0,
      agricultureChangeKm2:
          (json['agriculture_change_km2'] as num?)?.toDouble() ?? 0.0,
      agricultureChangePercentagePoints:
          (json['agriculture_change_percentage_points'] as num?)?.toDouble() ??
          0.0,
      agricultureRelativeChangePercentage:
          (json['agriculture_relative_change_percentage'] as num?)
              ?.toDouble() ??
          0.0,
    );
  }

  static FarmlandTrackingModel? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return FarmlandTrackingModel.fromJson(value);
    }
    return null;
  }
}

class AbnormalityModel {
  final String status;
  final String label;
  final bool priorityCheck;
  final String reason;

  AbnormalityModel({
    required this.status,
    required this.label,
    required this.priorityCheck,
    required this.reason,
  });

  factory AbnormalityModel.fromJson(Map<String, dynamic> json) {
    return AbnormalityModel(
      status: json['status']?.toString() ?? 'stable',
      label: json['label']?.toString() ?? 'Stable',
      priorityCheck: json['priority_check'] == true,
      reason: json['reason']?.toString() ?? '',
    );
  }

  static AbnormalityModel? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return AbnormalityModel.fromJson(value);
    }
    return null;
  }
}

class RecommendationModel {
  final String status;
  final String summary;
  final List<String> actions;
  final List<String> secondaryInsights;

  RecommendationModel({
    required this.status,
    required this.summary,
    required this.actions,
    required this.secondaryInsights,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      status: json['status']?.toString() ?? 'stable',
      summary: json['summary']?.toString() ?? '',
      actions:
          (json['actions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      secondaryInsights:
          (json['secondary_insights'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  static RecommendationModel? fromJsonOrNull(dynamic value) {
    if (value is Map<String, dynamic> && value.isNotEmpty) {
      return RecommendationModel.fromJson(value);
    }
    return null;
  }
}
