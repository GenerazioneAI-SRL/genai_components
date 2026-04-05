/// Enums condivisi per il modulo HR
/// Allineati alla specifica API backend skillGateway
library;

// ============================================================
// TIME EVENTS
// ============================================================

/// Tipo di evento timbratura
enum EventType {
  clockIn('CLOCK_IN'),
  clockOut('CLOCK_OUT'),
  breakStart('BREAK_START'),
  breakEnd('BREAK_END');

  final String value;
  const EventType(this.value);

  static EventType? fromString(String? value) {
    if (value == null) return null;
    return EventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventType.clockIn,
    );
  }

  String get displayName {
    switch (this) {
      case EventType.clockIn:
        return 'Entrata';
      case EventType.clockOut:
        return 'Uscita';
      case EventType.breakStart:
        return 'Inizio Pausa';
      case EventType.breakEnd:
        return 'Fine Pausa';
    }
  }
}

/// Sorgente dell'evento timbratura
enum EventSource {
  deviceNfc('DEVICE_NFC'),
  deviceQr('DEVICE_QR'),
  deviceQrAuto('DEVICE_QR_AUTO'),
  webapp('WEBAPP'),
  manualEntry('MANUAL_ENTRY'),
  systemAutoFix('SYSTEM_AUTO_FIX'),
  correction('CORRECTION');

  final String value;
  const EventSource(this.value);

  static EventSource? fromString(String? value) {
    if (value == null) return null;
    return EventSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EventSource.webapp,
    );
  }

  String get displayName {
    switch (this) {
      case EventSource.deviceNfc:
        return 'Dispositivo NFC';
      case EventSource.deviceQr:
        return 'QR Code';
      case EventSource.deviceQrAuto:
        return 'QR Automatico';
      case EventSource.webapp:
        return 'WebApp';
      case EventSource.manualEntry:
        return 'Inserimento Manuale';
      case EventSource.systemAutoFix:
        return 'Correzione Automatica';
      case EventSource.correction:
        return 'Correzione';
    }
  }
}

// ============================================================
// ATTENDANCE (PRESENZE)
// ============================================================

/// Stato della presenza calcolata
enum AttendanceStatus {
  present('PRESENT'),
  presentWithAnomaly('PRESENT_WITH_ANOMALY'),
  absent('ABSENT'),
  absentJustified('ABSENT_JUSTIFIED'),
  absentUnjustified('ABSENT_UNJUSTIFIED'),
  partial('PARTIAL'),
  partialJustified('PARTIAL_JUSTIFIED'),
  partialUnjustified('PARTIAL_UNJUSTIFIED'),
  dayOff('DAY_OFF'),
  restDay('REST_DAY'),
  holiday('HOLIDAY'),
  notApplicable('NOT_APPLICABLE');

  final String value;
  const AttendanceStatus(this.value);

  static AttendanceStatus? fromString(String? value) {
    if (value == null) return null;
    return AttendanceStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AttendanceStatus.notApplicable,
    );
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Presente';
      case AttendanceStatus.presentWithAnomaly:
        return 'Presente con anomalie';
      case AttendanceStatus.absent:
        return 'Assente';
      case AttendanceStatus.absentJustified:
        return 'Assente giustificato';
      case AttendanceStatus.absentUnjustified:
        return 'Assente ingiustificato';
      case AttendanceStatus.partial:
        return 'Parziale';
      case AttendanceStatus.partialJustified:
        return 'Parziale giustificato';
      case AttendanceStatus.partialUnjustified:
        return 'Parziale ingiustificato';
      case AttendanceStatus.dayOff:
        return 'Giorno libero';
      case AttendanceStatus.restDay:
        return 'Riposo';
      case AttendanceStatus.holiday:
        return 'Festivo';
      case AttendanceStatus.notApplicable:
        return 'Non applicabile';
    }
  }

  /// Colore associato allo stato per UI
  String get colorHex {
    switch (this) {
      case AttendanceStatus.present:
        return '#22C55E';
      case AttendanceStatus.presentWithAnomaly:
        return '#F59E0B';
      case AttendanceStatus.absent:
      case AttendanceStatus.absentUnjustified:
        return '#EF4444';
      case AttendanceStatus.absentJustified:
        return '#3B82F6';
      case AttendanceStatus.partial:
      case AttendanceStatus.partialUnjustified:
        return '#F97316';
      case AttendanceStatus.partialJustified:
        return '#8B5CF6';
      case AttendanceStatus.dayOff:
      case AttendanceStatus.restDay:
        return '#6B7280';
      case AttendanceStatus.holiday:
        return '#06B6D4';
      case AttendanceStatus.notApplicable:
        return '#9CA3AF';
    }
  }
}

