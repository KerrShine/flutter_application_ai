import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    if (!file.path.endsWith('.dart')) continue;
    var content = file.readAsStringSync();
    
    bool changed = false;

    if (content.contains('page/section_design/')) {
      content = content.replaceAll('page/section_design/', 'page/form_design/form_section_design/');
      changed = true;
    }
    
    if (content.contains('SectionDesign')) {
      content = content.replaceAll('SectionDesign', 'FormSectionDesign');
      changed = true;
    }
    
    if (content.contains('section_design') && !content.contains('form_section_design')) {
      content = content.replaceAll('section_design', 'form_section_design');
      changed = true;
    }
    
    if (content.contains('sectionDesign')) {
      content = content.replaceAll('sectionDesign', 'formSectionDesign');
      changed = true;
    }
    
    if (content.contains('section-design')) {
        content = content.replaceAll('section-design', 'form-section-design');
        changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
    }
  }

  // Ensure parent exists
  final formDesignDir = Directory('lib/page/form_design');
  if (!formDesignDir.existsSync()) {
    formDesignDir.createSync(recursive: true);
  }

  // Rename directory
  final sectionDesignDir = Directory('lib/page/section_design');
  if (sectionDesignDir.existsSync()) {
      sectionDesignDir.renameSync('lib/page/form_design/form_section_design');
  }

  // Rename inner files
  final formSectionDesignDir = Directory('lib/page/form_design/form_section_design');
  if (formSectionDesignDir.existsSync()) {
      final innerFiles = formSectionDesignDir.listSync(recursive: true).whereType<File>().toList();
      for (var file in innerFiles) {
         if (file.path.contains('section_design')) {
            final newPath = file.path.replaceAll('section_design', 'form_section_design');
            // ensure subdirs exist if any
            File(newPath).parent.createSync(recursive: true);
            file.renameSync(newPath);
         }
      }
  }

  // repositories
  final repoDir = Directory('lib/repositories');
  if (repoDir.existsSync()) {
      final repoFiles = repoDir.listSync(recursive: true).whereType<File>().toList();
      for (var file in repoFiles) {
         if (file.path.contains('section_design')) {
            final newPath = file.path.replaceAll('section_design', 'form_section_design');
             File(newPath).parent.createSync(recursive: true);
            file.renameSync(newPath);
         }
      }
  }

  // services
  final serviceDir = Directory('lib/service');
  if (serviceDir.existsSync()) {
      final serviceFiles = serviceDir.listSync(recursive: true).whereType<File>().toList();
      for (var file in serviceFiles) {
         if (file.path.contains('section_design')) {
            final newPath = file.path.replaceAll('section_design', 'form_section_design');
             File(newPath).parent.createSync(recursive: true);
            file.renameSync(newPath);
         }
      }
  }
}
