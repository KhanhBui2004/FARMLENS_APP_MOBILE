class OverlayModel {
  final String imageUrl;
  final String analysisId;

  OverlayModel({required this.imageUrl, required this.analysisId});

  factory OverlayModel.fromJson(Map<String, dynamic> json) {
    return OverlayModel(
      imageUrl: json['overlay_url'] as String,
      analysisId: json['analysis_id'] as String,
    );
  }
}