/// Tipo di giornata lavorativa
enum WorkdayType {
  workday('WORKDAY'),
  restDay('REST_DAY'),
  dayOff('DAY_OFF'),
  holiday('HOLIDAY'),
  companyClosure('COMPANY_CLOSURE');

  final String value;
  const WorkdayType(this.value);

  static WorkdayType? fromString(String? value) {
    if (value == null) return null;
    return WorkdayType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkdayType.workday,
    );
  }

  String get displayName {
    switch (this) {
      case WorkdayType.workday:
        return 'Giorno Lavorativo';
      case WorkdayType.restDay:
        return 'Giorno di Riposo';
      case WorkdayType.dayOff:
        return 'Giorno Libero';
      case WorkdayType.holiday:
        return 'Festivo';
      case WorkdayType.companyClosure:
        return 'Chiusura Aziendale';
    }
  }
}

// ============================================================
// ANOMALIE
// ============================================================

/// Tipo di anomalia
enum AnomalyType {
  lateArrival('LATE_ARRIVAL'),
  earlyArrival('EARLY_ARRIVAL'),
  earlyDeparture('EARLY_DEPARTURE'),
  lateDeparture('LATE_DEPARTURE'),
  missingClockIn('MISSING_CLOCK_IN'),
  missingClockOut('MISSING_CLOCK_OUT'),
  absentUnjustified('ABSENT_UNJUSTIFIED'),
  doubleClockIn('DOUBLE_CLOCK_IN'),
  doubleClockOut('DOUBLE_CLOCK_OUT'),
  clockOutWithoutIn('CLOCK_OUT_WITHOUT_IN'),
  breakNotClosed('BREAK_NOT_CLOSED'),
  breakEndWithoutStart('BREAK_END_WITHOUT_START'),
  doubleBreakStart('DOUBLE_BREAK_START'),
  breakOutsideWindow('BREAK_OUTSIDE_WINDOW'),
  breakTooShort('BREAK_TOO_SHORT'),
  breakWithoutSession('BREAK_WITHOUT_SESSION'),
  missingSession('MISSING_SESSION'),
  noSchedule('NO_SCHEDULE'),
  clockSequenceError('CLOCK_SEQUENCE_ERROR'),
  workedDuringAbsence('WORKED_DURING_ABSENCE'),
  crossStructureNoClose('CROSS_STRUCTURE_NO_CLOSE'),
  excessiveOvertime('EXCESSIVE_OVERTIME');

  final String value;
  const AnomalyType(this.value);

