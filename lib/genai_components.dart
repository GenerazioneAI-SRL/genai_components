/// CL Components — UI component library for Generazione AI projects.
library genai_components;

// Theme
export 'cl_theme.dart';

// Layout
export 'layout/constants/sizes.constant.dart';

// Foundation (Tier 0 — primitivi di base condivisi)
export 'widgets/foundation/cl_pressable.widget.dart';
export 'widgets/foundation/cl_tone_style.dart';

// Buttons
export 'widgets/buttons/cl_button.widget.dart';
export 'widgets/buttons/cl_compact_action_scope.dart';
export 'widgets/buttons/cl_icon_button.widget.dart';
export 'widgets/buttons/cl_outline_button.widget.dart';
export 'widgets/buttons/cl_ghost_button.widget.dart';
export 'widgets/buttons/cl_soft_button.widget.dart';
export 'widgets/buttons/cl_action_text.widget.dart';
export 'widgets/buttons/cl_action_chip.widget.dart';
export 'widgets/buttons/cl_confirm_dialog.dart';

// Layout widgets
export 'widgets/cl_card.widget.dart';
export 'widgets/cl_container.widget.dart';
export 'widgets/cl_label_value.widget.dart';
export 'widgets/cl_input_group.widget.dart';
export 'widgets/cl_popup_surface.widget.dart';
export 'widgets/layout/cl_adaptive_shell.widget.dart';
export 'widgets/layout/cl_bottom_bar.widget.dart';
export 'widgets/layout/cl_destination.dart';
export 'widgets/layout/cl_nav_list.widget.dart';
export 'widgets/layout/cl_nav_rail.widget.dart';
export 'widgets/layout/cl_page_container.widget.dart';
export 'widgets/layout/cl_responsive_grid_shadcn.widget.dart';
export 'widgets/layout/cl_responsive_stack.widget.dart';
export 'widgets/layout/cl_shell_config.dart';
export 'widgets/layout/cl_shell_slots.dart';
export 'widgets/cl_divider.widget.dart';
export 'widgets/cl_separator.widget.dart';
export 'widgets/cl_section_card.widget.dart';
export 'widgets/cl_title.widget.dart';

// Form
export 'widgets/cl_text_field.widget.dart';
export 'widgets/cl_checkbox.widget.dart';
export 'widgets/cl_dropdown/cl_dropdown.dart';
export 'widgets/cl_dropdown/cl_dropdown_registry.dart';
export 'widgets/cl_file_picker.widget.dart';
export 'widgets/textfield_validator.dart';
export 'widgets/time_input_field.widget.dart';

// Data display
export 'widgets/avatar.widget.dart';
export 'widgets/cl_clipboard.widget.dart';
export 'widgets/cl_code_text.widget.dart';
export 'widgets/cl_pill.widget.dart';
export 'widgets/cl_role_badge.widget.dart';
export 'widgets/cl_status_badge.widget.dart';
export 'widgets/cl_summary_stat_card.widget.dart';
export 'widgets/cl_metric_card.widget.dart';
export 'widgets/cl_media_viewer.widget.dart';
export 'widgets/cl_media_attach.widget.dart';
export 'widgets/excerpt_text.widget.dart';
export 'widgets/table_action_item.widget.dart';
export 'widgets/cl_universal_repeatable.widget.dart';

// Navigation
export 'widgets/cl_pagination.widget.dart';
export 'widgets/cl_popup_menu.widget.dart';
export 'widgets/cl_view_toggle.widget.dart';
export 'widgets/cl_tabs/cl_tab_view.widget.dart';
export 'widgets/cl_tabs/cl_tab_item.model.dart';
export 'widgets/cl_entity_tabs/entity_domain.dart';
export 'widgets/cl_entity_tabs/entity_tab.model.dart';
export 'widgets/cl_entity_tabs/cl_entity_tabs.widget.dart';
export 'widgets/cl_sheet.widget.dart';

// Feedback
export 'widgets/cl_alert.widget.dart';
export 'widgets/cl_info_banner.widget.dart';
export 'widgets/cl_toast.widget.dart';
export 'widgets/alertmanager/alert_manager.dart';

// Progress
export 'widgets/cl_lifecycle_progress.widget.dart';
export 'widgets/cl_progress.widget.dart';
export 'widgets/cl_confirm_refuse_buttons.widget.dart';

// States
export 'widgets/cl_shimmer.widget.dart';
export 'widgets/cl_collapsible.widget.dart';
export 'widgets/cl_skeleton.widget.dart';
export 'widgets/loading.widget.dart';
export 'widgets/gradient_background.widget.dart';
export 'widgets/logo.widget.dart';
export 'widgets/cl_pdf_viewer.widget.dart';

// Calendar
export 'widgets/cl_month_calendar.widget.dart';

// Charts
export 'widgets/charts/cl_bar_chart.widget.dart';

// Data table
export 'widgets/paged_datatable/paged_datatable.dart';
export 'widgets/paged_datatable/column_builders.dart';

// Org chart
export 'widgets/cl_org_chart/org_chart.dart';

// Survey
export 'widgets/cl_survey/survey.dart';
export 'widgets/cl_survey/cl_survey_builder.widget.dart';
export 'widgets/cl_survey/cl_survey_viewer.widget.dart';
export 'widgets/cl_survey/cl_survey_result_viewer.widget.dart';
export 'widgets/cl_survey/models/question.dart';
export 'widgets/cl_survey/models/question_result.dart';

// Grid
export 'widgets/cl_responsive_grid/flutter_responsive_flex_grid.dart';

// Utils
export 'widgets/cl_tooltip_wrapper.widget.dart';
export 'utils/shared_manager.util.dart';
export 'utils/providers/cl_theme.provider.dart';
export 'utils/models/custom_model.model.dart';


// Core Models
export 'core_models/upload_file.model.dart';
export 'core_models/media.model.dart';

// Enums
export 'enums/resource_type.enum.dart';
export 'enums/message_role.enum.dart';
export 'enums/tool_name.enum.dart';

// AI Assistant
export 'widgets/cl_ai_assistant/src/core/ai_assistant_config.dart';
export 'widgets/cl_ai_assistant/src/core/ai_conversation_store.dart';
export 'widgets/cl_ai_assistant/src/llm/providers/openai_provider.dart';
export 'widgets/cl_ai_assistant/src/tools/tool_definition.dart';

// Command Palette
export 'widgets/cl_command/cl_command_item.model.dart';
export 'widgets/cl_command/cl_command.widget.dart';

// Dialogs
export 'widgets/cl_dialog.widget.dart';
export 'widgets/dialogs/qr_code_dialog.dart';
export 'widgets/dialogs/confirmation_dialog.dart';
export 'widgets/dialogs/assign_entities_modal.dart';
