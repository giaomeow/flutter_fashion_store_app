import 'package:flutter_riverpod/legacy.dart';

/// Provider để quản lý search query và navigation
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  /// Set search query và trigger navigation to Store tab
  void navigateToStoreWithSearch(String searchQuery) {
    state = NavigationState(
      shouldNavigateToStore: true,
      searchQuery: searchQuery,
    );
  }

  /// Reset navigation state sau khi đã navigate
  void resetNavigation() {
    state = NavigationState();
  }
}

class NavigationState {
  final bool shouldNavigateToStore;
  final String? searchQuery;

  NavigationState({this.shouldNavigateToStore = false, this.searchQuery});
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
