import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _addPet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    await petProvider.addPet(
      ownerId: authProvider.user!.uid,
      name: _nameController.text.trim(),
      species: _selectedSpecies,
      birthDate: _birthDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mascota agregada con éxito')),
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _birthDate = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Mascota')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la mascota'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: const InputDecoration(labelText: 'Especie'),
                items: const [
                  DropdownMenuItem(value: 'Perro', child: Text('Perro')),
                  DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                ],
                onChanged: (value) => setState(() => _selectedSpecies = value!),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(_birthDate == null
                      ? 'Seleccionar fecha de nacimiento'
                      : 'Nacimiento: $_birthDate'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPet,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
