import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _tabUnderline = 0;
  int _tabPill = 0;
  int _tabSegmented = 0;
  int _stepperIdx = 1;
  int _bottomIdx = 0;
  int _railIdx = 0;
  int _page = 3;
  late List<GenaiNotificationItem> _notifs;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _notifs = [
      GenaiNotificationItem(
        id: '1',
        title: 'Nuovo cliente registrato',
        body: 'Mario Rossi si è iscritto.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        level: GenaiNotificationLevel.success,
      ),
      GenaiNotificationItem(
        id: '2',
        title: 'Pagamento in attesa',
        body: 'Ordine #2451 in attesa da 2 ore.',
        timestamp: now.subtract(const Duration(hours: 2)),
        level: GenaiNotificationLevel.warning,
      ),
      GenaiNotificationItem(
        id: '3',
        title: 'Backup completato',
        timestamp: now.subtract(const Duration(days: 1)),
        level: GenaiNotificationLevel.info,
        isRead: true,
      ),
    ];
  }

  void _openCommandPalette() {
    showGenaiCommandPalette(context, commands: [
      GenaiCommand(
          id: 'new-customer',
          title: 'Crea nuovo cliente',
          icon: LucideIcons.userPlus,
          shortcut: 'N C',
          group: 'Azioni',
          onInvoke: () => showGenaiToast(context, message: 'Crea cliente invocato')),
      GenaiCommand(
          id: 'new-order',
          title: 'Crea nuovo ordine',
          icon: LucideIcons.shoppingCart,
          shortcut: 'N O',
          group: 'Azioni',
          onInvoke: () => showGenaiToast(context, message: 'Crea ordine invocato')),
      GenaiCommand(
          id: 'go-dashboard',
          title: 'Vai a Dashboard',
          icon: LucideIcons.layoutDashboard,
          group: 'Naviga',
          onInvoke: () => showGenaiToast(context, message: 'Apri dashboard')),
      GenaiCommand(
          id: 'go-settings',
          title: 'Impostazioni',
          icon: LucideIcons.settings,
          group: 'Naviga',
          onInvoke: () => showGenaiToast(context, message: 'Apri settings')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tabItems = <GenaiTabItem>[
      const GenaiTabItem(label: 'Panoramica', icon: LucideIcons.layoutDashboard),
      const GenaiTabItem(label: 'Attività', icon: LucideIcons.activity, badgeCount: 3),
      GenaiTabItem(label: 'Report', icon: LucideIcons.chartColumn),
      const GenaiTabItem(label: 'Disabilitato', isDisabled: true),
    ];

    return ShowcaseScaffold(
      title: 'Navigation',
      description: 'Tabs · Breadcrumb · Pagination · Stepper · BottomNav · NavigationRail · CommandPalette · NotificationCenter.',
      children: [
        ShowcaseSection(
          title: 'GenaiTabs — varianti',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseVariant(
                label: 'underline',
                child: GenaiTabs(
                  items: tabItems,
                  selectedIndex: _tabUnderline,
                  onChanged: (i) => setState(() => _tabUnderline = i),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'pill',
                child: GenaiTabs(
                  items: tabItems,
                  variant: GenaiTabsVariant.pill,
                  selectedIndex: _tabPill,
                  onChanged: (i) => setState(() => _tabPill = i),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'segmented · fullWidth',
                child: GenaiTabs(
                  items: const [
                    GenaiTabItem(label: 'Mese'),
                    GenaiTabItem(label: 'Trimestre'),
                    GenaiTabItem(label: 'Anno'),
                  ],
                  variant: GenaiTabsVariant.segmented,
                  isFullWidth: true,
                  selectedIndex: _tabSegmented,
                  onChanged: (i) => setState(() => _tabSegmented = i),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiBreadcrumb',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiBreadcrumb(items: [
                GenaiBreadcrumbItem(label: 'Home', icon: LucideIcons.house, onTap: () {}),
                GenaiBreadcrumbItem(label: 'Clienti', onTap: () {}),
                const GenaiBreadcrumbItem(label: 'Mario Rossi'),
              ]),
              const SizedBox(height: 12),
              GenaiBreadcrumb(
                maxVisible: 3,
                items: [
                  GenaiBreadcrumbItem(label: 'Home', onTap: () {}),
                  GenaiBreadcrumbItem(label: 'Sezione', onTap: () {}),
                  GenaiBreadcrumbItem(label: 'Sotto', onTap: () {}),
                  GenaiBreadcrumbItem(label: 'Più giù', onTap: () {}),
                  const GenaiBreadcrumbItem(label: 'Pagina'),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiPagination',
          child: GenaiPagination(
            currentPage: _page,
            totalPages: 12,
            onPageChanged: (p) => setState(() => _page = p),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiStepper',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseVariant(
                label: 'orizzontale',
                child: GenaiStepper(
                  currentStep: _stepperIdx,
                  onStepTap: (i) => setState(() => _stepperIdx = i),
                  steps: const [
                    GenaiStepperStep(title: 'Anagrafica', description: 'Dati personali'),
                    GenaiStepperStep(title: 'Indirizzi', description: 'Spedizione'),
                    GenaiStepperStep(title: 'Pagamento', description: 'Metodo'),
                    GenaiStepperStep(title: 'Conferma', description: 'Riepilogo'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ShowcaseVariant(
                label: 'verticale · con errore',
                child: SizedBox(
                  width: 360,
                  child: GenaiStepper(
                    currentStep: 2,
                    orientation: GenaiStepperOrientation.vertical,
                    steps: const [
                      GenaiStepperStep(title: 'Account creato', description: '2 minuti fa'),
                      GenaiStepperStep(title: 'Email verificata', description: 'Conferma ricevuta'),
                      GenaiStepperStep(title: 'Pagamento', description: 'Carta rifiutata', hasError: true),
                      GenaiStepperStep(title: 'Attivazione', description: 'In attesa di pagamento'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiBottomNav (preview)',
          child: SizedBox(
            width: 380,
            child: GenaiCard.outlined(
              padding: EdgeInsets.zero,
              child: GenaiBottomNav(
                selectedIndex: _bottomIdx,
                onChanged: (i) => setState(() => _bottomIdx = i),
                items: const [
                  GenaiBottomNavItem(icon: LucideIcons.house, label: 'Home'),
                  GenaiBottomNavItem(icon: LucideIcons.search, label: 'Cerca'),
                  GenaiBottomNavItem(icon: LucideIcons.bell, label: 'Notifiche', badgeCount: 5),
                  GenaiBottomNavItem(icon: LucideIcons.user, label: 'Profilo'),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiNavigationRail (preview)',
          child: SizedBox(
            height: 320,
            child: GenaiCard.outlined(
              padding: EdgeInsets.zero,
              child: GenaiNavigationRail(
                selectedIndex: _railIdx,
                onChanged: (i) => setState(() => _railIdx = i),
                items: const [
                  GenaiNavigationRailItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard'),
                  GenaiNavigationRailItem(icon: LucideIcons.users, label: 'Clienti', badgeCount: 12),
                  GenaiNavigationRailItem(icon: LucideIcons.fileText, label: 'Documenti'),
                  GenaiNavigationRailItem(icon: LucideIcons.settings, label: 'Settings'),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCommandPalette',
          subtitle: 'Premi Cmd/Ctrl+K oppure il bottone qui sotto.',
          child: GenaiButton.primary(label: 'Apri command palette', icon: LucideIcons.search, onPressed: _openCommandPalette),
        ),
        ShowcaseSection(
          title: 'GenaiNotificationCenter',
          child: SizedBox(
            width: 420,
            height: 360,
            child: GenaiCard.outlined(
              padding: EdgeInsets.zero,
              child: GenaiNotificationCenter(
                notifications: _notifs,
                onMarkRead: (id) => setState(() {
                  _notifs = _notifs
                      .map((n) => n.id == id
                          ? GenaiNotificationItem(
                              id: n.id,
                              title: n.title,
                              body: n.body,
                              timestamp: n.timestamp,
                              level: n.level,
                              isRead: true,
                              onTap: n.onTap,
                            )
                          : n)
                      .toList();
                }),
                onDismiss: (id) => setState(() => _notifs = _notifs.where((n) => n.id != id).toList()),
                onMarkAllRead: () => setState(() {
                  _notifs = _notifs
                      .map((n) => GenaiNotificationItem(
                            id: n.id,
                            title: n.title,
                            body: n.body,
                            timestamp: n.timestamp,
                            level: n.level,
                            isRead: true,
                            onTap: n.onTap,
                          ))
                      .toList();
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
