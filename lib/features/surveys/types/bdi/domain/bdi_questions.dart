/// Modelo genérico de pregunta de encuesta
class SurveyQuestion {
  final int number;
  final String category;
  final List<SurveyOption> options;

  const SurveyQuestion({
    required this.number,
    required this.category,
    required this.options,
  });
}

/// Modelo genérico de opción de respuesta
class SurveyOption {
  final int score;
  final String text;
  final String? mayaText;

  const SurveyOption({
    required this.score,
    required this.text,
    this.mayaText,
  });
}

/// Preguntas del Inventario de Depresión de Beck (BDI-II)
class BDIQuestions {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Tristeza',
      options: [
        SurveyOption(score: 0, text: 'No me siento triste.'),
        SurveyOption(score: 1, text: 'Me siento triste gran parte del tiempo'),
        SurveyOption(score: 2, text: 'Me siento triste todo el tiempo.'),
        SurveyOption(score: 3, text: 'Me siento tan triste o soy tan infeliz que no puedo soportarlo.'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Pesimismo',
      options: [
        SurveyOption(score: 0, text: 'No estoy desalentado respecto del mi futuro.'),
        SurveyOption(score: 1, text: 'Me siento más desalentado respecto de mi futuro que lo que solía estarlo.'),
        SurveyOption(score: 2, text: 'No espero que las cosas funcionen para mi.'),
        SurveyOption(score: 3, text: 'Siento que no hay esperanza para mi futuro y que sólo puede empeorar.'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Fracaso',
      options: [
        SurveyOption(score: 0, text: 'No me siento como un fracasado.'),
        SurveyOption(score: 1, text: 'He fracasado más de lo que hubiera debido.'),
        SurveyOption(score: 2, text: 'Cuando miro hacia atrás, veo muchos fracasos.'),
        SurveyOption(score: 3, text: 'Siento que como persona soy un fracaso total.'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Pérdida de Placer',
      options: [
        SurveyOption(score: 0, text: 'Obtengo tanto placer como siempre por las cosas de las que disfruto.'),
        SurveyOption(score: 1, text: 'No disfruto tanto de las cosas como solía hacerlo.'),
        SurveyOption(score: 2, text: 'Obtengo muy poco placer de las cosas que solía disfrutar.'),
        SurveyOption(score: 3, text: 'No puedo obtener ningún placer de las cosas de las que solía disfrutar.'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Sentimientos de Culpa',
      options: [
        SurveyOption(score: 0, text: 'No me siento particularmente culpable.'),
        SurveyOption(score: 1, text: 'Me siento culpable respecto de varias cosas que he hecho o que debería haber hecho.'),
        SurveyOption(score: 2, text: 'Me siento bastante culpable la mayor parte del tiempo.'),
        SurveyOption(score: 3, text: 'Me siento culpable todo el tiempo.'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: 'Sentimientos de Castigo',
      options: [
        SurveyOption(score: 0, text: 'No siento que este siendo castigado'),
        SurveyOption(score: 1, text: 'Siento que tal vez pueda ser castigado.'),
        SurveyOption(score: 2, text: 'Espero ser castigado.'),
        SurveyOption(score: 3, text: 'Siento que estoy siendo castigado.'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: 'Disconformidad con uno mismo',
      options: [
        SurveyOption(score: 0, text: 'Siento acerca de mi lo mismo que siempre.'),
        SurveyOption(score: 1, text: 'He perdido la confianza en mí mismo.'),
        SurveyOption(score: 2, text: 'Estoy decepcionado conmigo mismo.'),
        SurveyOption(score: 3, text: 'No me gusto a mí mismo.'),
      ],
    ),
    SurveyQuestion(
      number: 8,
      category: 'Autocrítica',
      options: [
        SurveyOption(score: 0, text: 'No me critico ni me culpo más de lo habitual'),
        SurveyOption(score: 1, text: 'Estoy más crítico conmigo mismo de lo que solía estarlo'),
        SurveyOption(score: 2, text: 'Me critico a mí mismo por todos mis errores'),
        SurveyOption(score: 3, text: 'Me culpo a mí mismo por todo lo malo que sucede.'),
      ],
    ),
    SurveyQuestion(
      number: 9,
      category: 'Pensamientos o Deseos Suicidas',
      options: [
        SurveyOption(score: 0, text: 'No tengo ningún pensamiento de matarme.'),
        SurveyOption(score: 1, text: 'He tenido pensamientos de matarme, pero no lo haría'),
        SurveyOption(score: 2, text: 'Querría matarme'),
        SurveyOption(score: 3, text: 'Me mataría si tuviera la oportunidad de hacerlo.'),
      ],
    ),
    SurveyQuestion(
      number: 10,
      category: 'Llanto',
      options: [
        SurveyOption(score: 0, text: 'No lloro más de lo que solía hacerlo.'),
        SurveyOption(score: 1, text: 'Lloro más de lo que solía hacerlo'),
        SurveyOption(score: 2, text: 'Lloro por cualquier pequeñez.'),
        SurveyOption(score: 3, text: 'Siento ganas de llorar pero no puedo.'),
      ],
    ),
    SurveyQuestion(
      number: 11,
      category: 'Agitación',
      options: [
        SurveyOption(score: 0, text: 'No estoy más inquieto o tenso que lo habitual.'),
        SurveyOption(score: 1, text: 'Me siento más inquieto o tenso que lo habitual.'),
        SurveyOption(score: 2, text: 'Estoy tan inquieto o agitado que me es difícil quedarme quieto'),
        SurveyOption(score: 3, text: 'Estoy tan inquieto o agitado que tengo que estar siempre en movimiento o haciendo algo.'),
      ],
    ),
    SurveyQuestion(
      number: 12,
      category: 'Pérdida de Interés',
      options: [
        SurveyOption(score: 0, text: 'No he perdido el interés en otras actividades o personas.'),
        SurveyOption(score: 1, text: 'Estoy menos interesado que antes en otras personas o cosas.'),
        SurveyOption(score: 2, text: 'He perdido casi todo el interés en otras personas o cosas.'),
        SurveyOption(score: 3, text: 'Me es difícil interesarme por algo.'),
      ],
    ),
    SurveyQuestion(
      number: 13,
      category: 'Indecisión',
      options: [
        SurveyOption(score: 0, text: 'Tomo mis propias decisiones tan bien como siempre.'),
        SurveyOption(score: 1, text: 'Me resulta más difícil que de costumbre tomar decisiones'),
        SurveyOption(score: 2, text: 'Encuentro mucha más dificultad que antes para tomar decisiones.'),
        SurveyOption(score: 3, text: 'Tengo problemas para tomar cualquier decisión.'),
      ],
    ),
    SurveyQuestion(
      number: 14,
      category: 'Desvalorización',
      options: [
        SurveyOption(score: 0, text: 'No siento que yo no sea valioso'),
        SurveyOption(score: 1, text: 'No me considero a mi mismo tan valioso y útil como solía considerarme'),
        SurveyOption(score: 2, text: 'Me siento menos valioso cuando me comparo con otros.'),
        SurveyOption(score: 3, text: 'Siento que no valgo nada.'),
      ],
    ),
    SurveyQuestion(
      number: 15,
      category: 'Pérdida de Energía',
      options: [
        SurveyOption(score: 0, text: 'Tengo tanta energía como siempre.'),
        SurveyOption(score: 1, text: 'Tengo menos energía que la que solía tener.'),
        SurveyOption(score: 2, text: 'No tengo suficiente energía para hacer demasiado'),
        SurveyOption(score: 3, text: 'No tengo energía suficiente para hacer nada.'),
      ],
    ),
    SurveyQuestion(
      number: 16,
      category: 'Cambios en los Hábitos de Sueño',
      options: [
        SurveyOption(score: 0, text: 'No he experimentado ningún cambio en mis hábitos de sueño.'),
        SurveyOption(score: 1, text: 'Duermo un poco más que lo habitual.'),
        SurveyOption(score: 1, text: 'Duermo un poco menos que lo habitual.'),
        SurveyOption(score: 2, text: 'Duermo mucho más que lo habitual.'),
        SurveyOption(score: 2, text: 'Duermo mucho menos que lo habitual'),
        SurveyOption(score: 3, text: 'Duermo la mayor parte del día'),
        SurveyOption(score: 3, text: 'Me despierto 1-2 horas más temprano y no puedo volver a dormirme'),
      ],
    ),
    SurveyQuestion(
      number: 17,
      category: 'Irritabilidad',
      options: [
        SurveyOption(score: 0, text: 'No estoy tan irritable que lo habitual.'),
        SurveyOption(score: 1, text: 'Estoy más irritable que lo habitual.'),
        SurveyOption(score: 2, text: 'Estoy mucho más irritable que lo habitual.'),
        SurveyOption(score: 3, text: 'Estoy irritable todo el tiempo.'),
      ],
    ),
    SurveyQuestion(
      number: 18,
      category: 'Cambios en el Apetito',
      options: [
        SurveyOption(score: 0, text: 'No he experimentado ningún cambio en mi apetito.'),
        SurveyOption(score: 1, text: 'Mi apetito es un poco menor que lo habitual.'),
        SurveyOption(score: 1, text: 'Mi apetito es un poco mayor que lo habitual.'),
        SurveyOption(score: 2, text: 'Mi apetito es mucho menor que antes.'),
        SurveyOption(score: 2, text: 'Mi apetito es mucho mayor que lo habitual'),
        SurveyOption(score: 3, text: 'No tengo apetito en absoluto.'),
        SurveyOption(score: 3, text: 'Quiero comer todo el día.'),
      ],
    ),
    SurveyQuestion(
      number: 19,
      category: 'Dificultad de Concentración',
      options: [
        SurveyOption(score: 0, text: 'Puedo concentrarme tan bien como siempre.'),
        SurveyOption(score: 1, text: 'No puedo concentrarme tan bien como habitualmente'),
        SurveyOption(score: 2, text: 'Me es difícil mantener la mente en algo por mucho tiempo.'),
        SurveyOption(score: 3, text: 'Encuentro que no puedo concentrarme en nada.'),
      ],
    ),
    SurveyQuestion(
      number: 20,
      category: 'Cansancio o Fatiga',
      options: [
        SurveyOption(score: 0, text: 'No estoy más cansado o fatigado que lo habitual.'),
        SurveyOption(score: 1, text: 'Me fatigo o me canso más fácilmente que lo habitual.'),
        SurveyOption(score: 2, text: 'Estoy demasiado fatigado o cansado para hacer muchas de las cosas que solía hacer.'),
        SurveyOption(score: 3, text: 'Estoy demasiado fatigado o cansado para hacer la mayoría de las cosas que solía hacer'),
      ],
    ),
    SurveyQuestion(
      number: 21,
      category: 'Pérdida de Interés en el Sexo',
      options: [
        SurveyOption(score: 0, text: 'No he notado ningún cambio reciente en mi interés por el sexo.'),
        SurveyOption(score: 1, text: 'Estoy menos interesado en el sexo de lo que solía estarlo.'),
        SurveyOption(score: 2, text: 'Estoy mucho menos interesado en el sexo.'),
        SurveyOption(score: 3, text: 'He perdido completamente el interés en el sexo.'),
      ],
    ),
  ];
}

/// Preguntas del Inventario de Ansiedad de Beck (BAI)
class BAIQuestions {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Torpe o entumecido',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Acalorado',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Con temblor en las piernas',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Incapaz de relajarse',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Con temor a que ocurra lo peor',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: 'Mareado, o que se le va la cabeza',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: 'Con latidos del corazón fuertes y acelerados',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 8,
      category: 'Inestable',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 9,
      category: 'Atemorizado o asustado',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 10,
      category: 'Nervioso',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 11,
      category: 'Con sensación de bloqueo',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 12,
      category: 'Con temblores en las manos',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 13,
      category: 'Inquieto, inseguro',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 14,
      category: 'Con miedo a perder el control',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 15,
      category: 'Con sensación de ahogo',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 16,
      category: 'Con temor a morir',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 17,
      category: 'Con miedo',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 18,
      category: 'Con problemas digestivos',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 19,
      category: 'Con desvanecimientos',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 20,
      category: 'Con rubor facial',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
    SurveyQuestion(
      number: 21,
      category: 'Con sudores, fríos o calientes',
      options: [
        SurveyOption(score: 0, text: 'En absoluto'),
        SurveyOption(score: 1, text: 'Levemente'),
        SurveyOption(score: 2, text: 'Moderadamente'),
        SurveyOption(score: 3, text: 'Severamente'),
      ],
    ),
  ];
}
