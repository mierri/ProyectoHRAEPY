import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class ScoreInterpretationCard extends StatelessWidget {
  final int surveyType;

  const ScoreInterpretationCard({super.key, required this.surveyType});

  List<Map<String, dynamic>> _ranges() {
    switch (surveyType) {
      case 1:  return [{'range': '0-13', 'label': 'Depresión mínima', 'color': LightModeColors.lightTertiary}, {'range': '14-19', 'label': 'Depresión leve', 'color': const Color(0xFFFBBF24)}, {'range': '20-28', 'label': 'Depresión moderada', 'color': const Color(0xFFF97316)}, {'range': '29-63', 'label': 'Depresión severa', 'color': LightModeColors.lightError}];
      case 2:  return [{'range': '0-21', 'label': 'Ansiedad muy baja', 'color': LightModeColors.lightTertiary}, {'range': '22-35', 'label': 'Ansiedad moderada', 'color': const Color(0xFFF97316)}, {'range': '36+', 'label': 'Ansiedad severa', 'color': LightModeColors.lightError}];
      case 3:  return [{'range': '4.0-5.0', 'label': 'Calidad de vida excelente', 'color': LightModeColors.lightTertiary}, {'range': '3.5-3.9', 'label': 'Muy buena', 'color': const Color(0xFFFBBF24)}, {'range': '3.0-3.4', 'label': 'Buena', 'color': const Color(0xFFF97316)}, {'range': '2.5-2.9', 'label': 'Regular', 'color': const Color(0xFFFF7043)}, {'range': '1.0-2.4', 'label': 'Baja', 'color': LightModeColors.lightError}];
      case 5:  return [{'range': '4.0-5.0', 'label': 'Salud excelente', 'color': LightModeColors.lightTertiary}, {'range': '3.5-3.9', 'label': 'Muy buena', 'color': const Color(0xFFFBBF24)}, {'range': '3.0-3.4', 'label': 'Buena', 'color': const Color(0xFFF97316)}, {'range': '2.5-2.9', 'label': 'Regular', 'color': const Color(0xFFFF7043)}, {'range': '1.0-2.4', 'label': 'Baja', 'color': LightModeColors.lightError}];
      case 7:  return [{'range': '0-4', 'label': 'Normal. No indicativo de depresion', 'color': LightModeColors.lightTertiary}, {'range': '5-8', 'label': 'Depresion leve', 'color': const Color(0xFFFBBF24)}, {'range': '9-11', 'label': 'Depresion moderada', 'color': const Color(0xFFF97316)}, {'range': '12-15', 'label': 'Depresion severa', 'color': LightModeColors.lightError}];
      case 8:  return [{'range': '0-1', 'label': 'Dependencia total', 'color': LightModeColors.lightError}, {'range': '2-3', 'label': 'Dependencia grave', 'color': const Color(0xFFDC2626)}, {'range': '4-5', 'label': 'Dependencia moderada', 'color': const Color(0xFFF97316)}, {'range': '6-7', 'label': 'Dependencia ligera', 'color': const Color(0xFFFBBF24)}, {'range': '8', 'label': 'Autonoma / Independencia total', 'color': LightModeColors.lightTertiary}];
      case 9:  return [{'range': '0-2', 'label': 'Bajo riesgo', 'color': LightModeColors.lightTertiary}, {'range': '3-5', 'label': 'Riesgo moderado', 'color': const Color(0xFFF59E0B)}, {'range': '6-10', 'label': 'Alto riesgo', 'color': LightModeColors.lightError}];
      case 10: return [{'range': '0-1', 'label': 'Ausencia de incapacidad o incapacidad leve', 'color': LightModeColors.lightTertiary}, {'range': '2-3', 'label': 'Incapacidad moderada', 'color': const Color(0xFFF59E0B)}, {'range': '4-6', 'label': 'Incapacidad severa', 'color': LightModeColors.lightError}];
      case 11: return [{'range': '0-5', 'label': 'Leve', 'color': LightModeColors.lightTertiary}, {'range': '6-12', 'label': 'Moderado', 'color': const Color(0xFFFBBF24)}, {'range': '13-18', 'label': 'Severo', 'color': const Color(0xFFF97316)}, {'range': '19-21', 'label': 'Muy severo', 'color': LightModeColors.lightError}];
      case 12: return [{'range': 'GHQ 0-2', 'label': 'Sin malestar significativo', 'color': LightModeColors.lightTertiary}, {'range': 'GHQ >=3', 'label': 'Caso probable de malestar psicologico', 'color': LightModeColors.lightError}, {'range': 'Likert 0-11', 'label': 'Rango bajo', 'color': LightModeColors.lightTertiary}, {'range': 'Likert >=12', 'label': 'Rango elevado', 'color': LightModeColors.lightError}];
      case 13: return [{'range': '0-4', 'label': 'Sin depresion', 'color': LightModeColors.lightTertiary}, {'range': '5-9', 'label': 'Minima', 'color': const Color(0xFFFBBF24)}, {'range': '10-14', 'label': 'Moderada', 'color': const Color(0xFFF97316)}, {'range': '15-19', 'label': 'Moderadamente severa', 'color': const Color(0xFFDC2626)}, {'range': '20-27', 'label': 'Severa', 'color': const Color(0xFFB91C1C)}];
      case 14: return [{'range': 'N/A', 'label': 'Sociodemográfico', 'color': const Color(0xFF4F46E5)}];
      case 15: return [{'range': 'N/A', 'label': 'Determinantes Sociales', 'color': const Color(0xFF0F766E)}];
      case 16: return [{'range': 'N/A', 'label': 'Asistencia en Consulta de Especialidad', 'color': const Color(0xFFB45309)}];
      case 17: return [{'range': 'N/A', 'label': 'Barreras Percibidas para la Asistencia', 'color': const Color(0xFFBE123C)}];
      case 18: return [{'range': '26-30', 'label': 'Rango esperado en MoCA 8.1', 'color': LightModeColors.lightTertiary}, {'range': '0-25', 'label': 'Interpretacion clinica y correlacion por dominios', 'color': const Color(0xFF0F766E)}];
      case 19: return [{'range': '19-22', 'label': 'Rango normal en MoCA Blind', 'color': LightModeColors.lightTertiary}, {'range': '0-18', 'label': 'Bajo esperado; requiere interpretacion clinica', 'color': const Color(0xFF1D4ED8)}];
      default: return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ranges = _ranges();
    if (ranges.isEmpty) return const SizedBox.shrink();

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(material.Icons.info_outline, color: LightModeColors.lightPrimary),
            const Gap(12),
            Expanded(child: Text('Interpretación de Puntajes').semiBold().large()),
          ]),
          const Gap(20),
          ...ranges.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(color: r['color'] as Color, borderRadius: BorderRadius.circular(4)),
              ),
              const Gap(10),
              Expanded(child: Text('${r['range']}: ${r['label']}', style: const TextStyle(fontSize: 14), softWrap: true)),
            ]),
          )),
        ]),
      ),
    );
  }
}
