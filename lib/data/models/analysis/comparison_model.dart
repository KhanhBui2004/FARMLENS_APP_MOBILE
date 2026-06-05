class ComparisonModel {
  final String id;
  final double lat;
  final double lng;
  final List<String> dates;
  final double cloudCover;
  final String createdAt;
  final List<ComparisonTimelineItem> timeline;

  ComparisonModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.dates,
    required this.cloudCover,
    required this.createdAt,
    required this.timeline,
  });

  factory ComparisonModel.fromJson(Map<String, dynamic> json) {
    return ComparisonModel(
      id: json['_id'] ?? json['id'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      dates: (json['dates'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cloudCover: (json['cloud_cover'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] ?? '',
      timeline:
          (json['timeline'] as List?)
              ?.map(
                (item) => ComparisonTimelineItem.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
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
      date: json['date'] ?? '',
      imageSize: json['image_size'] ?? {},
      totalPixels: (json['total_pixels'] as num?)?.toInt() ?? 0,
      regionAreaM2: (json['region_area_m2'] as num?)?.toDouble() ?? 0.0,
      pixelAreaM2: (json['pixel_area_m2'] as num?)?.toDouble() ?? 0.0,
      classes: ComparisonClasses.fromJson(json['classes'] ?? {}),
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
