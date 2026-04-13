import 'package:flutter/material.dart';

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
