import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().toList();

  // 1. Replace text in files
  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    if (content.contains('FormDesigner') || 
        content.contains('form_designer') || 
        content.contains('formDesigner') ||
        content.contains('form-designer')) {
      
      content = content.replaceAll('FormDesigner', 'SectionDesign');
      content = content.replaceAll('form_designer', 'section_design');
      content = content.replaceAll('formDesigner', 'sectionDesign');
      content = content.replaceAll('form-designer', 'section-design');
      
      file.writeAsStringSync(content);
    }
  }

  // 2. Rename the directory
  final pageDir = Directory('lib/page/form_designer');
  if (pageDir.existsSync()) {
    pageDir.renameSync('lib/page/section_design');
  }

  // 3. Rename files in the new directory (including nested files)
  if (Directory('lib/page/section_design').existsSync()) {
      final sectionDesignFiles = Directory('lib/page/section_design').listSync(recursive: true).whereType<File>().toList();
      for (var file in sectionDesignFiles) {
         if (file.path.contains('form_designer')) {
            final newPath = file.path.replaceAll('form_designer', 'section_design');
            file.renameSync(newPath);
         }
      }
  }

  // 4. Rename files in repositories
  final repoDir = Directory('lib/repositories');
  if (repoDir.existsSync()) {
      final repoFiles = repoDir.listSync(recursive: true).whereType<File>().toList();
      for (var file in repoFiles) {
         if (file.path.contains('form_designer')) {
            final newPath = file.path.replaceAll('form_designer', 'section_design');
            file.renameSync(newPath);
         }
      }
  }

  // 5. Rename files in service
  final serviceDir = Directory('lib/service');
  if (serviceDir.existsSync()) {
      final serviceFiles = serviceDir.listSync(recursive: true).whereType<File>().toList();
      for (var file in serviceFiles) {
         if (file.path.contains('form_designer')) {
            final newPath = file.path.replaceAll('form_designer', 'section_design');
            file.renameSync(newPath);
         }
      }
  }

}
