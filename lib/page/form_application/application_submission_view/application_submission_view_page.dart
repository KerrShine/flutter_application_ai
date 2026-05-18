import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_ai/bloc/current_employee/current_employee_bloc.dart';
import 'package:flutter_application_ai/dialog/message_dialog.dart';
import 'package:flutter_application_ai/enum/leave_sign_off_status.dart';
import 'package:flutter_application_ai/enum/submission_view_mode.dart';
import 'package:flutter_application_ai/injection/dependency_injection.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/bloc/application_submission_view_bloc.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/widgets/application_sign_off_action_panel_widget.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/widgets/sign_off_status_widget.dart';
import 'package:flutter_application_ai/page/form_application/application_submission_view/widgets/submission_meta_card_widget.dart';
import 'package:flutter_application_ai/route/app_router.dart';
import 'package:flutter_application_ai/theme/form_application_theme_colors.dart';
import 'package:flutter_application_ai/theme/text_size.dart';

class ApplicationSubmissionViewPage extends StatefulWidget {
  final String signOffId;
  final SubmissionViewMode mode;

  const ApplicationSubmissionViewPage({
    super.key,
    required this.signOffId,
    this.mode = SubmissionViewMode.viewer,
  });

  @override
  State<ApplicationSubmissionViewPage> createState() =>
      _ApplicationSubmissionViewPageState();
}

