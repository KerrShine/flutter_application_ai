import 'package:flutter/material.dart';
import 'package:flutter_application_ai/page/employee/emp_manager/widgets/emp_manager_guide_checklist_item_widget.dart';

class EmpManagerGuideChecklistPanelWidget extends StatelessWidget {
  const EmpManagerGuideChecklistPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: const [
            EmpManagerGuideChecklistItemWidget(
              title: '角色類型需先建立',
              description: '角色建立前，需先完成角色類型資料。',
            ),
            Divider(height: 24),
            EmpManagerGuideChecklistItemWidget(
              title: '組織架構需先完成',
              description: '職員部門資料直接關聯組織架構中的 departmentId。',
            ),
            Divider(height: 24),
            EmpManagerGuideChecklistItemWidget(
              title: '代理人不可為離職職員',
              description: '代理人頁面需過濾 status 非在職的人員。',
            ),
            Divider(height: 24),
            EmpManagerGuideChecklistItemWidget(
              title: '目前部門規格為單一部門',
              description:
                  'EmployeeModel 以單一 departmentId 與 OrgDepartmentNode 關聯。',
            ),
          ],
        ),
      ),
    );
  }
}
