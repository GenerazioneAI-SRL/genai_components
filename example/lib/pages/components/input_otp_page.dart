import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/gen/gen.dart' hide WidgetBuilder;

import '../../shared/demo_page.dart';

/// Showcase esaustiva di [GenInputOtp] (=GenInputOtp) + [GenInputOtpGroup]
/// (=GenInputOtpGroup) + [GenInputOtpSlot] (=GenInputOtpSlot).
///
/// Copre: 6 cifre in 2 gruppi da 3 con separatore, 4 cifre in un solo gruppo,
/// gruppo unico da 6, valore iniziale, solo numeri (inputFormatters),
/// keyboardType numerica, `onChanged` live, "onCompleted" (derivato da onChanged
/// quando tutti gli slot sono pieni — GenInputOtp non espone un callback
/// dedicato), `jumpToNextWhenFilled: false`, `gap` custom e disabilitato.
class InputOtpShowcase extends StatefulWidget {
  const InputOtpShowcase({super.key});

  @override
  State<InputOtpShowcase> createState() => _InputOtpShowcaseState();
}

class _InputOtpShowcaseState extends State<InputOtpShowcase> {
  String _live = '';
  String? _completed;

  /// Solo cifre 0-9 per ogni slot.
  static final _digitsOnly = FilteringTextInputFormatter.digitsOnly;

  /// Separatore visivo tra due gruppi.
  Widget _dash(GenTokens t) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(LucideIcons.minus, size: 16, color: t.secondaryText),
      );

  /// Costruisce N slot per un gruppo.
  List<Widget> _slots(int n) => List.generate(n, (_) => const GenInputOtpSlot());

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);

    return DemoPage(
      children: [
        // ── 1. Base 6 cifre, 2 gruppi da 3 con separatore ───────────────────
        DemoGroup(
          title: 'Base — 6 cifre',
          description:
              '2 gruppi da 3 slot separati da un divisore. maxLength: 6, '
              'keyboardType numerica, solo cifre.',
          items: [
            DemoTile(
              label: '2 gruppi da 3 + separatore',
              child: GenInputOtp(
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [_digitsOnly],
                children: [
                  GenInputOtpGroup(children: _slots(3)),
                  _dash(t),
                  GenInputOtpGroup(children: _slots(3)),
                ],
              ),
            ),
          ],
        ),

        // ── 2. 4 cifre ──────────────────────────────────────────────────────
        DemoGroup(
          title: '4 cifre',
          description: 'Un solo gruppo da 4 slot. maxLength: 4.',
          items: [
            DemoTile(
              label: 'gruppo unico da 4',
              child: GenInputOtp(
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [_digitsOnly],
                children: [
                  GenInputOtpGroup(children: _slots(4)),
                ],
              ),
            ),
          ],
        ),

        // ── 3. onChanged live + onCompleted ─────────────────────────────────
        DemoGroup(
          title: 'onChanged / onCompleted',
          description:
              'onChanged riporta il valore ad ogni battitura (gli slot vuoti '
              'sono spazi). "Completato" scatta quando tutti i 6 slot sono pieni '
              '(nessuno spazio) — derivato da onChanged.',
          items: [
            DemoTile(
              label: 'live value + completamento',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenInputOtp(
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_digitsOnly],
                    onChanged: (v) {
                      setState(() {
                        _live = v;
                        _completed =
                            (v.length == 6 && !v.contains(' ')) ? v : null;
                      });
                    },
                    children: [
                      GenInputOtpGroup(children: _slots(3)),
                      _dash(t),
                      GenInputOtpGroup(children: _slots(3)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('onChanged: "$_live"', style: t.smallText),
                  Text(
                    _completed == null
                        ? 'onCompleted: —'
                        : 'onCompleted: $_completed',
                    style: t.smallText.copyWith(
                      color: _completed == null ? t.secondaryText : t.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── 4. Valore iniziale ──────────────────────────────────────────────
        DemoGroup(
          title: 'Valore iniziale',
          description:
              'initialValue pre-riempie gli slot. Uno spazio salta uno slot.',
          items: [
            DemoTile(
              label: "initialValue: '123456'",
              child: GenInputOtp(
                maxLength: 6,
                initialValue: '123456',
                keyboardType: TextInputType.number,
                inputFormatters: [_digitsOnly],
                children: [
                  GenInputOtpGroup(children: _slots(3)),
                  _dash(t),
                  GenInputOtpGroup(children: _slots(3)),
                ],
              ),
            ),
          ],
        ),

        // ── 5. Gruppo unico da 6 ────────────────────────────────────────────
        DemoGroup(
          title: 'Gruppo unico da 6',
          description: 'Tutti gli slot in un solo gruppo, senza separatore.',
          items: [
            DemoTile(
              label: 'single group',
              child: GenInputOtp(
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [_digitsOnly],
                children: [
                  GenInputOtpGroup(children: _slots(6)),
                ],
              ),
            ),
          ],
        ),

        // ── 6. Opzioni: jumpToNextWhenFilled, gap ───────────────────────────
        DemoGroup(
          title: 'Opzioni',
          description:
              'jumpToNextWhenFilled: false (niente auto-avanzamento) e gap '
              'personalizzato tra gli slot.',
          items: [
            DemoTile(
              label: 'jumpToNextWhenFilled: false',
              child: GenInputOtp(
                maxLength: 4,
                jumpToNextWhenFilled: false,
                keyboardType: TextInputType.number,
                inputFormatters: [_digitsOnly],
                children: [
                  GenInputOtpGroup(children: _slots(4)),
                ],
              ),
            ),
            DemoTile(
              label: 'gap: 16',
              child: GenInputOtp(
                maxLength: 4,
                gap: 16,
                keyboardType: TextInputType.number,
                inputFormatters: [_digitsOnly],
                children: [
                  GenInputOtpGroup(children: _slots(4)),
                ],
              ),
            ),
          ],
        ),

        // ── 7. Disabilitato ─────────────────────────────────────────────────
        DemoGroup(
          title: 'Disabilitato',
          description: 'enabled: false — non interagibile.',
          items: [
            DemoTile(
              label: 'enabled: false',
              child: GenInputOtp(
                maxLength: 6,
                enabled: false,
                initialValue: '12  34',
                children: [
                  GenInputOtpGroup(children: _slots(3)),
                  _dash(t),
                  GenInputOtpGroup(children: _slots(3)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
