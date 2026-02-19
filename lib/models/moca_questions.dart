/// Modelo para preguntas del MoCA (Montreal Cognitive Assessment)
/// Version 8.3 en español

enum MocaQuestionType {
  trailMaking,        // Test del trazo alterno (1 punto)
  visuoconstructiveCube,  // Cama/Cubo (1 punto)
  visuoconstructiveClock, // Reloj (3 puntos: contorno, números, manecillas)
  naming,             // Denominación (3 puntos)
  memory,             // Memoria - solo almacenamiento, no puntúa aquí
  digitsForward,      // Dígitos directos (1 punto)
  digitsBackward,     // Dígitos inversos (1 punto)
  vigilance,          // Concentración - vigilancia (1 punto)
  serialSubtraction,  // Sustracción de 7 (3 puntos)
  sentenceRepetition, // Repetición de oraciones (2 puntos)
  fluency,            // Fluidez verbal (1 punto)
  abstraction,        // Abstracción (2 puntos)
  delayedRecall,      // Recuerdo diferido (5 puntos)
  orientation,        // Orientación (6 puntos)
}

class MocaSection {
  final String title;
  final String description;
  final int maxPoints;
  final MocaQuestionType type;
  final String? instructions;
  final List<String>? options;
  final Map<String, dynamic>? metadata;

  const MocaSection({
    required this.title,
    required this.description,
    required this.maxPoints,
    required this.type,
    this.instructions,
    this.options,
    this.metadata,
  });
}

class MocaTest {
  static const int maxScore = 30;
  static const int normalCutoff = 26;
  static const int educationAdjustment = 1; // Add 1 point if education <= 12 years

  // Palabras para la prueba de memoria
  static const List<String> memoryWords = [
    'PIERNA',
    'ALGODÓN',
    'ESCUELA',
    'TOMATE',
    'BLANCO',
  ];

  // Pistas de categoría
  static const Map<String, String> categoryHints = {
    'PIERNA': 'Parte del cuerpo',
    'ALGODÓN': 'Tipo de tela',
    'ESCUELA': 'Edificio público',
    'TOMATE': 'Tipo de alimento',
    'BLANCO': 'Color',
  };

  // Opciones de elección múltiple
  static const Map<String, List<String>> multipleChoiceHints = {
    'PIERNA': ['Mano', 'Pierna', 'Cara'],
    'ALGODÓN': ['Seda', 'Algodón', 'Naylon'],
    'ESCUELA': ['Escuela', 'Hospital', 'Biblioteca'],
    'TOMATE': ['Lechuga', 'Tomate', 'Zanahoria'],
    'BLANCO': ['Morado', 'Blanco', 'Verde'],
  };

  // Secuencias para dígitos
  static const String digitsForwardSequence = '21854';
  static const String digitsBackwardSequence = '742';
  static const String digitsBackwardAnswer = '247';

  // Letras para concentración
  static const String vigilanceLetters = 'F B A C M N A A J K L B A F A K D E A A A J A M O F A A B';

  // Oraciones para repetición
  static const List<String> sentences = [
    'El niño paseaba a su perro en el parque después de medianoche.',
    'El artista terminó su pintura en el momento exacto para la exhibición.',
  ];

  // Pares de palabras para abstracción
  static const List<Map<String, dynamic>> abstractionPairs = [
    {
      'words': ['martillo', 'desarmador'],
      'correctAnswers': ['herramientas', 'carpintería', 'construcción', 'instrumentos de trabajo'],
      'incorrectExamples': ['instrumentos', 'tienen mangos', 'objetos de metal'],
    },
    {
      'words': ['cerillos', 'lámpara'],
      'correctAnswers': ['luz', 'luminosos', 'iluminación'],
      'incorrectExamples': ['fuego', 'objetos calientes', 'producen calor'],
    },
  ];

  // Animales para denominación
  static const List<Map<String, dynamic>> namingAnimals = [
    {
      'name': 'caballo',
      'alternates': ['poni', 'yegua', 'potro'],
    },
    {
      'name': 'tigre',
      'alternates': [],
    },
    {
      'name': 'pato',
      'alternates': [],
    },
  ];

