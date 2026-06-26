import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class ScoreInterpretationCard extends StatelessWidget {
  final int surveyType;

  const ScoreInterpretationCard({super.key, required this.surveyType});

  List<Map<String, dynamic>> _ranges() {
    switch (surveyType) {
      case 1:  return [{'range': '0-13', 'label': 'Depresión mínima', 'color': LightModeColors.lightTertiary}, {'range': '14-19', 'label': 'Depresión leve', 'color': const Color(0xFFFBBF24)}, {'range': '20-28', 'label': 'Depresión moderada', 'color': const Color(0xFFF97316)}, {'range': '29-63', 'label': 'Depresión severa', 'color': LightModeColors.lightError}];
      case 2:  return [{'range': '0-7', 'label': 'Ansiedad mínima', 'color': LightModeColors.lightTertiary}, {'range': '8-15', 'label': 'Ansiedad leve', 'color': const Color(0xFFFBBF24)}, {'range': '16-25', 'label': 'Ansiedad moderada', 'color': const Color(0xFFF97316)}, {'range': '26-63', 'label': 'Ansiedad severa', 'color': LightModeColors.lightError}];
      case 3:  return [{'range': '4.0-5.0', 'label': 'Calidad de vida excelente', 'color': LightModeColors.lightTertiary}, {'range': '3.5-3.9', 'label': 'Muy buena', 'color': const Color(0xFFFBBF24)}, {'range': '3.0-3.4', 'label': 'Buena', 'color': const Color(0xFFF97316)}, {'range': '2.5-2.9', 'label': 'Regular', 'color': const Color(0xFFFF7043)}, {'range': '1.0-2.4', 'label': 'Baja', 'color': LightModeColors.lightError}];
      case 5:  return [{'range': '4.0-5.0', 'label': 'Salud excelente', 'color': LightModeColors.lightTertiary}, {'range': '3.5-3.9', 'label': 'Muy buena', 'color': const Color(0xFFFBBF24)}, {'range': '3.0-3.4', 'label': 'Buena', 'color': const Color(0xFFF97316)}, {'range': '2.5-2.9', 'label': 'Regular', 'color': const Color(0xFFFF7043)}, {'range': '1.0-2.4', 'label': 'Baja', 'color': LightModeColors.lightError}];
      case 7:  return [{'range': '0-4', 'label': 'Normal', 'color': LightModeColors.lightTertiary}, {'range': '5-15', 'label': 'Síntomas depresivos', 'color': LightModeColors.lightError}];
      case 8:  return [{'range': '8', 'label': 'Independencia total', 'color': LightModeColors.lightTertiary}, {'range': '0-7', 'label': 'Deterioro funcional', 'color': const Color(0xFFF59E0B)}];
      case 9:  return [{'range': '0-2', 'label': 'Bajo riesgo', 'color': LightModeColors.lightTertiary}, {'range': '3-5', 'label': 'Riesgo moderado', 'color': const Color(0xFFF59E0B)}, {'range': '6-10', 'label': 'Alto riesgo', 'color': LightModeColors.lightError}];
      case 10: return [{'range': '6', 'label': 'Independencia total', 'color': LightModeColors.lightTertiary}, {'range': '0-5', 'label': 'Dependencia en algún grado', 'color': const Color(0xFFF59E0B)}, {'range': 'A-H', 'label': 'Clasificación Katz', 'color': LightModeColors.lightSecondary}];
      case 11: return [{'range': '0', 'label': 'Sin incontinencia', 'color': LightModeColors.lightTertiary}, {'range': '1-5', 'label': 'Impacto leve', 'color': const Color(0xFFFBBF24)}, {'range': '6-12', 'label': 'Impacto moderado', 'color': const Color(0xFFF97316)}, {'range': '13-21', 'label': 'Impacto severo', 'color': LightModeColors.lightError}];
      case 12: return [{'range': '0-11', 'label': 'Malestar bajo', 'color': LightModeColors.lightTertiary}, {'range': '12-20', 'label': 'Malestar leve', 'color': const Color(0xFFFBBF24)}, {'range': '21-27', 'label': 'Malestar moderado', 'color': const Color(0xFFF97316)}, {'range': '28-36', 'label': 'Malestar alto', 'color': LightModeColors.lightError}];
      case 13: return [{'range': '0-4', 'label': 'Depresión mínima', 'color': LightModeColors.lightTertiary}, {'range': '5-9', 'label': 'Leve', 'color': const Color(0xFFFBBF24)}, {'range': '10-14', 'label': 'Moderada', 'color': const Color(0xFFF97316)}, {'range': '15-19', 'label': 'Moderadamente grave', 'color': const Color(0xFFDC2626)}, {'range': '20-27', 'label': 'Grave', 'color': const Color(0xFFB91C1C)}];
      case 14: return [{'range': 'N/A', 'label': 'Sociodemográfico', 'color': const Color(0xFF4F46E5)}];
      case 15: return [{'range': 'N/A', 'label': 'Determinantes Sociales', 'color': const Color(0xFF0F766E)}];
      case 16: return [{'range': 'N/A', 'label': 'Asistencia en Consulta de Especialidad', 'color': const Color(0xFFB45309)}];
      case 17: return [{'range': 'N/A', 'label': 'Barreras Percibidas para la Asistencia', 'color': const Color(0xFFBE123C)}];
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
