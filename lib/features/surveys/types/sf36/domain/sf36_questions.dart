class SF36Question {
  final int number;
  final String text;
  final SF36Dimension dimension;
  final SF36ScaleType scaleType;
  final List<String> options;
  final bool inverted; // indica si la puntuación debe invertirse (opción más alta = peor salud)
  final List<double>? customScoring; // puntuación personalizada para cada opción (debe tener la misma longitud que options)
  final bool useRawScore; // usar el raw score directamente sin invertir ni transformar

  const SF36Question({
    required this.number,
    required this.text,
    required this.dimension,
    required this.scaleType,
    required this.options,
    this.inverted = false,
    this.customScoring,
    this.useRawScore = false,
  });
}

enum SF36Dimension {
  physicalFunctioning,      // PF: Función Física
  rolePhysical,             // RP: Rol Físico
  bodilypain,               // BP: Dolor Corporal
  generalHealth,            // GH: Salud General
  vitality,                 // VT: Vitalidad
  socialFunctioning,        // SF: Función Social
  roleEmotional,            // RE: Rol Emocional
  mentalHealth,             // MH: Salud Mental
  healthTransition,         // HT: Evolución Declarada de la Salud
}

enum SF36ScaleType {
  yesNo,                    // 1-2: Si, No
  limitation,               // 1-3: Si me limita mucho, Si me limita poco, No me limita
  frequency6,               // 1-6: Siempre, Casi siempre, Muchas veces, Algunas veces, Solo alguna vez, Nunca
  frequency5,               // 1-5: Similar to 1-6 but 5 points
  pain,                     // 1-6: Con opciones específicas para dolor
  health,                   // 1-5: Excelente, Muy buena, Buena, Regular, Mala
  truth,                    // 1-5: Totalmente cierta, Bastante cierta, No lo sé, Bastante falsa, Totalmente falsa
  comparison,               // 1-5: Mucho mejor ahora que hace un año, Algo mejor ahora que hace un año, Más o menos igual que hace un año, Algo peor ahora que hace un año, Mucho peor ahora que hace un año
}

