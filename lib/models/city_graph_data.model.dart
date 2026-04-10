import '../utils/models/custom_model.model.dart';

class CityGraphData extends BaseModel {
  @override
  String get modelIdentifier => key;

  String key;
  int value;

  CityGraphData({
    required this.key,
    required this.value,
  });

  factory CityGraphData.fromJson({
    required dynamic jsonObject,
  }) {
    return CityGraphData(
      key: jsonObject["cityName"]?.toString() ?? "",
      value: int.tryParse(jsonObject["count"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': key,
      'count': value,
    };
  }
}

