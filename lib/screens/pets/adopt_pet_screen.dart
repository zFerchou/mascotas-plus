import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet_model.dart';

class AdoptPetScreen extends StatefulWidget {
  const AdoptPetScreen({super.key});

  @override
  State<AdoptPetScreen> createState() => _AdoptPetScreenState();
}

class _AdoptPetScreenState extends State<AdoptPetScreen> {
  // Mapa de emojis y colores para fallback
  final Map<String, String> _speciesEmojis = {
    'Perro': '🐕', 'Gato': '🐈', 'Ave': '🐦', 'Conejo': '🐰',
    'Hamster': '🐹', 'Pez': '🐠', 'Tortuga': '🐢', 'Serpiente': '🐍',
    'Caballo': '🐴', 'Iguana': '🦎',
  };

  final Map<String, Color> _speciesColors = {
    'Perro': Colors.amber.shade100,
    'Gato': Colors.blueGrey.shade100,
    'Ave': Colors.lightBlue.shade100,
    'Conejo': Colors.pink.shade100,
    'Hamster': Colors.orange.shade100,
    'Pez': Colors.cyan.shade100,
    'Tortuga': Colors.green.shade100,
    'Serpiente': Colors.brown.shade100,
    'Caballo': Colors.deepOrange.shade100,
    'Iguana': Colors.lightGreen.shade100,
  };

  // ✅ NUEVO: Mostrar información del dueño
  void _showOwnerInfo(PetModel pet) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Obtener información del dueño desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(pet.ownerId)
          .get();

