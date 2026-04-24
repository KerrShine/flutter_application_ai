import 'package:flutter_application_ai/enum/designer_item_type.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/form_data_binding_draft.dart';
import 'package:flutter_application_ai/model/form_model.dart';
import 'package:flutter_application_ai/model/section_model.dart';
import 'package:flutter_application_ai/repositories/interface/form_data_binding_repository.dart';
import 'package:flutter_application_ai/repositories/interface/form_repository.dart';
import 'package:flutter_application_ai/repositories/interface/section_repository.dart';
import 'package:flutter_application_ai/service/form_data_binding_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFormRepository extends Mock implements FormRepository {}

class MockSectionRepository extends Mock implements SectionRepository {}

class MockFormDataBindingRepository extends Mock
    implements FormDataBindingRepository {}

class FakeFormDataBindingDraft extends Fake implements FormDataBindingDraft {}

void main() {
  late MockFormRepository formRepository;
  late MockSectionRepository sectionRepository;
  late MockFormDataBindingRepository bindingRepository;
  late FormDataBindingService service;

  setUpAll(() {
    registerFallbackValue(FakeFormDataBindingDraft());
  });

  setUp(() {
    formRepository = MockFormRepository();
    sectionRepository = MockSectionRepository();
    bindingRepository = MockFormDataBindingRepository();
    service = FormDataBindingService(
      formRepository,
      sectionRepository,
      bindingRepository,
    );
  });

  group('initialize', () {
    test('restores saved draft fields and keeps action settings', () async {
      final form = _buildForm();
      final section = _buildSection();
      final savedDraft = FormDataBindingDraft(
        bindingId: 'binding-1',
        bindingName: '客戶資料綁定',
        bindingDescription: '既有綁定',
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
                outputKey: 'customer_name_saved',
                nullStrategy: BindingNullStrategy.custom,
                customDefaultValue: '訪客',
              ),
            ],
          ),
        ],
        actions: const [
          FormActionBindingDraft(
            actionId: 'submit-button_buttonPressed_submitForm',
            sourceItemId: 'submit-button',
            sourceLabel: '送出',
            sourceType: 'button',
            triggerType: ActionTriggerType.buttonPressed,
            actionType: ActionType.submitForm,
            description: '點擊事件 -> 送出表單',
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
      expect(result.error, isNull);
      expect(result.data, isNotNull);

      final draft = result.data!;
      final fields = draft.sections.single.fields;
      final nameField =
          fields.firstWhere((field) => field.itemId == 'name-field');
      final dropdownField =
          fields.firstWhere((field) => field.itemId == 'city-dropdown');
      final buttonField =
          fields.firstWhere((field) => field.itemId == 'submit-button');

      expect(draft.bindingId, 'binding-1');
      expect(draft.bindingName, '客戶資料綁定');
      expect(draft.actions, savedDraft.actions);
      expect(nameField.outputKey, 'customer_name_saved');
      expect(nameField.nullStrategy, BindingNullStrategy.custom);
      expect(nameField.customDefaultValue, '訪客');
      expect(dropdownField.outputKey, 'city_code');
      expect(dropdownField.sourceType, DesignerItemType.dropdown.name);
      expect(buttonField.fieldKind, BindingFieldKind.button);
      expect(buttonField.outputKey, '事件綁定');
      expect(buttonField.customDefaultValue, '事件綁定');

      verify(() => formRepository.loadFormById(form.id)).called(1);
      verify(() => sectionRepository.loadSections()).called(1);
      verify(() => bindingRepository.loadDraftsByFormId(form.id)).called(1);
    });
  });

  group('validateDraft', () {
    test('returns error when custom default does not match number type', () {
      const draft = FormDataBindingDraft(
        sections: [
          FormDataBindingSectionDraft(
            sectionId: 'section-1',
            sectionName: '基本資料',
            fields: [
              FormDataBindingFieldDraft(
                itemId: 'amount-field',
                label: '金額',
                fieldName: 'amount',
                valueType: BindingFieldValueType.number,
                outputKey: 'amount',
                nullStrategy: BindingNullStrategy.custom,
                customDefaultValue: 'abc',
              ),
            ],
          ),
        ],
      );

      final errors = service.validateDraft(draft);

      expect(errors, hasLength(1));
      expect(errors['section-1::amount-field'], '預設值必須為數字');
    });
  });

  group('saveDraft', () {
    test('does not call repository when draft still has validation errors',
        () async {
      const invalidDraft = FormDataBindingDraft(
        sections: [
          FormDataBindingSectionDraft(
            sectionId: 'section-1',
            sectionName: '基本資料',
            fields: [
              FormDataBindingFieldDraft(
                itemId: 'name-field',
                label: '姓名',
                fieldName: 'customer_name',
                outputKey: '',
              ),
            ],
          ),
        ],
      );

      final result = await service.saveDraft(invalidDraft);

      expect(result.isSuccess, isFalse);
      expect(result.error, '仍有欄位設定未完成，無法暫存');
      verifyNever(() => bindingRepository.saveDraft(any()));
    });

    test('writes updated draft when validation passes', () async {
      const validDraft = FormDataBindingDraft(
        bindingId: 'binding-1',
        bindingName: '客戶資料綁定',
        formId: 'form-1',
        formName: '客戶表單',
        sections: [
          FormDataBindingSectionDraft(
            sectionId: 'section-1',
            sectionName: '基本資料',
            fields: [
              FormDataBindingFieldDraft(
                itemId: 'name-field',
                label: '姓名',
                fieldName: 'customer_name',
                outputKey: 'customer_name',
              ),
            ],
          ),
        ],
      );

      when(() => bindingRepository.saveDraft(any()))
          .thenAnswer((_) async => Result.success(true));

      final result = await service.saveDraft(validDraft);

      expect(result.isSuccess, isTrue);
      expect(result.data, isTrue);

      final captured =
          verify(() => bindingRepository.saveDraft(captureAny())).captured;
      final savedDraft = captured.single as FormDataBindingDraft;
      expect(savedDraft.bindingId, 'binding-1');
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
  return SectionModel(
    id: 'section-1',
    name: '基本資料',
    items: const [
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
