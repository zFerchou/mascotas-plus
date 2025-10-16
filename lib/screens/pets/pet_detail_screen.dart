import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import 'adopt_pet_screen.dart'; // asegúrate de tener esta pantalla creada

class PetDetailScreen extends StatelessWidget {
  final PetModel pet;

  const PetDetailScreen({super.key, required this.pet});

  void _confirmAdoption(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar adopción'),
        content: Text(
          '¿Estás seguro de que deseas poner a ${pet.name} en adopción?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.pets, color: Colors.white),
            label: const Text('Dar en adopción'),
            onPressed: () async {
              Navigator.pop(ctx);
              await _setPetForAdoption(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setPetForAdoption(BuildContext context) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    // Actualizamos el estado de la mascota
    final updatedPet = PetModel(
      id: pet.id,
      ownerId: pet.ownerId,
      name: pet.name,
      species: pet.species,
      birthDate: pet.birthDate,
      vaccines: pet.vaccines,
      appointments: pet.appointments,
      isAdoptable: true,
    );

    await petProvider.updatePet(updatedPet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pet.name} ahora está disponible para adopción 🐶'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Redirige a la pantalla de adopción
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdoptPetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (!pet.isAdoptable)
            IconButton(
              icon: const Icon(Icons.volunteer_activism),
              tooltip: 'Dar en adopción',
              onPressed: () => _confirmAdoption(context),
            ),
        ],
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                            fontWeight: FontWeight.bold,
                          ),
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
                  if (pet.birthDate.isNotEmpty)
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
                  const SizedBox(height: 30),
                  if (!pet.isAdoptable)
                    ElevatedButton.icon(
                      onPressed: () => _confirmAdoption(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.volunteer_activism,
                          color: Colors.white),
                      label: const Text(
                        'Dar en adopción',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (pet.isAdoptable)
                    const Center(
                      child: Text(
                        'Esta mascota ya está disponible para adopción 💚',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
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
