class SegmentationModel {
  final String id;
  final double lat;
  final double lng;
  final String date;
  final double cloud_cover;
  final String sentinel_image_url;
  final String segmentation_url;
  final double pixel_area_m2;

  SegmentationModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.date,
    required this.cloud_cover,
    required this.sentinel_image_url,
    required this.segmentation_url,
    required this.pixel_area_m2,
  });

  factory SegmentationModel.fromJson(Map<String, dynamic> json) {
    return SegmentationModel(
      id: json['_id'] ?? json['id'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      cloud_cover: (json['cloud_cover'] as num?)?.toDouble() ?? 0.0,
      sentinel_image_url: json['sentinel_url'] ?? '',
      segmentation_url: json['segmentation_url'] ?? '',
      pixel_area_m2: (json['pixel_area_m2'] as num?)?.toDouble() ??
          (json['pixel_m2'] as num?)?.toDouble() ??
          0.0,
    );
  }
}
