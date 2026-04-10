import '../utils/models/custom_model.model.dart';

class UserGraphData extends BaseModel {
  @override
  String get modelIdentifier => key;

  String key;
  int value;
  int total;

  UserGraphData({required this.key, required this.value, required this.total});

  factory UserGraphData.fromJson({
    required dynamic jsonObject,
  }) {
    return UserGraphData(
      key: jsonObject["monthName"]?.toString() ?? "",
      value: int.tryParse(jsonObject["countPerMonth"].toString()) ?? 0,
      total: int.tryParse(jsonObject["totalCount"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'monthName': key, 'countPerMonth': value, 'totalCount': total};
  }
}

