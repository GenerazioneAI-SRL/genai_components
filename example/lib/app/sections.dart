import 'package:flutter/material.dart';

import '../pages/components/accordion_page.dart';
import '../pages/components/alert_page.dart';
import '../pages/components/avatar_page.dart';
import '../pages/components/badge_page.dart';
import '../pages/components/breadcrumb_page.dart';
import '../pages/components/button_page.dart';
import '../pages/components/calendar_page.dart';
import '../pages/components/card_page.dart';
import '../pages/components/checkbox_page.dart';
import '../pages/components/context_menu_page.dart';
import '../pages/components/event_calendar_page.dart';
import '../pages/components/date_picker_page.dart';
import '../pages/components/dialog_page.dart';
import '../pages/components/form_page.dart';
import '../pages/components/icon_button_page.dart';
import '../pages/components/input_otp_page.dart';
import '../pages/components/input_page.dart';
import '../pages/components/menubar_page.dart';
import '../pages/components/popover_page.dart';
import '../pages/components/progress_page.dart';
import '../pages/components/radio_page.dart';
import '../pages/components/resizable_page.dart';
import '../pages/components/segmented_page.dart';
import '../pages/components/select_page.dart';
import '../pages/components/separator_page.dart';
import '../pages/components/sheet_page.dart';
import '../pages/components/slider_page.dart';
import '../pages/components/sonner_page.dart';
import '../pages/components/switch_page.dart';
import '../pages/components/table_page.dart';
import '../pages/components/tabs_page.dart';
import '../pages/components/textarea_page.dart';
import '../pages/components/time_picker_page.dart';
import '../pages/components/toast_page.dart';
import '../pages/components/tooltip_page.dart';
import '../pages/components/utility_page.dart';

/// Voce di navigazione dello showcase: path go_router + etichetta/icona menu +
/// builder della pagina. Un'unica sorgente per costruire sia le route sia le
/// destination della sidebar.
@immutable
class NavSection {
  const NavSection({required this.path, required this.label, required this.icon, required this.builder});

  final String path;
  final String label;
  final IconData icon;
  final Widget Function() builder;
}

/// Registry showcase (componenti Gen). I moduli "esempio" (Users) hanno route
/// proprie fuori da qui (vedi `modules/users/users_module.dart`).
const List<NavSection> showcaseSections = [
  // Actions
  NavSection(path: '/button', label: 'Button', icon: Icons.smart_button, builder: ButtonShowcase.new),
  NavSection(path: '/icon-button', label: 'Icon Button', icon: Icons.adjust, builder: IconButtonShowcase.new),
  NavSection(path: '/badge', label: 'Badge', icon: Icons.label_outline, builder: BadgeShowcase.new),
  // Forms
  NavSection(path: '/input', label: 'Input', icon: Icons.text_fields, builder: InputShowcase.new),
  NavSection(path: '/textarea', label: 'Textarea', icon: Icons.notes, builder: TextareaShowcase.new),
  NavSection(path: '/select', label: 'Select', icon: Icons.arrow_drop_down_circle_outlined, builder: SelectShowcase.new),
  NavSection(path: '/checkbox', label: 'Checkbox', icon: Icons.check_box_outlined, builder: CheckboxShowcase.new),
  NavSection(path: '/switch', label: 'Switch', icon: Icons.toggle_on_outlined, builder: SwitchShowcase.new),
  NavSection(path: '/radio', label: 'Radio', icon: Icons.radio_button_checked, builder: RadioShowcase.new),
  NavSection(path: '/segmented', label: 'Segmented', icon: Icons.view_week_outlined, builder: SegmentedShowcase.new),
  NavSection(path: '/slider', label: 'Slider', icon: Icons.tune, builder: SliderShowcase.new),
  NavSection(path: '/input-otp', label: 'Input OTP', icon: Icons.pin_outlined, builder: InputOtpShowcase.new),
  NavSection(path: '/form', label: 'Form', icon: Icons.assignment_outlined, builder: FormShowcase.new),
  // Pickers
  NavSection(path: '/date-picker', label: 'Date Picker', icon: Icons.calendar_today, builder: DatePickerShowcase.new),
  NavSection(path: '/time-picker', label: 'Time Picker', icon: Icons.schedule, builder: TimePickerShowcase.new),
  NavSection(path: '/calendar', label: 'Calendar', icon: Icons.calendar_month, builder: CalendarShowcase.new),
  NavSection(path: '/event-calendar', label: 'Event Calendar', icon: Icons.event_note, builder: EventCalendarShowcase.new),
  // Feedback
  NavSection(path: '/alert', label: 'Alert', icon: Icons.warning_amber_outlined, builder: AlertShowcase.new),
  NavSection(path: '/progress', label: 'Progress', icon: Icons.linear_scale, builder: ProgressShowcase.new),
  NavSection(path: '/tooltip', label: 'Tooltip', icon: Icons.info_outline, builder: TooltipShowcase.new),
  NavSection(path: '/toast', label: 'Toast', icon: Icons.notifications_none, builder: ToastShowcase.new),
  NavSection(path: '/sonner', label: 'Sonner', icon: Icons.stacked_bar_chart, builder: SonnerShowcase.new),
  // Overlays
  NavSection(path: '/dialog', label: 'Dialog', icon: Icons.web_asset, builder: DialogShowcase.new),
  NavSection(path: '/sheet', label: 'Sheet', icon: Icons.vertical_split, builder: SheetShowcase.new),
  NavSection(path: '/popover', label: 'Popover', icon: Icons.chat_bubble_outline, builder: PopoverShowcase.new),
  NavSection(path: '/context-menu', label: 'Context Menu', icon: Icons.menu_open, builder: ContextMenuShowcase.new),
  NavSection(path: '/menubar', label: 'Menubar', icon: Icons.menu, builder: MenubarShowcase.new),
  // Layout
  NavSection(path: '/card', label: 'Card', icon: Icons.crop_square, builder: CardShowcase.new),
  NavSection(path: '/accordion', label: 'Accordion', icon: Icons.unfold_more, builder: AccordionShowcase.new),
  NavSection(path: '/tabs', label: 'Tabs', icon: Icons.tab, builder: TabsShowcase.new),
  NavSection(path: '/separator', label: 'Separator', icon: Icons.horizontal_rule, builder: SeparatorShowcase.new),
  NavSection(path: '/resizable', label: 'Resizable', icon: Icons.open_in_full, builder: ResizableShowcase.new),
  // Nav / data / media
  NavSection(path: '/breadcrumb', label: 'Breadcrumb', icon: Icons.more_horiz, builder: BreadcrumbShowcase.new),
  NavSection(path: '/avatar', label: 'Avatar', icon: Icons.account_circle_outlined, builder: AvatarShowcase.new),
  NavSection(path: '/table', label: 'Table', icon: Icons.grid_on, builder: TableShowcase.new),
  NavSection(path: '/utility', label: 'Utility', icon: Icons.build_outlined, builder: UtilityShowcase.new),
];
