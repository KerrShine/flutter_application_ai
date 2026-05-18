part of 'application_sign_off_pending_bloc.dart';

enum SignOffPendingStatus {
  init,
  loading,
  success,
  failure,
}

class ApplicationSignOffPendingState extends Equatable {
  final SignOffPendingStatus status;
  final String message;
  final String employeeId;
  final List<SignOffInstance> pendingItems;
  final String searchQuery;
  final SignOffPendingSortOrder sortOrder;
  final String formNameFilter;

  const ApplicationSignOffPendingState({
    this.status = SignOffPendingStatus.init,
    this.message = '',
    this.employeeId = '',
    this.pendingItems = const [],
    this.searchQuery = '',
    this.sortOrder = SignOffPendingSortOrder.submittedAtDesc,
    this.formNameFilter = '',
  });

  ApplicationSignOffPendingState copyWith({
    SignOffPendingStatus? status,
    String? message,
    String? employeeId,
    List<SignOffInstance>? pendingItems,
    String? searchQuery,
    SignOffPendingSortOrder? sortOrder,
    String? formNameFilter,
  }) {
    return ApplicationSignOffPendingState(
      status: status ?? this.status,
      message: message ?? this.message,
      employeeId: employeeId ?? this.employeeId,
      pendingItems: pendingItems ?? this.pendingItems,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      formNameFilter: formNameFilter ?? this.formNameFilter,
    );
  }

  List<String> get availableFormNames {
    final names = <String>{};
    for (final item in pendingItems) {
      if (item.formName.isNotEmpty) {
        names.add(item.formName);
      }
    }
    final list = names.toList()..sort();
    return list;
  }

  List<SignOffInstance> get filteredItems {
    final query = searchQuery.trim().toLowerCase();
    final filter = formNameFilter.trim();

    final filtered = pendingItems.where((item) {
      if (filter.isNotEmpty && item.formName != filter) {
        return false;
      }
      if (query.isEmpty) return true;
      return item.applicantName.toLowerCase().contains(query) ||
          item.applicantId.toLowerCase().contains(query) ||
          item.formName.toLowerCase().contains(query);
    }).toList();

    int compare(SignOffInstance a, SignOffInstance b) {
      switch (sortOrder) {
        case SignOffPendingSortOrder.submittedAtDesc:
          return b.submittedAt.compareTo(a.submittedAt);
        case SignOffPendingSortOrder.submittedAtAsc:
          return a.submittedAt.compareTo(b.submittedAt);
        case SignOffPendingSortOrder.updatedAtDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case SignOffPendingSortOrder.updatedAtAsc:
          return a.updatedAt.compareTo(b.updatedAt);
      }
    }

    filtered.sort(compare);
    return filtered;
  }

  @override
  List<Object> get props => [
        status,
        message,
        employeeId,
        pendingItems,
        searchQuery,
        sortOrder,
        formNameFilter,
      ];
}
