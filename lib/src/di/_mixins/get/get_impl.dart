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

// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:df_type/df_type.dart';
import 'package:meta/meta.dart';

import '../_index.g.dart';
import '/src/_index.g.dart';
import '../../_di_base.dart';
import '../../../_dependency.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@internal
base mixin GetImpl on DIBase implements GetIface {
  @override
  @pragma('vm:prefer-inline')
  T call<T extends Object>({
    Id? group,
  }) {
    return getSync<T>(group: group);
  }

  @override
  T? getSyncOrNull<T extends Object>({
    Id? group,
  }) {
    final focusGroup = preferFocusGroup(group);
    final registered = isRegistered<T>(
      group: focusGroup,
    );
    if (registered) {
      try {
        return getSync<T>(group: focusGroup);
      } catch (_) {}
    }
    return null;
  }

  @override
  T getSync<T extends Object>({
    Id? group,
  }) {
    final value = get<T>(group: group);
    if (value is Future<T>) {
      throw TypeError();
    }
    return value;
  }

  @override
  Future<T>? getAsyncOrNull<T extends Object>({
    Id? group,
  }) {
    final focusGroup = preferFocusGroup(group);
    final registered = isRegistered<T>(
      group: focusGroup,
    );
    if (registered) {
      try {
        return getAsync<T>(group: focusGroup);
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<T> getAsync<T extends Object>({
    Id? group,
  }) async {
    final value = await get<T>(group: group);
    return value;
  }

  @override
  FutureOr<T?> getOrNull<T extends Object>({
    Id? group,
  }) {
    final focusGroup = preferFocusGroup(group);
    final registered = isRegistered<T>(
      group: focusGroup,
    );
    if (registered) {
      return get<T>(group: focusGroup);
    }
    return null;
  }

  @override
  FutureOr<T> get<T extends Object>({
    Id? group,
  }) {
    final dep = _get<T>(group: group);
    return dep.thenOr((dep) {
      if (dep.condition?.call(this) ?? true) {
        return dep.value;
      } else {
        // TODO: Need a specific error.
        throw Error();
      }
    });
  }

  @protected
  FutureOr<Dependency<T>> _get<T extends Object>({
    Id? group,
  }) {
    final focusGroup = preferFocusGroup(group);
    final result = getFirstNonNull(
      child: this,
      parent: parent,
      test: (di) => _getInternal<T>(
        di: di,
        group: focusGroup,
      ),
    );
    if (result == null) {
      throw DependencyNotFoundException(
        type: T,
        group: focusGroup,
      );
    }
    return result;
  }
}

FutureOr<Dependency<T>>? _getInternal<T extends Object>({
  required DI di,
  required Id group,
}) {
  // Sync types.
  {
    final dep = di.registry.getDependencyOrNull<T>(
      group: group,
    );
    if (dep != null) {
      return dep.cast();
    }
  }
  // Future types.
  {
    final res = _inst<T, FutureInst<T>>(
      di: di,
      group: group,
    );
    if (res != null) {
      return res;
    }
  }
  // Singleton types.
  {
    final res = _inst<T, SingletonInst<T>>(
      di: di,
      group: group,
    );
    if (res != null) {
      return res;
    }
  }
  return null;
}

FutureOr<Dependency<T>>? _inst<T extends Object, TInst extends Inst<T, Object>>({
  required DI di,
  required Id group,
}) {
  final dep = di.registry.getDependencyOrNull<TInst>(
    group: group,
  );
  if (dep != null) {
    final value = (dep.value as TInst).cast<T, Object>();
    return value.thenOr((value) {
      return value.constructor(-1);
    }).thenOr((newValue) {
      return di.registerDependency<T>(
        dependency: dep.reassign(newValue),
        suppressDependencyAlreadyRegisteredException: true,
      );
    }).thenOr((_) {
      return di.registry.removeDependency<TInst>(
        group: group,
      );
    }).thenOr((_) {
      return di._get<T>(
        group: group,
      );
    });
  }
  return null;
}
