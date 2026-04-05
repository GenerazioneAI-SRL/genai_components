/// CL Components — UI component library for Generazione AI projects.
library cl_components;

// Theme
export 'cl_theme.dart';

// Layout
export 'layout/constants/sizes.constant.dart';

// Buttons
export 'widgets/buttons/cl_button.widget.dart';
export 'widgets/buttons/cl_outline_button.widget.dart';
export 'widgets/buttons/cl_ghost_button.widget.dart';
export 'widgets/buttons/cl_soft_button.widget.dart';
export 'widgets/buttons/cl_action_text.widget.dart';
export 'widgets/buttons/cl_confirm_dialog.dart';

// Layout widgets
export 'widgets/cl_card.widget.dart';
export 'widgets/cl_container.widget.dart';
export 'widgets/cl_divider.widget.dart';
export 'widgets/cl_section_card.widget.dart';

// Form
export 'widgets/cl_text_field.widget.dart';
export 'widgets/cl_checkbox.widget.dart';
export 'widgets/cl_dropdown/cl_dropdown.dart';
export 'widgets/cl_file_picker.widget.dart';

// Data display
export 'widgets/avatar.widget.dart';
export 'widgets/cl_clipboard.widget.dart';
export 'widgets/cl_code_text.widget.dart';
export 'widgets/cl_pill.widget.dart';
export 'widgets/cl_role_badge.widget.dart';
export 'widgets/cl_status_badge.widget.dart';
export 'widgets/cl_media_viewer.widget.dart';

// Navigation
export 'widgets/cl_page_header.widget.dart';
export 'widgets/cl_pagination.widget.dart';
export 'widgets/cl_popup_menu.widget.dart';
export 'widgets/cl_view_toggle.widget.dart';
export 'widgets/cl_tabs/cl_tab_view.widget.dart';

// Feedback
export 'widgets/cl_alert.widget.dart';
export 'widgets/cl_info_banner.widget.dart';
export 'widgets/alertmanager/alert_manager.dart';

// Progress
export 'widgets/cl_lifecycle_progress.widget.dart';
export 'widgets/cl_confirm_refuse_buttons.widget.dart';

// States
export 'widgets/cl_shimmer.widget.dart';
export 'widgets/loading.widget.dart';

// Calendar
export 'widgets/cl_calendar.widget.dart';
export 'widgets/cl_month_calendar.widget.dart';

// Charts
export 'widgets/charts/cl_bar_chart.widget.dart';
export 'widgets/charts/cl_pie_chart.widget.dart';
export 'widgets/charts/cl_spline_chart.widget.dart';
export 'widgets/charts/cl_spline_area_chart.widget.dart';

// Data table
export 'widgets/paged_datatable/paged_datatable.dart';

// Org chart
export 'widgets/cl_org_chart/org_chart.dart';

// Survey
export 'widgets/cl_survey/survey.dart';

// Grid
export 'widgets/cl_responsive_grid/flutter_responsive_flex_grid.dart';

// Utils
export 'utils/shared_manager.util.dart';
export 'utils/providers/cl_theme.provider.dart';
export 'utils/providers/module_theme.util.provider.dart';
export 'utils/models/custom_model.model.dart';

// Auth (interfacce astratte)
export 'auth/cl_auth_state.dart';
export 'auth/cl_user_info.dart';
export 'auth/cl_tenant.dart';
// App
export 'app/cl_app.dart';
export 'app/cl_app_config.dart';

// Router
export 'router/go_router_modular/module.dart';
export 'router/go_router_modular/go_router_modular_configure.dart';
export 'router/go_router_modular/cl_path_utils.dart';
export 'router/go_router_modular/page_transition_enum.dart';
export 'router/go_router_modular/route_registry.dart';
export 'router/go_router_modular/routes/child_route.dart';
export 'router/go_router_modular/routes/cl_route.dart';
export 'router/go_router_modular/routes/i_modular_route.dart';
export 'router/go_router_modular/routes/module_route.dart';
export 'router/go_router_modular/routes/shell_modular_route.dart';
export 'router/resume_observer.dart';
export 'router/page_data.dart';

// Layout
export 'layout/app.layout.dart';
export 'layout/menu.layout.dart';
export 'layout/header.layout.dart';
export 'layout/footer.layout.dart';
export 'layout/breadcrumbs.layout.dart';

// API
export 'api/api_manager.dart';

// Providers
export 'providers/app_state.dart';
export 'providers/error_state.dart';
export 'providers/theme_provider.dart';

// Core Utils
export 'core_utils/base_viewmodel.dart';
export 'core_utils/extension.util.dart' hide DownloadExtension;
export 'core_utils/navigation_observer.dart';

// Core Models
export 'core_models/upload_file.model.dart';
export 'core_models/media.model.dart';
