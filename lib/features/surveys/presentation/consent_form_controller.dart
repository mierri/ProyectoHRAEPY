import 'package:flutter/foundation.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/shared/models/patient_model.dart';

// Responsabilidad: manejar estado, validaciones y envio del formulario de consentimiento.
class ConsentFormController extends ChangeNotifier {
  final String? surveyType;

  ConsentFormController({this.surveyType});

  String _name = '';
  DateTime? _dateOfBirth;
  String _gender = 'M';
  bool _consentGiven = false;
  bool _isLoading = false;
  PatientModel? _selectedPatient;
  List<PatientModel> _availablePatients = [];
  bool _isLoadingPatients = false;
  String? _osteoporosisWarning;
  double? _weight;
  double? _height;
  double? _imc;

  String get resolvedSurveyType => SurveyTypeConfig.normalizeType(surveyType);
  bool get isOsteoporosisSurvey => resolvedSurveyType == 'osteoporosis';

  String get name => _name;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get gender => _gender;
  bool get consentGiven => _consentGiven;
  bool get isLoading => _isLoading;
  PatientModel? get selectedPatient => _selectedPatient;
  List<PatientModel> get availablePatients => List.unmodifiable(_availablePatients);
  bool get isLoadingPatients => _isLoadingPatients;
  String? get osteoporosisWarning => _osteoporosisWarning;
  double? get weight => _weight;
  double? get height => _height;
  double? get imc => _imc;

  int? get patientAge {
    if (_selectedPatient != null) return _selectedPatient!.age;
    if (_dateOfBirth != null) {
      final now = DateTime.now();
      var age = now.year - _dateOfBirth!.year;
      if (now.month < _dateOfBirth!.month ||
          (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
        age--;
      }
      return age;
    }
    return null;
  }

  bool get osteoporosisAgeInvalid {
    final age = patientAge;
    return isOsteoporosisSurvey && age != null && age < 50;
  }

  String get imcText => _imc == null ? '' : _imc!.toStringAsFixed(2);

  Future<void> loadAvailablePatients(PatientService patientService) async {
    _isLoadingPatients = true;
    notifyListeners();
    try {
      _availablePatients = patientService.patients;
    } catch (error) {
      debugPrint('Error loading patients: $error');
    } finally {
      _isLoadingPatients = false;
      notifyListeners();
    }
  }

  void selectPatient(PatientModel patient) {
    _selectedPatient = patient;
    _name = patient.name;
    _dateOfBirth = patient.birthDate;
    _gender = patient.gender;
    notifyListeners();
  }

  void clearSelectedPatient() {
    _selectedPatient = null;
    _name = '';
    _dateOfBirth = null;
    _osteoporosisWarning = null;
    notifyListeners();
  }

  void onNameChanged(String value) {
    _name = value.trim();
    notifyListeners();
  }

  void onDateOfBirthChanged(DateTime? value) {
    _dateOfBirth = value;
    notifyListeners();
  }

  void onGenderChanged(String code) {
    _gender = code;
    notifyListeners();
  }

  void onConsentChanged(bool value) {
    _consentGiven = value;
    notifyListeners();
  }

  void onWeightChanged(String value) {
    _weight = double.tryParse(value.trim());
    _recalculateImc();
    notifyListeners();
  }

  void onHeightChanged(String value) {
    _height = double.tryParse(value.trim());
    _recalculateImc();
    notifyListeners();
  }

  void _recalculateImc() {
    if (!isOsteoporosisSurvey) {
      _imc = null;
      return;
    }
    if (_weight != null && _height != null && _height! > 0) {
      _imc = _weight! / (_height! * _height!);
    } else {
      _imc = null;
    }
  }

  String? _validateBeforeSubmit() {
    if (isOsteoporosisSurvey) {
      final age = patientAge;
      if (age != null && age < 50) {
        _osteoporosisWarning = 'Solo disponible para pacientes de 50 años o más.';
        return _osteoporosisWarning;
      }

      if (_weight == null || _height == null || _imc == null) {
        _osteoporosisWarning = 'Por favor complete peso, talla e IMC.';
        return _osteoporosisWarning;
      }
      _osteoporosisWarning = null;
    }

    if (_name.trim().isEmpty) {
      return 'Por favor ingrese el nombre completo o seleccione un paciente';
    }
    if (_dateOfBirth == null) {
      return 'Por favor seleccione la fecha de nacimiento';
    }
    if (!_consentGiven) {
      return 'Debe aceptar el consentimiento informado para continuar';
    }
    return null;
  }

  Future<int> submit(PatientService patientService) async {
    final validationError = _validateBeforeSubmit();
    if (validationError != null) {
      notifyListeners();
      throw Exception(validationError);
    }

    _isLoading = true;
    notifyListeners();

    try {
      PatientModel? patient;
      if (_selectedPatient != null) {
        patient = _selectedPatient;
      } else {
        patient = await patientService.createPatient(
          name: _name.trim(),
          birthDate: _dateOfBirth!,
          gender: _gender,
        );
      }

      if (patient == null) {
        throw Exception('No se pudo crear el registro del paciente. Por favor intente nuevamente.');
      }

      if (isOsteoporosisSurvey) {
        patient.weight = _weight;
        patient.height = _height;
        patient.imc = _imc;
        await patient.save();
      }

      return patient.patientId;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
