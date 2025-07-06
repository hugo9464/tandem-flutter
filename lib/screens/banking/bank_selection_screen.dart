import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gocardless_service.dart';
import '../../models/gocardless_models.dart';
import 'bank_connection_screen.dart';

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  String _searchQuery = '';
  String _selectedCountry = 'FR';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeService();
    });
  }

  Future<void> _initializeService() async {
    final service = Provider.of<GoCardlessService>(context, listen: false);
    
    if (!service.isAuthenticated) {
      final success = await service.authenticate();
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(service.error ?? 'Échec de l\'authentification'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }
    
    await service.fetchInstitutions(country: _selectedCountry);
  }

  List<BankInstitution> get _filteredInstitutions {
    final service = Provider.of<GoCardlessService>(context);
    if (_searchQuery.isEmpty) {
      return service.institutions;
    }
    
    return service.institutions.where((institution) {
      return institution.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             institution.bic.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner votre banque'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<GoCardlessService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des banques...'),
                ],
              ),
            );
          }

          if (service.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializeService,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final institutions = _filteredInstitutions;

          return Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une banque...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              
              // Sélecteur de pays
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Pays: '),
                    DropdownButton<String>(
                      value: _selectedCountry,
                      items: const [
                        DropdownMenuItem(value: 'FR', child: Text('🇫🇷 France')),
                        DropdownMenuItem(value: 'ES', child: Text('🇪🇸 Espagne')),
                        DropdownMenuItem(value: 'DE', child: Text('🇩🇪 Allemagne')),
                        DropdownMenuItem(value: 'IT', child: Text('🇮🇹 Italie')),
                        DropdownMenuItem(value: 'NL', child: Text('🇳🇱 Pays-Bas')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCountry = value;
                          });
                          service.fetchInstitutions(country: value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Liste des banques
              Expanded(
                child: institutions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune banque trouvée',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Essayez de modifier votre recherche ou changez de pays',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: institutions.length,
                        itemBuilder: (context, index) {
                          final institution = institutions[index];
                          return _BankTile(
                            institution: institution,
                            onTap: () => _connectToBank(institution),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _connectToBank(BankInstitution institution) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankConnectionScreen(institution: institution),
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  final BankInstitution institution;
  final VoidCallback onTap;

  const _BankTile({
    required this.institution,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            institution.logo,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.grey[600],
                ),
              );
            },
          ),
        ),
        title: Text(
          institution.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BIC: ${institution.bic}'),
            if (institution.countries.isNotEmpty)
              Text(
                'Pays: ${institution.countries.join(', ')}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}