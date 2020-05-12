import 'package:MarkMyProgress/extensions/string_extensions.dart';

class SearchableVariable {
  /// Value that will be searched
  final String value;

  /// Priority of searchable item.
  /// Values from 0 to 1 where 1 is highest priority.
  final double priority;

  /// Autogenerated stripped value
  String _strippedValue;

  String get strippedValue => _strippedValue;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  SearchableVariable(this.value, this.priority) {
    if (value != null) {
      _strippedValue = StringExtensions.stripString(value);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchableVariable &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          priority == other.priority);

  @override
  int get hashCode => value.hashCode ^ priority.hashCode;

  @override
  String toString() {
    return 'SearchableItem{' ' value: $value,' ' priority: $priority,' '}';
  }

  SearchableVariable copyWith({
    String value,
    double priority,
  }) {
    return SearchableVariable(
      value ?? this.value,
      priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value,
      'priority': priority,
    };
  }

  factory SearchableVariable.fromMap(Map<String, dynamic> map) {
    return SearchableVariable(
      map['value'] as String,
      map['priority'] as double,
    );
  }

//</editor-fold>
}
