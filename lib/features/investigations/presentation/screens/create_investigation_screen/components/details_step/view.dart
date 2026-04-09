import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestigationDetailsStep extends StatelessWidget {
  final TextEditingController nameController;

  const InvestigationDetailsStep({
    super.key,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final name = nameController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre de la investigacion').semiBold(),
        const Gap(8),
        TextField(
          controller: nameController,
          placeholder: const Text('Ej. Estudio de estado cognitivo'),
        ),
        const Gap(6),
        Text(
          name.isEmpty
              ? 'Este campo es obligatorio.'
              : 'Minimo 3 caracteres para continuar.',
        ).small().muted(),
      ],
    );
  }
}

