/// CL Components — UI component library for Generazione AI projects.
library genai_components;

// Theme
export 'old/cl_theme.dart';

// Layout
export 'old/layout/constants/sizes.constant.dart';

// Foundation (Tier 0 — primitivi di base condivisi)
export 'old/widgets/foundation/cl_pressable.widget.dart';
export 'old/widgets/foundation/cl_tone_style.dart';
export 'old/widgets/foundation/cl_focus_ring.dart';
export 'old/widgets/foundation/cl_surface.widget.dart';

// Buttons
export 'old/widgets/buttons/cl_button.widget.dart';
export 'old/widgets/buttons/cl_compact_action_scope.dart';
export 'old/widgets/buttons/cl_icon_button.widget.dart';
export 'old/widgets/buttons/cl_outline_button.widget.dart';
export 'old/widgets/buttons/cl_ghost_button.widget.dart';
export 'old/widgets/buttons/cl_soft_button.widget.dart';
export 'old/widgets/buttons/cl_link_button.widget.dart';
export 'old/widgets/buttons/cl_action_text.widget.dart';
export 'old/widgets/buttons/cl_action_chip.widget.dart';
export 'old/widgets/buttons/cl_confirm_dialog.dart';

// Layout widgets
export 'old/widgets/cl_card.widget.dart';
export 'old/widgets/cl_container.widget.dart';
export 'old/widgets/cl_label_value.widget.dart';
export 'old/widgets/cl_input_group.widget.dart';
export 'old/widgets/cl_popup_surface.widget.dart';
export 'old/widgets/layout/cl_adaptive_shell.widget.dart';
export 'old/widgets/layout/cl_bottom_bar.widget.dart';
export 'old/widgets/layout/cl_destination.dart';
export 'old/widgets/layout/cl_nav_list.widget.dart';
export 'old/widgets/layout/cl_nav_rail.widget.dart';
export 'old/widgets/layout/cl_page_container.widget.dart';
export 'old/widgets/layout/cl_responsive_grid_shadcn.widget.dart';
export 'old/widgets/layout/cl_responsive_stack.widget.dart';
export 'old/widgets/layout/cl_shell_config.dart';
export 'old/widgets/layout/cl_shell_slots.dart';
export 'old/widgets/cl_divider.widget.dart';
export 'old/widgets/cl_separator.widget.dart';
export 'old/widgets/cl_section_card.widget.dart';
export 'old/widgets/cl_title.widget.dart';

// Form
export 'old/widgets/cl_text_field.widget.dart';
export 'old/widgets/cl_checkbox.widget.dart';
export 'old/widgets/cl_switch.widget.dart';
export 'old/widgets/cl_dropdown/cl_dropdown.dart';
export 'old/widgets/cl_dropdown/cl_dropdown_registry.dart';
export 'old/widgets/cl_file_picker.widget.dart';
export 'old/widgets/textfield_validator.dart';
export 'old/widgets/time_input_field.widget.dart';

// Data display
export 'old/widgets/avatar.widget.dart';
export 'old/widgets/cl_clipboard.widget.dart';
export 'old/widgets/cl_code_text.widget.dart';
export 'old/widgets/cl_pill.widget.dart';
export 'old/widgets/cl_role_badge.widget.dart';
export 'old/widgets/cl_status_badge.widget.dart';
export 'old/widgets/cl_summary_stat_card.widget.dart';
export 'old/widgets/cl_metric_card.widget.dart';
export 'old/widgets/cl_media_viewer.widget.dart';
export 'old/widgets/cl_media_attach.widget.dart';
export 'old/widgets/excerpt_text.widget.dart';
export 'old/widgets/table_action_item.widget.dart';
export 'old/widgets/cl_universal_repeatable.widget.dart';

// Navigation
export 'old/widgets/cl_pagination.widget.dart';
export 'old/widgets/cl_popup_menu.widget.dart';
export 'old/widgets/cl_context_menu.widget.dart';
export 'old/widgets/cl_view_toggle.widget.dart';
export 'old/widgets/cl_tabs/cl_tab_view.widget.dart';
export 'old/widgets/cl_tabs/cl_tab_item.model.dart';
export 'old/widgets/cl_entity_tabs/entity_domain.dart';
export 'old/widgets/cl_entity_tabs/entity_tab.model.dart';
export 'old/widgets/cl_entity_tabs/cl_entity_tabs.widget.dart';
export 'old/widgets/cl_sheet.widget.dart';

