import 'dart:async';

typedef OrElse<R> = R? Function();
typedef AsyncOrElse<R> = FutureOr<R?>? Function();

extension OptionExtension<T> on T? {
  /// if the value is not null, apply the function and return the result
  /// return null otherwise
  R? map<R>(
    R? Function(T) op, {
    R? defaultValue,
    OrElse<R>? orElse,
  }) {
    final T? value = this;
    return value == null ? defaultValue ?? orElse?.call() : op(value);
  }
}

// // Constants for triggers
// enum MentionType {
//   user('@'),
//   room('#');

//   final String trigger;
//   const MentionType(this.trigger);
// }
