import 'package:flutter_complete_project/core/di/injector.dart';

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';
import 'src/flavors.dart';

const String _appFlavor = String.fromEnvironment(
  'APP_FLAVOR',
  defaultValue: 'development',
);

Flavor get _flavor =>
    _appFlavor == 'production' ? Flavor.production : Flavor.development;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.load(_flavor);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await configureDependencies();

  // await AppConfig.init();
  final config = FlavorConfig.current;
  if (config.isProduction) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      systemNavigationBarColor: Colors.amber,
    ));
  }

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}