// Feedback
export 'old/widgets/cl_alert.widget.dart';
export 'old/widgets/cl_info_banner.widget.dart';
export 'old/widgets/cl_toast.widget.dart';
export 'old/widgets/alertmanager/alert_manager.dart';

// Progress
export 'old/widgets/cl_lifecycle_progress.widget.dart';
export 'old/widgets/cl_progress.widget.dart';
export 'old/widgets/cl_confirm_refuse_buttons.widget.dart';

// States
export 'old/widgets/cl_empty_state.widget.dart';
export 'old/widgets/cl_shimmer.widget.dart';
export 'old/widgets/cl_collapsible.widget.dart';
export 'old/widgets/cl_skeleton.widget.dart';
export 'old/widgets/loading.widget.dart';
export 'old/widgets/gradient_background.widget.dart';
export 'old/widgets/logo.widget.dart';
export 'old/widgets/cl_pdf_viewer.widget.dart';

// Calendar
export 'old/widgets/cl_month_calendar.widget.dart';
export 'old/widgets/cl_calendar.widget.dart';
export 'old/widgets/cl_date_picker.widget.dart';

// Charts
export 'old/widgets/charts/cl_bar_chart.widget.dart';

// Data table
export 'old/widgets/paged_datatable/paged_datatable.dart';
export 'old/widgets/paged_datatable/column_builders.dart';

// Org chart
export 'old/widgets/cl_org_chart/org_chart.dart';

// Survey
export 'old/widgets/cl_survey/survey.dart';
export 'old/widgets/cl_survey/cl_survey_builder.widget.dart';
export 'old/widgets/cl_survey/cl_survey_viewer.widget.dart';
export 'old/widgets/cl_survey/cl_survey_result_viewer.widget.dart';
export 'old/widgets/cl_survey/models/question.dart';
export 'old/widgets/cl_survey/models/question_result.dart';

// Node graph (widget data-driven custom: Stack + CustomPaint)
export 'old/src/widgets/cl_node_graph/cl_graph_models.dart';
export 'old/src/widgets/cl_node_graph/cl_graph_layout.dart' show clHierarchicalLayout, clPrereqFlowLayout, clModuleFlowLayout, classifyGraphLink, CLGraphLinkRole;
export 'old/src/widgets/cl_node_graph/cl_node_graph.widget.dart';

// Grid
export 'old/widgets/cl_responsive_grid/flutter_responsive_flex_grid.dart';

// Utils
export 'old/widgets/cl_tooltip_wrapper.widget.dart';
export 'old/utils/shared_manager.util.dart';
export 'old/utils/providers/cl_theme.provider.dart';
export 'old/utils/models/custom_model.model.dart';


// Core Models
export 'old/core_models/upload_file.model.dart';
export 'old/core_models/media.model.dart';

// Enums
export 'old/enums/resource_type.enum.dart';
export 'old/enums/message_role.enum.dart';
export 'old/enums/tool_name.enum.dart';

// AI Assistant
export 'old/widgets/cl_ai_assistant/src/core/ai_assistant_config.dart';
export 'old/widgets/cl_ai_assistant/src/core/ai_conversation_store.dart';
export 'old/widgets/cl_ai_assistant/src/llm/providers/openai_provider.dart';
export 'old/widgets/cl_ai_assistant/src/tools/tool_definition.dart';

// Command Palette
export 'old/widgets/cl_command/cl_command_item.model.dart';
export 'old/widgets/cl_command/cl_command.widget.dart';

// Dialogs
export 'old/widgets/cl_dialog.widget.dart';
export 'old/widgets/dialogs/qr_code_dialog.dart';
export 'old/widgets/dialogs/confirmation_dialog.dart';
export 'old/widgets/dialogs/assign_entities_modal.dart';
