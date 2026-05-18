import 'package:flutter/material.dart';
import 'package:flutter_application_ai/enum/sign_off_pending_sort_order.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';

class PendingFilterBarWidget extends StatefulWidget {
  final String searchQuery;
  final SignOffPendingSortOrder sortOrder;
  final String formNameFilter;
  final List<String> availableFormNames;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SignOffPendingSortOrder> onSortChanged;
  final ValueChanged<String> onFormNameFilterChanged;

  const PendingFilterBarWidget({
    super.key,
    required this.searchQuery,
    required this.sortOrder,
    required this.formNameFilter,
    required this.availableFormNames,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onFormNameFilterChanged,
  });

  @override
  State<PendingFilterBarWidget> createState() => _PendingFilterBarWidgetState();
}

class _PendingFilterBarWidgetState extends State<PendingFilterBarWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant PendingFilterBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FormApplicationThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜尋申請人 / 員編 / 表單名稱...',
            prefixIcon: const Icon(Icons.search),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: colors.searchFill,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: '清除',
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                  )
                : null,
          ),
          onChanged: widget.onSearchChanged,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildSortDropdown(context, colors),
            _buildFormNameFilter(context, colors),
          ],
        ),
      ],
    );
  }

  Widget _buildSortDropdown(
    BuildContext context,
    FormApplicationThemeColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.chipBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort, size: 18, color: colors.subtitleText),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<SignOffPendingSortOrder>(
              value: widget.sortOrder,
              isDense: true,
              items: SignOffPendingSortOrder.values
                  .map(
                    (order) => DropdownMenuItem(
                      value: order,
                      child: Text(order.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) widget.onSortChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormNameFilter(
    BuildContext context,
    FormApplicationThemeColors colors,
  ) {
    final options = ['', ...widget.availableFormNames];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.chipBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, size: 18, color: colors.subtitleText),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(widget.formNameFilter)
                  ? widget.formNameFilter
                  : '',
              isDense: true,
              items: options
                  .map(
                    (name) => DropdownMenuItem(
                      value: name,
                      child: Text(name.isEmpty ? '所有表單' : name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                widget.onFormNameFilterChanged(value ?? '');
              },
            ),
          ),
        ],
      ),
    );
  }
}
