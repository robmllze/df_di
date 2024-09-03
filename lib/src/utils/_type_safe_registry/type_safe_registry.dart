//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by DevCetra.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:meta/meta.dart' show internal;
import 'package:collection/collection.dart' show MapEquality;

import '/src/_index.g.dart';
import '/src/utils/_dependency.dart';

import 'type_safe_registry_base.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// A type-safe registry for storing and managing dependencies of various types
/// within [DI]. This class provides methods for adding, retrieving, updating,
/// and removing dependencies, as well as checking if a specific dependency
/// exists.
@internal
final class TypeSafeRegistry extends TypeSafeRegistryBase {
  //
  //
  //

  /// Dependencies, organized by their type.
  final _state = TypeSafeRegistryMap();

  void Function(TypeSafeRegistryMap state) onUpdate = (_) {};

  /// A snapshot describing the current state of the dependencies.
  TypeSafeRegistryMap get state =>
      Map<Identifier, Map<Identifier, Dependency<Object>>>.unmodifiable(_state)
          .map((k, v) => MapEntry(k, Map.unmodifiable(v)));

  /// A snapshot of the current groups.
  Iterable<Identifier> get groups => state.keys;

  @override
  @pragma('vm:prefer-inline')
  Dependency<Object>? getDependencyOfExactTypeOrNull({
    required Identifier type,
    required Identifier group,
  }) {
    return _state[group]?[type];
  }

  @override
  Iterable<Dependency<Object>> getDependenciesByKey({
    required Identifier group,
  }) {
    return _state.entries
        .expand((entry) => entry.value.values.where((dependency) => dependency.group == group))
        .cast<Dependency<Object>>();
  }

  @override
  void setDependencyOfExactType({
    required Identifier type,
    required Dependency<Object> value,
  }) {
    final group = value.group;
    final prev = _state[group]?[type];
    if (prev != value) {
      (_state[group] ??= {})[type] = value;
      onUpdate(_state);
    }
  }

  @override
  Dependency<Object>? removeDependencyOfExactType({
    required Identifier group,
    required Identifier type,
  }) {
    final value = getDependencyMapByKey(group: group);
    if (value != null) {
      final dep = value.remove(type);
      if (value.isEmpty) {
        removeDependencyMapOfExactType(type: type);
      } else {
        setDependencyMapByKey(
          group: group,
          value: value,
        );
      }
      return dep;
    }
    return null;
  }

  @override
  void setDependencyMapByKey({
    required Identifier group,
    required DependencyMap value,
  }) {
    final prev = _state[group];
    final equals = const MapEquality<Identifier, Dependency<Object>>().equals(prev, value);
    if (!equals) {
      _state[group] = value;
      onUpdate(_state);
    }
  }

  @override
  @pragma('vm:prefer-inline')
  DependencyMap<Object>? getDependencyMapByKey({
    required Identifier group,
  }) {
    return _state[group];
  }

  @override
  @pragma('vm:prefer-inline')
  void removeDependencyMapOfExactType({
    required Identifier type,
  }) {
    _state.remove(type);
    onUpdate(_state);
  }

  @override
  @pragma('vm:prefer-inline')
  void clearRegistry() => _state.clear();
}
