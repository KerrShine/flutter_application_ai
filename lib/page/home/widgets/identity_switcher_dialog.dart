import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/model/employee_model.dart';

/// 開啟身分切換 dialog（從 IdentityCardWidget 觸發）。
///
/// 列出 `CurrentEmployeeBloc.state.candidates` 的所有員工，支援搜尋與在職過濾；
/// 點選員工觸發 `SwitchIdentityEvent` 並關閉 dialog。
Future<void> showIdentitySwitcherDialog({
  required BuildContext context,
}) {
  // 從外層取 bloc，傳入 dialog（dialog 在另一個 navigator stack，無法直接 lookup）
  final bloc = context.read<CurrentEmployeeBloc>();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: bloc,
        child: const _IdentitySwitcherDialog(),
      );
    },
  );
}

class _IdentitySwitcherDialog extends StatefulWidget {
  const _IdentitySwitcherDialog();

  @override
  State<_IdentitySwitcherDialog> createState() =>
      _IdentitySwitcherDialogState();
}

class _IdentitySwitcherDialogState extends State<_IdentitySwitcherDialog> {
  String _searchQuery = '';
  bool _activeOnly = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentEmployeeBloc, CurrentEmployeeState>(
      builder: (context, state) {
        final filtered = _filter(state.candidates);
        return AlertDialog(
          title: const Text('切換身分'),
          contentPadding:
              const EdgeInsets.fromLTRB(20, 16, 20, 0),
          content: SizedBox(
            width: 480,
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildActiveToggle(),
                const SizedBox(height: 8),
                Text(
                  '${filtered.length} 位候選',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Divider(),
                Expanded(child: _buildList(state, filtered)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search, size: 18),
        hintText: '搜尋姓名 / 角色 / 部門',
        isDense: true,
      ),
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      children: [
        Switch.adaptive(
          value: _activeOnly,
          onChanged: (v) => setState(() => _activeOnly = v),
        ),
        const SizedBox(width: 4),
        const Text('僅顯示在職'),
      ],
    );
  }

  Widget _buildList(
    CurrentEmployeeState state,
    List<EmployeeModel> filtered,
  ) {
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            state.candidates.isEmpty
                ? '系統內尚無員工資料'
                : '沒有符合條件的員工',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final emp = filtered[index];
        final isCurrent = emp.employeeId == state.current.employeeId;
        return _buildItem(context, emp, isCurrent);
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    EmployeeModel emp,
    bool isCurrent,
  ) {
    final theme = Theme.of(context);
    final state = context.read<CurrentEmployeeBloc>().state;
    final deptName = emp.departmentId.isEmpty
        ? '未綁部門'
        : state.departmentNameOf(emp.departmentId);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isCurrent
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.dividerColor,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            emp.employeeName.isEmpty ? '?' : emp.employeeName.substring(0, 1),
            style: TextStyle(
              color: isCurrent
                  ? Colors.white
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                emp.employeeName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '目前',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else if (!emp.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '停用',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${emp.roleName.isEmpty ? "—" : emp.roleName} · $deptName',
          overflow: TextOverflow.ellipsis,
        ),
        onTap: isCurrent
            ? null
            : () {
                context
                    .read<CurrentEmployeeBloc>()
                    .add(SwitchIdentityEvent(emp.employeeId));
                Navigator.of(context).pop();
              },
      ),
    );
  }

  List<EmployeeModel> _filter(List<EmployeeModel> all) {
    final state = context.read<CurrentEmployeeBloc>().state;
    return all.where((e) {
      if (_activeOnly && !e.isActive) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final deptName = state.departmentNameOf(e.departmentId).toLowerCase();
      return e.employeeName.toLowerCase().contains(q) ||
          e.roleName.toLowerCase().contains(q) ||
          deptName.contains(q) ||
          e.employeeCode.toLowerCase().contains(q);
    }).toList();
  }
}
