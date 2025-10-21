import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/message_provider.dart';
import '../../models/pet_model.dart';
import '../auth/login_screen.dart';
import '../pets/add_pet_screen.dart';
import '../settings/profile_screen.dart';
import '../pets/adopt_pet_screen.dart';
import '../info/animal_info_screen.dart';
import '../notifications/notifications_screen.dart';
import '../chat/chat_screen.dart';

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
  PetModel? _selectedPet;
  int _currentIndex = 0;

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

  final List<Widget> _screens = [
    const HomeContent(),
    const AdoptPetScreen(),
    const AnimalInfoScreen(),
    const ProfileScreen(),
  ];

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
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

  // ✅ NUEVO: Modal de interés en adopción
  void _showAdoptionInterestModal(PetModel pet) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal.shade100,
                    child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              pet.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            pet.name[0],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interés en adopción',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Estás interesado en adoptar a ${pet.name}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Opciones de contacto
              _buildContactOption(
                icon: Icons.chat,
                title: 'Enviar mensaje',
                subtitle: 'Chatea directamente con el dueño',
                onTap: () {
                  Navigator.pop(context);
                  _startChatWithOwner(pet, authProvider);
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildContactOption(
                icon: Icons.info,
                title: 'Más información',
                subtitle: 'Solicitar detalles adicionales',
                onTap: () {
                  Navigator.pop(context);
                  _requestMoreInfo(pet, authProvider);
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildContactOption(
                icon: Icons.visibility,
                title: 'Conocer a ${pet.name}',
                subtitle: 'Coordinar una visita',
                onTap: () {
                  Navigator.pop(context);
                  _scheduleVisit(pet, authProvider);
                },
              ),
              
              const Spacer(),
              
              // Botón cancelar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }

  void _startChatWithOwner(PetModel pet, AuthProvider authProvider) async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    
    try {
      final conversationId = await messageProvider.startConversation(
        petId: pet.id,
        petName: pet.name,
        ownerId: pet.ownerId,
        interestedUserId: authProvider.user!.uid,
        interestedUserName: authProvider.user!.displayName ?? 'Usuario',
      );

      // Navegar a la pantalla de chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            pet: pet,
            otherUserId: pet.ownerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar conversación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _requestMoreInfo(PetModel pet, AuthProvider authProvider) async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    
    try {
      final conversationId = await messageProvider.startConversation(
        petId: pet.id,
        petName: pet.name,
        ownerId: pet.ownerId,
        interestedUserId: authProvider.user!.uid,
        interestedUserName: authProvider.user!.displayName ?? 'Usuario',
      );

      // Enviar mensaje automático solicitando información
      await messageProvider.sendMessage(
        conversationId: conversationId,
        senderId: authProvider.user!.uid,
        receiverId: pet.ownerId,
        content: 'Hola! Me interesa adoptar a ${pet.name}. ¿Podrías darme más información?',
        petId: pet.id,
        petName: pet.name,
      );

      // Navegar al chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            pet: pet,
            otherUserId: pet.ownerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar mensaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scheduleVisit(PetModel pet, AuthProvider authProvider) async {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    
    try {
      final conversationId = await messageProvider.startConversation(
        petId: pet.id,
        petName: pet.name,
        ownerId: pet.ownerId,
        interestedUserId: authProvider.user!.uid,
        interestedUserName: authProvider.user!.displayName ?? 'Usuario',
      );

      // Enviar mensaje automático para coordinar visita
      await messageProvider.sendMessage(
        conversationId: conversationId,
        senderId: authProvider.user!.uid,
        receiverId: pet.ownerId,
        content: 'Hola! Me encantaría conocer a ${pet.name}. ¿Podríamos coordinar una visita?',
        petId: pet.id,
        petName: pet.name,
      );

      // Navegar al chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            pet: pet,
            otherUserId: pet.ownerId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar mensaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPetDetailsModal(PetModel pet) {
    setState(() {
      _selectedPet = pet;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPetDetailModal(pet),
    );
  }

  void _confirmAdoption(PetModel pet) {
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
              await _setPetForAdoption(pet);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setPetForAdoption(PetModel pet) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    final updatedPet = PetModel(
      id: pet.id,
      ownerId: pet.ownerId,
      name: pet.name,
      species: pet.species,
      birthDate: pet.birthDate,
      vaccines: pet.vaccines,
      appointments: pet.appointments,
      isAdoptable: true,
      imageUrl: pet.imageUrl,
    );

    await petProvider.updatePet(updatedPet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pet.name} ahora está disponible para adopción 🐶'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
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

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton() : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        '🐾 Mis Mascotas',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.teal,
      actions: [
        // ✅ NUEVO: Ícono de notificaciones con contador
        StreamBuilder<int>(
          stream: Provider.of<MessageProvider>(context, listen: false)
              .getUnreadCount(Provider.of<AuthProvider>(context, listen: false).user!.uid),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.white),
                  tooltip: 'Mensajes',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Cerrar Sesión',
          onPressed: () async {
            try {
              await Provider.of<AuthProvider>(context, listen: false).logout();
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
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Home',
                isActive: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _buildNavItem(
                icon: Icons.pets,
                label: 'Adoptar',
                isActive: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildNavItem(
                icon: Icons.info,
                label: 'Información',
                isActive: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'Perfil',
                isActive: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.teal : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isActive ? Colors.teal : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.tealAccent.shade700,
      elevation: 6,
      child: const Icon(Icons.add, size: 32),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddPetScreen()),
      ),
    );
  }

  // Método para construir la tarjeta de mascota - AHORA ES PÚBLICO
  Widget buildPetCard(PetModel pet, PetProvider petProvider) {
    final emoji = _speciesEmojis[pet.species] ?? '🐾';
    final color = _speciesColors[pet.species] ?? Colors.teal.shade100;

    return GestureDetector(
      onTap: () => _showPetDetailsModal(pet),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Stack(
          children: [
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
                    
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
                    
                    if (pet.isAdoptable)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              const Icon(Icons.favorite, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Adoptable',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
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
            
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar mascota'),
                        content: Text('¿Estás seguro de eliminar a ${pet.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      await petProvider.deletePet(pet.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${pet.name} eliminado correctamente'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDetailModal(PetModel pet) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwner = pet.ownerId == authProvider.user!.uid;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blueAccent,
                          child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    pet.imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text(
                                        pet.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Text(
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
                        leading: const Icon(Icons.health_and_safety_outlined, color: Colors.green),
                        title: Text('${v['name']}'),
                        subtitle: Text('Fecha: ${v['date']}'),
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
                    
                    const SizedBox(height: 10),
                    
                    const Text(
                      '📅 Citas:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ...pet.appointments.map(
                      (a) => ListTile(
                        leading: const Icon(Icons.event_note, color: Colors.orange),
                        title: Text('Fecha: ${a['date']}'),
                        subtitle: Text(a['note'] ?? 'Sin descripción'),
                      ),
                    ),
                    if (pet.appointments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No hay citas registradas',
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // ✅ NUEVO: Botones según el tipo de usuario
                    if (!isOwner && pet.isAdoptable)
                      ElevatedButton.icon(
                        onPressed: () => _showAdoptionInterestModal(pet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        label: const Text(
                          'Me interesa adoptar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    if (isOwner && !pet.isAdoptable)
                      ElevatedButton.icon(
                        onPressed: () => _confirmAdoption(pet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                        label: const Text(
                          'Dar en adopción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    if (pet.isAdoptable && isOwner)
                      const Center(
                        child: Text(
                          'Esta mascota ya está disponible para adopción 💚',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
            child: Stack(
              children: [
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
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            Text(
                              message['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message['subtitle'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildFallbackImage(Color color, String emoji) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 50),
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
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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
            child: Stack(
              children: [
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
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            Text(
                              message['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message['subtitle'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    return CustomScrollView(
      slivers: [
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
        
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                height: 180,
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
              const SizedBox(height: 16),
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
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        
        // ✅ CORREGIDO: Ahora pasa el contexto correctamente
        _HomePetsGrid(
          authProvider: authProvider, 
          petProvider: petProvider,
          homeState: context.findAncestorStateOfType<_HomeScreenState>()!,
        ),
        
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomePetsGrid extends StatelessWidget {
  final AuthProvider authProvider;
  final PetProvider petProvider;
  final _HomeScreenState homeState;

  const _HomePetsGrid({
    required this.authProvider,
    required this.petProvider,
    required this.homeState,
  });

  @override
  Widget build(BuildContext context) {
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
            child: homeState._buildEmptyState(),
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
              // ✅ CORREGIDO: Ahora usa el método buildPetCard del homeState
              return homeState.buildPetCard(pet, petProvider);
            },
            childCount: pets.length,
          ),
        );
      },
    );
  }
}

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