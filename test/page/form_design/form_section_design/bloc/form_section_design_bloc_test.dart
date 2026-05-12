import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_application_ai/model/designer_item.dart';
import 'package:flutter_application_ai/model/form_section_design_draft_model.dart';
import 'package:flutter_application_ai/page/form_design/form_section_design/bloc/form_section_design_bloc.dart';
import 'package:flutter_application_ai/service/condition_field_service.dart';
import 'package:flutter_application_ai/service/form_section_design_service.dart';
import 'package:flutter_application_ai/unit/base/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFormSectionDesignService extends Mock
    implements FormSectionDesignService {}

class MockConditionFieldService extends Mock
    implements ConditionFieldService {}

void main() {
  group('FormSectionDesignBloc', () {
    late MockFormSectionDesignService service;
    late MockConditionFieldService conditionService;

    setUp(() {
      service = MockFormSectionDesignService();
      conditionService = MockConditionFieldService();
      when(() => conditionService.loadDraft(any()))
          .thenAnswer((_) async => Result.success(null));
    });

    blocTest<FormSectionDesignBloc, FormSectionDesignState>(
      'InitEvent 優先載入 local draft',
      build: () {
        when(() => service.loadDraft('section_1')).thenAnswer(
          (_) async => Result.success(
            const FormSectionDesignDraftModel(
              sectionId: 'section_1',
              formName: '草稿表單',
              rowCount: 3,
              items: [
                DesignerItem(
                  id: 'item_1',
                  type: DesignerItemType.label,
                  text: '標題',
                ),
              ],
            ),
          ),
        );
        when(() => service.loadSection(any()))
            .thenAnswer((_) async => Result.success(null));

        return FormSectionDesignBloc(service, conditionService);
      },
      act: (bloc) => bloc.add(const InitEvent(sectionId: 'section_1')),
      expect: () => const [
        FormSectionDesignState(status: FormSectionDesignStatus.loading),
        FormSectionDesignState(
          status: FormSectionDesignStatus.success,
          items: [
            DesignerItem(
              id: 'item_1',
              type: DesignerItemType.label,
              text: '標題',
            ),
          ],
          rowCount: 3,
          draftName: '草稿表單',
          editingSectionId: 'section_1',
        ),
      ],
      verify: (_) {
        verify(() => service.loadDraft('section_1')).called(1);
        verifyNever(() => service.loadSection('section_1'));
      },
    );
  });
}
