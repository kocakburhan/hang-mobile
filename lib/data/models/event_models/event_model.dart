class Event {
  final int id;
  final String name;
  final String descriptionText;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? eventType;
  final List<String>? participants;
  final List<String> descriptionImages;
  final bool boostedEvent;

  Event({
    required this.id,
    required this.name,
    required this.descriptionText,
    required this.location,
    this.startDate,
    this.endDate,
    this.eventType,
    this.participants,
    required this.descriptionImages,
    required this.boostedEvent,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      descriptionText: json['descriptionText'],
      location: json['location'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      eventType: json['eventType'],
      participants:
          json['participants'] != null
              ? List<String>.from(json['participants'])
              : null,
      descriptionImages: List<String>.from(json['descriptionImages'] ?? []),
      boostedEvent: json['boostedEvent'] ?? false,
    );
  }
}
