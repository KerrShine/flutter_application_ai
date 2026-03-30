import 'package:flutter/material.dart';

class EmpManagerGuideHeaderWidget extends StatelessWidget {
  const EmpManagerGuideHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '職員設定首頁教學',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '這個頁面集中整理建置順序與前置條件，主頁只保留功能入口，避免首頁資訊過重。',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black87,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}
