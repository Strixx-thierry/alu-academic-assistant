/// Central models entry point
/// Design Decision: Using the 'Barrel' export pattern allows other
/// modules to import all models from a single file, while keeping
/// the implementation modular and separated into dedicated files.
export 'user.dart';
export 'assignment.dart';
export 'session.dart';
