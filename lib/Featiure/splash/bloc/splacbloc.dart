import 'dart:async';

class NavigationBloc {
  final _navigationController = StreamController<bool>();

  Stream<bool> get navigateStream => _navigationController.stream;

  void navigateToOnboarding() {
    _navigationController.add(true);
  }

  void dispose() {
    _navigationController.close();
  }
}

final navigationBloc = NavigationBloc();
