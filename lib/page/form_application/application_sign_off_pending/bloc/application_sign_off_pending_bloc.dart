import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'application_sign_off_pending_event.dart';
part 'application_sign_off_pending_state.dart';

/// 「待我簽核」v1 為空殼 — sign_off 流程模組完成後再接真實資料。
/// 目前不注入任何 service；handler 直接 emit success + 空 list。
class ApplicationSignOffPendingBloc extends Bloc<ApplicationSignOffPendingEvent, ApplicationSignOffPendingState> {
  ApplicationSignOffPendingBloc() : super(const ApplicationSignOffPendingState()) {
    on<InitEvent>(_onInitEvent);
  }

  void _onInitEvent(
    InitEvent event,
    Emitter<ApplicationSignOffPendingState> emit,
  ) {
    emit(state.copyWith(
      status: SignOffPendingStatus.success,
      employeeId: event.employeeId,
      pendingItems: const [],
    ));
  }
}
