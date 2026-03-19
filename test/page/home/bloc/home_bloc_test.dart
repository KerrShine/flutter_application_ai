import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_application_ai/page/home/bloc/home_bloc.dart';

void main() {
  group('HomeBloc', () {
    late HomeBloc homeBloc;

    setUp(() {
      homeBloc = HomeBloc();
    });

    tearDown(() {
      homeBloc.close();
    });

    test('initial state is HomeStatus.initial with tabIndex 0', () {
      expect(homeBloc.state, const HomeState());
    });

    blocTest<HomeBloc, HomeState>(
      'emits [HomeState(tabIndex: 1)] when HomeTabChanged(1) is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeTabChanged(1)),
      expect: () => const [
        HomeState(tabIndex: 1),
      ],
    );
  });
}