  static AnomalyType? fromString(String? value) {
    if (value == null) return null;
    return AnomalyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnomalyType.missingSession,
    );
  }

  String get displayName {
    switch (this) {
      case AnomalyType.lateArrival:
        return 'Arrivo in ritardo';
      case AnomalyType.earlyArrival:
        return 'Arrivo in anticipo';
      case AnomalyType.earlyDeparture:
        return 'Uscita anticipata';
      case AnomalyType.lateDeparture:
        return 'Uscita posticipata';
      case AnomalyType.missingClockIn:
        return 'Entrata mancante';
      case AnomalyType.missingClockOut:
        return 'Uscita mancante';
      case AnomalyType.absentUnjustified:
        return 'Assenza non giustificata';
      case AnomalyType.doubleClockIn:
        return 'Doppia entrata';
      case AnomalyType.doubleClockOut:
        return 'Doppia uscita';
      case AnomalyType.clockOutWithoutIn:
        return 'Uscita senza entrata';
      case AnomalyType.breakNotClosed:
        return 'Pausa non chiusa';
      case AnomalyType.breakEndWithoutStart:
        return 'Fine pausa senza inizio';
      case AnomalyType.doubleBreakStart:
        return 'Doppio inizio pausa';
      case AnomalyType.breakOutsideWindow:
        return 'Pausa fuori finestra';
      case AnomalyType.breakTooShort:
        return 'Pausa troppo breve';
      case AnomalyType.breakWithoutSession:
        return 'Pausa senza sessione';
      case AnomalyType.missingSession:
        return 'Sessione mancante';
      case AnomalyType.noSchedule:
        return 'Nessun turno programmato';
      case AnomalyType.clockSequenceError:
        return 'Errore sequenza timbrature';
      case AnomalyType.workedDuringAbsence:
        return 'Timbrato durante assenza';
      case AnomalyType.crossStructureNoClose:
        return 'Struttura incrociata';
      case AnomalyType.excessiveOvertime:
        return 'Straordinario eccessivo';
    }
  }

  /// Restituisce le opzioni di risoluzione disponibili per questo tipo di anomalia
  List<AnomalyResolution> get availableResolutions {
    switch (this) {
      case AnomalyType.lateArrival:
        return [
          AnomalyResolution.normalized,
          AnomalyResolution.manualCorrection,
          AnomalyResolution.assignDelay,
          AnomalyResolution.dismissed,
        ];
      case AnomalyType.earlyArrival:
        return [
          AnomalyResolution.normalized,
          AnomalyResolution.manualCorrection,
          AnomalyResolution.assignOvertime,
          AnomalyResolution.dismissed,
        ];
      case AnomalyType.earlyDeparture:
        return [
          AnomalyResolution.normalized,
          AnomalyResolution.manualCorrection,
          AnomalyResolution.assignDelay,
          AnomalyResolution.dismissed,
        ];
      case AnomalyType.lateDeparture:
        return [
          AnomalyResolution.normalized,
          AnomalyResolution.manualCorrection,
          AnomalyResolution.assignOvertime,
          AnomalyResolution.dismissed,
        ];
      case AnomalyType.missingClockIn:
      case AnomalyType.missingClockOut:
      case AnomalyType.clockOutWithoutIn:
        return [
          AnomalyResolution.normalized,
          AnomalyResolution.manualCorrection,
          AnomalyResolution.dismissed,
        ];
      case AnomalyType.absentUnjustified:
        // Per questa anomalia va creata una richiesta di assenza, non si usa resolve-anomaly
        return [AnomalyResolution.dismissed];
      case AnomalyType.doubleClockIn:
      case AnomalyType.doubleClockOut:
      case AnomalyType.breakNotClosed:
      case AnomalyType.noSchedule:
        return [
          AnomalyResolution.accepted,
          AnomalyResolution.dismissed,
        ];
      default:
        return [
          AnomalyResolution.accepted,
          AnomalyResolution.dismissed,
        ];
    }
  }

  /// Indica se questo tipo di anomalia richiede un time picker per la correzione manuale
  bool get requiresTimePicker => [
    AnomalyType.lateArrival,
    AnomalyType.earlyArrival,
    AnomalyType.earlyDeparture,
    AnomalyType.lateDeparture,
    AnomalyType.missingClockIn,
    AnomalyType.missingClockOut,
    AnomalyType.clockOutWithoutIn,
  ].contains(this);

  /// Indica se questa anomalia deve essere risolta creando una richiesta assenza
  bool get requiresAbsenceRequest => this == AnomalyType.absentUnjustified;
}

/// Gravità dell'anomalia
enum AnomalySeverity {
  info('INFO'),
  warning('WARNING'),
  error('ERROR');

  final String value;
  const AnomalySeverity(this.value);

  static AnomalySeverity? fromString(String? value) {
    if (value == null) return null;
    return AnomalySeverity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnomalySeverity.info,
    );
  }

  String get displayName {
    switch (this) {
      case AnomalySeverity.info:
        return 'Info';
      case AnomalySeverity.warning:
        return 'Attenzione';
      case AnomalySeverity.error:
        return 'Errore';
    }
  }
}

