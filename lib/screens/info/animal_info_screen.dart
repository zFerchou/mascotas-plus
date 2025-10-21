import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimalInfoScreen extends StatelessWidget {
  const AnimalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🐾 Información Animales Sin Hogar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de problema
            _buildInfoCard(
              title: 'El Problema',
              content: 'Millones de animales están sin hogar en todo el mundo. '
                  'Estas mascotas necesitan cuidado, amor y un hogar permanente.',
              icon: Icons.warning,
              color: Colors.orange,
            ),
            
            const SizedBox(height: 16),
            
            // Tarjeta de cómo ayudar
            _buildInfoCard(
              title: '¿Cómo Puedes Ayudar?',
              content: '1. Adopta, no compres\n'
                  '2. Esteriliza a tus mascotas\n'
                  '3. Sé voluntario en refugios\n'
                  '4. Dona alimentos o recursos\n'
                  '5. Comparte información en redes sociales',
              icon: Icons.volunteer_activism,
              color: Colors.green,
            ),
            
            const SizedBox(height: 16),
            
            // Tarjeta de beneficios
            _buildInfoCard(
              title: 'Beneficios de Adoptar',
              content: '✅ Salvas una vida\n'
                  '✅ Recibes amor incondicional\n'
                  '✅ Combates el comercio de mascotas\n'
                  '✅ Ayudas a reducir la sobrepoblación\n'
                  '✅ Encuentras un compañero fiel',
              icon: Icons.favorite,
              color: Colors.red,
            ),
            
            const SizedBox(height: 16),
            
            // Estadísticas
            _buildStatsCard(),
            
            const SizedBox(height: 16),
            
            // Llamado a la acción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.pets, size: 50, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    '¡Tú puedes marcar la diferencia!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cada pequeña acción cuenta. Juntos podemos crear un mundo mejor para los animales.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Estadísticas Importantes',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatItem('Animales sin hogar mundialmente', '200+ millones'),
            _buildStatItem('Eutanasiados anualmente', '2.7 millones'),
            _buildStatItem('Adopciones anuales', '4.1 millones'),
            _buildStatItem('Refugios en Latinoamérica', '5,000+'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }
}