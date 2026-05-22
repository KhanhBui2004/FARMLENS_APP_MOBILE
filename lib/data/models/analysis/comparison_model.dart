class ComparisonModel {
	final String id;
	final double lat;
	final double lng;
	final List<String> dates;
	final double cloud_cover;
	final String created_at;
	final List<ComparisonTimelineItem> timeline;

	ComparisonModel({
		required this.id,
		required this.lat,
		required this.lng,
		required this.dates,
		required this.cloud_cover,
		required this.created_at,
		required this.timeline,
	});

	factory ComparisonModel.fromJson(Map<String, dynamic> json) {
		return ComparisonModel(
			id: json['_id'] ?? json['id'] ?? '',
			lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
			lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
			dates: (json['dates'] as List?)?.map((e) => e.toString()).toList() ?? [],
			cloud_cover: (json['cloud_cover'] as num?)?.toDouble() ?? 0.0,
			created_at: json['created_at'] ?? '',
			timeline: (json['timeline'] as List?)
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
	final ComparisonClasses classes;

	ComparisonTimelineItem({
		required this.date,
		required this.classes,
	});

	factory ComparisonTimelineItem.fromJson(Map<String, dynamic> json) {
		return ComparisonTimelineItem(
			date: json['date'] ?? '',
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
	final double area_km2;

	ComparisonClassArea({required this.area_km2});

	factory ComparisonClassArea.fromJson(Map<String, dynamic> json) {
		return ComparisonClassArea(
			area_km2: (json['area_km2'] as num?)?.toDouble() ?? 0.0,
		);
	}

	static ComparisonClassArea? fromJsonOrNull(dynamic value) {
		if (value is Map<String, dynamic> && value.isNotEmpty) {
			return ComparisonClassArea.fromJson(value);
		}
		return null;
	}
}