// ============================================================
// CORREZIONI
// ============================================================

/// Stato della richiesta di correzione
enum CorrectionStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String value;
  const CorrectionStatus(this.value);

  static CorrectionStatus? fromString(String? value) {
    if (value == null) return null;
    return CorrectionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CorrectionStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case CorrectionStatus.pending:
        return 'In attesa';
      case CorrectionStatus.approved:
        return 'Approvata';
      case CorrectionStatus.rejected:
        return 'Rifiutata';
    }
  }
}

// ============================================================
// ASSENZE
// ============================================================

/// Stato della richiesta di assenza
enum AbsenceRequestStatus {
  draft('DRAFT'),
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  cancelled('CANCELLED');

  final String value;
  const AbsenceRequestStatus(this.value);

  static AbsenceRequestStatus? fromString(String? value) {
    if (value == null) return null;
    return AbsenceRequestStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AbsenceRequestStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case AbsenceRequestStatus.draft:
        return 'Bozza';
      case AbsenceRequestStatus.pending:
        return 'In attesa';
      case AbsenceRequestStatus.approved:
        return 'Approvata';
      case AbsenceRequestStatus.rejected:
        return 'Rifiutata';
      case AbsenceRequestStatus.cancelled:
        return 'Annullata';
    }
  }

  /// Colore associato allo stato per UI
  String get colorHex {
    switch (this) {
      case AbsenceRequestStatus.draft:
        return '#9CA3AF';
      case AbsenceRequestStatus.pending:
        return '#F59E0B';
      case AbsenceRequestStatus.approved:
        return '#22C55E';
      case AbsenceRequestStatus.rejected:
        return '#EF4444';
      case AbsenceRequestStatus.cancelled:
        return '#6B7280';
    }
  }
}

/// Copertura dell'assenza
enum AbsenceCoverage {
  fullDay('FULL_DAY'),
  partial('PARTIAL'),
  multiDayPartial('MULTI_DAY_PARTIAL');

  final String value;
  const AbsenceCoverage(this.value);

  static AbsenceCoverage? fromString(String? value) {
    if (value == null) return null;
    return AbsenceCoverage.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AbsenceCoverage.fullDay,
    );
  }

  String get displayName {
    switch (this) {
      case AbsenceCoverage.fullDay:
        return 'Giornata intera';
      case AbsenceCoverage.partial:
        return 'Parziale';
      case AbsenceCoverage.multiDayPartial:
        return 'Multi-giorno parziale';
    }
  }
}

// ============================================================
// SCHEDULES
// ============================================================

/// Tipo di slot pianificato
enum SlotType {
  work('WORK'),
  breakSlot('BREAK');

  final String value;
  const SlotType(this.value);

  static SlotType? fromString(String? value) {
    if (value == null) return null;
    return SlotType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SlotType.work,
    );
  }

  String get displayName {
    switch (this) {
      case SlotType.work:
        return 'Lavoro';
      case SlotType.breakSlot:
        return 'Pausa';
    }
  }
}

/// Politica di pausa
enum BreakPolicy {
  mandatoryFixed('MANDATORY_FIXED'),
  mandatoryWindowed('MANDATORY_WINDOWED'),
  optional('OPTIONAL');

  final String value;
  const BreakPolicy(this.value);

  static BreakPolicy? fromString(String? value) {
    if (value == null) return null;
    return BreakPolicy.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BreakPolicy.optional,
    );
  }

  String get displayName {
    switch (this) {
      case BreakPolicy.mandatoryFixed:
        return 'Obbligatoria fissa';
      case BreakPolicy.mandatoryWindowed:
        return 'Obbligatoria a finestra';
      case BreakPolicy.optional:
        return 'Opzionale';
    }
  }
}

/// Stato corrente del dipendente (per timbratura)
enum EmployeeCurrentState {
  notStarted('NOT_STARTED'),
  working('WORKING'),
  onBreak('ON_BREAK'),
  ended('ENDED');

