import 'package:genai_components/utils/models/custom_model.model.dart';

class NotificationItem extends BaseModel{
  @override
  String get modelIdentifier => title!;

  String? title;
  String? body;
  bool isRead;
  DateTime? date;
  NotificationItem({this.title,this.body,this.isRead=false,this.date});

  factory NotificationItem.fromJson({
    required dynamic jsonObject,
  }) {
    final notificationItem = NotificationItem();
    notificationItem.title = jsonObject["title"];
    notificationItem.body = jsonObject["title"];
    notificationItem.isRead = jsonObject["isRead"];
    notificationItem.date = DateTime.tryParse(jsonObject["createdAt"])?.toLocal()??DateTime.now();

    return notificationItem;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> useMap = <String, dynamic>{
      'title': title,
      'body': body,
      'isRead': isRead,
      'date': date.toString(),
    };
    return useMap;
  }
}
