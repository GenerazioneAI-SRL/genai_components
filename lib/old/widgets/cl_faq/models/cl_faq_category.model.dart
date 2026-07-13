import 'cl_faq.model.dart';

class CLFaqCategory {
  String title;
  String description;

  List<CLFaq> faqs = [];

  CLFaqCategory({required this.title, required this.description, this.faqs = const []});
}