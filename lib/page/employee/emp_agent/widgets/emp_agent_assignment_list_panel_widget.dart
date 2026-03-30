import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/emp_agent_assignment_view_model.dart';
import 'package:flutter_application_ai/theme/emp_agent_theme_colors.dart';

class EmpAgentAssignmentListPanelWidget extends StatelessWidget {
  final List<EmpAgentAssignmentViewModel> assignmentRows;
  final ValueChanged<String> onDeleteAssignment;

  const EmpAgentAssignmentListPanelWidget({
    super.key,
    required this.assignmentRows,
    required this.onDeleteAssignment,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColors.panelBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: themeColors.panelShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '現有代理清單',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: themeColors.inputText,
                  ),
                ),
              ),
              Text(
                '共 ${assignmentRows.length} 筆',
                style: TextStyle(
                  fontSize: 13,
                  color: themeColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _FakeFilterField(label: '所有部門')),
              SizedBox(width: 12),
              Expanded(child: _FakeFilterField(label: '有效中')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: assignmentRows.isEmpty
                ? Center(
                    child: Text(
                      '目前尚無代理人設定',
                      style: TextStyle(
                        color: themeColors.mutedText,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: assignmentRows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = assignmentRows[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeColors.summaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: themeColors.summaryBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _AssignmentActorCard(
                                name: item.principalEmployeeName,
                                subtitle: item.principalRoleName.isEmpty
                                    ? item.principalDepartmentName
                                    : '${item.principalRoleName} ｜ ${item.principalDepartmentName}',
                                statusText: '有效中',
                                accentColor:
                                    themeColors.summaryAvatarBackground,
                                textColor: themeColors.summaryAvatarText,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.arrow_forward,
                                color: themeColors.arrowAccent,
                                size: 18,
                              ),
                            ),
                            Expanded(
                              child: _AssignmentActorCard(
                                name: item.agentEmployeeName,
                                subtitle: item.agentRoleName.isEmpty
                                    ? item.agentDepartmentName
                                    : '${item.agentRoleName} ｜ ${item.agentDepartmentName}',
                                statusText: '有效中',
                                accentColor: themeColors.statusActiveBackground,
                                textColor: themeColors.statusActiveText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () =>
                                  onDeleteAssignment(item.assignmentId),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: themeColors.deleteText,
                                side:
                                    BorderSide(color: themeColors.deleteBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('移除'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _FooterGhostButton(label: '上一步'),
              Spacer(),
              _FooterPrimaryButton(label: '完成設定'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FakeFilterField extends StatelessWidget {
  final String label;

  const _FakeFilterField({required this.label});

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: themeColors.dropdownBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColors.dropdownBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: themeColors.inputText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: themeColors.filterIcon,
          ),
        ],
      ),
    );
  }
}

class _AssignmentActorCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String statusText;
  final Color accentColor;
  final Color textColor;

  const _AssignmentActorCard({
    required this.name,
    required this.subtitle,
    required this.statusText,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: accentColor,
          child: Text(
            name.isEmpty ? '?' : name.characters.first,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: themeColors.inputText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: themeColors.mutedText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColors.statusActiveBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: themeColors.statusActiveText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterGhostButton extends StatelessWidget {
  final String label;

  const _FooterGhostButton({required this.label});

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColors.footerGhostBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: themeColors.inputText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FooterPrimaryButton extends StatelessWidget {
  final String label;

  const _FooterPrimaryButton({required this.label});

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<EmpAgentThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: themeColors.footerPrimaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: themeColors.inputText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
