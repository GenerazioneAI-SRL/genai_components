class Pagination {
  int? total;
  int? lastPage;
  int? currentPage;
  int? perPage;
  int? prev;
  int? next;

  Pagination();

  factory Pagination.fromJson({required dynamic jsonObject}) {
    final pagination = Pagination();
    pagination.total = jsonObject['total'];
    pagination.lastPage = jsonObject['lastPage'];
    pagination.currentPage = jsonObject['currentPage'];
    pagination.perPage = jsonObject['perPage'];
    pagination.prev = jsonObject['prev'];
    pagination.next = jsonObject['next'];
    return pagination;
  }
}

