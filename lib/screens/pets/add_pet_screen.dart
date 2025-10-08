import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pet_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedSpecies = 'Perro';
  String? _birthDate;

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

  void _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    await petProvider.addPet(
      ownerId: authProvider.user!.uid,
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      birthDate: _birthDate,
      vaccines: [],
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
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la mascota',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  border: OutlineInputBorder(),
                ),
                items: speciesDescriptions.keys
                    .map((species) => DropdownMenuItem(
                          value: species,
                          child: Text(species),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedSpecies = value!);
                },
              ),
              const SizedBox(height: 8),
              Text(
                speciesDescriptions[_selectedSpecies] ?? '',
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _birthDate == null
                          ? 'Selecciona la fecha de nacimiento'
                          : 'Nacimiento: $_birthDate',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.teal),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.pets),
                label: Text(
                  'Guardar Mascota',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                onPressed: _addPet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
