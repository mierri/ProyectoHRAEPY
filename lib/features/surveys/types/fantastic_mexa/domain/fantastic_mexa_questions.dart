import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

/// IDs reservados (fuera del rango 1-46) para las respuestas de "datos generales"
/// que se guardan junto con la encuesta pero no suman al puntaje clinico.
class FantasticMexaGeneralDataFields {
  static const int fecha = 900;
  static const int iniciales = 901;
  static const int escolaridad = 902;
  static const int ocupacion = 903;
  static const int estadoCivil = 904;
  static const int habitantesCasa = 905;
  static const int numHabitantes = 906;
  static const int anosLaborando = 907;
  static const int horarioLaboral = 908;
  static const int pesoKg = 909;
  static const int estaturaM = 910;

  static const List<int> all = [
    fecha,
    iniciales,
    escolaridad,
    ocupacion,
    estadoCivil,
    habitantesCasa,
    numHabitantes,
    anosLaborando,
    horarioLaboral,
    pesoKg,
    estaturaM,
  ];
}

/// Opciones fijas de "datos generales" del cuestionario FANTASTIC MEX-A.
class FantasticMexaGeneralDataOptions {
  static const List<String> escolaridad = [
    'Primaria',
    'Secundaria',
    'Preparatoria',
    'Licenciatura',
    'Posgrado',
  ];

  static const List<String> estadoCivil = [
    'Soltero/a',
    'Casado/a',
    'Divorciado/a',
    'Union libre',
    'Separado/a',
    'Viudo/a',
  ];

  static const List<String> habitantesCasa = [
    'Pareja sin hijos',
    'Padres e hijos',
    'Mama o papa solo e hijos',
    'Padres, hijos y otros',
    'Padres, cuyos hijos ya salieron del hogar',
    'Otros y yo',
    'Unicamente yo',
  ];

  static const List<String> horarioLaboral = [
    'Medio tiempo',
    'Tiempo completo',
    'No empleado',
  ];

  static const List<String> numHabitantes = [
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10 o mas',
  ];
}

/// Ruta del asset de imagen para cada pregunta 1-45. La pregunta 46 (IMC) no tiene imagen.
class FantasticMexaImages {
  static String? forQuestion(int number) {
    if (number < 1 || number > 45) return null;
    return 'assets/imagenes-webp/$number.webp';
  }
}

