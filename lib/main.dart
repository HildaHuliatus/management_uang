import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wjvndlovqrjilfcjmrgd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indqdm5kbG92cXJqaWxmY2ptcmdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5NjIwNDYsImV4cCI6MjA4MzUzODA0Nn0.Xg7lTBF4mfYEFjjWLxjNSXiS0Uy2X4y0uXk9JxvYwuw',
  );

  runApp(const App());
}
