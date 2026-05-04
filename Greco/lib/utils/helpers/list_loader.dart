abstract class ListLoader<Element> {
  Stream<List<Element>> load();
}

class PassthroughListLoader<Element> extends ListLoader<Element> {
  final List<Element> elements;
  PassthroughListLoader(this.elements);
  @override
  Stream<List<Element>> load() {
    return Stream.value(elements);
  }
}
