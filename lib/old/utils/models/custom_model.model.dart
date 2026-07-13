abstract class BaseModel {
  String get modelIdentifier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BaseModel && runtimeType == other.runtimeType && modelIdentifier == other.modelIdentifier;
}
