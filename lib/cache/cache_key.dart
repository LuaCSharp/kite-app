part of 'box.dart';
class NamedCacheKey<T> extends CacheKey<T> {
  final String name;

  NamedCacheKey(super.box, this.name);

  @override
  T? get value {
    final cache = box.get(name);
    if (cache is T?) {
      return cache;
    } else {
      clear();
      return null;
    }
  }

  @override
  set value(T? newValue) {
    if (newValue == null) {
      clear();
    } else {
      box.put(name, newValue);
      lastUpdate = DateTime.now();
    }
  }

  @override
  DateTime? get lastUpdate {
    return box.get("$name/$_lastUpdateKey");
  }

  @override
  set lastUpdate(DateTime? newValue) {
    box.put("$name/$_lastUpdateKey", newValue);
  }

  @override
  bool needRefresh({required Duration after}) {
    final last = lastUpdate;
    if (last == null) {
      return true;
    } else {
      return DateTime.now().difference(last) > after;
    }
  }
}


class CacheNamespace<T> {
  final Box<dynamic> box;
  final String namespace;

  CacheNamespace(this.box, this.namespace);

  CacheKey<T> make(String name) {
    return _NamespaceCacheKey(box, namespace, name);
  }
}

class _NamespaceCacheKey<T> extends CacheKey<T> {
  final String namespace;
  final String name;

  _NamespaceCacheKey(
      super.box,
      this.namespace,
      this.name,
      );

  @override
  T? get value {
    final cache = box.get("$namespace/$name");
    if (cache is T?) {
      return cache;
    } else {
      clear();
      return null;
    }
  }

  @override
  set value(T? newValue) {
    if (newValue == null) {
      clear();
    } else {
      box.put("$namespace/$name", newValue);
      lastUpdate = DateTime.now();
    }
  }

  @override
  DateTime? get lastUpdate {
    return box.get("$namespace/$name/$_lastUpdateKey");
  }

  @override
  set lastUpdate(DateTime? newValue) {
    box.put("$namespace/$name/$_lastUpdateKey", newValue);
  }

  @override
  bool needRefresh({required Duration after}) {
    final last = lastUpdate;
    if (last == null) {
      return true;
    } else {
      return DateTime.now().difference(last) > after;
    }
  }
}
