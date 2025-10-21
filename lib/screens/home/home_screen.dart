import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/pet_model.dart';
import '../auth/login_screen.dart';
import '../pets/add_pet_screen.dart';
import '../pets/pet_detail_screen.dart';
import '../settings/profile_screen.dart';
import '../pets/adopt_pet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _carouselTimer;

  final List<Map<String, dynamic>> _motivationalMessages = [
    {
      'title': 'Adopta, \nsalva una vida',
      'subtitle': 'CAMBIALO TODO',
      'emoji': '🐕',
      'icon': Icons.favorite,
      'gradient': [const Color(0xFF26c6da), const Color(0xFF00acc1)],
      'badge': '50% OFF'
    },
    {
      'title': 'Un amigo \nfiel espera',
      'subtitle': 'ENCONTRALO HOY',
      'emoji': '🐈',
      'icon': Icons.celebration,
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)],
      'badge': 'NUEVO'
    },
    {
      'title': 'Hogares \nllenos de amor',
      'subtitle': 'SE PARTE',
      'emoji': '❤️',
      'icon': Icons.home,
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
      'badge': 'POPULAR'
    },
    {
      'title': 'Segunda \noportunidad',
      'subtitle': 'DALES AMOR',
      'emoji': '🏠',
      'icon': Icons.star,
      'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      'badge': 'LIMITADO'
    },
    {
      'title': 'Familia \nque crece',
      'subtitle': 'ADOPTA YA',
      'emoji': '👨‍👩‍👧‍👦',
      'icon': Icons.people,
      'gradient': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
      'badge': 'OFERTA'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Auto-animate carousel
    _startAutoCarousel();
  }

  void _startAutoCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _motivationalMessages.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoCarousel() {
    _carouselTimer?.cancel();
  }

  void _restartAutoCarousel() {
    _startAutoCarousel();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

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
          IconButton(
            icon: const Icon(Icons.pets, color: Colors.white),
            tooltip: 'Adoptar Mascota',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdoptPetScreen()),
              );
            },
          ),
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              try {
                await authProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Header con fondo curvo
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: CurvedBackgroundClipper(),
              child: Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF26c6da), Color(0xFF00acc1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tus compañeros\nleales",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Cuida y ama a tus mascotas",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Carrusel de mensajes motivacionales MEJORADO
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: 180,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollStartNotification) {
                        _stopAutoCarousel();
                      } else if (notification is ScrollEndNotification) {
                        _restartAutoCarousel();
                      }
                      return false;
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _motivationalMessages.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final message = _motivationalMessages[index];
                        return _buildEnhancedCarouselItem(message, index);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Indicadores del carrusel MEJORADOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _motivationalMessages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentPage == index 
                            ? Colors.teal 
                            : Colors.grey.shade300,
                        boxShadow: _currentPage == index 
                            ? [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Grid de mascotas - SEPARADO del carrusel
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 16),
            sliver: _buildPetsGrid(authProvider, petProvider),
          ),
          
          // Banner promocional al final MEJORADO
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildPromotionalBanner(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent.shade700,
        elevation: 6,
        child: const Icon(Icons.add, size: 32),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPetScreen()),
        ),
      ),
    );
  }

  Widget _buildEnhancedCarouselItem(Map<String, dynamic> message, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: List<Color>.from(message['gradient']),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdoptPetScreen()),
              );
            },
            splashColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.1),
            child: Stack(
              children: [
                // Patrón de fondo decorativo
                Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(
                      message['icon'] as IconData,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                message['badge'],
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Título
                            Text(
                              message['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Subtítulo
                            Text(
                              message['subtitle'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            
                            // Botón de acción
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.white.withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Descubrir',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Emoji/Icono grande
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            message['emoji'],
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetsGrid(AuthProvider authProvider, PetProvider petProvider) {
    return StreamBuilder<List<PetModel>>(
      stream: petProvider.getPets(authProvider.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        final pets = snapshot.data!;

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final pet = pets[index];
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPetCard(pet, petProvider),
              );
            },
            childCount: pets.length,
          ),
        );
      },
    );
  }

  Widget _buildPetCard(PetModel pet, PetProvider petProvider) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: pet)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.tealAccent.withOpacity(0.2),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Imagen de mascota
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icons/${pet.species.toLowerCase()}.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay degradado para texto
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.1),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pet.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
            // Badge adoptable
            if (pet.isAdoptable)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Adoptable',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            // Botón eliminar
            Positioned(
              right: 8,
              bottom: 8,
              child: IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                onPressed: () async {
                  await petProvider.deletePet(pet.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF26c6da), Color(0xFF00acc1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Primera\nmascota",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "REGISTRA AQUÍ",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.pets, size: 60, color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aún no tienes mascotas registradas 🐾',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.teal[900],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration, size: 50, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Adopta y\nGana Premios",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "PROGRAMA FIDELIDAD".toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Text(
                    'Ver Beneficios',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper para el fondo curvo
class CurvedBackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}