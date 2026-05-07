import 'package:flutter/material.dart';
import 'package:flutter_application_ai/theme/form_design_theme_colors.dart';

class EditorOptionsSectionWidget extends StatefulWidget {
  final bool requireActiveStatus;
  final bool requireManagerRole;
  final int isEnabled;
  final ValueChanged<bool> onRequireActiveStatusChanged;
  final ValueChanged<bool> onRequireManagerRoleChanged;
  final ValueChanged<int> onIsEnabledChanged;

  const EditorOptionsSectionWidget({
    super.key,
    required this.requireActiveStatus,
    required this.requireManagerRole,
    required this.isEnabled,
    required this.onRequireActiveStatusChanged,
    required this.onRequireManagerRoleChanged,
    required this.onIsEnabledChanged,
  });

  @override
  State<EditorOptionsSectionWidget> createState() =>
      _EditorOptionsSectionWidgetState();
}

class _EditorOptionsSectionWidgetState
    extends State<EditorOptionsSectionWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<FormDesignThemeColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.sectionPanelBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.panelBorder),
        boxShadow: [
          BoxShadow(
            color: colors.panelShadow,
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Collapsible header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.headerAccentBackground,
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(8))
                    : BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.sectionIconBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.tune_outlined,
                      color: colors.sectionIconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '其他設定',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.headerAccentForeground,
                            fontWeight: FontWeight.w700,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '在職條件、主管限制、啟用狀態',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.subtleText,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: colors.headerAccentForeground,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_expanded) ...[
            Divider(height: 1, color: colors.panelBorder),
            SwitchListTile(
              title: Text('須在職',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 19)),
              subtitle: Text('僅在職員工可發起',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 17)),
              value: widget.requireActiveStatus,
              onChanged: widget.onRequireActiveStatusChanged,
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: colors.panelBorder,
            ),
            SwitchListTile(
              title: Text('僅限主管',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 19)),
              subtitle: Text('僅主管級角色可發起',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 17)),
              value: widget.requireManagerRole,
              onChanged: widget.onRequireManagerRoleChanged,
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: colors.panelBorder,
            ),
            SwitchListTile(
              title: Text('啟用',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 19)),
              subtitle: Text('此權限設定是否生效',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 17)),
              value: widget.isEnabled == 1,
              onChanged: (value) =>
                  widget.onIsEnabledChanged(value ? 1 : 0),
            ),
          ],
        ],
      ),
    );
  }
}