/// Preguntas del cuestionario FANTASTIC MEX-A (Hernandez-Lopez y De Blas-Rangel, 2021).
/// 46 items puntuados 0-4; la puntuacion total (0-186) se interpreta con una tabla de 5 niveles.
class FantasticMexaQuestions {
  static const List<SurveyQuestion> questions = [
    // Familia y amigos
    SurveyQuestion(
      number: 1,
      category: 'Mi comunicacion con los demas es honesta, abierta y clara',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Me cuesta trabajo decir buenos dias, perdon, gracias o lo siento',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Tengo con quien hablar de las cosas que son importantes para mi',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Doy carino',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Recibo carino',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),

    // Actividad fisica y asociatividad
    SurveyQuestion(
      number: 6,
      category:
          'He realizado ejercicio fisico durante 30 minutos, tan intenso como para sentirme agitado/a o fatigado/a',
      options: [
        SurveyOption(score: 4, text: '4 veces o mas a la semana'),
        SurveyOption(score: 3, text: '3 veces a la semana'),
        SurveyOption(score: 2, text: '2 veces a la semana'),
        SurveyOption(score: 1, text: '1 vez a la semana'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: 'Participo en programas o actividades de ejercicio fisico bajo supervision',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 8,
      category: 'Soy integrante activo/a de un grupo de apoyo a mi salud o calidad de vida',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),

    // Nutricion
    SurveyQuestion(
      number: 9,
      category: 'Mi alimentacion diaria es balanceada',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 10,
      category: 'Desayuno diariamente',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 11,
      category: 'Consumo mucha azucar, sal, comida chatarra o con mucha grasa',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 12,
      category: 'Bebo ocho vasos con agua cada dia',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),

    // Tabaco, toxinas y dependencia
    SurveyQuestion(
      number: 13,
      category: 'Tengo sin fumar un solo cigarrillo',
      options: [
        SurveyOption(score: 4, text: 'Mas de un ano o no fumo'),
        SurveyOption(score: 3, text: 'Mas de seis meses'),
        SurveyOption(score: 2, text: 'Mas de un mes'),
        SurveyOption(score: 1, text: 'Mas de una semana'),
        SurveyOption(score: 0, text: 'Menos de una semana'),
      ],
    ),
    SurveyQuestion(
      number: 14,
      category: 'Generalmente fumo ___ cigarrillos por dia',
      options: [
        SurveyOption(score: 0, text: 'Mas de 15'),
        SurveyOption(score: 1, text: 'De 11 a 15'),
        SurveyOption(score: 2, text: 'De 6 a 10'),
        SurveyOption(score: 3, text: 'De 1 a 5'),
        SurveyOption(score: 4, text: 'Ninguno'),
      ],
    ),
    SurveyQuestion(
      number: 15,
      category: 'Uso drogas como marihuana, cocaina u otras',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 16,
      category: 'Uso excesivamente medicamento sin prescripcion medica',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 17,
      category: 'Tomo cafe o bebidas con cafeina',
      options: [
        SurveyOption(score: 0, text: 'Mas de 10 al dia'),
        SurveyOption(score: 1, text: '7 a 10 al dia'),
        SurveyOption(score: 2, text: '3 a 6 al dia'),
        SurveyOption(score: 3, text: '1 a 2 al dia'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),

    // Alcohol
    SurveyQuestion(
      number: 18,
      category: 'El numero promedio de bebidas alcoholicas que tomo por semana es de',
      options: [
        SurveyOption(score: 4, text: '0 a 7 bebidas'),
        SurveyOption(score: 3, text: '8 a 10 bebidas'),
        SurveyOption(score: 2, text: '11 a 13 bebidas'),
        SurveyOption(score: 1, text: '14 a 20 bebidas'),
        SurveyOption(score: 0, text: 'Mas de 20 bebidas'),
      ],
    ),
    SurveyQuestion(
      number: 19,
      category: 'Bebo mas de 4 bebidas alcoholicas en una misma ocasion',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 20,
      category: 'Manejo el auto despues de tomar bebidas alcoholicas',
      options: [
        SurveyOption(score: 0, text: 'Mas de una vez al mes'),
        SurveyOption(score: 1, text: 'Una vez al mes'),
        SurveyOption(score: 2, text: 'Solo ocasionalmente'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 21,
      category: 'Considero que los efectos de las bebidas alcoholicas son daninos',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 22,
      category: 'Las personas con quienes vivo toman bebidas alcoholicas',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),

    // Sueno y estres
    SurveyQuestion(
      number: 23,
      category: 'Duermo bien y me siento descansado/a al levantarme',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 24,
      category: 'Duermo 7 a 9 horas por la noche',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 25,
      category: 'El numero de episodios de estres importante que vivi el ultimo ano fue de',
      options: [
        SurveyOption(score: 0, text: 'Mas de cinco'),
        SurveyOption(score: 1, text: 'De cuatro a cinco'),
        SurveyOption(score: 2, text: 'De dos a tres'),
        SurveyOption(score: 3, text: 'Uno'),
        SurveyOption(score: 4, text: 'Ninguno'),
      ],
    ),
    SurveyQuestion(
      number: 26,
      category:
          'Me siento capaz de manejar situaciones estresantes o de encontrar facilmente alternativas de solucion',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 27,
      category: 'Me relajo y disfruto mi tiempo libre',
      options: [
        SurveyOption(score: 4, text: 'Diario'),
        SurveyOption(score: 3, text: '3 a 5 veces por semana'),
        SurveyOption(score: 2, text: '1 a 2 veces por semana'),
        SurveyOption(score: 1, text: 'Menos de 1 vez por semana'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),

    // Tipo de personalidad
    SurveyQuestion(
      number: 28,
      category: 'Tengo la sensacion de urgencia o impaciencia en mi vida cotidiana',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 29,
      category: 'Me siento enojado/a o agresivo/a en mi vida cotidiana',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 30,
      category: 'Me siento de buen humor en mi vida cotidiana',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 31,
      category: 'Tengo la necesidad de controlar mi entorno en la vida cotidiana',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),

    // Introspeccion
    SurveyQuestion(
      number: 32,
      category: 'Mis pensamientos son positivos y optimistas en mi vida cotidiana',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 33,
      category: 'Me siento ansioso/a o preocupado/a en mi vida cotidiana',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 34,
      category: 'Me siento deprimido/a o triste en mi vida cotidiana',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),

    // Carrera (satisfaccion laboral)
    SurveyQuestion(
      number: 35,
      category: 'Me siento contento/a con mi trabajo y actividades',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 36,
      category: 'Tengo buenas relaciones con quienes trabajo',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 37,
      category: 'Me he sentido presionado/a o agredido/a por parte de mis companeros de trabajo',
      options: [
        SurveyOption(score: 0, text: 'Siempre'),
        SurveyOption(score: 1, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 3, text: 'Rara vez'),
        SurveyOption(score: 4, text: 'Nunca'),
      ],
    ),

    // Control de salud y sexualidad
    SurveyQuestion(
      number: 38,
      category: 'Asisto a consulta para vigilar mi estado de salud',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 39,
      category: 'Realizo el control periodico de mi peso',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 40,
      category: 'En mi conducta sexual me preocupo del autocuidado y del cuidado de mi pareja',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 41,
      category: 'Converso con mi pareja o familia aspectos de sexualidad',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 42,
      category: 'Me acepto y me siento satisfecho/a con mi apariencia fisica o la forma como me veo',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),

    // Orden y disciplina
    SurveyQuestion(
      number: 43,
      category: 'Soy organizado/a con las responsabilidades diarias',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 44,
      category: 'Tengo claro el objetivo de mi vida',
      options: [
        SurveyOption(score: 4, text: 'Siempre'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),
    SurveyQuestion(
      number: 45,
      category: 'Respeto las normas de transito',
      options: [
        SurveyOption(score: 4, text: 'Siempre/No manejo'),
        SurveyOption(score: 3, text: 'Frecuentemente'),
        SurveyOption(score: 2, text: 'Algunas veces'),
        SurveyOption(score: 1, text: 'Rara vez'),
        SurveyOption(score: 0, text: 'Nunca'),
      ],
    ),

    // Somatometria
    SurveyQuestion(
      number: 46,
      category: 'Indice de Masa Corporal (Peso en kg dividido Estatura en mt dividido Estatura en mt)',
      options: [
        SurveyOption(score: 4, text: 'Menor a 25'),
        SurveyOption(score: 3, text: 'Menor a 30'),
        SurveyOption(score: 2, text: 'Menor a 35'),
        SurveyOption(score: 1, text: 'Menor a 40'),
        SurveyOption(score: 0, text: 'Igual o mayor a 40'),
      ],
    ),
  ];
}
