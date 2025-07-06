import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/tandem/tandem_selection_screen.dart';
import 'services/auth_service.dart';
import 'services/gocardless_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://olkwosfqonszrtvnrfgx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9sa3dvc2Zxb25zenJ0dm5yZmd4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczODM0NzUsImV4cCI6MjA2Mjk1OTQ3NX0.nbwzlcqmobVx95UPZIkQUZEK4cJs58wv-nKrCE_o91A',
  );
  
  runApp(const TandemApp());
}

class TandemApp extends StatelessWidget {
  const TandemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GoCardlessService()),
      ],
      child: MaterialApp(
      title: 'Tandem - Dépenses Couple',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF2D3748),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          return const TandemNavigationWrapper();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class TandemNavigationWrapper extends StatelessWidget {
  const TandemNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Toujours afficher la page de sélection des tandems comme page d'accueil
    return const TandemSelectionScreen();
  }
}

