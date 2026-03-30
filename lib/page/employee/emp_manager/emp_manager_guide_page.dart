import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_guide_checklist_panel_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_guide_header_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_guide_section_title_widget.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_guide_step_card_widget.dart';

class EmpManagerGuidePage extends StatefulWidget {
  const EmpManagerGuidePage({super.key});

  @override
  State<EmpManagerGuidePage> createState() => _EmpManagerGuidePageState();
}

class _EmpManagerGuidePageState extends State<EmpManagerGuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('職員設定教學'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            EmpManagerGuideHeaderWidget(),
            SizedBox(height: 32),
            EmpManagerGuideSectionTitleWidget(
              title: '建置順序',
              subtitle: '依目前流程與規格整理出的建議執行順序。',
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                EmpManagerGuideStepCardWidget(
                  step: '01',
                  title: '角色類型與角色設定',
                  description: '先建立角色類型，再建立全域角色與管理職設定。',
                ),
                EmpManagerGuideStepCardWidget(
                  step: '02',
                  title: '職員資料建立',
                  description: '建立工號、姓名、帳號與職員狀態。',
                ),
                EmpManagerGuideStepCardWidget(
                  step: '03',
                  title: '部門綁定',
                  description: '職員綁定單一部門，資料來源對應組織架構。',
                ),
                EmpManagerGuideStepCardWidget(
                  step: '04',
                  title: '代理人設定',
                  description: '設定代理區間，代理人不可為離職職員。',
                ),
              ],
            ),
            SizedBox(height: 32),
            EmpManagerGuideSectionTitleWidget(
              title: '前置條件',
              subtitle: '進入各模組前需要先確認的資料依賴。',
            ),
            SizedBox(height: 16),
            EmpManagerGuideChecklistPanelWidget(),
          ],
        ),
      ),
    );
  }
}
