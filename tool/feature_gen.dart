import 'dart:io';

void main(List<String> args) {
  // Feature name: from args OR ask interactively (no defaults)
  final feature =
      (args.isNotEmpty ? args[0] : _ask('Feature name? (e.g., orders)')).trim();

  if (feature.isEmpty) {
    stderr.writeln('❌ Feature name cannot be empty.');
    exit(64);
  }

  // Prefix: optional, if empty => same as feature
  final prefixInput = (args.length > 1
          ? args[1]
          : _ask('Files prefix? (Enter = same as feature) (e.g., my_orders)'))
      .trim();

  final prefix = prefixInput.isEmpty ? feature : prefixInput;

  // Feature base directory
  final base = Directory('lib/features/$feature');

  // Fixed folders
  final dirs = <String>[
    'data/api',
    'data/repo',
    'data/models',
    'presentation/cubit',
    'presentation/ui',
  ];

  for (final d in dirs) {
    Directory('${base.path}/$d').createSync(recursive: true);
  }

  void writeFile(String relPath, String content) {
    final file = File('${base.path}/$relPath');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(content);
      stdout.writeln('✅ Created: ${file.path}');
    } else {
      stdout.writeln('⏭️ Skipped (exists): ${file.path}');
    }
  }

  // Class/file naming
  final featurePascal = _pascal(feature); // Orders
  final prefixSnake = _snake(prefix); // my_orders
  final prefixPascal = _pascal(prefixSnake); // MyOrders

  // API
  writeFile(
    'data/api/${feature}_api_service.dart',
    '''
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part '${feature}_api_service.g.dart';

@RestApi()
abstract class ${featurePascal}ApiService {
  factory ${featurePascal}ApiService(Dio dio, {String baseUrl}) = _${featurePascal}ApiService;

  // TODO: endpoints
}
''',
  );

  // Repo
  writeFile(
    'data/repo/${feature}_repo.dart',
    '''
import 'package:shisha_driver/core/network/api_result.dart';
import 'package:shisha_driver/features/$feature/data/api/${feature}_api_service.dart';

class ${featurePascal}Repository {
  final ${featurePascal}ApiService api;
  ${featurePascal}Repository(this.api);

  // TODO: methods returning AppResponse
}
''',
  );

  // Models
  writeFile(
    'data/models/${prefixSnake}_models.dart',
    '''
// TODO: add models for "$feature"
''',
  );

  // State
  writeFile(
    'presentation/cubit/${prefixSnake}_state.dart',
    '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${prefixSnake}_state.freezed.dart';

@freezed
class ${prefixPascal}State with _\$${prefixPascal}State {
  const factory ${prefixPascal}State.initial() = _Initial;
  const factory ${prefixPascal}State.loading() = _Loading;
  const factory ${prefixPascal}State.error(String message) = _Error;
  const factory ${prefixPascal}State.loaded() = _Loaded; // TODO: add data
}
''',
  );

  // Cubit
  writeFile(
    'presentation/cubit/${prefixSnake}_cubit.dart',
    '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shisha_driver/features/$feature/data/repo/${feature}_repo.dart';
import '${prefixSnake}_state.dart';

class ${prefixPascal}Cubit extends Cubit<${prefixPascal}State> {
  final ${featurePascal}Repository repo;

  ${prefixPascal}Cubit(this.repo) : super(const ${prefixPascal}State.initial());

  // TODO: load() and actions
}
''',
  );

  // Screen
  writeFile(
    'presentation/ui/${feature}_screen.dart',
    '''
import 'package:flutter/material.dart';

class ${featurePascal}Screen extends StatelessWidget {
  const ${featurePascal}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('$feature')),
    );
  }
}
''',
  );

  stdout.writeln('\n🎉 Done: lib/features/$feature');
}

/// Ask user for input in terminal
String _ask(String q) {
  stdout.write('$q ');
  return stdin.readLineSync() ?? '';
}

/// Convert to PascalCase
String _pascal(String s) {
  final parts = s.split(RegExp(r'[_\-\s]+')).where((e) => e.isNotEmpty);
  return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

/// Convert to snake_case (simple)
String _snake(String s) {
  final cleaned = s.trim().replaceAll(RegExp(r'[\-\s]+'), '_');
  return cleaned.toLowerCase();
}
