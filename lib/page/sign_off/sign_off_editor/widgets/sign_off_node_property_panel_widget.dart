import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_ai/enum/sign_off_approver_mode.dart';
import 'package:flutter_application_ai/enum/sign_off_multi_strategy.dart';
import 'package:flutter_application_ai/enum/sign_off_node_type.dart';
import 'package:flutter_application_ai/enum/sign_off_return_policy.dart';
import 'package:flutter_application_ai/model/employee_model.dart';
import 'package:flutter_application_ai/model/emp_role_model.dart';
import 'package:flutter_application_ai/model/org_department_node.dart';
import 'package:flutter_application_ai/model/sign_off_canvas_node.dart';
import 'package:flutter_application_ai/model/sign_off_condition_field_choice.dart';
import 'package:flutter_application_ai/model/sign_off_path_rule.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_path_rule_card.dart';
import 'package:flutter_application_ai/page/sign_off/sign_off_editor/widgets/units/sign_off_path_rule_editor_dialog.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class SignOffNodePropertyPanelWidget extends StatelessWidget {
  final SignOffCanvasNode? selectedNode;
  final List<SignOffCanvasNode> allNodes;
  final List<OrgDepartmentNode> departments;
  final List<EmpRoleModel> roles;
  final List<EmployeeModel> employees;

  final void Function(SignOffNodeType) onTypeChanged;
  final void Function(SignOffApproverMode) onModeChanged;
  final void Function(String) onCrossLevelTargetChanged;
  final void Function(String) onDesignatedRoleChanged;
  final void Function(String) onDesignatedEmployeeChanged;
  final void Function(SignOffMultiStrategy) onMultiStrategyChanged;
  final void Function(SignOffReturnPolicy) onReturnPolicyChanged;
  final void Function(int) onSlaDaysChanged;
  final void Function(int) onApplicantAncestorOffsetChanged;
  final void Function(int) onApplicantTargetDepthLevelChanged;

  // Path rule props (only used by origin node section)
  final List<SignOffPathRule> pathRules;
  final List<SignOffConditionFieldChoice> formFields;
  final VoidCallback onAddPathRule;
  final void Function(String ruleId) onRemovePathRule;
  final void Function(SignOffPathRule rule) onUpdatePathRule;
  final void Function(String ruleId, bool isUp) onMovePathRule;
  final VoidCallback onGoToBinding;

  final VoidCallback onMoveOrderUp;
  final VoidCallback onMoveOrderDown;
  final VoidCallback onDelete;

  const SignOffNodePropertyPanelWidget({
    super.key,
    required this.selectedNode,
    required this.allNodes,
    required this.departments,
    required this.roles,
    required this.employees,
    required this.onTypeChanged,
    required this.onModeChanged,
    required this.onCrossLevelTargetChanged,
    required this.onDesignatedRoleChanged,
    required this.onDesignatedEmployeeChanged,
    required this.onMultiStrategyChanged,
    required this.onReturnPolicyChanged,
    required this.onSlaDaysChanged,
    required this.onApplicantAncestorOffsetChanged,
    required this.onApplicantTargetDepthLevelChanged,
    required this.pathRules,
    required this.formFields,
    required this.onAddPathRule,
    required this.onRemovePathRule,
    required this.onUpdatePathRule,
    required this.onMovePathRule,
    required this.onGoToBinding,
    required this.onMoveOrderUp,
    required this.onMoveOrderDown,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: colors.infoPanelBackground,
        border: Border(left: BorderSide(color: colors.panelBorder)),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 12,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: selectedNode == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colors.emptyStateIconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.touch_app_outlined,
                        size: 32,
                        color: colors.emptyStateIconColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '請選擇節點以編輯屬性',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize:
                            (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                        color: colors.faintText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(context, selectedNode!, colors),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SignOffCanvasNode node,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final dept = departments.cast<OrgDepartmentNode?>().firstWhere(
          (d) => d?.departmentId == node.departmentId,
          orElse: () => null,
        );
    final badgeColor = node.isApplicantOrigin
        ? theme.colorScheme.tertiary
        : colors.actionButtonAccent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.headerAccentBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.panelBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    node.isApplicantOrigin ? '起' : '${node.sortOrder}',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    node.isApplicantOrigin ? '申請起點' : (dept?.name ?? '未知部門'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize:
                          (theme.textTheme.titleMedium?.fontSize ?? 16) + 2,
                      fontWeight: FontWeight.w700,
                      color: colors.headerAccentForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!node.isApplicantOrigin) ...[
            const SizedBox(height: 14),
            _buildOrderControls(context, node, colors),
          ],
          const SizedBox(height: 16),
          if (!node.isApplicantOrigin)
            ..._buildApproverFields(context, node, colors),
          if (node.isApplicantOrigin) _buildOriginRulesSection(context, colors),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(
              '刪除節點',
              style: TextStyle(
                fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.actionWarning,
              side: BorderSide(color: colors.actionWarning),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildApproverFields(
    BuildContext context,
    SignOffCanvasNode node,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final fieldStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
    );
    return [
      _label(context, '節點類型', colors),
      DropdownButtonFormField<SignOffNodeType>(
        value: node.nodeType,
        style: fieldStyle,
        items: SignOffNodeType.values
            .map((t) => DropdownMenuItem(
                value: t, child: Text(t.label, style: fieldStyle)))
            .toList(),
        onChanged: (value) {
          if (value != null) onTypeChanged(value);
        },
      ),
      const SizedBox(height: 14),
      _label(context, '簽核人模式', colors),
      DropdownButtonFormField<SignOffApproverMode>(
        value: node.approverMode,
        style: fieldStyle,
        items: SignOffApproverMode.values
            .map((m) => DropdownMenuItem(
                value: m, child: Text(m.label, style: fieldStyle)))
            .toList(),
        onChanged: (value) {
          if (value != null) onModeChanged(value);
        },
      ),
      const SizedBox(height: 14),
      ..._buildModeSpecificFields(context, node, colors),
      if (node.nodeType == SignOffNodeType.countersign) ...[
        const SizedBox(height: 14),
        _label(context, '會簽策略', colors),
        DropdownButtonFormField<SignOffMultiStrategy>(
          value: node.multiStrategy,
          style: fieldStyle,
          items: SignOffMultiStrategy.values
              .map((s) => DropdownMenuItem(
                  value: s, child: Text(s.label, style: fieldStyle)))
              .toList(),
          onChanged: (value) {
            if (value != null) onMultiStrategyChanged(value);
          },
        ),
      ],
      if (node.nodeType == SignOffNodeType.approve ||
          node.nodeType == SignOffNodeType.countersign) ...[
        const SizedBox(height: 14),
        _label(context, '簽核期限（天）', colors),
        TextFormField(
          key: ValueKey('sla_${node.nodeId}'),
          initialValue: '${node.slaDays}',
          keyboardType: TextInputType.number,
          style: fieldStyle,
          decoration: const InputDecoration(
            hintText: '0 = 不限期',
            isDense: true,
            suffixText: '天',
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value.trim()) ?? 0;
            onSlaDaysChanged(parsed);
          },
        ),
      ],
      const SizedBox(height: 14),
      _label(context, '退回策略', colors),
      DropdownButtonFormField<SignOffReturnPolicy>(
        value: node.returnPolicy,
        style: fieldStyle,
        items: SignOffReturnPolicy.values
            .map((p) => DropdownMenuItem(
                value: p, child: Text(p.label, style: fieldStyle)))
            .toList(),
        onChanged: (value) {
          if (value != null) onReturnPolicyChanged(value);
        },
      ),
    ];
  }

  List<Widget> _buildModeSpecificFields(
    BuildContext context,
    SignOffCanvasNode node,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final fieldStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
    );

    switch (node.approverMode) {
      case SignOffApproverMode.hierarchyManager:
        return [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.infoRowBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.infoRowBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: colors.actionInfo),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '由此節點所屬部門主管簽核。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.subtleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      case SignOffApproverMode.crossLevel:
        final candidates = allNodes
            .where((n) =>
                n.nodeId != node.nodeId &&
                !n.isApplicantOrigin &&
                n.departmentId.isNotEmpty)
            .toList();
        return [
          _label(context, '同層互簽目標', colors),
          DropdownButtonFormField<String>(
            value: node.crossLevelTargetNodeId.isEmpty
                ? null
                : node.crossLevelTargetNodeId,
            style: fieldStyle,
            items: candidates.map((n) {
              final dept = departments.cast<OrgDepartmentNode?>().firstWhere(
                    (d) => d?.departmentId == n.departmentId,
                    orElse: () => null,
                  );
              return DropdownMenuItem(
                value: n.nodeId,
                child: Text(dept?.name ?? n.departmentId, style: fieldStyle),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onCrossLevelTargetChanged(value);
            },
          ),
        ];
      case SignOffApproverMode.designatedRole:
        return [
          _label(context, '指定角色', colors),
          DropdownButtonFormField<String>(
            value: node.designatedRoleId.isEmpty
                ? null
                : node.designatedRoleId,
            style: fieldStyle,
            items: roles
                .map((r) => DropdownMenuItem(
                      value: r.roleId,
                      child: Text(r.roleName, style: fieldStyle),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) onDesignatedRoleChanged(value);
            },
          ),
        ];
      case SignOffApproverMode.designatedEmployee:
        return [
          _label(context, '指定員工', colors),
          DropdownButtonFormField<String>(
            value: node.designatedEmployeeId.isEmpty
                ? null
                : node.designatedEmployeeId,
            style: fieldStyle,
            items: employees
                .where((e) => e.isActive)
                .map((e) => DropdownMenuItem(
                      value: e.employeeId,
                      child: Text(
                        '${e.employeeName}（${e.roleName}）',
                        style: fieldStyle,
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) onDesignatedEmployeeChanged(value);
            },
          ),
        ];
      case SignOffApproverMode.applicantSelf:
        return [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.infoRowBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.infoRowBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: colors.actionInfo),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '執行時直接帶入申請人為簽核人，常用於補件確認。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.subtleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      case SignOffApproverMode.applicantManagerAtDepth:
        // 動態從載入的 departments 取所有出現過的 depthLevel；若節點現值不在其中也要納入避免 dropdown 失效
        final depths = <int>{
          ...departments.map((d) => d.depthLevel),
          node.applicantTargetDepthLevel,
        }.toList()
          ..sort();
        String exampleFor(int depth) {
          for (final d in departments) {
            if (d.depthLevel == depth) return d.name;
          }
          return '';
        }
        return [
          _label(context, '目標組織層級', colors),
          DropdownButtonFormField<int>(
            value: node.applicantTargetDepthLevel,
            style: fieldStyle,
            isExpanded: true,
            items: depths.map((depth) {
              final example = exampleFor(depth);
              final label = example.isEmpty
                  ? 'L$depth 主管'
                  : 'L$depth 主管（例：$example）';
              return DropdownMenuItem(
                value: depth,
                child: Text(label,
                    style: fieldStyle, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onApplicantTargetDepthLevelChanged(value);
            },
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.infoRowBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.infoRowBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: colors.actionInfo),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '依當前載入組織的層級自動列出。從申請人所屬部門沿 parent 鏈往上找，第一個 depthLevel == 此值的祖先即為簽核部門。組織新增 / 重整層級時，選項會自動跟著變動，無需改動模板程式。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.subtleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      case SignOffApproverMode.applicantAncestorManager:
        return [
          _label(context, '上幾層主管', colors),
          TextFormField(
            key: ValueKey('anc_${node.nodeId}'),
            initialValue: '${node.applicantAncestorOffset}',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: fieldStyle,
            decoration: const InputDecoration(
              isDense: true,
              suffixText: '層',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value.trim()) ?? 1;
              onApplicantAncestorOffsetChanged(parsed);
            },
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.infoRowBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.infoRowBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: colors.actionInfo),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '1 = 直屬主管、2 = 直屬主管的上一層、N = 沿組織樹往上 N 步。執行時依申請人動態解析。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize:
                          (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
                      color: colors.subtleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
    }
  }

  Widget _buildOrderControls(
    BuildContext context,
    SignOffCanvasNode node,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);

    final approverNodes = allNodes
        .where((n) => !n.isApplicantOrigin)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final index = approverNodes.indexWhere((n) => n.nodeId == node.nodeId);
    final canMoveUp = index > 0;
    final canMoveDown = index >= 0 && index < approverNodes.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.statsCardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.statsCardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, size: 18, color: colors.actionButtonAccent),
          const SizedBox(width: 8),
          Text(
            '簽核順序',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) + 2,
              fontWeight: FontWeight.w700,
              color: colors.subtleText,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: '上移',
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            onPressed: canMoveUp ? onMoveOrderUp : null,
            icon: const Icon(Icons.arrow_upward),
            color: colors.actionButtonAccent,
          ),
          IconButton(
            tooltip: '下移',
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            onPressed: canMoveDown ? onMoveOrderDown : null,
            icon: const Icon(Icons.arrow_downward),
            color: colors.actionButtonAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildOriginRulesSection(
    BuildContext context,
    FormDesignThemeColors colors,
  ) {
    final theme = Theme.of(context);
    final approverNodes = allNodes.where((n) => !n.isApplicantOrigin).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final sortedRules = List<SignOffPathRule>.from(pathRules)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.alt_route, size: 18, color: colors.actionButtonAccent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '簽核路徑規則',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: (theme.textTheme.titleSmall?.fontSize ?? 14) + 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: approverNodes.isEmpty ? null : onAddPathRule,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('新增規則'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (approverNodes.isEmpty)
          _buildHintBox(
            context,
            colors,
            '請先在畫布上新增至少一個簽核節點，才能建立路徑規則。',
            colors.actionWarning,
          )
        else if (sortedRules.isEmpty)
          _buildHintBox(
            context,
            colors,
            '無規則 → 預設所有簽核節點都會被啟用（向後相容行為）。',
            colors.actionInfo,
          )
        else
          Column(
            children: [
              for (var i = 0; i < sortedRules.length; i++) ...[
                SignOffPathRuleCard(
                  rule: sortedRules[i],
                  canMoveUp: i > 0,
                  canMoveDown: i < sortedRules.length - 1,
                  onTap: () async {
                    final updated = await showSignOffPathRuleEditorDialog(
                      context: context,
                      initialRule: sortedRules[i],
                      formFields: formFields,
                      approverNodes: approverNodes,
                      onGoToBinding: onGoToBinding,
                    );
                    if (updated != null) onUpdatePathRule(updated);
                  },
                  onMoveUp: () => onMovePathRule(sortedRules[i].ruleId, true),
                  onMoveDown: () =>
                      onMovePathRule(sortedRules[i].ruleId, false),
                  onDelete: () => onRemovePathRule(sortedRules[i].ruleId),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        const SizedBox(height: 4),
        Text(
          '評估順序：上而下，第一個命中的規則被選用。',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12),
            color: colors.faintText,
          ),
        ),
      ],
    );
  }

  Widget _buildHintBox(
    BuildContext context,
    FormDesignThemeColors colors,
    String text,
    Color accent,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 1,
                color: colors.subtleText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(
      BuildContext context, String text, FormDesignThemeColors colors) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: (theme.textTheme.bodySmall?.fontSize ?? 12) + 2,
          fontWeight: FontWeight.w700,
          color: colors.subtleText,
        ),
      ),
    );
  }
}
