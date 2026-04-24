part of 'main_bloc.dart';

class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

// 初始事件
class InitEvent extends MainEvent {
  const InitEvent();
}

// 新增快捷路由
class MainAddShortcutEvent extends MainEvent {
  final String path;
  const MainAddShortcutEvent(this.path);

  @override
  List<Object> get props => [path];
}

// 移除快捷路由
class MainRemoveShortcutEvent extends MainEvent {
  final String path;
  const MainRemoveShortcutEvent(this.path);

  @override
  List<Object> get props => [path];
}

// 切換快捷管理編輯模式
class MainToggleShortcutEditEvent extends MainEvent {
  const MainToggleShortcutEditEvent();
}
