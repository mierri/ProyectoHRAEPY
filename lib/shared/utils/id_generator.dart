import 'dart:math';

int generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final rand = Random().nextInt(9999);
  return ts * 10000 + rand;
}
