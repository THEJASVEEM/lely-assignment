import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lely_assignment/feature/activity/data/models/robot_activity_dto.dart';
import 'package:lely_assignment/feature/activity/data/repositories/mock_robot_activity_repository.dart';
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart';
import 'package:lely_assignment/feature/activity/presentation/widgets/add_activity_bottomsheet.dart';

import '../data/fake_robot_activity_local_datasource.dart';

void main() {
  late FakeRobotActivityLocalDataSource localDataSource;
  late MockRobotActivityRepository repository;
  late ActivityCubit cubit;

  const dateFieldKey = Key('add_activity_date_field');
  const minutesFieldKey = Key('add_activity_duration_field');
  const saveButtonKey = Key('add_activity_submit_button');

  setUp(() async {
    localDataSource = FakeRobotActivityLocalDataSource(const [
      RobotActivityDto(date: '08/10/2025', duration: '60 min'),
      RobotActivityDto(date: '09/10/2025', duration: '90 min'),
      RobotActivityDto(date: '10/10/2025', duration: '120 min'),
    ]);

    repository = MockRobotActivityRepository(localDataSource);
    cubit = ActivityCubit(repository);

    await cubit.loadActivities();
  });

  tearDown(() async {
    await cubit.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<ActivityCubit>.value(
          value: cubit,
          child: const AddActivityBottomSheet(),
        ),
      ),
    );
  }

  Future<void> selectDate(WidgetTester tester, {required int day}) async {
    await tester.tap(find.byKey(dateFieldKey));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    final dayFinder = find.text('$day');

    expect(dayFinder, findsWidgets);

    await tester.tap(dayFinder.last);
    await tester.tap(find.text('OK'));

    await tester.pumpAndSettle();
  }

  group('AddActivityBottomSheet', () {
    testWidgets('renders all form controls', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Add activity'), findsOneWidget);

      expect(find.byKey(dateFieldKey), findsOneWidget);
      expect(find.byKey(minutesFieldKey), findsOneWidget);
      expect(find.byKey(saveButtonKey), findsOneWidget);

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows required errors when submitting empty form', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byKey(saveButtonKey));
      await tester.pump();

      expect(find.text('Date is required.'), findsOneWidget);
      expect(find.text('Minutes active is required.'), findsOneWidget);

      final state = cubit.state as ActivityLoaded;
      expect(state.activities, hasLength(3));
    });

    testWidgets('rejects zero minutes', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byKey(minutesFieldKey), '0');

      await tester.tap(find.byKey(saveButtonKey));
      await tester.pump();

      expect(find.text('Minutes must be greater than zero.'), findsOneWidget);
    });

    testWidgets('rejects minutes above 1440', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byKey(minutesFieldKey), '1441');

      await tester.tap(find.byKey(saveButtonKey));
      await tester.pump();

      expect(find.text('Minutes cannot exceed 1440 per day.'), findsOneWidget);
    });

    testWidgets('accepts the maximum duration of 1440 minutes', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byKey(minutesFieldKey), '1440');

      await tester.tap(find.byKey(saveButtonKey));
      await tester.pump();

      expect(find.text('Minutes cannot exceed 1440 per day.'), findsNothing);
      expect(find.text('Minutes must be greater than zero.'), findsNothing);
    });

    testWidgets('minutes field accepts only four digits', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(find.byKey(minutesFieldKey), '12345');

      final field = tester.widget<TextFormField>(find.byKey(minutesFieldKey));

      expect(field.controller?.text, '1234');
    });

    testWidgets('shows duplicate-date error', (tester) async {
      await tester.pumpWidget(buildSubject());

      await selectDate(tester, day: 8);

      await tester.enterText(find.byKey(minutesFieldKey), '300');

      await tester.tap(find.byKey(saveButtonKey));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Activity already exists for the selected date.'),
        findsOneWidget,
      );

      final state = cubit.state as ActivityLoaded;

      expect(state.activities, hasLength(3));
      expect(state.isSubmitting, isFalse);
    });

    testWidgets('adds a unique activity and closes the sheet', (tester) async {
      await tester.pumpWidget(buildSubject());

      await selectDate(tester, day: 11);

      await tester.enterText(find.byKey(minutesFieldKey), '180');

      await tester.tap(find.byKey(saveButtonKey));

      await tester.pump();
      await tester.pumpAndSettle();

      final state = cubit.state as ActivityLoaded;

      expect(state.activities, hasLength(4));
      expect(state.addActivityError, isNull);
      expect(state.isSubmitting, isFalse);

      final addedActivity = state.activities.firstWhere(
        (activity) =>
            activity.date.day == 11 && activity.durationMinutes == 180,
      );

      expect(addedActivity.durationMinutes, 180);

      expect(find.byType(AddActivityBottomSheet), findsNothing);
    });
  });
}
