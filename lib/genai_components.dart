/// Genai Components — UI component library for GenerazioneAI projects.
///
/// Single canonical design system: **v3 Forma LMS** (light-first; dark-capable
/// presets ship in v3.1). All public symbols carry the `Genai*` prefix.
library;

// ─── Tokens ─────────────────────────────────────────────────────────────────
export 'src/tokens/tokens.dart';

// ─── Theme ──────────────────────────────────────────────────────────────────
export 'src/theme/theme_extension.dart';
export 'src/theme/theme_builder.dart';
export 'src/theme/presets.dart';
export 'src/theme/context_extensions.dart';

// ─── Foundations ────────────────────────────────────────────────────────────
export 'src/foundations/responsive.dart';
export 'src/foundations/animations.dart';
export 'src/foundations/icons.dart';
export 'src/foundations/genai_direction.dart';

// ─── Components — Actions ───────────────────────────────────────────────────
export 'src/components/actions/genai_button.dart';
export 'src/components/actions/genai_button_group.dart';
export 'src/components/actions/genai_copy_button.dart';
export 'src/components/actions/genai_fab.dart';
export 'src/components/actions/genai_icon_button.dart';
export 'src/components/actions/genai_link_button.dart';
export 'src/components/actions/genai_split_button.dart';
export 'src/components/actions/genai_toggle_button.dart';
export 'src/components/actions/genai_toggle_button_group.dart';

// ─── Components — Indicators ────────────────────────────────────────────────
export 'src/components/indicators/genai_avatar.dart';
export 'src/components/indicators/genai_avatar_group.dart';
export 'src/components/indicators/genai_badge.dart';
export 'src/components/indicators/genai_chip.dart';
export 'src/components/indicators/genai_kbd.dart';
export 'src/components/indicators/genai_progress_ring.dart';
export 'src/components/indicators/genai_status_badge.dart';
export 'src/components/indicators/genai_trend_indicator.dart';

// ─── Components — Feedback ──────────────────────────────────────────────────
export 'src/components/feedback/genai_alert.dart';
export 'src/components/feedback/genai_circular_progress.dart';
export 'src/components/feedback/genai_empty_state.dart';
export 'src/components/feedback/genai_error_state.dart';
export 'src/components/feedback/genai_progress_bar.dart';
export 'src/components/feedback/genai_skeleton.dart';
export 'src/components/feedback/genai_spinner.dart';
export 'src/components/feedback/genai_toast.dart';

// ─── Components — Inputs ────────────────────────────────────────────────────
export 'src/components/inputs/genai_checkbox.dart';
export 'src/components/inputs/genai_color_picker.dart';
export 'src/components/inputs/genai_combobox.dart';
export 'src/components/inputs/genai_date_picker.dart';
export 'src/components/inputs/genai_field.dart';
export 'src/components/inputs/genai_file_upload.dart';
export 'src/components/inputs/genai_input_group.dart';
export 'src/components/inputs/genai_label.dart';
export 'src/components/inputs/genai_native_select.dart';
export 'src/components/inputs/genai_otp_input.dart';
export 'src/components/inputs/genai_radio.dart';
export 'src/components/inputs/genai_select.dart';
export 'src/components/inputs/genai_slider.dart';
export 'src/components/inputs/genai_tag_input.dart';
export 'src/components/inputs/genai_text_field.dart';
export 'src/components/inputs/genai_textarea.dart';
export 'src/components/inputs/genai_toggle.dart';

// ─── Components — Layout ────────────────────────────────────────────────────
export 'src/components/layout/genai_accordion.dart';
export 'src/components/layout/genai_aspect_ratio.dart';
export 'src/components/layout/genai_card.dart';
export 'src/components/layout/genai_collapsible.dart';
export 'src/components/layout/genai_divider.dart';
export 'src/components/layout/genai_resizable.dart';
export 'src/components/layout/genai_scroll_area.dart';
export 'src/components/layout/genai_section.dart';

// ─── Components — Overlay ───────────────────────────────────────────────────
export 'src/components/overlay/genai_alert_dialog.dart';
export 'src/components/overlay/genai_context_menu.dart';
export 'src/components/overlay/genai_drawer.dart';
export 'src/components/overlay/genai_dropdown_menu.dart';
export 'src/components/overlay/genai_hover_card.dart';
export 'src/components/overlay/genai_modal.dart';
export 'src/components/overlay/genai_popover.dart';
export 'src/components/overlay/genai_sheet.dart';
export 'src/components/overlay/genai_tooltip.dart';

