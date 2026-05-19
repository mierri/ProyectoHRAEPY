import 'package:flutter/material.dart' as material show Icons;
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/features/surveys/presentation/consent_form/components/scale_item.dart';

/// Full instructions dialog shown before starting a survey.
/// Shows scale explanation items specific to the survey variant.
class SurveyInstructionsDialog extends StatelessWidget {
  final String surveyType;
  final Color surveyColor;
  final VoidCallback onStart;

  const SurveyInstructionsDialog({
    super.key,
    required this.surveyType,
    required this.surveyColor,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final instruction = SurveyTypeConfig.instructionFor(surveyType);
    final variant     = instruction.variant;
    final items       = _buildScaleItems(variant);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: surveyColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(material.Icons.help_outline_rounded, color: surveyColor, size: 28),
              ),
              const Gap(12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Instrucciones').textLarge().bold(),
                Text(instruction.title, style: TextStyle(fontSize: 13, color: surveyColor)),
              ])),
            ]),
            const Gap(20),
            // Instruction text
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surveyColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: surveyColor.withValues(alpha: 0.3)),
              ),
              child: Text(instruction.instructions, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
            if (items.isNotEmpty) ...[
              const Gap(20),
              const Text('¿Qué significa cada opción?').medium().semiBold(),
              const Gap(12),
              ...items,
            ],
            const Gap(20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(material.Icons.lightbulb_outline, color: surveyColor, size: 20),
              const Gap(8),
              const Expanded(
                child: Text(
                  'No hay respuestas correctas o incorrectas. Responda lo más honestamente posible según cómo se ha sentido.',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.4),
                ),
              ),
            ]),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: onStart,
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Comenzar'), Gap(8), Icon(material.Icons.arrow_forward, size: 18),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _buildScaleItems(SurveyInstructionVariant variant) {
    Widget item(IconData icon, String label, String desc, Color color) =>
        ScaleItem(icon: icon, label: label, description: desc, color: color);
    const g = Gap(8);

    if (variant == SurveyInstructionVariant.bai) return [
      item(Symbols.sentiment_very_satisfied, 'En absoluto', 'No me ha afectado nada o casi nada.', const Color(0xFF16A34A)), g,
      item(Symbols.sentiment_satisfied, 'Levemente', 'Me ha afectado un poco, pero no me ha perturbado mucho.', const Color(0xFF65A30D)), g,
      item(Symbols.sentiment_dissatisfied, 'Moderadamente', 'Me ha afectado bastante y fue muy desagradable.', const Color(0xFFF59E0B)), g,
      item(Symbols.sentiment_very_dissatisfied, 'Severamente', 'Apenas podía soportarlo.', const Color(0xFFDC2626)),
    ];
    if (variant == SurveyInstructionVariant.ghq12) return [
      item(Symbols.sentiment_very_satisfied, '0-1: Mejor/Igual que lo habitual', 'Indica bajo malestar psicológico.', const Color(0xFF16A34A)), g,
      item(Symbols.sentiment_dissatisfied, '2: Menos/Algo más que lo habitual', 'Indica alteración reciente leve a moderada.', const Color(0xFFF59E0B)), g,
      item(Symbols.sentiment_very_dissatisfied, '3: Mucho menos/Mucho más que lo habitual', 'Indica alteración importante en las últimas dos semanas.', const Color(0xFFDC2626)),
    ];
    if (variant == SurveyInstructionVariant.phq9) return [
      item(Symbols.sentiment_very_satisfied, '0 - Para nada', 'El síntoma no estuvo presente.', const Color(0xFF16A34A)), g,
      item(Symbols.sentiment_satisfied, '1 - Varios días', 'El síntoma estuvo presente algunos días.', const Color(0xFF65A30D)), g,
      item(Symbols.sentiment_dissatisfied, '2 - Más de la mitad de los días', 'El síntoma fue frecuente y persistente.', const Color(0xFFF59E0B)), g,
      item(Symbols.sentiment_very_dissatisfied, '3 - Casi todos los días', 'El síntoma estuvo presente casi continuamente.', const Color(0xFFDC2626)),
    ];
    if (variant == SurveyInstructionVariant.gds) return [
      item(Symbols.check_circle, 'Sí / No', 'Seleccione la opción que mejor refleje su situación actual.', const Color(0xFF0EA5E9)), g,
      item(Symbols.calculate, 'Puntaje total (0–15)', 'Cada pregunta suma 0 o 1 según la clave de corrección de GDS-15.', const Color(0xFF0284C7)), g,
      item(Symbols.rule, 'Interpretación', '0–4: Normal | 5–15: Síntomas depresivos.', const Color(0xFF0369A1)),
    ];
    if (variant == SurveyInstructionVariant.osteoporosis) return [
      item(Symbols.check_circle, 'Sí / No', 'Marque la respuesta correspondiente para cada pregunta.', const Color(0xFF145374)),
    ];
    if (variant == SurveyInstructionVariant.lawton) return [
      item(Symbols.check_circle, 'Capacidad actual', 'Seleccione la opción que mejor describa su independencia en cada actividad.', const Color(0xFF14B8A6)), g,
      item(Symbols.calculate, 'Puntaje total (0–8)', 'Cada ítem aporta 1 punto si la actividad se realiza con independencia.', const Color(0xFF0F766E)), g,
      item(Symbols.rule, 'Interpretación', '8: Independencia total | 0–7: Deterioro funcional.', const Color(0xFF115E59)),
    ];
    if (variant == SurveyInstructionVariant.katz) return [
      item(Symbols.check_circle, 'Independiente = 1', 'Independencia total o con mínima ayuda.', const Color(0xFF0D9488)), g,
      item(Symbols.warning, 'Dependiente = 0', 'Requiere ayuda o supervisión significativa.', const Color(0xFFF59E0B)), g,
      item(Symbols.rule, 'Resultado y clasificación', 'Puntaje 0–6 y clasificación Katz A–H según patrón de dependencia.', const Color(0xFF115E59)),
    ];
    if (variant == SurveyInstructionVariant.iciqSf) return [
      item(Symbols.calculate, 'Puntaje total (0–21)', 'Se calcula como P1 + P2 + P3. La pregunta 4 no suma.', const Color(0xFF2563EB)), g,
      item(Symbols.rule, 'Interpretación', '0: Sin incontinencia | >0: Presencia de incontinencia con severidad.', const Color(0xFF1D4ED8)), g,
      item(Symbols.list_alt, 'Pregunta 4 (múltiple)', 'Permite seleccionar varias situaciones para orientar el tipo clínico.', const Color(0xFF1E40AF)),
    ];
    if (variant == SurveyInstructionVariant.whoqol) return [
      item(Symbols.sentiment_very_satisfied, '1 – Nada / Muy insatisfecho/a / Nunca', 'La situación no aplica o está completamente ausente.', const Color(0xFF16A34A)), g,
      item(Symbols.sentiment_satisfied, '2 – Un poco / Insatisfecho/a / Raramente', 'La situación aplica de manera mínima o poco frecuente.', const Color(0xFF65A30D)), g,
      item(Symbols.sentiment_neutral, '3 – Lo normal / Moderado / Medianamente', 'La situación aplica de forma moderada o más o menos frecuente.', const Color(0xFFF59E0B)), g,
      item(Symbols.sentiment_dissatisfied, '4 – Bastante / Satisfecho/a / Frecuentemente', 'La situación aplica bastante o con frecuencia.', const Color(0xFFEA580C)), g,
      item(Symbols.sentiment_very_dissatisfied, '5 – Extremadamente / Muy satisfecho/a / Siempre', 'La situación aplica en el máximo grado posible.', const Color(0xFFDC2626)),
    ];
    if (variant == SurveyInstructionVariant.assist) return [
      item(Symbols.check_circle, 'Frecuencia en 3 meses', 'Nunca / 1-2 veces / Cada mes / Cada semana / A diario.', const Color(0xFF0EA5E9)), g,
      item(Symbols.rule, 'Puntaje por sustancia', 'Se suma P2+P3+P4+P5+P6+P7 (tabaco no incluye P5).', const Color(0xFF0284C7)), g,
      item(Symbols.warning, 'Vía inyectada', 'Se registra aparte como advertencia clínica, no suma al puntaje por sustancia.', const Color(0xFFDC2626)),
    ];
    // BDI default
    return [
      item(Symbols.sentiment_very_satisfied, 'Opción 1', 'No lo experimento o no me aplica en este momento.', const Color(0xFF16A34A)), g,
      item(Symbols.sentiment_satisfied, 'Opción 2', 'Lo experimento algunas veces o de manera leve.', const Color(0xFF65A30D)), g,
      item(Symbols.sentiment_dissatisfied, 'Opción 3', 'Lo experimento con más frecuencia o de forma notable.', const Color(0xFFF59E0B)), g,
      item(Symbols.sentiment_very_dissatisfied, 'Opción 4', 'Lo experimento casi siempre o de manera muy intensa.', const Color(0xFFDC2626)),
    ];
  }
}
