part of 'cl_announcement_widget.dart';

class _CLAnnouncementState<T extends Object> extends ChangeNotifier {
  int currentPage = 1;
  int lastPage = 1;
  bool hasPreviousPage = false;
  bool hasNextPage = false;
  Map<String, String> _searchParams = {};
  _AnnouncementState _announcementState = _AnnouncementState.ready;
  final Future<dynamic> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy}) fetchAnnouncement;
  final CLAnnouncement Function(T) onAnnouncementBuild;
  List<CLAnnouncement> announcementList = [];

  _CLAnnouncementState({required this.fetchAnnouncement, required this.onAnnouncementBuild}) {
    _dispatchCallback(page: 1);
  }

  _dispatchCallback({required int page}) async {
    _announcementState = _AnnouncementState.loading;
    announcementList.clear();
    currentPage = page;

    notifyListeners();
    var (elements, paginationCallback) = await fetchAnnouncement(page: page, perPage: 5, searchBy: _searchParams);
    Pagination pagination = paginationCallback;
    currentPage = pagination.currentPage ?? currentPage;
    lastPage = pagination.lastPage ?? currentPage;
    hasNextPage = pagination.next != null && pagination.next != currentPage;
    hasPreviousPage = pagination.prev != null && pagination.prev != currentPage;
    elements.forEach((element) {
      announcementList.add(onAnnouncementBuild(element));
    });
    _announcementState = _AnnouncementState.ready;
    notifyListeners();
  }

  Future<void> nextPage({bool isInfiniteScroll = false}) => _dispatchCallback(page: currentPage + 1);

  Future<void> previousPage() => _dispatchCallback(page: currentPage - 1);

  Future<void> goToPage(int page) => _dispatchCallback(page: page);

  void onSearch(Map<String, String> searchParams) {
    currentPage = 1;
    lastPage = 1;
    _searchParams = searchParams;
    _dispatchCallback(page: currentPage);
  }

  Future markAsRead(int index, Future Function(String)? onAnnouncementRead) async {
    announcementList[index].readedAt = DateTime.now();
    await onAnnouncementRead!(announcementList[index].id);
    notifyListeners(); // Notifica il cambiamento di stato
  }
}

enum _AnnouncementState { loading, ready }
