import 'country.model.dart';
import 'package:genai_components/utils/models/custom_model.model.dart';
import 'province.model.dart';

class State extends BaseModel {
  @override
  String get modelIdentifier => name;

  String id;
  String code;
  String name;
  String? countryId;
  Country? country;
  List<Province> provinces;

  State._internal({
    required this.id,
    required this.code,
    required this.name,
    this.countryId,
    this.country,
    required this.provinces,
  });

  factory State({
    String id = "",
    String code = "",
    String name = "",
    String countryId = "",
    required Country country,
    List<Province> provinces = const [],
  }) {
    return State._internal(
      id: id,
      code: code,
      name: name,
      countryId: countryId,
      country: country,
      provinces: provinces,
    );
  }

  factory State.fromJson({
    required dynamic jsonObject,
  }) {
    return State(
      id: jsonObject["id"]?.toString() ?? "",
      code: jsonObject["code"] ?? "",
      name: jsonObject["name"] ?? "",
      countryId: jsonObject["countryId"],
      country: jsonObject["country"] != null ? Country.fromJson(jsonObject: jsonObject["country"]) : Country(),
      provinces: (jsonObject["Province"] as List<dynamic>?)?.map((province) => Province.fromJson(jsonObject: province)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'countryId': countryId,
      'country': country?.toMap(),
      'Province': provinces.map((province) => province.toMap()).toList(),
    };
  }
}
