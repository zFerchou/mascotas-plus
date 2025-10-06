import 'package:flutter/material.dart';
import '../../models/pet_model.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;

  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${pet.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Especie: ${pet.species}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (pet.birthDate != null)
              Text(
                'Fecha de nacimiento: ${pet.birthDate}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            const Text(
              'Vacunas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...pet.vaccines.map((vaccine) => Text(
                  '${vaccine['name']} - ${vaccine['date']}',
                  style: const TextStyle(fontSize: 16),
                )),
            const SizedBox(height: 16),
            const Text(
              'Citas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...pet.appointments.map((appointment) => Text(
                  '${appointment['date']} - ${appointment['note']}',
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}
