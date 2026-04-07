// Responsabilidad: mapear representaciones de genero entre UI (codigos) y base de datos (etiquetas).
class GenderMapper {
  static const Map<String, String> _toDb = {
    'M': 'Masculino',
    'F': 'Femenino',
    'O': 'Otro',
    'N': 'Prefiero no decir',
  };

  static const Map<String, String> _fromDb = {
    'Masculino': 'M',
    'Femenino': 'F',
    'Otro': 'O',
    'Prefiero no decir': 'N',
  };

  static String toDb(String code) => _toDb[code] ?? code;

  static String fromDb(String label) => _fromDb[label] ?? label;
}
