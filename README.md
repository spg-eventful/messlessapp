# Important

in order for JSON Serialization generation to work, you need to run

```
dart run build_runner watch --delete-conflicting-outputs
```

once. This will start the generator in the background - leave it running for the entire dev session.

A working example of JSON Serialization can be found in `/lib/ws/schema/generic_error.dart`

## Docs
https://docs.flutter.dev/data-and-backend/serialization/json#running-the-code-generation-utility