import 'package:cl_components/utils/models/custom_model.model.dart';
import '../enums/hr_enums.dart';

/// Slot pianificato di un turno di lavoro.
/// Usato da WorkSchedule e AttendanceRecord.
class PlannedSlot extends BaseModel {
  @override
  String get modelIdentifier => id;

  String id;
  SlotType slotType;
  String startTime; // "HH:mm"
  String endTime; // "HH:mm" o "HH:mm+1" per turni notturni
  BreakPolicy? breakPolicy;
  String? windowStart;
  String? windowEnd;
  int? minDurationMinutes;
  int? maxDurationMinutes;

  PlannedSlot({
    this.id = '',
    this.slotType = SlotType.work,
    this.startTime = '',
    this.endTime = '',
    this.breakPolicy,
    this.windowStart,
    this.windowEnd,
    this.minDurationMinutes,
    this.maxDurationMinutes,
  });

  factory PlannedSlot.fromJson({required dynamic jsonObject}) {
    return PlannedSlot(
      id: jsonObject['id'] ?? '',
      slotType: SlotType.fromString(jsonObject['slotType']) ?? SlotType.work,
      startTime: jsonObject['startTime'] ?? '',
      endTime: jsonObject['endTime'] ?? '',
      breakPolicy: BreakPolicy.fromString(jsonObject['breakPolicy']),
      windowStart: jsonObject['windowStart'],
      windowEnd: jsonObject['windowEnd'],
      minDurationMinutes: jsonObject['minDurationMinutes'],
      maxDurationMinutes: jsonObject['maxDurationMinutes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slotType': slotType.value,
      'startTime': startTime,
      'endTime': endTime,
      if (breakPolicy != null) 'breakPolicy': breakPolicy!.value,
      if (windowStart != null) 'windowStart': windowStart,
      if (windowEnd != null) 'windowEnd': windowEnd,
      if (minDurationMinutes != null) 'minDurationMinutes': minDurationMinutes,
      if (maxDurationMinutes != null) 'maxDurationMinutes': maxDurationMinutes,
    };
  }

  /// Formattazione leggibile dello slot
  String get displayRange => '$startTime - $endTime';
}
