import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().toList();

  // 1. Rename occurrences in files: "form_create" -> "form_design/form_create"
  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    
    bool changed = false;
    if (content.contains('page/form_create/')) {
      content = content.replaceAll('page/form_create/', 'page/form_design/form_create/');
      changed = true;
    }
    
    if (changed) {
      file.writeAsStringSync(content);
    }
  }

  // 2. Move directory
  final formCreateDir = Directory('lib/page/form_create');
  final formDesignDir = Directory('lib/page/form_design');
  
  if (!formDesignDir.existsSync()) {
     formDesignDir.createSync();
  }
  
  if (formCreateDir.existsSync()) {
      formCreateDir.renameSync('lib/page/form_design/form_create');
  }
}
