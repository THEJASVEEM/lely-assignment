import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';
import 'package:lely_assignment/feature/activity/data/repositories/mock_robot_activity_repository.dart';
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart';

import '../data/fake_robot_activity_local_datasource.dart';

void main() {
  group('ActivityCubit', () {
    late FakeRobotActivityLocalDataSource localDataSource;
    late MockRobotActivityRepository repository;
    late ActivityCubit cubit;

    setUp(() {
      localDataSource = FakeRobotActivityLocalDataSource([
        const RobotActivityDto(date: '10/10/2025', duration: '120 min'),
        const RobotActivityDto(date: '08/10/2025', duration: '60 min'),
        const RobotActivityDto(date: '09/10/2025', duration: '90 min'),
      ]);

      repository = MockRobotActivityRepository(localDataSource);
      cubit = ActivityCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is ActivityInitial', () {
      expect(cubit.state, isA<ActivityInitial>());
    });

    test('loads and sorts activities', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ActivityLoading>(),
          isA<ActivityLoaded>()
              .having((state) => state.activities.length, 'activity count', 3)
              .having(
                (state) => state.activities.first.date,
                'first activity date',
                DateTime(2025, 10, 8),
              ),
        ]),
      );

      await cubit.loadActivities();
      await expectation;
    });

    test(
      'adds a unique activity and emits submitting then updated loaded state',
      () async {
        await cubit.loadActivities();

        expect(cubit.state, isA<ActivityLoaded>());

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<ActivityLoaded>()
                .having((state) => state.isSubmitting, 'isSubmitting', isTrue)
                .having(
                  (state) => state.activities.length,
                  'existing activity count',
                  3,
                ),
            isA<ActivityLoaded>()
                .having((state) => state.isSubmitting, 'isSubmitting', isFalse)
                .having(
                  (state) => state.addActivityError,
                  'addActivityError',
                  isNull,
                )
                .having(
                  (state) => state.activities.length,
                  'updated activity count',
                  4,
                )
                .having(
                  (state) => state.activities.last.date,
                  'added activity date',
                  DateTime(2025, 10, 11),
                )
                .having(
                  (state) => state.activities.last.durationMinutes,
                  'added duration',
                  180,
                ),
          ]),
        );

        await cubit.addActivity(
          date: DateTime(2025, 10, 11),
          durationMinutes: 180,
        );

        await expectation;

        final state = cubit.state as ActivityLoaded;

        expect(state.activities, hasLength(4));
        expect(state.isSubmitting, isFalse);
        expect(state.addActivityError, isNull);
      },
    );

    test('shows duplicate-date error without replacing loaded data', () async {
      await cubit.loadActivities();

      final previousState = cubit.state as ActivityLoaded;

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ActivityLoaded>().having(
            (state) => state.isSubmitting,
            'isSubmitting',
            isTrue,
          ),
          isA<ActivityLoaded>()
              .having((state) => state.isSubmitting, 'isSubmitting', isFalse)
              .having(
                (state) => state.addActivityError,
                'addActivityError',
                'Activity already exists for the selected date.',
              )
              .having(
                (state) => state.activities.length,
                'activity count',
                previousState.activities.length,
              ),
        ]),
      );

      await cubit.addActivity(
        date: DateTime(2025, 10, 8),
        durationMinutes: 180,
      );

      await expectation;

      final state = cubit.state as ActivityLoaded;

      expect(state.isSubmitting, isFalse);
      expect(
        state.addActivityError,
        'Activity already exists for the selected date.',
      );
      expect(state.activities.length, previousState.activities.length);
    });
  });
}
