import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    
    bool changed = false;

    if (content.contains('FormFormSectionDesign')) {
      content = content.replaceAll('FormFormSectionDesign', 'FormSectionDesign');
      changed = true;
    }
    
    if (content.contains('form_form_section_design')) {
      content = content.replaceAll('form_form_section_design', 'form_section_design');
      changed = true;
    }
    
    if (content.contains('formFormSectionDesign')) {
      content = content.replaceAll('formFormSectionDesign', 'formSectionDesign');
      changed = true;
    }
    
    if (content.contains('form-form-section-design')) {
        content = content.replaceAll('form-form-section-design', 'form-section-design');
        changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
    }
  }

  // Same for fixing double folders if any
  final repoDir = Directory('lib');
  final repoFiles = repoDir.listSync(recursive: true).whereType<File>().toList();
  for (var file in repoFiles) {
      if (file.path.contains('form_form_section_design')) {
          final newPath = file.path.replaceAll('form_form_section_design', 'form_section_design');
          File(newPath).parent.createSync(recursive: true);
          file.renameSync(newPath);
      }
  }
}
