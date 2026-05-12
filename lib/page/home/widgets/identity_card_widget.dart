import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/page/home/widgets/identity_switcher_dialog.dart';

/// Drawer 頂端的「目前身分」卡片，取代原本「選單」標題。
///
/// 顯示 avatar + 姓名 + 角色 + 部門 / 在職狀態；點擊整個卡片開
/// `IdentitySwitcherDialog` 切換 dev impersonation。
class IdentityCardWidget extends StatelessWidget {
  const IdentityCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentEmployeeBloc, CurrentEmployeeState>(
      builder: (context, state) {
        return Material(
          color: Colors.blue,
          child: InkWell(
            onTap: () => _onTap(context, state),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 16.0),
                child: Row(
                  children: [
                    _buildAvatar(state),
                    const SizedBox(width: 12),
                    Expanded(child: _buildText(context, state)),
                    const Icon(
                      Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(CurrentEmployeeState state) {
    final initial = state.hasIdentity
        ? state.current.employeeName.substring(0, 1)
        : '?';
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, CurrentEmployeeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.displayTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          state.displaySubtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (!state.hasIdentity) ...[
          const SizedBox(height: 4),
          const Text(
            '點擊開啟切換',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _onTap(
    BuildContext context,
    CurrentEmployeeState state,
  ) async {
    if (state.candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('系統內尚無員工資料，請先到員工管理建立員工'),
        ),
      );
      return;
    }
    await showIdentitySwitcherDialog(context: context);
  }
}
