import 'package:flutter/material.dart' show IconData;
import 'package:flutter/material.dart' as material show Icons;

enum CreateFlowStep { details, surveys, consent, review }

extension CreateFlowStepX on CreateFlowStep {
  String get label {
    switch (this) {
      case CreateFlowStep.details:
        return 'Detalles';
      case CreateFlowStep.surveys:
        return 'Encuestas';
      case CreateFlowStep.consent:
        return 'Consentimiento';
      case CreateFlowStep.review:
        return 'Revision';
    }
  }

  IconData get icon {
    switch (this) {
      case CreateFlowStep.details:
        return material.Icons.science;
      case CreateFlowStep.surveys:
        return material.Icons.checklist;
      case CreateFlowStep.consent:
        return material.Icons.description;
      case CreateFlowStep.review:
        return material.Icons.visibility;
    }
  }
}