  final String value;
  const EmployeeCurrentState(this.value);

  static EmployeeCurrentState? fromString(String? value) {
    if (value == null) return null;
    return EmployeeCurrentState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EmployeeCurrentState.notStarted,
    );
  }

  String get displayName {
    switch (this) {
      case EmployeeCurrentState.notStarted:
        return 'Non iniziato';
      case EmployeeCurrentState.working:
        return 'In servizio';
      case EmployeeCurrentState.onBreak:
        return 'In pausa';
      case EmployeeCurrentState.ended:
        return 'Terminato';
    }
  }
}

/// Stato riepilogo giornaliero (da daily-summary endpoint)
enum DailySummaryStatus {
  complete('COMPLETE'),
  incomplete('INCOMPLETE'),
  openBreak('OPEN_BREAK'),
  noEvents('NO_EVENTS');

  final String value;
  const DailySummaryStatus(this.value);

  static DailySummaryStatus? fromString(String? value) {
    if (value == null) return null;
    return DailySummaryStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DailySummaryStatus.noEvents,
    );
  }

  String get displayName {
    switch (this) {
      case DailySummaryStatus.complete:
        return 'Completa';
      case DailySummaryStatus.incomplete:
        return 'Incompleta';
      case DailySummaryStatus.openBreak:
        return 'Pausa aperta';
      case DailySummaryStatus.noEvents:
        return 'Nessun evento';
    }
  }

  String get colorHex {
    switch (this) {
      case DailySummaryStatus.complete:
        return '#10B981';
      case DailySummaryStatus.incomplete:
        return '#F59E0B';
      case DailySummaryStatus.openBreak:
        return '#F97316';
      case DailySummaryStatus.noEvents:
        return '#9CA3AF';
    }
  }
}

/// Risoluzione anomalia
enum AnomalyResolution {
  normalized('NORMALIZED'),
  manualCorrection('MANUAL_CORRECTION'),
  assignDelay('ASSIGN_DELAY'),
  assignOvertime('ASSIGN_OVERTIME'),
  dismissed('DISMISSED'),
  accepted('ACCEPTED'),
  /// Legacy - manteniamo per compatibilità con vecchie anomalie
  fixedViaOverride('FIXED_VIA_OVERRIDE');

  final String value;
  const AnomalyResolution(this.value);

  static AnomalyResolution? fromString(String? value) {
    if (value == null) return null;
    return AnomalyResolution.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnomalyResolution.dismissed,
    );
  }

  String get displayName {
    switch (this) {
      case AnomalyResolution.normalized:
        return 'Normalizzata';
      case AnomalyResolution.manualCorrection:
        return 'Correzione manuale';
      case AnomalyResolution.assignDelay:
        return 'Ritardo assegnato';
      case AnomalyResolution.assignOvertime:
        return 'Straordinario assegnato';
      case AnomalyResolution.dismissed:
        return 'Ignorata';
      case AnomalyResolution.accepted:
        return 'Accettata';
      case AnomalyResolution.fixedViaOverride:
        return 'Corretta con override';
    }
  }
}

// ============================================================
// EXPENSE REPORTS (RIMBORSI SPESE)
// ============================================================

/// Stato della nota spese
enum ExpenseReportStatus {
  draft('DRAFT'),
  submitted('SUBMITTED'),
  underReview('UNDER_REVIEW'),
  approved('APPROVED'),
  partiallyApproved('PARTIALLY_APPROVED'),
  rejected('REJECTED'),
  paid('PAID');

  final String value;
  const ExpenseReportStatus(this.value);

