enum Flavor { development, production }

class FlavorConfig {
FlavorConfig(this.flavor);

final Flavor flavor;

static late FlavorConfig current;

static void load(Flavor flavor) {
current = FlavorConfig(flavor);
}

static String get name => current.flavor.name;
}