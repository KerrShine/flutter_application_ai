import 'package:flutter/material.dart';
import 'package:flutter_application_ai/model/employee_model.dart';

class EmpDepEmployeeCardWidget extends StatelessWidget {
  final EmployeeModel employee;
  final String departmentName;
  final bool isHighlighted;
  final bool draggable;
  final bool showManagerStyle;
  final bool showRemoveButton;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const EmpDepEmployeeCardWidget({
    super.key,
    required this.employee,
    required this.departmentName,
    required this.isHighlighted,
    this.draggable = false,
    this.showManagerStyle = false,
    this.showRemoveButton = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isManagerCard = showManagerStyle && employee.isManagerLevel;
    final borderColor = isManagerCard
        ? const Color(0xFFD97A00)
        : isHighlighted
            ? const Color(0xFF111111)
            : const Color(0xFFE0E0E0);
    final backgroundColor = isManagerCard
        ? const Color(0xFFFFF3E0)
        : isHighlighted
            ? const Color(0xFFFFF8E1)
            : Colors.white;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: showRemoveButton ? 6 : 0,
                  right: showRemoveButton ? 30 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isManagerCard) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0B2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          '主管職',
                          style: TextStyle(
                            color: Color(0xFFB25C00),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      employee.employeeName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '工號 ${employee.employeeCode}',
                      style: const TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '職位 ${employee.roleName.isEmpty ? '未指定角色' : employee.roleName}',
                      style: const TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '部門 $departmentName',
                      style: const TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: employee.isActive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        employee.isActive ? '啟用' : '停用',
                        style: TextStyle(
                          color: employee.isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF757575),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showRemoveButton && onRemove != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onRemove,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEA),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF5C2C7)),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!draggable) {
      return card;
    }

    return Draggable<EmployeeModel>(
      data: employee,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 220,
          child: card,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: card,
      ),
      child: card,
    );
  }
}
