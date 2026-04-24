import 'package:flutter/material.dart';

/// 動作綁定中間工作區的空白佔位 Widget。
/// 當左側尚未選取任何互動來源元件時顯示提示文字，引導使用者操作。
class ActionBindingEmptyWorkbenchWidget extends StatelessWidget {
  const ActionBindingEmptyWorkbenchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '請先從左側選擇一個可觸發元件，再選擇事件節點。',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
