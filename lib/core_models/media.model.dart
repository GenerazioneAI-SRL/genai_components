import 'package:genai_components/utils/models/custom_model.model.dart';

import 'package:genai_components/enums/resource_type.enum.dart';

class Media extends BaseModel {
  @override
  String get modelIdentifier => id;
  final String id;
  final String name;
  final String fileUrl;
  final String resourceType;

  ResourceType get resourceTypeEnum {
    switch (resourceType) {
      case "DETAIL":
        return ResourceType.detail;
      case "CASE_SHEET":
        return ResourceType.caseSheet;
      default:
        return ResourceType.detail;
    }
  }

  Media._internal({required this.id, required this.name, required this.fileUrl, required this.resourceType});

  factory Media({String id = "", String name = "", String fileUrl = "", String resourceType = ""}) {
    return Media._internal(id: id, name: name, fileUrl: fileUrl, resourceType: resourceType);
  }

  factory Media.fromJson({required dynamic jsonObject}) {
    return Media(
      id: jsonObject["id"]?.toString() ?? "",
      name: jsonObject["name"] ?? "",
      fileUrl: jsonObject["fileUrl"] ?? "",
      resourceType: jsonObject["resourceType"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'fileUrl': fileUrl, 'resourceType': resourceType};
  }
}