  static const List<MocaSection> sections = [
    MocaSection(
      title: 'Test del Trazo Alterno',
      description: 'Dibuje una línea desde un número hacia una letra en orden ascendente',
      maxPoints: 1,
      type: MocaQuestionType.trailMaking,
      instructions: 'Dibuje una línea que vaya desde un número hacia una letra en orden ascendente. '
          'Comience en el 1 y dibuje una línea hacia la letra A, a continuación hacia el número 2 '
          'y así consecutivamente, terminando en la letra E.',
    ),
    MocaSection(
      title: 'Habilidades Visuoconstructivas (Cama)',
      description: 'Copie este dibujo tan preciso como pueda',
      maxPoints: 1,
      type: MocaQuestionType.visuoconstructiveCube,
      instructions: 'Copie el dibujo de la cama tridimensional. El dibujo debe ser tridimensional, '
          'todas las líneas deben estar dibujadas y conectadas correctamente.',
    ),
    MocaSection(
      title: 'Habilidades Visuoconstructivas (Reloj)',
      description: 'Dibuje un reloj con todos los números y marque las 10:10',
      maxPoints: 3,
      type: MocaQuestionType.visuoconstructiveClock,
      instructions: 'Dibuje un reloj. Coloque todos los números dentro y marque las diez con cinco minutos.',
      metadata: {
        'subtasks': ['Contorno', 'Números', 'Manecillas'],
      },
    ),
    MocaSection(
      title: 'Denominación',
      description: 'Nombre estos tres animales',
      maxPoints: 3,
      type: MocaQuestionType.naming,
      instructions: 'Dígame el nombre de cada animal que le señalo.',
    ),
    MocaSection(
      title: 'Memoria - Primera Lectura',
      description: 'Recuerde estas palabras (1er intento)',
      maxPoints: 0,
      type: MocaQuestionType.memory,
      instructions: 'Esta es una prueba de memoria. Le voy a leer una lista de palabras que debe recordar '
          'ahora y también solicitaré que lo haga más adelante. Escuche cuidadosamente. '
          'Cuando yo finalice, diga todas las palabras que le sean posible recordar, no importa el orden.',
      options: memoryWords,
    ),
    MocaSection(
      title: 'Atención - Dígitos Directos',
      description: 'Repita los números en el mismo orden',
      maxPoints: 1,
      type: MocaQuestionType.digitsForward,
      instructions: 'Voy a decir algunos números y cuando termine, repítalos exactamente como los dije.',
      metadata: {'sequence': digitsForwardSequence},
    ),
    MocaSection(
      title: 'Atención - Dígitos Inversos',
      description: 'Repita los números en orden inverso',
      maxPoints: 1,
      type: MocaQuestionType.digitsBackward,
      instructions: 'Ahora voy a decir algunos números más, pero cuando termine, deberá repetirlos en orden inverso.',
      metadata: {
        'sequence': digitsBackwardSequence,
        'correctAnswer': digitsBackwardAnswer,
      },
    ),
    MocaSection(
      title: 'Atención - Concentración',
      description: 'Golpee cuando escuche la letra A',
      maxPoints: 1,
      type: MocaQuestionType.vigilance,
      instructions: 'Voy a leer una secuencia de letras. Cada vez que mencione la letra A, '
          'dé un pequeño golpe con su mano. Si digo una letra diferente, no dé ningún golpe.',
      metadata: {'letters': vigilanceLetters},
    ),
    MocaSection(
      title: 'Atención - Sustracción de 7',
      description: 'Reste 7 desde 60, cinco veces',
      maxPoints: 3,
      type: MocaQuestionType.serialSubtraction,
      instructions: 'Ahora, le pido que al número 60 le reste 7 y después continúe restando 7 '
          'a su respuesta hasta que yo le indique que se detenga.',
      metadata: {
        'correctAnswers': [60, 53, 46, 39, 32, 25],
      },
    ),
    MocaSection(
      title: 'Lenguaje - Repetición',
      description: 'Repita estas oraciones exactamente',
      maxPoints: 2,
      type: MocaQuestionType.sentenceRepetition,
      instructions: 'Voy a leerle unas oraciones. Repítalas después de mí, exactamente como las diga.',
      options: sentences,
    ),
    MocaSection(
      title: 'Lenguaje - Fluidez Verbal',
      description: 'Diga palabras que comiencen con B (60 seg)',
      maxPoints: 1,
      type: MocaQuestionType.fluency,
      instructions: 'Ahora quiero que me diga el mayor número de palabras que le sean posible recordar '
          'que comiencen con la letra B. Le pediré que se detenga en un minuto. '
          'No se permiten nombres propios, números y las formas conjugadas de un verbo.',
      metadata: {'minWords': 11},
    ),
    MocaSection(
      title: 'Abstracción',
      description: '¿Qué tienen en común estas palabras?',
      maxPoints: 2,
      type: MocaQuestionType.abstraction,
      instructions: 'Le diré dos palabras y me gustaría que me dijera a qué categoría pertenecen.',
    ),
    MocaSection(
      title: 'Recuerdo Diferido',
      description: 'Recuerde las palabras de antes (sin pistas)',
      maxPoints: 5,
      type: MocaQuestionType.delayedRecall,
      instructions: 'Con anterioridad, le leí algunas palabras, y le pedí las recordara. '
          'Dígame ahora todas las palabras que recuerde.',
      options: memoryWords,
    ),
    MocaSection(
      title: 'Orientación',
      description: 'Fecha, día, mes, año, lugar, ciudad',
      maxPoints: 6,
      type: MocaQuestionType.orientation,
      instructions: 'Dígame la fecha del día de hoy completa (día, mes, año y día de la semana). '
          'Ahora, dígame el nombre de este lugar, y en qué ciudad está.',
    ),
  ];

  /// Calcula el Memory Index Score (MIS)
  static int calculateMIS({
    required int spontaneousRecall,
    required int categoryRecall,
    required int multipleChoiceRecall,
  }) {
    return (spontaneousRecall * 3) + (categoryRecall * 2) + (multipleChoiceRecall * 1);
  }

  /// Interpreta el resultado del MoCA
  static String interpretScore(int score) {
    if (score >= normalCutoff) {
      return 'Normal';
    } else if (score >= 18) {
      return 'Deterioro Cognitivo Leve';
    } else {
      return 'Deterioro Cognitivo Significativo';
    }
  }

  /// Obtiene un mensaje descriptivo del resultado
  static String getScoreDescription(int score) {
    if (score >= normalCutoff) {
      return 'El puntaje está dentro del rango normal. '
          'No se detectan signos significativos de deterioro cognitivo.';
    } else if (score >= 18) {
      return 'El puntaje sugiere un posible deterioro cognitivo leve. '
          'Se recomienda seguimiento y evaluación adicional.';
    } else {
      return 'El puntaje sugiere un deterioro cognitivo significativo. '
          'Se recomienda evaluación clínica completa.';
    }
  }
}