class SF36Questions {
  static const List<SF36Question> questions = [
    // item 1: salud general - se codifica (1-5) con puntuación personalizada
    SF36Question(
      number: 1,
      text: 'En general, usted diría que su salud es:',
      dimension: SF36Dimension.generalHealth,
      scaleType: SF36ScaleType.health,
      options: [
        'Excelente',
        'Muy buena',
        'Buena',
        'Regular',
        'Mala',
      ],
      customScoring: [5.0, 4.4, 3.4, 2.0, 1.0],
      useRawScore: false,
    ),

    // ITEM 2: evolución declarada de la salud - se codifica (1-5) con puntuación personalizada
    SF36Question(
      number: 2,
      text: '¿Cómo diría usted que es su salud actual, comparada con la de hace un año?',
      dimension: SF36Dimension.healthTransition,
      scaleType: SF36ScaleType.comparison,
      options: [
        'Mucho mejor ahora que hace un año',
        'Algo mejor ahora que hace un año',
        'Más o menos igual que hace un año',
        'Algo peor ahora que hace un año',
        'Mucho peor ahora que hace un año',
      ],
      useRawScore: true,
    ),

    // ITEM 3a: función física - se invierte (1-3) con puntuación personalizada
    SF36Question(
      number: 3,
      text: 'Las siguientes preguntas se refieren a actividades o cosas que usted podría hacer en un día normal. Su salud actual, ¿le limita para hacer esas actividades o cosas? Si es así, ¿cuánto?\n\n3a. Esfuerzos intensos, tales como correr, levantar objetos pesados, o participar en deportes agotadores.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3b
    SF36Question(
      number: 4,
      text: '3b. Esfuerzos moderados, como mover una mesa, pasar la aspiradora, jugar a los bolos o caminar más de 1 hora.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3c
    SF36Question(
      number: 5,
      text: '3c. Coger o llevar la bolsa de la compra.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3d
    SF36Question(
      number: 6,
      text: '3d. Subir varios pisos por la escalera.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3e
    SF36Question(
      number: 7,
      text: '3e. Subir un sólo piso por la escalera.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3f
    SF36Question(
      number: 8,
      text: '3f. Agacharse o arrodillarse.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3g
    SF36Question(
      number: 9,
      text: '3g. Caminar un kilómetro o más.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3h
    SF36Question(
      number: 10,
      text: '3h. Caminar varios centenares de metros.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3i
    SF36Question(
      number: 11,
      text: '3i. Caminar unos 100 metros.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 3j
    SF36Question(
      number: 12,
      text: '3j. Bañarse o vestirse por sí mismo.',
      dimension: SF36Dimension.physicalFunctioning,
      scaleType: SF36ScaleType.limitation,
      options: ['Sí, me limita mucho', 'Sí, me limita un poco', 'No, no me limita nada'],
      useRawScore: true,
    ),

    // ITEM 4a: rol físico - No se modifica (1-2)
    SF36Question(
      number: 13,
      text: 'Durante las 4 últimas semanas, ¿con qué frecuencia ha tenido alguno de los siguientes problemas en su trabajo o en sus actividades cotidianas, a causa de su salud física?\n\n4a. ¿Tuvo que reducir el tiempo dedicado al trabajo o a sus actividades cotidianas?',
      dimension: SF36Dimension.rolePhysical,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 4b
    SF36Question(
      number: 14,
      text: '4b. ¿Hizo menos de lo que hubiera querido hacer?',
      dimension: SF36Dimension.rolePhysical,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 4c
    SF36Question(
      number: 15,
      text: '4c. ¿Tuvo que dejar de hacer algunas tareas en su trabajo o en sus actividades cotidianas?',
      dimension: SF36Dimension.rolePhysical,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 4d
    SF36Question(
      number: 16,
      text: '4d. ¿Tuvo dificultad para hacer su trabajo o sus actividades cotidianas (por ejemplo, le costó más de lo normal)?',
      dimension: SF36Dimension.rolePhysical,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 5a: Role Emotional - No se modifica (1-2)
    SF36Question(
      number: 17,
      text: 'Durante las 4 últimas semanas, ¿con qué frecuencia ha tenido alguno de los siguientes problemas en su trabajo o en sus actividades cotidianas, a causa de algún problema emocional (como estar triste, deprimido o nervioso)?\n\n5a. ¿Tuvo que reducir el tiempo dedicado al trabajo o a sus actividades cotidianas por algún problema emocional?',
      dimension: SF36Dimension.roleEmotional,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 5b
    SF36Question(
      number: 18,
      text: '5b. ¿Hizo menos de lo que hubiera querido hacer por algún problema emocional?',
      dimension: SF36Dimension.roleEmotional,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 5c
    SF36Question(
      number: 19,
      text: '5c. ¿Hizo su trabajo o sus actividades cotidianas menos cuidadosamente que de costumbre, por algún problema emocional?',
      dimension: SF36Dimension.roleEmotional,
      scaleType: SF36ScaleType.yesNo,
      options: ['Sí', 'No'],
      useRawScore: true,
    ),

    // ITEM 6: Social Functioning - Se invierte (1-5)
    SF36Question(
      number: 20,
      text: 'Durante las 4 últimas semanas, ¿hasta qué punto su salud física o los problemas emocionales han dificultado sus actividades sociales habituales con la familia, los amigos, los vecinos u otras personas?',
      dimension: SF36Dimension.socialFunctioning,
      scaleType: SF36ScaleType.frequency5,
      options: ['Nada', 'Un poco', 'Regular', 'Bastante', 'Mucho'],
      inverted: true,
      customScoring: [5, 4, 3, 2, 1],
    ),

    // ITEM 7: dolor corporal - Se invierte (1-6) con puntuación personalizada
    SF36Question(
      number: 21,
      text: '¿Tuvo dolor en alguna parte del cuerpo durante las 4 últimas semanas?',
      dimension: SF36Dimension.bodilypain,
      scaleType: SF36ScaleType.pain,
      options: [
        'No, ninguno',
        'Sí, muy poco',
        'Sí, un poco',
        'Sí, moderado',
        'Sí, mucho',
        'Sí, muchísimo',
      ],
      customScoring: [6, 5.4, 4.2, 3.1, 2.2, 1.0],
    ),

    // ITEM 8: dolor corporal - Se invierte (1-5) con puntuación personalizada, pero depende de la respuesta del ítem 7
    SF36Question(
      number: 22,
      text: 'Durante las 4 últimas semanas, ¿hasta qué punto el dolor le ha dificultado su trabajo habitual (incluido el trabajo fuera de casa y las tareas domésticas)?',
      dimension: SF36Dimension.bodilypain,
      scaleType: SF36ScaleType.frequency5,
      options: ['Nada', 'Un poco', 'Regular', 'Bastante', 'Mucho'],
      customScoring: [6, 4, 3, 2, 1],
    ),

    // ITEM 9a: vitality - Se invierte (1-6) con puntuación personalizada
    SF36Question(
      number: 23,
      text: 'Las preguntas que siguen se refieren a cómo se ha sentido y cómo le han ido las cosas durante las 4 últimas semanas. En cada pregunta responda lo que se parezca más a cómo se ha sentido usted. Durante las últimas 4 semanas ¿con qué frecuencia...\n\n9a. ¿se sintió lleno de vitalidad?',
      dimension: SF36Dimension.vitality,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      inverted: true,
      customScoring: [6, 5, 4, 3, 2, 1],
    ),

    // ITEM 9b: salud mental - No se invierte (1-6)
    SF36Question(
      number: 24,
      text: '9b. ¿estuvo muy nervioso?',
      dimension: SF36Dimension.mentalHealth,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      useRawScore: true,
    ),

    // ITEM 9c: salud mental - No se invierte (1-6)
    SF36Question(
      number: 25,
      text: '9c. ¿se sintió tan bajo de moral que nada podía animarle?',
      dimension: SF36Dimension.mentalHealth,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      useRawScore: true,
    ),

    // ITEM 9d: salud mental - Se invierte (1-6) con puntuación personalizada
    SF36Question(
      number: 26,
      text: '9d. ¿se sintió calmado y tranquilo?',
      dimension: SF36Dimension.mentalHealth,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      inverted: true,
      customScoring: [6, 5, 4, 3, 2, 1],
    ),

    // ITEM 9e: vitalidad - Se invierte (1-6) con puntuación personalizada
    SF36Question(
      number: 27,
      text: '9e. ¿tuvo mucha energía?',
      dimension: SF36Dimension.vitality,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      inverted: true,
      customScoring: [6, 5, 4, 3, 2, 1],
    ),

    // ITEM 9f: salud mental - No se invierte (1-6)
    SF36Question(
      number: 28,
      text: '9f. ¿se sintió desanimado y deprimido?',
      dimension: SF36Dimension.mentalHealth,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      useRawScore: true,
    ),

    // ITEM 9g: vitalidad - No se invierte (1-6)
    SF36Question(
      number: 29,
      text: '9g. ¿se sintió agotado?',
      dimension: SF36Dimension.vitality,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      useRawScore: true,
    ),

    // ITEM 9h: salud mental - Se invierte (1-6) con puntuación personalizada
    SF36Question(
      number: 30,
      text: '9h. ¿se sintió feliz?',
      dimension: SF36Dimension.mentalHealth,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      inverted: true,
      customScoring: [6, 5, 4, 3, 2, 1],
    ),

    // ITEM 9i: vitalidad - No se invierte (1-6)
    SF36Question(
      number: 31,
      text: '9i. ¿se sintió cansado?',
      dimension: SF36Dimension.vitality,
      scaleType: SF36ScaleType.frequency6,
      options: ['Siempre', 'Casi siempre', 'Muchas veces', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      useRawScore: true,
    ),

    // ITEM 10: función social - Se invierte (1-5) con puntuación personalizada
    SF36Question(
      number: 32,
      text: 'Durante las 4 últimas semanas, ¿con qué frecuencia la salud física o los problemas emocionales le han dificultado sus actividades sociales (como visitar a los amigos o familiares)?',
      dimension: SF36Dimension.socialFunctioning,
      scaleType: SF36ScaleType.frequency5,
      options: ['Siempre', 'Casi siempre', 'Algunas veces', 'Sólo alguna vez', 'Nunca'],
      useRawScore: true,
    ),

    // ITEM 11a: salud general - No se invierte (1-5)
    SF36Question(
      number: 33,
      text: 'Por favor diga si le parece CIERTA o FALSA cada una de las siguientes frases:\n\n11a. Creo que me pongo enfermo más fácilmente que otras personas',
      dimension: SF36Dimension.generalHealth,
      scaleType: SF36ScaleType.truth,
      options: ['Totalmente cierta', 'Bastante cierta', 'No lo sé', 'Bastante falsa', 'Totalmente falsa'],
      useRawScore: true,
    ),

    // ITEM 11b: salud general - Se invierte (1-5) con puntuación personalizada
    SF36Question(
      number: 34,
      text: '11b. Estoy tan sano como cualquiera',
      dimension: SF36Dimension.generalHealth,
      scaleType: SF36ScaleType.truth,
      options: ['Totalmente cierta', 'Bastante cierta', 'No lo sé', 'Bastante falsa', 'Totalmente falsa'],
      inverted: true,
      customScoring: [5, 4, 3, 2, 1],
    ),

    // ITEM 11c: salud general - No se invierte (1-5)
    SF36Question(
      number: 35,
      text: '11c. Creo que mi salud va a empeorar',
      dimension: SF36Dimension.generalHealth,
      scaleType: SF36ScaleType.truth,
      options: ['Totalmente cierta', 'Bastante cierta', 'No lo sé', 'Bastante falsa', 'Totalmente falsa'],
      useRawScore: true,
    ),

    // ITEM 11d: salud general - Se invierte (1-5) con puntuación personalizada
    SF36Question(
      number: 36,
      text: '11d. Mi salud es excelente',
      dimension: SF36Dimension.generalHealth,
      scaleType: SF36ScaleType.truth,
      options: ['Totalmente cierta', 'Bastante cierta', 'No lo sé', 'Bastante falsa', 'Totalmente falsa'],
      inverted: true,
      customScoring: [5, 4, 3, 2, 1],
    ),
  ];

  static List<SF36Question> getQuestionsForDimension(SF36Dimension dimension) {
    return questions.where((q) => q.dimension == dimension).toList();
  }
}