      // Cerrar loading
      Navigator.pop(context);

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo encontrar la información del dueño')),
        );
        return;
      }

      final userData = userDoc.data()!;
      final showContactInfo = userData['showContactInfo'] ?? false;

      // Mostrar modal con información del dueño
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildOwnerInfoModal(userData, showContactInfo, pet),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar información: $e')),
      );
    }
  }

  // ✅ NUEVO: Modal de información del dueño
  Widget _buildOwnerInfoModal(Map<String, dynamic> userData, bool showContactInfo, PetModel pet) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Información del Dueño 🏠',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                
                Text(
                  'Persona que ofrece a ${pet.name} en adopción',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Información básica siempre visible
                      _buildOwnerInfoItem(
                        icon: Icons.person,
                        title: 'Nombre',
                        value: userData['name'] ?? 'No especificado',
                      ),
                      
                      _buildOwnerInfoItem(
                        icon: Icons.pets,
                        title: 'Experiencia con mascotas',
                        value: userData['experienceYears'] != null 
                            ? '${userData['experienceYears']} años de experiencia' 
                            : 'No especificada',
                      ),
                      
                      if (userData['bio'] != null && userData['bio'].isNotEmpty)
                        _buildOwnerInfoItem(
                          icon: Icons.description,
                          title: 'Sobre el dueño',
                          value: userData['bio'],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Información de contacto (depende de la configuración de privacidad)
                      if (showContactInfo) ...[
                        Text(
                          'Información de Contacto:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        if (userData['phone'] != null && userData['phone'].isNotEmpty)
                          _buildOwnerInfoItem(
                            icon: Icons.phone,
                            title: 'Teléfono',
                            value: userData['phone'],
                          ),
                        
                        if (userData['city'] != null && userData['city'].isNotEmpty)
                          _buildOwnerInfoItem(
                            icon: Icons.location_city,
                            title: 'Ciudad',
                            value: userData['city'],
                          ),
                        
                        if (userData['address'] != null && userData['address'].isNotEmpty)
                          _buildOwnerInfoItem(
                            icon: Icons.home,
                            title: 'Dirección',
                            value: userData['address'],
                          ),
                        
                        const SizedBox(height: 20),
                        
                        // Botones de acción
                        Row(
                          children: [
                            if (userData['phone'] != null && userData['phone'].isNotEmpty)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Aquí puedes implementar la llamada telefónica
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Llamar a ${userData['phone']}')),
                                    );
                                  },
                                  icon: const Icon(Icons.phone, size: 18),
                                  label: const Text('Llamar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            
                            if (userData['phone'] != null && userData['phone'].isNotEmpty) 
                              const SizedBox(width: 10),
                            
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Aquí puedes implementar el envío de mensaje
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Enviar mensaje')),
                                  );
                                },
                                icon: const Icon(Icons.message, size: 18),
                                label: const Text('Mensaje'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Mensaje cuando la información está privada
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'El dueño ha configurado su información de contacto como privada. '
                                  'Puedes contactarlo a través de los botones de mensaje si comparte su teléfono.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Información adicional
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Consejo para la adopción:',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Coordina una visita para conocer a ${pet.name}\n'
                              '• Pregunta sobre sus hábitos y cuidados\n'
                              '• Asegúrate de tener todo listo para su llegada\n'
                              '• Sé paciente durante el periodo de adaptación',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ NUEVO: Item de información del dueño
  Widget _buildOwnerInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.green),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ✅ NUEVO: Mostrar detalles de mascota antes de adoptar
  void _showPetDetailsModal(PetModel pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPetDetailModal(pet),
    );
  }

  // ✅ NUEVO: Confirmar adopción
  void _showAdoptionConfirmation(PetModel pet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar Adopción 🐕'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres adoptar a ${pet.name}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (pet.vaccines.isNotEmpty) ...[
              const Text('✅ Incluye vacunas:'),
              ...pet.vaccines.take(2).map((v) => 
                Text('   • ${v['name']} (${v['date']})')
              ),
            ],
            if (pet.imageUrl != null) 
              const Text('✅ Incluye foto'),
            const SizedBox(height: 10),
            Text(
              '💡 Te recomendamos contactar al dueño primero',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.pets, color: Colors.white),
            label: const Text('Adoptar'),
            onPressed: () async {
              Navigator.pop(ctx);
              await _adoptPet(pet);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _adoptPet(PetModel pet) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    try {
      await petProvider.adoptPet(pet.id, authProvider.user!.uid);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Felicidades! Has adoptado a ${pet.name} 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al adoptar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ NUEVO: Widget para imagen de fallback
  Widget _buildFallbackImage(Color color, String emoji) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🐾 Adopta una Mascota',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<PetModel>>(
          stream: petProvider.getAdoptablePets(authProvider.user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay mascotas disponibles\npara adopción en este momento 🐾',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Vuelve pronto!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final pets = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header informativo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.heart_broken, color: Colors.green, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pets.length} mascota${pets.length > 1 ? 's' : ''} esperan un hogar',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[800],
                                ),
                              ),
                              Text(
                                'Dales una segunda oportunidad ❤️',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid de mascotas
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return _buildAdoptablePetCard(pet, petProvider);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ✅ NUEVO: Tarjeta moderna para mascotas adoptables CON BOTÓN DE CONTACTO
  Widget _buildAdoptablePetCard(PetModel pet, PetProvider petProvider) {
    final emoji = _speciesEmojis[pet.species] ?? '🐾';
    final color = _speciesColors[pet.species] ?? Colors.green.shade100;

    return GestureDetector(
      onTap: () => _showPetDetailsModal(pet),
      child: Container(
        child: Stack(
          children: [
            // Tarjeta principal
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Imagen de la mascota
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                            ? Image.network(
                                pet.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackImage(color, emoji);
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              )
                            : _buildFallbackImage(color, emoji),
                      ),
                    ),
                    
                    // Gradiente overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120, // Aumentado para los botones
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    
                    // Información de la mascota
                    Positioned(
                      bottom: 50, // Ajustado para los botones
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              pet.species,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // ✅ NUEVO: Botones de acción
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        children: [
                          // Botón de contacto
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showOwnerInfo(pet),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                foregroundColor: Colors.green.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.contact_page, size: 14),
                              label: const Text(
                                'Contactar Dueño',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Botón de adopción
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _showAdoptionConfirmation(pet),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.pets, size: 14),
                              label: const Text(
                                'Adoptar',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Badge de "En Adopción"
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Adopción',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NUEVO: Modal de detalles de mascota ACTUALIZADO
  Widget _buildPetDetailModal(PetModel pet) {
    final emoji = _speciesEmojis[pet.species] ?? '🐾';
    final color = _speciesColors[pet.species] ?? Colors.green.shade100;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
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
                  controller: scrollController,
                  children: [
                    // Header con imagen grande
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                            ? Image.network(
                                pet.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 60),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 60),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Información principal
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                pet.species,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ✅ NUEVO: Botón de contacto en el modal también
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context); // Cerrar este modal
                                _showOwnerInfo(pet); // Abrir modal del dueño
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.contact_page, size: 16),
                              label: const Text('Dueño'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showAdoptionConfirmation(pet),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.pets),
                              label: const Text('Adoptar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    
                    // Información detallada
                    if (pet.birthDate.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.cake, color: Colors.green),
                        title: const Text('Fecha de Nacimiento'),
                        subtitle: Text(pet.birthDate),
                      ),
                    
                    // Vacunas
                    const SizedBox(height: 10),
                    const Text(
                      '💉 Vacunas Registradas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...pet.vaccines.map(
                      (v) => ListTile(
                        leading: const Icon(Icons.health_and_safety, color: Colors.green),
                        title: Text(v['name'] ?? 'Vacuna'),
                        subtitle: Text('Fecha: ${v['date'] ?? 'No especificada'}'),
                        dense: true,
                      ),
                    ),
                    if (pet.vaccines.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No hay vacunas registradas',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    const Text(
                      '💡 Contacta al dueño para conocer más detalles y coordinar la adopción',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}