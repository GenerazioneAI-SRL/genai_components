import 'country.model.dart';
import 'package:genai_components/utils/models/custom_model.model.dart';
import 'province.model.dart';
import 'state.model.dart';

class City extends BaseModel {
  @override
  String get modelIdentifier => name;

  String id;
  String name;
  List<String> zips;
  String code;
  String cadastralCode;
  String provinceId;
  Province province;

  City._internal({
    required this.id,
    required this.name,
    required this.zips,
    required this.code,
    required this.cadastralCode,
    required this.provinceId,
    required this.province,
  });

  factory City({
    String id = "",
    String name = "",
    List<String> zips = const [],
    String code = "",
    String cadastralCode = "",
    String provinceId = "",
    required Province province,
  }) {
    return City._internal(
      id: id,
      name: name,
      zips: zips,
      code: code,
      cadastralCode: cadastralCode,
      provinceId: provinceId,
      province: province,
    );
  }

  factory City.fromJson({
    required dynamic jsonObject,
  }) {
    return City(
      id: jsonObject["id"]?.toString() ?? "",
      name: jsonObject["name"] ?? "",
      zips: (jsonObject["zip"] as List<dynamic>?)?.map((zip) => zip.toString()).toList() ?? [],
      code: jsonObject["code"] ?? "",
      cadastralCode: jsonObject["cadastralCode"] ?? "",
      provinceId: jsonObject["provinceId"],
      province: jsonObject["province"] != null ? Province.fromJson(jsonObject: jsonObject["province"]) : Province(state: State(country: Country())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'zip': zips,
      'code': code,
      'cadastralCode': cadastralCode,
      'provinceId': provinceId,
      'province': province.toMap(),
    };
  }
}
