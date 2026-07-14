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
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _wasSubmitting = false;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    context.read<ActivityCubit>().addActivity(
      date: _selectedDate,
      durationMinutes: int.parse(_durationController.text),
    );
  }

  String? _validateDuration(String? value) {
    final minutes = int.tryParse(value ?? '');

    if (minutes == null || minutes <= 0) {
      return 'Enter a duration greater than 0.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityCubit, ActivityState>(
      listenWhen: (previous, current) =>
          previous is ActivityLoaded && current is ActivityLoaded,
      listener: (context, state) {
        final loadedState = state as ActivityLoaded;

        final didSucceed =
            _wasSubmitting &&
            !loadedState.isSubmitting &&
            loadedState.addActivityError == null;

        _wasSubmitting = loadedState.isSubmitting;

        if (didSucceed) {
          Navigator.of(context).pop();
        }
      },
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
                  InkWell(
                    key: const Key('add_activity_date_field'),
                    onTap: isSubmitting ? null : () => _pickDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat.yMMMd().format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('add_activity_duration_field'),
                    controller: _durationController,
                    enabled: !isSubmitting,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateDuration,
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
                  FilledButton(
                    key: const Key('add_activity_submit_button'),
                    onPressed: isSubmitting ? null : () => _submit(context),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
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
