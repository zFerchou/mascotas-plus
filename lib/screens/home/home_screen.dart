import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet_model.dart';
import '../pets/add_pet_screen.dart';
import '../pets/pet_detail_screen.dart'; // <-- importamos la pantalla de detalle

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    // Si no hay usuario logueado, muestra un loader
    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Mascotas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<PetModel>>(
        stream: petProvider.getPets(authProvider.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes mascotas registradas.'));
          }

          final pets = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  title: Text(
                    pet.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    pet.species,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await petProvider.deletePet(pet.id);
                    },
                  ),
                  onTap: () {
                    // Navegar a la pantalla de detalle al tocar la tarjeta
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PetDetailScreen(pet: pet),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPetScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
