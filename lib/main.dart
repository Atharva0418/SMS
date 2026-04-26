import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/local/hive_service.dart';
import 'providers/visitor_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.init();
  await HiveService.visitorBox.clear();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => VisitorProvider())],
      child: MaterialApp(
        title: 'Society MS',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const ConnectivityWrapper(child: HomeScreen()),
      ),
    );
  }
}

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({required this.child, super.key});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && _wasOffline) {
        context.read<VisitorProvider>().syncPending();
        _showBanner('Back online. Syncing entries...');
      }
      if (!isOnline) {
        _showBanner('No internet. Entries will sync when reconnected.');
      }
      _wasOffline = !isOnline;
    });
  }

  void _showBanner(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
