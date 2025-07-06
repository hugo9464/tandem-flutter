import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/tandem_service.dart';
import '../../models/tandem.dart';

class CreateTandemScreen extends StatefulWidget {
  const CreateTandemScreen({super.key});

  @override
  State<CreateTandemScreen> createState() => _CreateTandemScreenState();
}

class _CreateTandemScreenState extends State<CreateTandemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  Tandem? _createdTandem;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createTandem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tandem = await TandemService.createTandem(_nameController.text.trim());
      setState(() {
        _createdTandem = tandem;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyCode() {
    if (_createdTandem != null) {
      Clipboard.setData(ClipboardData(text: _createdTandem!.code));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copié !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Tandem'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _createdTandem == null
              ? _buildCreateForm()
              : _buildSuccessView(),
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        
        Icon(
          Icons.favorite,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Créer votre Tandem',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Donnez un nom à votre tandem pour commencer',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF718096),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du tandem',
                  hintText: 'Ex: Marie & Jean',
                  prefixIcon: const Icon(Icons.people_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  if (value.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createTandem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Créer le tandem',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.check,
            size: 40,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'Tandem créé !',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _createdTandem!.name,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A5568),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Code d\'invitation',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _createdTandem!.code,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copier le code',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Partagez ce code avec votre partenaire',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF718096),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continuer',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const Spacer(flex: 2),
      ],
    );
  }
}