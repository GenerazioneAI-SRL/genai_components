part of 'alert_manager.dart';

class _OverlayBody extends StatefulWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final void Function() onClosed; // Callback per chiudere l'overlay
  final Function()? onTap;
  final AlertPosition alertPosition;
  final AlertType alertType;
  final BehaviorSubject<double>? downloadPercentageStream;
  final bool closeOnTap;

  const _OverlayBody(
      {required this.title,
        required this.message,
        required this.backgroundColor,
        required this.textColor,
        required this.onClosed,
        required this.onTap,
        required this.closeOnTap,
        required this.alertPosition,
        required this.downloadPercentageStream,
        required this.alertType});

  @override
  _OverlayBodyState createState() => _OverlayBodyState();
}

class _OverlayBodyState extends State<_OverlayBody> with SingleTickerProviderStateMixin {
  double? top, bottom, left, right;
  final animationDuration = Duration(milliseconds: 200);
  late AnimationController controller;
  late Animation<double> positionAnimation;
  Timer? _timer; // Timer per la chiusura automatica

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: animationDuration);

    // Configura la posizione e l'animazione in base all'alertPosition
    switch (widget.alertPosition) {
      case AlertPosition.top:
        top = -100; // Parte fuori dallo schermo sopra
        left = Sizes.padding;
        right = Sizes.padding;
        positionAnimation = Tween<double>(begin: -100, end: Sizes.padding).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
        break;
      case AlertPosition.bottom:
        bottom = -100; // Parte fuori dallo schermo sotto
        left = Sizes.padding;
        right = Sizes.padding;
        positionAnimation = Tween<double>(begin: -100, end: Sizes.padding).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
        break;
      case AlertPosition.leftTopCorner:
        top = Sizes.padding;
        left = -200; // Parte fuori dallo schermo a sinistra
        positionAnimation = Tween<double>(begin: -200, end: Sizes.padding).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
        break;
      case AlertPosition.rightTopCorner:
        top = Sizes.padding;
        right = -200; // Parte fuori dallo schermo a destra
        positionAnimation = Tween<double>(begin: -200, end: Sizes.padding).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
        break;
      case AlertPosition.leftBottomCorner:
        bottom = Sizes.padding;
        left = -200; // Parte fuori dallo schermo a sinistra
        positionAnimation = Tween<double>(begin: -200, end: Sizes.padding).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
        break;
      case AlertPosition.rightBottomCorner:
        bottom = Sizes.padding;
        right = -200; // Parte fuori dallo schermo a destra
        positionAnimation = Tween<double>(begin: -200, end: Sizes.padding).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOut),
        );
        break;
    }

    controller.forward();
    if (widget.alertType != AlertType.download) {
      // Inizializza e avvia il timer per la chiusura automatica
      _timer = Timer(Duration(seconds: 5), () {
        _close();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: positionAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                top: widget.alertPosition == AlertPosition.top ? positionAnimation.value : top,
                bottom: widget.alertPosition == AlertPosition.bottom ? positionAnimation.value : bottom,
                left: widget.alertPosition == AlertPosition.leftTopCorner || widget.alertPosition == AlertPosition.leftBottomCorner
                    ? positionAnimation.value
                    : left,
                right: widget.alertPosition == AlertPosition.rightTopCorner || widget.alertPosition == AlertPosition.rightBottomCorner
                    ? positionAnimation.value
                    : right,
                child: GestureDetector(
                  onTap: () {
                    if (widget.closeOnTap) {
                      _close();
                    }
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: IntrinsicWidth(
                      child: _buildAlertContent(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertContent() {
    switch (widget.alertType) {
      case AlertType.primary:
        return CLAlert.border(
          widget.title,
          widget.message,
          backgroundColor: CLTheme.of(context).primary,
          onClose: () {
            _close();
          },
        );
      case AlertType.secondary:
        return CLAlert.border(
          widget.title,
          widget.message,
          backgroundColor: CLTheme.of(context).secondary,
          onClose: () {
            _close();
          },
        );
      case AlertType.success:
        return CLAlert.border(
          widget.title,
          widget.message,
          icon: FontAwesomeIcons.check,
          backgroundColor: CLTheme.of(context).success,
          onClose: () {
            _close();
          },
        );
      case AlertType.danger:
        return CLAlert.border(
          widget.title,
          widget.message,
          icon: FontAwesomeIcons.triangleExclamation,
          backgroundColor: CLTheme.of(context).danger,
          onClose: () {
            _close();
          },
        );
      case AlertType.warning:
        return CLAlert.border(
          widget.title,
          widget.message,
          icon: FontAwesomeIcons.triangleExclamation,
          backgroundColor: CLTheme.of(context).warning,
          onClose: () {
            _close();
          },
        );
      case AlertType.info:
        return CLAlert.border(
          widget.title,
          widget.message,
          icon: FontAwesomeIcons.info,
          backgroundColor: CLTheme.of(context).info,
          onClose: () {
            _close();
          },
        );
      case AlertType.notification:
        return CLAlert.border(
          widget.title,
          widget.message,
          //foregroundColor: Colors.white,
          icon: FontAwesomeIcons.bell,
          backgroundColor: CLTheme.of(context).info,
          onClose: () {
            _close();
          },
        );
      case AlertType.download:
        return CLAlert.download(
          widget.title,
          widget.message,
          icon: FontAwesomeIcons.info,
          backgroundColor: CLTheme.of(context).info,
          downloadPercentageStream: widget.downloadPercentageStream!,
          onClose: () {
            _close();
          },
        );
    }
  }

  void _close() {
    // Verifica e annulla il timer se è attivo
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    controller.reverse().then((value) {
      widget.onClosed();
    });
  }

  @override
  void dispose() {
    // Verifica e annulla il timer se è attivo
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    controller.dispose();
    super.dispose();
  }
}