  static ExpenseReportStatus? fromString(String? value) {
    if (value == null) return null;
    return ExpenseReportStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseReportStatus.draft,
    );
  }

  String get displayName {
    switch (this) {
      case ExpenseReportStatus.draft:
        return 'Bozza';
      case ExpenseReportStatus.submitted:
        return 'Inviata';
      case ExpenseReportStatus.underReview:
        return 'In revisione';
      case ExpenseReportStatus.approved:
        return 'Approvata';
      case ExpenseReportStatus.partiallyApproved:
        return 'Parzialmente approvata';
      case ExpenseReportStatus.rejected:
        return 'Rifiutata';
      case ExpenseReportStatus.paid:
        return 'Pagata';
    }
  }

  String get colorHex {
    switch (this) {
      case ExpenseReportStatus.draft:
        return '#9CA3AF';
      case ExpenseReportStatus.submitted:
        return '#3B82F6';
      case ExpenseReportStatus.underReview:
        return '#F59E0B';
      case ExpenseReportStatus.approved:
        return '#10B981';
      case ExpenseReportStatus.partiallyApproved:
        return '#F97316';
      case ExpenseReportStatus.rejected:
        return '#EF4444';
      case ExpenseReportStatus.paid:
        return '#6366F1';
    }
  }
}

/// Tipo di nota spese
enum ExpenseReportType {
  trip('TRIP'),
  monthly('MONTHLY'),
  single('SINGLE');

  final String value;
  const ExpenseReportType(this.value);

  static ExpenseReportType? fromString(String? value) {
    if (value == null) return null;
    return ExpenseReportType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseReportType.single,
    );
  }

  String get displayName {
    switch (this) {
      case ExpenseReportType.trip:
        return 'Trasferta';
      case ExpenseReportType.monthly:
        return 'Mensile';
      case ExpenseReportType.single:
        return 'Singola';
    }
  }
}

/// Categoria spesa
enum ExpenseCategory {
  food('VITTO'),
  accommodation('ALLOGGIO'),
  transport('TRASPORTO'),
  fuel('CARBURANTE'),
  taxi('TAXI'),
  parking('PARCHEGGIO'),
  phone('TELEFONO'),
  entertainment('RAPPRESENTANZA'),
  material('MATERIALE'),
  training('FORMAZIONE'),
  mileage('CHILOMETRICO'),
  other('ALTRO');

  final String value;
  const ExpenseCategory(this.value);

  static ExpenseCategory? fromString(String? value) {
    if (value == null) return null;
    return ExpenseCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseCategory.other,
    );
  }

  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Vitto';
      case ExpenseCategory.accommodation:
        return 'Alloggio';
      case ExpenseCategory.transport:
        return 'Trasporto';
      case ExpenseCategory.fuel:
        return 'Carburante';
      case ExpenseCategory.taxi:
        return 'Taxi';
      case ExpenseCategory.parking:
        return 'Parcheggio';
      case ExpenseCategory.phone:
        return 'Telefono';
      case ExpenseCategory.entertainment:
        return 'Rappresentanza';
      case ExpenseCategory.material:
        return 'Materiale';
      case ExpenseCategory.training:
        return 'Formazione';
      case ExpenseCategory.mileage:
        return 'Chilometrico';
      case ExpenseCategory.other:
        return 'Altro';
    }
  }

  String get iconName {
    switch (this) {
      case ExpenseCategory.food:
        return 'restaurant';
      case ExpenseCategory.accommodation:
        return 'hotel';
      case ExpenseCategory.transport:
        return 'directions_bus';
      case ExpenseCategory.fuel:
        return 'local_gas_station';
      case ExpenseCategory.taxi:
        return 'local_taxi';
      case ExpenseCategory.parking:
        return 'local_parking';
      case ExpenseCategory.phone:
        return 'phone';
      case ExpenseCategory.entertainment:
        return 'people';
      case ExpenseCategory.material:
        return 'inventory_2';
      case ExpenseCategory.training:
        return 'school';
      case ExpenseCategory.mileage:
        return 'directions_car';
      case ExpenseCategory.other:
        return 'category';
    }
  }
}

/// Stato singola voce di spesa
enum ExpenseItemStatus {
  draft('DRAFT'),
  submitted('SUBMITTED'),
  flagged('FLAGGED'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String value;
  const ExpenseItemStatus(this.value);

  static ExpenseItemStatus? fromString(String? value) {
    if (value == null) return null;
    return ExpenseItemStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpenseItemStatus.draft,
    );
  }

