import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _showContactInfo = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _nameController.text = doc.data()?['name'] ?? '';
          _ageController.text = doc.data()?['age']?.toString() ?? '';
          _phoneController.text = doc.data()?['phone'] ?? '';
          _addressController.text = doc.data()?['address'] ?? '';
          _cityController.text = doc.data()?['city'] ?? '';
          _experienceController.text = doc.data()?['experienceYears']?.toString() ?? '';
          _bioController.text = doc.data()?['bio'] ?? '';
          _showContactInfo = doc.data()?['showContactInfo'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
        'email': user.email,
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'experienceYears': int.tryParse(_experienceController.text) ?? 0,
        'bio': _bioController.text.trim(),
        'showContactInfo': _showContactInfo,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente ✅'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.teal),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : 'No especificado',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(child: Text('No hay usuario autenticado'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con foto de perfil
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.teal,
                                    width: 3,
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF26c6da), Color(0xFF00acc1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                                      : Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.teal,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                    onPressed: _pickImage,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _nameController.text.isNotEmpty 
                                ? _nameController.text 
                                : 'Usuario',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user.email ?? 'Correo no disponible',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Información Personal
                    Text(
                      'Información Personal',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Edad
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Edad',
                        prefixIcon: const Icon(Icons.cake_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu edad';
                        if (int.tryParse(value) == null) return 'Debe ser un número';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Información de Contacto
                    Text(
                      'Información de Contacto',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Esta información será visible para otros usuarios si lo permites',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Dirección
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Ciudad
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Ciudad',
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Toggle para mostrar información de contacto
                    Card(
                      elevation: 2,
                      child: SwitchListTile(
                        title: Text(
                          'Mostrar información de contacto',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Otros usuarios podrán ver tu teléfono y dirección',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        value: _showContactInfo,
                        onChanged: (value) {
                          setState(() {
                            _showContactInfo = value;
                          });
                        },
                        secondary: const Icon(Icons.visibility_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Experiencia con mascotas
                    TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Años de experiencia con mascotas',
                        prefixIcon: const Icon(Icons.pets_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tus años de experiencia';
                        if (int.tryParse(value) == null) return 'Debe ser un número';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Sobre mí',
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Botón guardar
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save, size: 20),
                              label: Text(
                                'GUARDAR PERFIL',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.teal.withOpacity(0.3),
                              ),
                              onPressed: _saveProfile,
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Vista previa de cómo verán otros tu perfil
                    Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(top: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.visibility_outlined, color: Colors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  'Vista previa pública',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildInfoCard('Nombre', _nameController.text, Icons.person),
                            _buildInfoCard('Experiencia', 
                                _experienceController.text.isNotEmpty 
                                    ? '${_experienceController.text} años' 
                                    : '', 
                                Icons.pets),
                            _buildInfoCard('Biografía', _bioController.text, Icons.description),
                            if (_showContactInfo) ...[
                              _buildInfoCard('Teléfono', _phoneController.text, Icons.phone),
                              _buildInfoCard('Ubicación', 
                                  '${_addressController.text}${_addressController.text.isNotEmpty && _cityController.text.isNotEmpty ? ', ' : ''}${_cityController.text}', 
                                  Icons.location_on),
                            ] else ...[
                              _buildInfoCard('Contacto', 'Información privada', Icons.lock_outline),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}