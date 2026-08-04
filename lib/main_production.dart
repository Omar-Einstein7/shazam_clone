import 'package:flutter_complete_project/core/di/injector.dart';

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  await configureDependencies();

  //  await AppConfig.init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.green,
    systemNavigationBarColor: Colors.amber
  ));
  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}