  String get displayName {
    switch (this) {
      case ExpenseItemStatus.draft:
        return 'Bozza';
      case ExpenseItemStatus.submitted:
        return 'Inviata';
      case ExpenseItemStatus.flagged:
        return 'Segnalata';
      case ExpenseItemStatus.approved:
        return 'Approvata';
      case ExpenseItemStatus.rejected:
        return 'Rifiutata';
    }
  }
}

/// Tipo veicolo per rimborso chilometrico
enum MileageVehicleType {
  autoBenzina('AUTO_BENZINA'),
  autoDiesel('AUTO_DIESEL'),
  autoGpl('AUTO_GPL'),
  autoElettrica('AUTO_ELETTRICA'),
  autoIbrida('AUTO_IBRIDA'),
  motoSmall('MOTO_SMALL'),
  motoLarge('MOTO_LARGE');

  final String value;
  const MileageVehicleType(this.value);

  static MileageVehicleType? fromString(String? value) {
    if (value == null) return null;
    return MileageVehicleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MileageVehicleType.autoBenzina,
    );
  }

  String get displayName {
    switch (this) {
      case MileageVehicleType.autoBenzina:
        return 'Auto Benzina';
      case MileageVehicleType.autoDiesel:
        return 'Auto Diesel';
      case MileageVehicleType.autoGpl:
        return 'Auto GPL';
      case MileageVehicleType.autoElettrica:
        return 'Auto Elettrica';
      case MileageVehicleType.autoIbrida:
        return 'Auto Ibrida';
      case MileageVehicleType.motoSmall:
        return 'Moto < 250cc';
      case MileageVehicleType.motoLarge:
        return 'Moto > 250cc';
    }
  }
}

/// Stato carta aziendale
enum CorporateCardStatus {
  active('ACTIVE'),
  blocked('BLOCKED'),
  expired('EXPIRED');

  final String value;
  const CorporateCardStatus(this.value);

  static CorporateCardStatus? fromString(String? value) {
    if (value == null) return null;
    return CorporateCardStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CorporateCardStatus.active,
    );
  }

  String get displayName {
    switch (this) {
      case CorporateCardStatus.active:
        return 'Attiva';
      case CorporateCardStatus.blocked:
        return 'Bloccata';
      case CorporateCardStatus.expired:
        return 'Scaduta';
    }
  }

  String get colorHex {
    switch (this) {
      case CorporateCardStatus.active:
        return '#10B981';
      case CorporateCardStatus.blocked:
        return '#EF4444';
      case CorporateCardStatus.expired:
        return '#9CA3AF';
    }
  }
}

/// Stato riconciliazione transazione carta
enum CardReconciliationStatus {
  unmatched('UNMATCHED'),
  matched('MATCHED'),
  disputed('DISPUTED'),
  personal('PERSONAL');

  final String value;
  const CardReconciliationStatus(this.value);

  static CardReconciliationStatus? fromString(String? value) {
    if (value == null) return null;
    return CardReconciliationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CardReconciliationStatus.unmatched,
    );
  }

  String get displayName {
    switch (this) {
      case CardReconciliationStatus.unmatched:
        return 'Non riconciliata';
      case CardReconciliationStatus.matched:
        return 'Riconciliata';
      case CardReconciliationStatus.disputed:
        return 'Contestata';
      case CardReconciliationStatus.personal:
        return 'Personale';
    }
  }
}

/// Metodo di pagamento rimborso
enum ExpensePaymentMethod {
  bankTransfer('BANK_TRANSFER'),
  payroll('PAYROLL'),
  pettyCash('PETTY_CASH');

  final String value;
  const ExpensePaymentMethod(this.value);

  static ExpensePaymentMethod? fromString(String? value) {
    if (value == null) return null;
    return ExpensePaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExpensePaymentMethod.bankTransfer,
    );
  }

  String get displayName {
    switch (this) {
      case ExpensePaymentMethod.bankTransfer:
        return 'Bonifico bancario';
      case ExpensePaymentMethod.payroll:
        return 'Busta paga';
      case ExpensePaymentMethod.pettyCash:
        return 'Cassa contanti';
    }
  }
}
