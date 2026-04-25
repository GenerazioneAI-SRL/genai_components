part of '../cl_text_field.widget.dart';

/// File picker integration. Preserves §2.1.3 + §2.3.1 mounted guards and
/// the `isPicking` re-entry guard.
class _TextFieldFileHelper extends _Helper {
  _TextFieldFileHelper(super.s);

  Future<void> pick(BuildContext context) async {
    if (s.isPicking) return;
    // ignore: invalid_use_of_protected_member
    s.setState(() => s.isPicking = true);
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (!s.mounted) return;
    // ignore: invalid_use_of_protected_member
    s.setState(() => s.isPicking = false);

    if (result != null) {
      final PlatformFile pf = result.files.first;
      if (!kIsWeb) {
        w.onFilePicked!(File(pf.path!));
      } else {
        w.onFilePicked!(null);
      }
      // ignore: invalid_use_of_protected_member
      s.setState(() => s.isFilePicked = true);
      s.controllerRef.text = pf.name;
    }
  }
}
