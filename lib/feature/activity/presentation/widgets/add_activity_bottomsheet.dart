import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lely_assignment/feature/activity/presentation/cubit/activity_cubit.dart';

class AddActivityBottomSheet extends StatefulWidget {
  const AddActivityBottomSheet({super.key});

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  static const int _maxMinutes = 1440;

  final _formKey = GlobalKey<FormState>();
  final _dateFieldKey = GlobalKey<FormFieldState<DateTime>>();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  DateTime _initialPickerDate() {
    final state = context.read<ActivityCubit>().state;
    final now = DateTime.now();

    if (state is ActivityLoaded && state.activities.isNotEmpty) {
      final latestDate = state.activities
          .map((activity) => activity.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      final dayAfterLatest = latestDate.add(const Duration(days: 1));

      return dayAfterLatest.isAfter(now) ? now : dayAfterLatest;
    }

    return now;
  }

  Future<void> _pickDate(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: field.value ?? _initialPickerDate(),
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (pickedDate != null) {
      field.didChange(pickedDate);
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final date = _dateFieldKey.currentState!.value!;

    context.read<ActivityCubit>().addActivity(
      date: date,
      durationMinutes: int.parse(_minutesController.text),
    );
  }

  String? _validateMinutes(String? value) {
    if (value == null || value.isEmpty) {
      return 'Minutes active is required.';
    }

    final minutes = int.parse(value);

    if (minutes <= 0) {
      return 'Minutes must be greater than zero.';
    }

    if (minutes > _maxMinutes) {
      return 'Minutes cannot exceed $_maxMinutes per day.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityCubit, ActivityState>(
      listenWhen: (previous, current) {
        if (previous is! ActivityLoaded || current is! ActivityLoaded) {
          return false;
        }

        return previous.isSubmitting &&
            !current.isSubmitting &&
            current.addActivityError == null;
      },
      listener: (context, state) => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: BlocBuilder<ActivityCubit, ActivityState>(
          builder: (context, state) {
            final loadedState = state is ActivityLoaded ? state : null;
            final isSubmitting = loadedState?.isSubmitting ?? false;
            final error = loadedState?.addActivityError;

            return Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  FormField<DateTime>(
                    key: _dateFieldKey,
                    validator: (value) =>
                        value == null ? 'Date is required.' : null,
                    builder: (field) {
                      return InkWell(
                        key: const Key('add_activity_date_field'),
                        onTap: isSubmitting
                            ? null
                            : () => _pickDate(context, field),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            field.value == null
                                ? 'Select a date'
                                : DateFormat.yMMMd().format(field.value!),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('add_activity_duration_field'),
                    controller: _minutesController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Minutes active',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateMinutes,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      key: const Key('add_activity_error_text'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('add_activity_cancel_button'),
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          key: const Key('add_activity_submit_button'),
                          onPressed: isSubmitting
                              ? null
                              : () => _submit(context),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
