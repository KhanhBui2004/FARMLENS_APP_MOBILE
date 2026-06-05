class SegmentationModel {
  final String id;
  final double lat;
  final double lng;
  final String date;
  final double cloudCover;
  final String sentinelImageUrl;
  final String segmentationUrl;
  final double regionAreaM2;

  SegmentationModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.date,
    required this.cloudCover,
    required this.sentinelImageUrl,
    required this.segmentationUrl,
    required this.regionAreaM2,
  });

  factory SegmentationModel.fromJson(Map<String, dynamic> json) {
    return SegmentationModel(
      id: json['_id'] ?? json['id'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      cloudCover: (json['cloud_cover'] as num?)?.toDouble() ?? 0.0,
      sentinelImageUrl: json['sentinel_url'] ?? '',
      segmentationUrl: json['segmentation_url'] ?? '',
      regionAreaM2: (json['region_area_m2'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
