#!/usr/bin/env dart
import 'dart:io';

/// Test runner script for Tandem Flutter app
/// This script runs all tests with proper coverage and reporting
void main(List<String> args) async {
  print('🧪 Starting Tandem Flutter Test Suite...\n');

  final stopwatch = Stopwatch()..start();

  try {
    // Run unit tests
    print('📋 Running Unit Tests...');
    await runTests('test/', excludeIntegration: true);

    // Run widget tests
    print('\n🎨 Running Widget Tests...');
    await runTests('test/widgets/');

    // Run model tests
    print('\n📊 Running Model Tests...');
    await runTests('test/models/');

    // Run service tests
    print('\n⚙️ Running Service Tests...');
    await runTests('test/services/');

    // Run integration tests (if requested)
    if (args.contains('--integration')) {
      print('\n🔄 Running Integration Tests...');
      await runTests('test/integration/');
    }

    stopwatch.stop();
    
    print('\n✅ All tests completed successfully!');
    print('⏱️ Total time: ${stopwatch.elapsedMilliseconds}ms');
    
    if (!args.contains('--integration')) {
      print('\n💡 Tip: Run with --integration flag to include integration tests');
    }

  } catch (e) {
    stopwatch.stop();
    print('\n❌ Tests failed: $e');
    print('⏱️ Failed after: ${stopwatch.elapsedMilliseconds}ms');
    exit(1);
  }
}

Future<void> runTests(String path, {bool excludeIntegration = false}) async {
  final args = ['test'];
  
  if (excludeIntegration) {
    args.addAll(['--exclude-tags', 'integration']);
  }
  
  args.add(path);

  final result = await Process.run('flutter', args);
  
  if (result.exitCode != 0) {
    print('❌ Tests in $path failed:');
    print(result.stdout);
    print(result.stderr);
    throw Exception('Test failure in $path');
  } else {
    print('✅ Tests in $path passed');
    // Print summary if available
    final output = result.stdout.toString();
    final lines = output.split('\n');
    for (final line in lines) {
      if (line.contains('passed') || line.contains('failed') || line.contains('All tests')) {
        print('   $line');
      }
    }
  }
}