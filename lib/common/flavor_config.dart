enum FlavorType {
  paid,
  free,
}

class FlavorValues {
  final String titleApp;

  const FlavorValues({
    this.titleApp = "Story App",
  });
}

class FlavorConfig {
  final FlavorType flavor;

  static FlavorConfig? _instance;

  FlavorConfig({
    this.flavor = FlavorType.free,
  }) {
    _instance = this;
  }

  static FlavorConfig get instance => _instance ?? FlavorConfig();
}
