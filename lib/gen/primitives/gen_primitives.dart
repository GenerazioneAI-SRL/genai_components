import 'package:shadcn_ui/shadcn_ui.dart';

/// Gen* primitives = 1:1 aliases over shadcn_ui. `GenButton` IS `ShadButton`:
/// same constructors (incl. named like `.secondary`), same params, zero
/// boilerplate. Theming comes from the [GenTheme] ancestor. When a primitive
/// needs to diverge, replace its typedef here with a real wrapper class.
typedef GenApp = ShadApp;
typedef GenButton = ShadButton;
typedef GenIconButton = ShadIconButton;
typedef GenInput = ShadInput;
typedef GenInputFormField = ShadInputFormField;
typedef GenTextarea = ShadTextarea;
typedef GenSelect<T> = ShadSelect<T>;
typedef GenOption<T> = ShadOption<T>;
typedef GenCheckbox = ShadCheckbox;
typedef GenCheckboxFormField = ShadCheckboxFormField;
typedef GenSwitch = ShadSwitch;
typedef GenRadioGroup<T> = ShadRadioGroup<T>;
typedef GenRadio<T> = ShadRadio<T>;
typedef GenSlider = ShadSlider;
typedef GenBadge = ShadBadge;
typedef GenCard = ShadCard;
typedef GenAvatar = ShadAvatar;
typedef GenAlert = ShadAlert;
typedef GenAccordion<T> = ShadAccordion<T>;
typedef GenAccordionItem<T> = ShadAccordionItem<T>;
typedef GenTabs<T> = ShadTabs<T>;
typedef GenTab<T> = ShadTab<T>;
typedef GenTooltip = ShadTooltip;
typedef GenProgress = ShadProgress;
typedef GenSeparator = ShadSeparator;
typedef GenTable = ShadTable;

// Overlay / menu
typedef GenDialog = ShadDialog;
typedef GenSheet = ShadSheet;
typedef GenPopover = ShadPopover;
typedef GenPopoverController = ShadPopoverController;
typedef GenContextMenu = ShadContextMenu;
typedef GenContextMenuItem = ShadContextMenuItem;
typedef GenMenubar = ShadMenubar;
typedef GenMenubarItem = ShadMenubarItem;
typedef GenToast = ShadToast;
typedef GenSonner = ShadSonner;

// Picker / data
typedef GenDatePicker = ShadDatePicker;
typedef GenTimePicker = ShadTimePicker;
typedef GenCalendar = ShadCalendar;

// Form / input
typedef GenForm = ShadForm;
typedef GenInputOtp = ShadInputOTP;
typedef GenInputOtpGroup = ShadInputOTPGroup;
typedef GenInputOtpSlot = ShadInputOTPSlot;

// Nav / misc
typedef GenBreadcrumb = ShadBreadcrumb;
typedef GenBreadcrumbLink = ShadBreadcrumbLink;
typedef GenResizablePanelGroup = ShadResizablePanelGroup;
typedef GenResizablePanel = ShadResizablePanel;

// Form field family (varianti form-bound dei widget; usate dentro GenForm).
typedef GenSelectFormField<T> = ShadSelectFormField<T>;
typedef GenSelectMultipleFormField<T> = ShadSelectMultipleFormField<T>;
typedef GenRadioGroupFormField<T> = ShadRadioGroupFormField<T>;
typedef GenSwitchFormField = ShadSwitchFormField;
typedef GenTextareaFormField = ShadTextareaFormField;
typedef GenDatePickerFormField = ShadDatePickerFormField;
typedef GenDateRangePickerFormField = ShadDateRangePickerFormField;
typedef GenTimePickerFormField = ShadTimePickerFormField;
typedef GenInputOtpFormField = ShadInputOTPFormField;

// Utility wrapper (ShadDisabled NON è esportato dal barrel → niente alias).
typedef GenResponsiveBuilder = ShadResponsiveBuilder;

// Sotto-componenti / accessor / enum (alias per usare SOLO nomi Gen nel codice).
typedef GenTableCell = ShadTableCell;
typedef GenToaster = ShadToaster;
typedef GenContextMenuRegion = ShadContextMenuRegion;
typedef GenBreadcrumbSeparator = ShadBreadcrumbSeparator;
typedef GenBreadcrumbEllipsis = ShadBreadcrumbEllipsis;
typedef GenBreadcrumbDropdown = ShadBreadcrumbDropdown;
typedef GenBreadcrumbDropMenuItem = ShadBreadcrumbDropMenuItem;
typedef GenAnchor = ShadAnchor;
typedef GenAnchorBase = ShadAnchorBase;
typedef GenFormState = ShadFormState;
typedef GenTimeOfDay = ShadTimeOfDay;
typedef GenDateTimeRange = ShadDateTimeRange;

// Enum
typedef GenButtonVariant = ShadButtonVariant;
typedef GenButtonSize = ShadButtonSize;
typedef GenBadgeVariant = ShadBadgeVariant;
typedef GenSheetSide = ShadSheetSide;
typedef GenCalendarCaptionLayout = ShadCalendarCaptionLayout;
typedef GenDayPeriod = ShadDayPeriod;
