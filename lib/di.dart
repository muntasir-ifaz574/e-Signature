import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/core/data/data.dart';
import 'app/route/app_route.dart';

final sl = GetIt.instance;
Future dI() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<LocalData>(() => LocalData(sl()));
  final apiService = NetworkApiServices(sl());
  sl.registerLazySingleton(() => apiService);
  sl.registerSingleton<AppRouter>(AppRouter());
}
