import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    
    bool changed = false;

    if (content.contains('form_form_section_design')) {
      content = content.replaceAll('form_form_section_design', 'form_section_design');
      changed = true;
    }
    
    if (content.contains('FormFormSectionDesign')) {
      content = content.replaceAll('FormFormSectionDesign', 'FormSectionDesign');
      changed = true;
    }
    
    if (content.contains('formFormSectionDesign')) {
      content = content.replaceAll('formFormSectionDesign', 'formSectionDesign');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
    }
  }
}
