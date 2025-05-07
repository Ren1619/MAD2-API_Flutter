import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/bootprint_api_service.dart';
import 'providers/bootprint_provider.dart';
import 'screens/space_explorer_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create API service
    final apiService = BootprintApiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BootprintProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Bootprint Space Explorer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SpaceExplorerScreen(),
      ),
    );
  }
}
