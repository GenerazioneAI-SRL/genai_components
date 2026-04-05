
import 'package:cl_components/utils/models/custom_model.model.dart';
import 'state.model.dart';

class Country extends BaseModel {
  @override
  String get modelIdentifier => name;

  String id;
  String name;
  String slug;
  List<State> states;

  Country._internal({
    required this.id,
    required this.name,
    required this.slug,
    required this.states,
  });

  factory Country({
    String id = "",
    String name = "",
    String slug = "",
    List<State> states = const [],
  }) {
    return Country._internal(
      id: id,
      name: name,
      slug: slug,
      states: states,
    );
  }

  factory Country.fromJson({
    required dynamic jsonObject,
  }) {
    return Country(
      id: jsonObject["id"]?.toString() ?? "",
      name: jsonObject["name"] ?? "",
      slug: jsonObject["slug"] ?? "",
      states: (jsonObject["State"] as List<dynamic>?)?.map((state) => State.fromJson(jsonObject: state)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'State': states.map((state) => state.toMap()).toList(),
    };
  }
}
