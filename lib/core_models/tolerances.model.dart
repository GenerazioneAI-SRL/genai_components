import 'package:cl_components/utils/models/custom_model.model.dart';

/// Tolleranze per il calcolo delle anomalie nei turni.
/// Usato da WorkSchedule e configurazione profili orari.
class Tolerances extends BaseModel {
  @override
  String get modelIdentifier => '$earlyIn-$lateIn-$earlyOut-$lateOut';

  int earlyIn; // minuti tolleranza entrata anticipata (default 15)
  int lateIn; // minuti tolleranza entrata ritardata (default 10)
  int earlyOut; // minuti tolleranza uscita anticipata (default 5)
  int lateOut; // minuti tolleranza uscita ritardata (default 30)

  Tolerances({
    this.earlyIn = 15,
    this.lateIn = 10,
    this.earlyOut = 5,
    this.lateOut = 30,
  });

  factory Tolerances.fromJson({required dynamic jsonObject}) {
    return Tolerances(
      earlyIn: jsonObject['earlyIn'] ?? 15,
      lateIn: jsonObject['lateIn'] ?? 10,
      earlyOut: jsonObject['earlyOut'] ?? 5,
      lateOut: jsonObject['lateOut'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'earlyIn': earlyIn,
      'lateIn': lateIn,
      'earlyOut': earlyOut,
      'lateOut': lateOut,
    };
  }
}
