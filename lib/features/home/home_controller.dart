import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(),
);

class HomeState {
  final bool isLoading;
  final String? error;

  const HomeState({this.isLoading = false, this.error});

  HomeState copyWith({bool? isLoading, String? error}) =>
      HomeState(isLoading: isLoading ?? this.isLoading, error: error);
}

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState());

  void setLoading(bool val) => state = state.copyWith(isLoading: val);
  void setError(String? msg) => state = state.copyWith(error: msg);
}
