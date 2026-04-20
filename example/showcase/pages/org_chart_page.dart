import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class _Employee {
  final String id;
  final String? managerId;
  final String name;
  final String role;
  const _Employee({
    required this.id,
    required this.name,
    required this.role,
    this.managerId,
  });
}

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({super.key});

  @override
  State<OrgChartPage> createState() => _OrgChartPageState();
}

class _OrgChartPageState extends State<OrgChartPage> {
  late final GenaiOrgChartController<_Employee> _controller;

  static const _data = [
    _Employee(id: '1', name: 'Alice Rossi', role: 'CEO'),
    _Employee(id: '2', name: 'Bruno Bianchi', role: 'CTO', managerId: '1'),
    _Employee(id: '3', name: 'Carla Verdi', role: 'COO', managerId: '1'),
    _Employee(id: '4', name: 'Davide Neri', role: 'Engineering Lead', managerId: '2'),
    _Employee(id: '5', name: 'Elena Gialli', role: 'Design Lead', managerId: '2'),
    _Employee(id: '6', name: 'Fabio Blu', role: 'Operations Lead', managerId: '3'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = GenaiOrgChartController<_Employee>(
      items: _data,
      idProvider: (e) => e.id,
      toProvider: (e) => e.managerId,
      boxSize: const Size(180, 90),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    return ListView(
      padding: EdgeInsets.all(spacing.s6),
      children: [
        ShowcaseSection(
          title: 'GenaiOrgChart',
          subtitle: 'Visualizzazione albero gerarchico con drag & drop, hide/show e zoom.',
          child: SizedBox(
            height: 520,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius.md),
              child: Container(
                color: c.surfaceCard,
                child: GenaiOrgChart<_Employee>(
                  controller: _controller,
                  isDraggable: false,
                  builder: (details) {
                    return Container(
                      decoration: BoxDecoration(
                        color: c.colorPrimarySubtle,
                        borderRadius: BorderRadius.circular(radius.md),
                        border: Border.all(color: c.colorPrimary),
                      ),
                      padding: EdgeInsets.all(spacing.s2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(details.item.name,
                              style: ty.bodyMd.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(details.item.role, style: ty.caption.copyWith(color: c.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
