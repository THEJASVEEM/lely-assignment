# lely_assignment

A flutter mobile application created for the Lely assignment

## Features

- Login using predefined credentials
- View robot activities as in hours active per day
- Filter the display
- Add new activities maintained in local memory
- Minutes converted to hours
- Custom `CustomPainter` line chart with gradient and tooltip
- Date filters: 1W, 1M, 3M
- Add activity using a modal bottom sheet
- Duplicate-date validation
- Temporary in-memory persistence
- Unit and widget tests

## Login

```text
Username: Lely
Password: LelyControl2
```

## Run

```text
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Tests

```text
flutter test
flutter analyze
```