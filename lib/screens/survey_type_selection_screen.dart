import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/utils/theme.dart';

enum SurveyType {
  bai,
  bdi,
  whoqol,
  moca,
  sf36,
  assist,
}

extension SurveyTypeExtension on SurveyType {
  String get code {
    switch (this) {
      case SurveyType.bai:
        return 'BAI';
      case SurveyType.bdi:
        return 'BDI-II';
      case SurveyType.moca:
        return 'MoCA';
      case SurveyType.whoqol:
        return 'WHOQOL-BREF';
      case SurveyType.sf36:
        return 'SF-36';
      case SurveyType.assist:
        return 'ASSIST V3.0';
    }
  }

  String get englishName {
    switch (this) {
      case SurveyType.bai:
        return 'Beck Anxiety Inventory';
      case SurveyType.bdi:
        return 'Beck Depression Inventory — Segunda Edición';
      case SurveyType.moca:
        return 'Montreal Cognitive Assessment';
      case SurveyType.whoqol:
        return 'World Health Organization Quality of Life';
      case SurveyType.sf36:
        return 'Short Form 36 Health Survey';
      case SurveyType.assist:
        return 'Alcohol, Smoking and Substance Involvement Screening Test';
    }
  }

  String get spanishName {
    switch (this) {
      case SurveyType.bai:
        return 'Inventario de Ansiedad de Beck';
      case SurveyType.bdi:
        return 'Inventario de Depresión de Beck';
      case SurveyType.moca:
        return 'Evaluación Cognitiva Montreal';
      case SurveyType.whoqol:
        return 'Cuestionario de Calidad de Vida';
      case SurveyType.sf36:
        return 'Encuesta de Salud de 36 Items';
      case SurveyType.assist:
        return 'Cribado de Consumo de Sustancias OMS';
    }
  }

  IconData get icon {
    switch (this) {
      case SurveyType.bai:
        return material.Icons.psychology_outlined;
      case SurveyType.bdi:
        return material.Icons.favorite_outline;
      case SurveyType.moca:
        return material.Icons.spa_outlined;
      case SurveyType.whoqol:
        return material.Icons.self_improvement_outlined;
      case SurveyType.sf36:
        return material.Icons.health_and_safety_outlined;
      case SurveyType.assist:
        return material.Icons.medication_outlined;
    }
  }

  Color getColor() {
    switch (this) {
      case SurveyType.bai:
        return LightModeColors.lightTertiary;
      case SurveyType.bdi:
        return LightModeColors.lightPrimary;
      case SurveyType.moca:
        return LightModeColors.lightSecondary;
      case SurveyType.whoqol:
        return const Color(0xFF7C3AED);
      case SurveyType.sf36:
        return const Color(0xFF06B6D4);
      case SurveyType.assist:
        return LightModeColors.lightSecondary;
    }
  }
}

class SurveyTypeSelectionScreen extends StatelessWidget {
  const SurveyTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Seleccionar Tipo de Encuesta'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.go('/'),
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipos de Encuestas Disponibles').textLarge().bold(),
            const Gap(8),
            const Text(
              'Selecciona el tipo de evaluación que deseas aplicar',
            ).muted(),
            const Gap(32),
            ...SurveyType.values.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SurveyTypeCard(
                surveyType: type,
                onTap: () => context.push('/consent-form?surveyType=${type.name}'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class SurveyTypeCard extends StatefulWidget {
  final SurveyType surveyType;
  final VoidCallback onTap;

  const SurveyTypeCard({
    super.key,
    required this.surveyType,
    required this.onTap,
  });

  @override
  State<SurveyTypeCard> createState() => _SurveyTypeCardState();
}

class _SurveyTypeCardState extends State<SurveyTypeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.surveyType.getColor();

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPressed ? color : color.withValues(alpha: 0.6),
              width: 2.0,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: _isPressed ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.surveyType.icon,
                      size: 32,
                      color: color,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.surveyType.code,
                          style: TextStyle(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        Text(widget.surveyType.englishName).small().muted(),
                        const Gap(2),
                        Text(widget.surveyType.spanishName).small().muted(),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
