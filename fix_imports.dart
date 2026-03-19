import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    
    bool changed = false;

    if (content.contains('section_design_')) {
      content = content.replaceAll('section_design_', 'form_section_design_');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
    }
  }
}
