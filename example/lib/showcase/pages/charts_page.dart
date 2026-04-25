import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class _WeekPoint {
  final String w;
  final double h;
  const _WeekPoint(this.w, this.h);
}

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  static const _weekly = <_WeekPoint>[
    _WeekPoint('S-7', 3.2),
    _WeekPoint('S-6', 4.1),
    _WeekPoint('S-5', 5.0),
    _WeekPoint('S-4', 3.8),
    _WeekPoint('S-3', 4.5),
    _WeekPoint('S-2', 5.2),
    _WeekPoint('S-1', 6.0),
    _WeekPoint('S0', 6.5),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Charts',
      description: 'GenaiBarChart — ore settimanali in varie configurazioni.',
      children: [
        ShowcaseSection(
          title: 'Bar chart — default (ink)',
          child: SizedBox(
            height: 260,
            child: GenaiBarChart<_WeekPoint>(
              data: _weekly,
              xValueMapper: (w, _) => w.w,
              yValueMapper: (w, _) => w.h,
              yAxisLabel: 'Ore',
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Bar chart — colorato info',
          child: SizedBox(
            height: 260,
            child: GenaiBarChart<_WeekPoint>(
              data: _weekly,
              xValueMapper: (w, _) => w.w,
              yValueMapper: (w, _) => w.h,
              barColor: context.colors.colorInfo,
              showGrid: false,
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Bar chart — compatto',
          child: SizedBox(
            height: 160,
            child: GenaiBarChart<_WeekPoint>(
              data: _weekly,
              xValueMapper: (w, _) => w.w,
              yValueMapper: (w, _) => w.h,
              barColor: context.colors.colorSuccess,
              barWidth: 10,
            ),
          ),
        ),
      ],
    );
  }
}
