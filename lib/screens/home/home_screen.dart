import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet_model.dart';
import '../pets/add_pet_screen.dart';
import '../pets/pet_detail_screen.dart';
import '../settings/profile_screen.dart'; // 👈 Importamos el nuevo perfil

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🐾 Mis Mascotas',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        actions: [
          // 👤 Botón de perfil
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Ver Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          // 🚪 Botón de logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f7fa), Color(0xFFb2ebf2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<PetModel>>(
          stream: petProvider.getPets(authProvider.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Aún no tienes mascotas registradas 🐾',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.teal[900],
                  ),
                ),
              );
            }

            final pets = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF80deea), Color(0xFF26c6da)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage(
                            'assets/icons/${pet.species.toLowerCase()}.png',
                          ),
                        ),
                        title: Text(
                          pet.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          pet.species,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.white),
                          onPressed: () async {
                            await petProvider.deletePet(pet.id);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Mascota'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPetScreen()),
        ),
      ),
    );
  }
}
