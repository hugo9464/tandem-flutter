import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/tandem_service.dart';
import '../../models/tandem.dart';
import 'tandem_detail_screen.dart';
import 'create_tandem_screen.dart';
import 'join_tandem_screen.dart';
import '../banking/bank_selection_screen.dart';

class TandemSelectionScreen extends StatefulWidget {
  const TandemSelectionScreen({super.key});

  @override
  State<TandemSelectionScreen> createState() => _TandemSelectionScreenState();
}

class _TandemSelectionScreenState extends State<TandemSelectionScreen> {
  List<Tandem> _tandems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTandems();
  }

  Future<void> _loadTandems() async {
    setState(() => _isLoading = true);
    try {
      final tandems = await TandemService.getUserTandems();
      if (mounted) {
        setState(() {
          _tandems = tandems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tandems.isEmpty
                ? _buildNoTandemView()
                : _buildTandemListView(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BankSelectionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.account_balance),
        label: const Text('Banques'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildNoTandemView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          
          Text(
            'Bienvenue sur Tandem',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez ou rejoignez un tandem pour commencer',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTandemScreen(),
                  ),
                );
                _loadTandems();
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Créer un tandem',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinTandemScreen(),
                  ),
                );
                _loadTandems();
              },
              icon: const Icon(Icons.group_add),
              label: Text(
                'Rejoindre un tandem',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildTandemListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes Tandems',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez un tandem pour continuer',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadTandems,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _tandems.length + 1,
              itemBuilder: (context, index) {
                if (index == _tandems.length) {
                  return _buildAddTandemCard();
                }
                return _TandemCard(
                  tandem: _tandems[index],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TandemDetailScreen(tandemId: _tandems[index].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddTandemCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTandemScreen(),
                  ),
                );
                _loadTandems();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Créer',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const JoinTandemScreen(),
                  ),
                );
                _loadTandems();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_add, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Rejoindre',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TandemCard extends StatelessWidget {
  final Tandem tandem;
  final VoidCallback onTap;

  const _TandemCard({
    required this.tandem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tandem.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${tandem.code}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}