// ─── Components — Display ───────────────────────────────────────────────────
export 'src/components/display/genai_agenda_row.dart';
export 'src/components/display/genai_bar_row.dart';
export 'src/components/display/genai_calendar.dart';
export 'src/components/display/genai_carousel.dart';
export 'src/components/display/genai_focus_card.dart';
export 'src/components/display/genai_formation_card.dart';
export 'src/components/display/genai_item.dart';
export 'src/components/display/genai_kanban.dart';
export 'src/components/display/genai_kpi_card.dart';
export 'src/components/display/genai_list.dart';
export 'src/components/display/genai_sparkline.dart';
export 'src/components/display/genai_suggestion_item.dart';
export 'src/components/display/genai_table.dart';
export 'src/components/display/genai_timeline.dart';
export 'src/components/display/genai_tree_view.dart';
export 'src/components/display/genai_typography.dart';

// ─── Components — Charts ────────────────────────────────────────────────────
export 'src/components/charts/genai_bar_chart.dart';
export 'src/components/charts/genai_org_chart.dart';

// ─── Components — Navigation ────────────────────────────────────────────────
export 'src/components/navigation/genai_app_bar.dart';
export 'src/components/navigation/genai_ask_bar.dart';
export 'src/components/navigation/genai_bottom_nav.dart';
export 'src/components/navigation/genai_breadcrumb.dart';
export 'src/components/navigation/genai_command_palette.dart';
export 'src/components/navigation/genai_menubar.dart';
export 'src/components/navigation/genai_navigation_menu.dart';
export 'src/components/navigation/genai_navigation_rail.dart';
export 'src/components/navigation/genai_notification_center.dart';
export 'src/components/navigation/genai_pagination.dart';
export 'src/components/navigation/genai_shell.dart';
export 'src/components/navigation/genai_sidebar.dart';
export 'src/components/navigation/genai_stepper.dart';
export 'src/components/navigation/genai_tabs.dart';
export 'src/components/navigation/genai_topbar.dart';

// ─── Components — Survey (kept from v1) ─────────────────────────────────────
export 'src/components/survey/models/genai_survey_option.dart';
export 'src/components/survey/models/genai_survey_question.dart';
export 'src/components/survey/models/genai_survey_result.dart';
export 'src/components/survey/genai_survey.dart';
export 'src/components/survey/genai_survey_answer_choice.dart';
export 'src/components/survey/genai_survey_builder.dart';
export 'src/components/survey/genai_survey_builder_state.dart';
export 'src/components/survey/genai_survey_form_field.dart';
export 'src/components/survey/genai_survey_question_card.dart';
export 'src/components/survey/genai_survey_result_viewer.dart';
export 'src/components/survey/genai_survey_viewer.dart';

// ─── Components — AI Assistant (kept from v1) ───────────────────────────────
export 'src/components/ai_assistant/genai_ai_assistant.dart';

// ─── Scaffold — Router (go_router modular) ──────────────────────────────────
export 'src/scaffold/router/configure.dart';
export 'src/scaffold/router/module.dart';
export 'src/scaffold/router/page_data.dart';
export 'src/scaffold/router/page_transition.dart';
export 'src/scaffold/router/path_utils.dart';
export 'src/scaffold/router/resume_observer.dart';
export 'src/scaffold/router/route_registry.dart';
export 'src/scaffold/router/routes/child_route.dart';
export 'src/scaffold/router/routes/genai_route.dart';
export 'src/scaffold/router/routes/modular_route.dart';
export 'src/scaffold/router/routes/module_route.dart';
export 'src/scaffold/router/routes/shell_modular_route.dart';

// ─── Scaffold — Auth ────────────────────────────────────────────────────────
export 'src/scaffold/auth/genai_auth_state.dart';
export 'src/scaffold/auth/genai_tenant.dart';
export 'src/scaffold/auth/genai_user_info.dart';

// ─── Scaffold — Providers ───────────────────────────────────────────────────
export 'src/scaffold/providers/genai_app_state.dart';
export 'src/scaffold/providers/genai_error_state.dart';
export 'src/scaffold/providers/genai_notifications_panel_state.dart';

// ─── Scaffold — Pages ───────────────────────────────────────────────────────
export 'src/scaffold/genai_error_page.dart';

// ─── Utils ──────────────────────────────────────────────────────────────────
export 'src/utils/genai_access_state.dart';
export 'src/utils/genai_form_controller.dart';
export 'src/utils/genai_formatters.dart';
export 'src/utils/genai_validators.dart';
