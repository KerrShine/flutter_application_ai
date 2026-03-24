import 'package:flutter/material.dart';

class DepartmentFormPanelWidget extends StatelessWidget {
  final TextEditingController departmentNameController;
  final TextEditingController departmentCodeController;
  final String selectedDepartmentId;
  final int draftDepartmentStatus;
  final ValueChanged<String> onDepartmentNameChanged;
  final ValueChanged<String> onDepartmentCodeChanged;
  final ValueChanged<int?> onStatusChanged;
  final VoidCallback onSaveDepartmentNode;
  final VoidCallback onResetDepartmentDraft;

  const DepartmentFormPanelWidget({
    super.key,
    required this.departmentNameController,
    required this.departmentCodeController,
    required this.selectedDepartmentId,
    required this.draftDepartmentStatus,
    required this.onDepartmentNameChanged,
    required this.onDepartmentCodeChanged,
    required this.onStatusChanged,
    required this.onSaveDepartmentNode,
    required this.onResetDepartmentDraft,
  });

  @override
  Widget build(BuildContext context) {
    final isEditing = selectedDepartmentId.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? '編輯部門節點' : '新增部門節點',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: onResetDepartmentDraft,
                    child: const Text('新增模式'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: departmentNameController,
              decoration: const InputDecoration(
                labelText: '部門名稱',
                border: OutlineInputBorder(),
              ),
              onChanged: onDepartmentNameChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: departmentCodeController,
              decoration: const InputDecoration(
                labelText: '部門代碼',
                border: OutlineInputBorder(),
              ),
              onChanged: onDepartmentCodeChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: draftDepartmentStatus,
              decoration: const InputDecoration(
                labelText: '啟用狀態',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('啟用'),
                ),
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text('停用'),
                ),
              ],
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onSaveDepartmentNode,
                icon: Icon(isEditing ? Icons.save : Icons.add),
                label: Text(isEditing ? '儲存節點資料' : '新增部門節點'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
