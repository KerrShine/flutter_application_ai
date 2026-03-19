import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection/dependency_injection.dart'; // import sl
import 'bloc/main_bloc.dart';
import '../../service/main_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final MainBloc _bloc;

  @override
  void initState() {
    super.initState();
    // 透過 DI 注入 Service 來初始化 Bloc
    _bloc = MainBloc(sl<MainService>());
    // 發送初始事件
    _bloc.add(const InitEvent());
  }

  @override
  void dispose() {
    // 關閉 Bloc
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MultiBlocListener(
        listeners: [
          // 狀態監聽範例，例如：處理 Dialog、SnackBar、導航
          BlocListener<MainBloc, MainState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == MainStatus.failure) {
                // 顯示錯誤訊息範例
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state.status == MainStatus.success) {
                // 處理成功後邏輯
              }
            },
          ),
        ],
        child: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MainState state) {
    if (state.status == MainStatus.init || state.status == MainStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // UI Layout 呈現
        Center(
          child: Text('Current Status: ${state.status}'),
        ),
      ],
    );
  }
}
