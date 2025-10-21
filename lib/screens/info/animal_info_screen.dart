import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimalInfoScreen extends StatelessWidget {
  const AnimalInfoScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          '🐾 Conciencia Animal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Emotivo
            _buildEmotionalHeader(),
            
            // Sección de Estadísticas Impactantes
            _buildStatisticsSection(),
            
            // Gráficas y Datos Visuales
            _buildVisualDataSection(context),
            
            // Razones para Adoptar
            _buildAdoptionReasons(),
            
            // Proceso de Adopción
            _buildAdoptionProcess(),
            
            // Cómo Ayudar
            _buildHowToHelp(),
            
            // Fundaciones y Enlaces
            _buildFoundationsSection(),
            
            // Llamado Final a la Acción
            _buildFinalCallToAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, size: 50, color: Colors.white.withOpacity(0.9)),
          const SizedBox(height: 16),
          Text(
            'Cada Vida Merece una Segunda Oportunidad',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Miles de animales esperan un hogar donde recibir amor y cuidado. '
            'Tú puedes ser su héroe.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📈 La Realidad en Números',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 20),
          
          // Tarjetas de estadísticas
          _buildStatCard(
            '600+ Millones',
            'Animales sin hogar en el mundo',
            Icons.pets,
            Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          
          _buildStatCard(
            '3 Millones',
            'Eutanasiados cada año en refugios',
            Icons.heart_broken,
            Colors.orange.shade400,
          ),
          const SizedBox(height: 12),
          
          _buildStatCard(
            '25%',
            'De mascotas en refugios son de raza pura',
            Icons.flag,
            Colors.purple.shade400,
          ),
          const SizedBox(height: 12),
          
          _buildStatCard(
            'Solo 30%',
            'De animales en refugios encuentran hogar',
            Icons.home,
            Colors.green.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String text, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualDataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Impacto Visual de la Adopción',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 20),
          
          // Gráfica de barras simple
          _buildBarChart(context),
          const SizedBox(height: 24),
          
          // Datos comparativos
          _buildComparisonData(),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Destino de Animales en Refugios',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildBar('Adoptados', 30, Colors.green, context),
          const SizedBox(height: 12),
          _buildBar('Eutanasiados', 40, Colors.red, context),
          const SizedBox(height: 12),
          _buildBar('Esperando', 30, Colors.orange, context),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int percentage, Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            Text('$percentage%', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 20,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: (MediaQuery.of(context).size.width - 88) * (percentage / 100),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonData() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '💰 Comparación de Costos',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildCostComparison('Adopción', '\$50-\$150', 'Incluye vacunas, esterilización y chequeo'),
          const SizedBox(height: 12),
          _buildCostComparison('Compra en Tienda', '\$500-\$2000+', 'Costos adicionales de vacunas y cuidados'),
        ],
      ),
    );
  }

  Widget _buildCostComparison(String type, String cost, String includes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  includes,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: type == 'Adopción' ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              cost,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: type == 'Adopción' ? Colors.green.shade800 : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionReasons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❤️ ¿Por Qué Adoptar?',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildReasonCard(
            'Salvas una Vida',
            'Le das una segunda oportunidad a un ser vivo que merece amor y cuidado.',
            Icons.favorite,
            Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          
          _buildReasonCard(
            'Combates el Comercio',
            'No apoyas las fábricas de cachorros que explotan animales.',
            Icons.gpp_good,
            Colors.purple.shade400,
          ),
          const SizedBox(height: 12),
          
          _buildReasonCard(
            'Ahorras Dinero',
            'La adopción es más económica e incluye vacunas y esterilización.',
            Icons.savings,
            Colors.green.shade400,
          ),
          const SizedBox(height: 12),
          
          _buildReasonCard(
            'Mascotas Agradecidas',
            'Los animales adoptados muestran un amor y lealtad incomparables.',
            Icons.emoji_emotions,
            Colors.orange.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
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
    );
  }

  Widget _buildAdoptionProcess() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔄 Proceso de Adopción',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildProcessStep('1', 'Visita el Refugio', 'Conoce a los animales disponibles'),
          _buildProcessStep('2', 'Entrevista', 'Evalúan tu compatibilidad'),
          _buildProcessStep('3', 'Visita al Hogar', 'Verifican que tengas espacio adecuado'),
          _buildProcessStep('4', 'Firmas el Contrato', 'Compromiso de cuidado responsable'),
          _buildProcessStep('5', '¡Lleva a Casa!', 'Comienza una nueva vida juntos'),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToHelp() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤝 Otras Formas de Ayudar',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildHelpChip('🏠 Hogar Temporal', Icons.home_work),
              _buildHelpChip('💰 Donaciones', Icons.attach_money),
              _buildHelpChip('🕒 Voluntariado', Icons.people),
              _buildHelpChip('📢 Difusión', Icons.share),
              _buildHelpChip('🎁 Suministros', Icons.local_grocery_store),
              _buildHelpChip('🎉 Eventos', Icons.celebration),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.teal.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundationsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏥 Fundaciones que Necesitan Tu Ayuda',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Estas organizaciones trabajan incansablemente para rescatar y cuidar animales. '
            'Tu apoyo puede hacer la diferencia.',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildFoundationCard(
            'Patitas de la Calle',
            'Rescate y rehabilitación de animales en situación de calle',
            'https://www.patitasdelacalle.org',
          ),
          const SizedBox(height: 12),
          
          _buildFoundationCard(
            'Amigos de los Animales',
            'Refugio y programa de adopción responsable',
            'https://www.amigosdelosanimales.org',
          ),
          const SizedBox(height: 12),
          
          _buildFoundationCard(
            'Hogar Temporal Animal',
            'Red de hogares temporales para animales rescatados',
            'https://www.hogartemporalanimal.org',
          ),
        ],
      ),
    );
  }

  Widget _buildFoundationCard(String name, String description, String url) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, color: Colors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalCallToAction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite_border, size: 50, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            'Tú Puedes Cambiar una Vida',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Cada adopción, cada donación, cada hora de voluntariado cuenta. '
            'Juntos podemos crear un mundo mejor para los animales que nos necesitan.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '¡Haz la Diferencia Hoy!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.teal.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}