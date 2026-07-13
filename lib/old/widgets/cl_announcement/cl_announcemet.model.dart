import 'package:intl/intl.dart';

class CLAnnouncement {
  String id;
  String title;
  String subtitle;
  DateTime? readedAt;
  DateTime createdAt;
  List<String> mediaUrls;
  CLAnnouncementPriority announcementPriority;

  String get formattedReadedAt => readedAt != null ? DateFormat('dd-MM-yyyy HH:mm').format(readedAt!) : "";

  String get formattedCreatedAt => DateFormat('dd-MM-yyyy HH:mm').format(createdAt);

  CLAnnouncement(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.createdAt,
      this.readedAt,
      this.announcementPriority = CLAnnouncementPriority.normal,
      this.mediaUrls = const []});
}

enum CLAnnouncementPriority { normal, warning ,urgent }
