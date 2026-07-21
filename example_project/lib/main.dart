import 'package:example_project/network/app_repos.dart';
import 'package:example_project/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '[${record.loggerName}] ${record.level.name}: '
      '${record.time}: ${record.message}',
    );
  });

  final appRepos = AppRepos();
  runApp(App(repos: appRepos));
}

/// The root of the application
class App extends StatelessWidget {
  /// create the root of the application with dependencies.
  const App({
    required this.repos,
    super.key,
  });

  /// The bundle of all api clients.
  final AppRepos repos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Layer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: DashboardPage(
        apiClient: repos.example,
      ),
    );
  }
}
