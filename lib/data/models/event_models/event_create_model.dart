// lib/data/models/event_models/event_create_model.dart
class EventCreateModel {
  String name;
  String descriptionText;
  String location;
  DateTime startDate;
  DateTime endDate;
  List<String> descriptionImages;
  String eventType;
  bool isBoostedEvent;

  EventCreateModel({
    required this.name,
    required this.descriptionText,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.descriptionImages,
    required this.eventType,
    required this.isBoostedEvent,
  });

  // JSON veriye dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'descriptionText': descriptionText,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'descriptionImages': descriptionImages,
      'eventType': eventType,
      'isBoostedEvent': isBoostedEvent,
    };
  }

  // JSON veriden model oluşturma
  factory EventCreateModel.fromJson(Map<String, dynamic> json) {
    return EventCreateModel(
      name: json['name'],
      descriptionText: json['descriptionText'],
      location: json['location'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      descriptionImages: List<String>.from(json['descriptionImages']),
      eventType: json['eventType'],
      isBoostedEvent: json['isBoostedEvent'],
    );
  }
}
