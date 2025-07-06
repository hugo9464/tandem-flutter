import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/tandem_service.dart';

class JoinTandemScreen extends StatefulWidget {
  const JoinTandemScreen({super.key});

  @override
  State<JoinTandemScreen> createState() => _JoinTandemScreenState();
}

class _JoinTandemScreenState extends State<JoinTandemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _hasJoined = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinTandem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await TandemService.joinTandem(_codeController.text.trim());
      setState(() {
        _hasJoined = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre un Tandem'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _hasJoined ? _buildSuccessView() : _buildJoinForm(),
        ),
      ),
    );
  }

  Widget _buildJoinForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        
        Icon(
          Icons.group_add,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        
        Text(
          'Rejoindre un Tandem',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez le code d\'invitation partagé par votre partenaire',
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
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: 'ABC123',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un code';
                  }
                  if (value.trim().length != 6) {
                    return 'Le code doit contenir 6 caractères';
                  }
                  return null;
                },
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                maxLength: 6,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _joinTandem,
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
                          'Rejoindre',
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
          'Bienvenue dans le tandem !',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Vous avez rejoint le tandem avec succès',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: const Color(0xFF718096),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
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

// TextInputFormatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}