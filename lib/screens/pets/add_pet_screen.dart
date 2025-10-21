import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedSpecies = 'Perro';
  String _selectedGender = 'Macho';
  String? _birthDate;

  List<Map<String, dynamic>> _vaccines = [];
  File? _petImage;
  String? _petImageUrl; // Para web

  final Map<String, String> speciesDescriptions = {
    'Perro': 'Compañero leal y protector 🐶',
    'Gato': 'Independiente y curioso 🐱',
    'Ave': 'Alegre y lleno de energía 🐦',
    'Conejo': 'Tierno y tranquilo 🐰',
    'Hamster': 'Pequeño y juguetón 🐹',
    'Pez': 'Relajante y colorido 🐠',
    'Tortuga': 'Pacífica y longeva 🐢',
    'Serpiente': 'Exótica y fascinante 🐍',
    'Caballo': 'Fuerte y noble 🐴',
    'Iguana': 'Silenciosa y observadora 🦎',
  };

  // 📸 Seleccionar imagen - COMPATIBLE CON WEB
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    
    if (picked != null) {
      setState(() {
        // Para web usamos la URL, para móvil el File
        if (kIsWeb) {
          _petImageUrl = picked.path;
          _petImage = null;
        } else {
          _petImage = File(picked.path);
          _petImageUrl = null;
        }
      });
    }
  }

  // Método auxiliar para la imagen por defecto
  Widget _buildDefaultImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.teal, size: 35),
        SizedBox(height: 5),
        Text('Agregar foto', 
            style: TextStyle(color: Colors.teal, fontSize: 12))
      ],
    );
  }

  // Widget de imagen compatible con web y móvil
  Widget _buildPetImage() {
    if (kIsWeb && _petImageUrl != null) {
      // Para Web
      return Image.network(
        _petImageUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    } else if (!kIsWeb && _petImage != null) {
      // Para Móvil
      return Image.file(
        _petImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    } else {
      // Sin imagen
      return _buildDefaultImage();
    }
  }

  // 🧬 Agregar vacuna
  void _addVaccine() {
    showDialog(
      context: context,
      builder: (context) {
        final _vaccineNameController = TextEditingController();
        DateTime? _vaccineDate;

        return AlertDialog(
          title: const Text("Agregar vacuna 💉"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vaccineNameController,
                decoration: const InputDecoration(labelText: "Nombre de la vacuna"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (pickedDate != null) {
                    setState(() => _vaccineDate = pickedDate);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_vaccineDate == null
                    ? 'Seleccionar fecha'
                    : "${_vaccineDate!.day}/${_vaccineDate!.month}/${_vaccineDate!.year}"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Agregar"),
              onPressed: () {
                if (_vaccineNameController.text.isNotEmpty && _vaccineDate != null) {
                  setState(() {
                    _vaccines.add({
                      'name': _vaccineNameController.text,
                      'date': "${_vaccineDate!.day}/${_vaccineDate!.month}/${_vaccineDate!.year}",
                    });
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 🗓️ Seleccionar fecha de nacimiento
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _birthDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // 🐾 Guardar mascota
  void _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    await petProvider.addPet(
      ownerId: authProvider.user!.uid,
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      birthDate: _birthDate,
      vaccines: _vaccines,
      appointments: [],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mascota agregada con éxito 🎉',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota', style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 📸 Imagen - COMPATIBLE CON WEB Y MÓVIL
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _buildPetImage(), // Widget adaptativo
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🐾 Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la mascota',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 20),

              // 🐶 Especie
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  border: OutlineInputBorder(),
                ),
                items: speciesDescriptions.keys
                    .map((species) => DropdownMenuItem(value: species, child: Text(species)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSpecies = value!);
                },
              ),
              const SizedBox(height: 8),
              Text(
                speciesDescriptions[_selectedSpecies] ?? '',
                style: GoogleFonts.poppins(fontStyle: FontStyle.italic, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // ⚤ Género
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                  DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                ],
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const SizedBox(height: 20),

              // 🧬 Raza
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Raza', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // 🎨 Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // ⚖️ Peso
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso (kg)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // 📅 Fecha de nacimiento
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _birthDate == null ? 'Selecciona fecha de nacimiento' : 'Nacimiento: $_birthDate',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.teal),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 💉 Vacunas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Vacunas registradas:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add, color: Colors.teal), onPressed: _addVaccine),
                ],
              ),
              if (_vaccines.isEmpty)
                const Text('Aún no has agregado vacunas.')
              else
                ..._vaccines.map(
                  (v) => ListTile(
                    leading: const Icon(Icons.health_and_safety, color: Colors.green),
                    title: Text(v['name']),
                    subtitle: Text('Fecha: ${v['date']}'),
                  ),
                ),

              const SizedBox(height: 20),

              // 📝 Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // 🐾 Botón guardar
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.pets),
                label: Text('Guardar Mascota', style: GoogleFonts.poppins(fontSize: 16)),
                onPressed: _addPet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}