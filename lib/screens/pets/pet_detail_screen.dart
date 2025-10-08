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
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          pet.name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          pet.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Text(
                    '🐾 Especie: ${pet.species}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (pet.birthDate != null)
                    Text(
                      '🎂 Nacimiento: ${pet.birthDate}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    '💉 Vacunas:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...pet.vaccines.map(
                    (v) => ListTile(
                      leading: const Icon(Icons.health_and_safety_outlined,
                          color: Colors.green),
                      title: Text('${v['name']}'),
                      subtitle: Text('Fecha: ${v['date']}'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '📅 Citas:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...pet.appointments.map(
                    (a) => ListTile(
                      leading: const Icon(Icons.event_note, color: Colors.orange),
                      title: Text('Fecha: ${a['date']}'),
                      subtitle: Text(a['note']),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
