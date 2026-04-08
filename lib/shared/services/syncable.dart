// Responsabilidad: definir el contrato minimo para servicios/repositorios sincronizables.
abstract class ISyncable {
  Future<int> syncPendingToServer();
  Future<void> downloadFromServer();
}
