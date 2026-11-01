import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pto_mobile/viewmodels/apply_viewmodel.dart';
import 'package:pto_mobile/viewmodels/renew_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';

import 'views/splash_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fhiqwldcrpxzmonmuxet.supabase.co',
    publishableKey: 'sb_publishable_6fyjrrb3-R07fGBq_J-uHw_C_lHv3_h',
  );
  runApp(const PTOApp());
}

class PTOApp extends StatelessWidget {
  const PTOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
         ChangeNotifierProvider(create: (_) => ApplyViewModel()),
         ChangeNotifierProvider(create: (_) => RenewViewModel()),
      ],
      child: MaterialApp(
        title: 'PTO Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFE87A2D),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}