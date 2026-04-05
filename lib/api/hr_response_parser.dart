import 'package:cl_components/api/api_manager.dart';
import 'package:cl_components/utils/models/pagination.model.dart';

/// Utility per parsare le risposte paginatie delle API HR.
///
/// Le API HR restituiscono:
///   { items: [...], total, page, limit, totalPages }
/// invece del formato standard:
///   { data: [...], meta: { total, lastPage, currentPage, perPage } }
///
/// Questa classe estrae correttamente items e pagination.
class HrResponseParser {
  /// Estrae la lista di oggetti JSON dalla risposta HR.
  static List<dynamic> extractItems(ApiCallResponse response) {
    final body = response.jsonBody;
    if (body is List) return body;
    if (body is Map) {
      return (body['items'] as List?) ?? (body['data'] as List?) ?? [];
    }
    return [];
  }

  /// Costruisce la Pagination dalla risposta HR.
  /// Se `response.pagination` è già popolato (formato standard), lo usa.
  /// Altrimenti lo costruisce dal body `{total, page, limit, totalPages}`.
  static Pagination? extractPagination(ApiCallResponse response) {
    if (response.pagination != null) return response.pagination;
    final body = response.jsonBody;
    if (body is Map && body['total'] != null) {
      final p = Pagination();
      p.total = body['total'] as int?;
      p.currentPage = body['page'] as int?;
      p.perPage = body['limit'] as int?;
      p.lastPage = body['totalPages'] as int?;
      if (p.currentPage != null && p.currentPage! > 1) {
        p.prev = p.currentPage! - 1;
      }
      if (p.currentPage != null &&
          p.lastPage != null &&
          p.currentPage! < p.lastPage!) {
        p.next = p.currentPage! + 1;
      }
      return p;
    }
    return null;
  }
}
