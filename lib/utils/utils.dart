List<T> dynamicToList<T>(dynamic value) {
  return (value as List? ?? []).map((e) => e as T).toList();
}
