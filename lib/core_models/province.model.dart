

import 'city.model.dart';
import 'country.model.dart';
import 'package:genai_components/utils/models/custom_model.model.dart';
import 'state.model.dart';

class Province extends BaseModel {
  @override
  String get modelIdentifier => name;

  String id;
  String slug;
  String name;
  String code;
  String? stateId;
  State? state;
  List<City> cities;

  Province._internal({
    required this.id,
    required this.slug,
    required this.name,
    required this.code,
    required this.stateId,
    required this.state,
    required this.cities,
  });

  factory Province({
    String id = "",
    String slug = "",
    String name = "",
    String code = "",
    String stateId = "",
    required State state,
    List<City> cities = const [],
  }) {
    return Province._internal(
      id: id,
      slug: slug,
      name: name,
      code: code,
      stateId: stateId,
      state: state,
      cities: cities,
    );
  }

  factory Province.fromJson({
    required dynamic jsonObject,
  }) {
    return Province(
      id: jsonObject["id"]?.toString() ?? "",
      slug: jsonObject["slug"] ?? "",
      name: jsonObject["name"] ?? "",
      code: jsonObject["code"] ?? "",
      stateId: jsonObject["stateId"],
      state: jsonObject["state"] != null ? State.fromJson(jsonObject: jsonObject["state"]) : State(country: Country()),
      cities: (jsonObject["City"] as List<dynamic>?)?.map((city) => City.fromJson(jsonObject: city)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'code': code,
      'stateId': stateId,
      'state': state?.toMap(),
      'City': cities.map((city) => city.toMap()).toList(),
    };
  }
}