class _ApplicationSubmissionViewPageState
    extends State<ApplicationSubmissionViewPage> {
  late final ApplicationSubmissionViewBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ApplicationSubmissionViewBloc>();
    _bloc.add(InitEvent(signOffId: widget.signOffId, mode: widget.mode));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ApplicationSubmissionViewBloc,
              ApplicationSubmissionViewState>(
            listenWhen: (previous, current) =>
                previous.exportDialogRequestId !=
                    current.exportDialogRequestId &&
                current.exportJson.isNotEmpty,
            listener: (context, state) {
              _showExportJsonDialog(context, state.exportJson);
            },
          ),
          BlocListener<ApplicationSubmissionViewBloc,
              ApplicationSubmissionViewState>(
            listenWhen: (previous, current) =>
                previous.messageRequestId != current.messageRequestId &&
                current.message.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            },
          ),
          BlocListener<ApplicationSubmissionViewBloc,
              ApplicationSubmissionViewState>(
            listenWhen: (previous, current) =>
                previous.actionCompletedRequestId !=
                current.actionCompletedRequestId,
            listener: (context, state) async {
              await Future.delayed(const Duration(milliseconds: 800));
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
        child: BlocBuilder<ApplicationSubmissionViewBloc,
            ApplicationSubmissionViewState>(
          builder: (context, state) {
            final signOff = state.signOff;
            final hasData = signOff != null;
            final canEdit = hasData &&
                state.mode == SubmissionViewMode.viewer &&
                signOff.isEditableByApplicant;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  state.mode == SubmissionViewMode.reviewer
                      ? '審核申請'
                      : '申請詳情',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                actions: [
                  if (canEdit)
                    IconButton(
                      tooltip: '編輯本筆',
                      onPressed: () => context.go(
                        RouteName.formRunPage,
                        extra: {
                          'formId': signOff.formId,
                          'bindingId': '',
                          'signOffId': signOff.signOffId,
                        },
                      ),
                      icon: const Icon(Icons.edit),
                    ),
                  IconButton(
                    tooltip: '匯出此筆 JSON',
                    onPressed: hasData
                        ? () => _bloc.add(const RequestExportJsonEvent())
                        : null,
                    icon: const Icon(Icons.code),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showExportJsonDialog(
    BuildContext context,
    String exportJson,
  ) {
    return showScrollableMessageDialog(
      context: context,
      title: '此筆申請 JSON（LocalStorage）',
      width: 860,
      rightText: '關閉',
      child: SelectableText(
        exportJson,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: TextSize.body,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, ApplicationSubmissionViewState state) {
    final colors =
        Theme.of(context).extension<FormApplicationThemeColors>()!;
    final textTheme = Theme.of(context).textTheme;

    if (state.status == ApplicationSubmissionViewStatus.init ||
        state.status == ApplicationSubmissionViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ApplicationSubmissionViewStatus.failure ||
        state.signOff == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colors.errorColor),
            const SizedBox(height: 16),
            Text(
              state.message.isEmpty ? '無法載入此申請' : state.message,
              style: textTheme.titleLarge?.copyWith(
                fontSize: TextSize.title,
                color: colors.errorColor,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => _bloc.add(const RefreshEvent()),
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    final signOff = state.signOff!;
    final currentEmployeeId =
        context.watch<CurrentEmployeeBloc>().state.current.employeeId;
    final canSign = _canCurrentEmployeeSign(state, currentEmployeeId);
    return Container(
      color: colors.pageBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubmissionMetaCardWidget(signOff: signOff),
            const SizedBox(height: 20),
            SignOffStatusWidget(
              signOff: signOff,
              resolvedChain: state.resolvedChain,
              employees: state.employees,
            ),
            if (state.mode == SubmissionViewMode.reviewer && canSign) ...[
              const SizedBox(height: 20),
              _buildReviewerPanel(context, state),
            ],
          ],
        ),
      ),
    );
  }

  /// 登入者是否為當前關卡的合格簽核者（含 allowAgentFallback 代理人）。
  /// 用於 reviewer mode 下判斷是否顯示簽核動作面板。
  bool _canCurrentEmployeeSign(
    ApplicationSubmissionViewState state,
    String employeeId,
  ) {
    final signOff = state.signOff;
    if (signOff == null) return false;
    if (signOff.status != LeaveSignOffStatus.pending &&
        signOff.status != LeaveSignOffStatus.inReview) {
      return false;
    }
    final approvers = state.resolvedChain
        .where((r) => r.description != '申請起點')
        .toList();
    final idx = signOff.currentStepIndex;
    if (idx < 0 || idx >= approvers.length) return false;
    final approver = approvers[idx];
    final eligible = <String>{
      ...approver.approverEmployeeIds,
      if (approver.allowAgentFallback && approver.agentEmployeeId.isNotEmpty)
        approver.agentEmployeeId,
    };
    return eligible.contains(employeeId);
  }

  Widget _buildReviewerPanel(
      BuildContext context, ApplicationSubmissionViewState state) {
    final emp = context.read<CurrentEmployeeBloc>().state.current;
    // 取當前關卡判斷 allowAddSigner（僅該關卡 allowAddSigner=true 才開放加簽）
    final approvers = state.resolvedChain
        .where((r) => r.description != '申請起點')
        .toList();
    final idx = state.signOff?.currentStepIndex ?? -1;
    final allowAddSigner = (idx >= 0 && idx < approvers.length)
        ? approvers[idx].allowAddSigner
        : false;
    return ApplicationSignOffActionPanelWidget(
      employees: state.employees,
      allowAddSigner: allowAddSigner,
      onApprove: (comment) => _bloc.add(ApproveActionEvent(
        approverId: emp.employeeId,
        approverName: emp.employeeName,
        comment: comment,
      )),
      onReject: (comment) => _bloc.add(RejectActionEvent(
        approverId: emp.employeeId,
        approverName: emp.employeeName,
        comment: comment,
      )),
      onReturnBack: (comment) => _bloc.add(ReturnBackActionEvent(
        approverId: emp.employeeId,
        approverName: emp.employeeName,
        comment: comment,
      )),
      onRequestSupplement: (comment) => _bloc.add(RequestSupplementActionEvent(
        approverId: emp.employeeId,
        approverName: emp.employeeName,
        comment: comment,
      )),
      onTransfer: (targetId, comment) => _bloc.add(TransferActionEvent(
        approverId: emp.employeeId,
        approverName: emp.employeeName,
        targetEmployeeId: targetId,
        comment: comment,
      )),
      onAddApprover: (addedId, comment) => _bloc.add(AddApproverActionEvent(
        approverId: emp.employeeId,
        approverName: emp.employeeName,
        addedEmployeeId: addedId,
        comment: comment,
      )),
    );
  }
}
