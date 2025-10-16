import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet_model.dart';

class AdoptPetScreen extends StatelessWidget {
  const AdoptPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopta una Mascota'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<PetModel>>(
        stream: petProvider.getAdoptablePets(authProvider.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay mascotas disponibles para adopción 🐾'),
            );
          }

          final pets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage(
                      'assets/icons/${pet.species.toLowerCase()}.png',
                    ),
                  ),
                  title: Text(pet.name),
                  subtitle: Text(pet.species),
                  trailing: ElevatedButton(
                    child: const Text('Adoptar'),
                    onPressed: () async {
                      await petProvider.adoptPet(pet.id, authProvider.user!.uid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('¡Has adoptado a ${pet.name}! 🎉')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
