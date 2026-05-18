import 'dart:convert';

import 'package:flutter_application_ai/model/api_definition.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/api_catalog_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/service/form_action_binding_service.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFormRepository extends Mock implements FormRepository {}

class MockSectionRepository extends Mock implements SectionRepository {}

class MockFormDataBindingRepository extends Mock
    implements FormDataBindingRepository {}

class MockApiCatalogRepository extends Mock implements ApiCatalogRepository {}

class FakeFormDataBindingDraft extends Fake implements FormDataBindingDraft {}

void main() {
  late MockFormRepository formRepository;
  late MockSectionRepository sectionRepository;
  late MockFormDataBindingRepository bindingRepository;
  late MockApiCatalogRepository apiCatalogRepository;
  late FormDataBindingService formDataBindingService;
  late FormActionBindingService service;

  setUpAll(() {
    registerFallbackValue(FakeFormDataBindingDraft());
  });

  setUp(() {
    formRepository = MockFormRepository();
    sectionRepository = MockSectionRepository();
    bindingRepository = MockFormDataBindingRepository();
    apiCatalogRepository = MockApiCatalogRepository();
    when(() => apiCatalogRepository.loadApiList())
        .thenAnswer((_) async => Result.success(<ApiDefinition>[]));
    when(() => apiCatalogRepository.loadDropdownApiList())
        .thenAnswer((_) async => Result.success(<ApiDefinition>[]));
    formDataBindingService = FormDataBindingService(
      formRepository,
      sectionRepository,
      bindingRepository,
    );
    service =
        FormActionBindingService(formDataBindingService, apiCatalogRepository);
  });

  group('initialize', () {
    test('builds action sources for button and dropdown only', () async {
      final form = _buildForm();
      final section = _buildSection();
      final savedDraft = FormDataBindingDraft(
        bindingId: 'binding-1',
        bindingName: '客戶互動綁定',
        formId: form.id,
        formName: form.name,
        formSize: form.size,
        sections: const [
          FormDataBindingSectionDraft(
            sectionId: 'section-1',
            sectionName: '基本資料',
            fields: [
              FormDataBindingFieldDraft(
                itemId: 'name-field',
                label: '姓名',
                fieldName: 'customer_name',
                sourceType: 'textField',
                outputKey: 'customer_name',
              ),
            ],
          ),
        ],
        actions: const [
          FormActionBindingDraft(
            actionId: 'city-dropdown_dropdownChanged_refreshTarget',
            sourceItemId: 'city-dropdown',
            sourceLabel: '城市',
            sourceType: 'dropdown',
            triggerType: ActionTriggerType.dropdownChanged,
            actionType: ActionType.refreshTarget,
            description: '選項變更事件 -> 更新目標欄位',
          ),
        ],
      );

      when(() => formRepository.loadFormById(form.id))
          .thenAnswer((_) async => Result.success(form));
      when(() => sectionRepository.loadSections())
          .thenAnswer((_) async => Result.success([section]));
      when(() => bindingRepository.loadDraftsByFormId(form.id))
          .thenAnswer((_) async => Result.success([savedDraft]));

      final result = await service.initialize(form.id, bindingId: 'binding-1');

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);

      final data = result.data!;
      expect(data.actionSources, hasLength(2));
      expect(
        data.actionSources.map((item) => item.itemId),
        containsAll(['city-dropdown', 'submit-button']),
      );

      final dropdownSource = data.actionSources.firstWhere(
        (item) => item.itemId == 'city-dropdown',
      );
      final buttonSource = data.actionSources.firstWhere(
        (item) => item.itemId == 'submit-button',
      );

      expect(dropdownSource.sourceType, 'dropdown');
      expect(dropdownSource.availableTriggers,
          ['dropdownLoaded', 'dropdownChanged']);
      expect(dropdownSource.suggestedActions, contains('refreshTarget'));
      expect(buttonSource.sourceType, 'button');
      expect(buttonSource.availableTriggers, ['buttonPressed']);
      expect(buttonSource.suggestedActions, contains('submitForm'));

      final preview = jsonDecode(data.previewJson) as Map<String, dynamic>;
      expect(preview['bindingId'], 'binding-1');
      expect(preview['formId'], 'form-1');
      expect(preview['actionBindings'], hasLength(1));
      expect(preview['actionSources'], hasLength(2));
    });
  });

  group('saveActionSettings', () {
    test('writes updated action list back through data binding storage',
        () async {
      const draft = FormDataBindingDraft(
        bindingId: 'binding-1',
        bindingName: '客戶互動綁定',
        formId: 'form-1',
        formName: '客戶表單',
      );
      const actions = [
        FormActionBindingDraft(
          actionId: 'submit-button_buttonPressed_submitForm',
          sourceItemId: 'submit-button',
          sourceLabel: '送出',
          sourceType: 'button',
          triggerType: ActionTriggerType.buttonPressed,
          actionType: ActionType.submitForm,
          description: '點擊事件 -> 送出表單',
        ),
      ];

      when(() => bindingRepository.saveDraft(any()))
          .thenAnswer((_) async => Result.success(true));

      final result = await service.saveActionSettings(
        draft: draft,
        actions: actions,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.actions, actions);

      final captured =
          verify(() => bindingRepository.saveDraft(captureAny())).captured;
      final savedDraft = captured.single as FormDataBindingDraft;
      expect(savedDraft.bindingId, 'binding-1');
      expect(savedDraft.actions, actions);
      expect(savedDraft.updatedAt, isNotEmpty);
    });
  });
}

FormModel _buildForm() {
  return const FormModel(
    id: 'form-1',
    name: '客戶表單',
    size: 'A4',
    sectionIds: ['section-1'],
  );
}

SectionModel _buildSection() {
  return const SectionModel(
    id: 'section-1',
    name: '基本資料',
    items: [
      DesignerItem(
        id: 'name-field',
        type: DesignerItemType.textField,
        text: '姓名',
        fieldName: 'customer_name',
      ),
      DesignerItem(
        id: 'city-dropdown',
        type: DesignerItemType.dropdown,
        text: '城市',
        fieldName: 'city_code',
      ),
      DesignerItem(
        id: 'submit-button',
        type: DesignerItemType.button,
        text: '送出',
      ),
      DesignerItem(
        id: 'note-label',
        type: DesignerItemType.label,
        text: '僅供顯示',
      ),
    ],
  );
}
