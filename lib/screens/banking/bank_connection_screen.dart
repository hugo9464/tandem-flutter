import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../services/gocardless_service.dart';
import '../../services/preferences_service.dart';
import '../../models/gocardless_models.dart';
import 'bank_accounts_screen.dart';

class BankConnectionScreen extends StatefulWidget {
  final BankInstitution institution;

  const BankConnectionScreen({
    super.key,
    required this.institution,
  });

  @override
  State<BankConnectionScreen> createState() => _BankConnectionScreenState();
}

class _BankConnectionScreenState extends State<BankConnectionScreen> {
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;
  String? _requisitionId;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeWebView();
    }
    _createRequisition();
  }

  void _initializeWebView() {
    if (!kIsWeb) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
              _handleUrlChange(url);
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              _handleUrlChange(request.url);
              return NavigationDecision.navigate;
            },
          ),
        );
    }
  }

  void _handleUrlChange(String url) {
    debugPrint('🌐 Navigation vers: $url');

    // Détecter si l'utilisateur a terminé l'authentification
    if (url.contains('localhost') ||
        url.contains('success') ||
        url.contains('callback')) {
      // Extraire l'ID de requisition de l'URL si possible
      final uri = Uri.parse(url);
      final ref = uri.queryParameters['ref'];

      if (ref != null && _requisitionId != null) {
        _onAuthenticationComplete();
      }
    }
  }

  Future<void> _createRequisition() async {
    final service = Provider.of<GoCardlessService>(context, listen: false);

    try {
      // URL de redirection après authentification
      // Utiliser l'URL actuelle de l'app Flutter
      final currentUri = Uri.base;
      final redirectUrl = '${currentUri.origin}/callback';

      final response = await service.createRequisition(
        widget.institution.id,
        redirectUrl,
      );

      if (response != null && response['linkUrl'] != null) {
        // Stocker l'ID de requisition
        _requisitionId = response['requisitionId'];
        final linkUrl = response['linkUrl'];
        if (kIsWeb) {
          // Sur le web, ouvrir l'URL dans un nouvel onglet
          _launchUrlInNewTab(linkUrl!);
          _showManualAuthDialog();
        } else {
          // Sur mobile, utiliser WebView
          await _webViewController!.loadRequest(Uri.parse(linkUrl!));
          _startAuthenticationCheck();
        }
      } else {
        setState(() {
          _errorMessage =
              service.error ?? 'Impossible de créer la connexion bancaire';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création de la requisition: $e';
      });
    }
  }

  Future<void> _launchUrlInNewTab(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        _errorMessage = 'Impossible d\'ouvrir l\'URL de connexion bancaire';
      });
    }
  }

  void _showManualAuthDialog() {
    setState(() {
      _isLoading = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connexion bancaire'),
        content: const Text(
            'Un nouvel onglet s\'est ouvert pour vous connecter à votre banque. '
            'Une fois l\'authentification terminée, revenez à cette page et cliquez sur "Terminé".'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour à la sélection
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onAuthenticationComplete();
            },
            child: const Text('Terminé'),
          ),
        ],
      ),
    );
  }

  void _startAuthenticationCheck() {
    // On simule la détection de fin d'authentification
    // Dans un vrai projet, on récupérerait l'ID de requisition de l'URL de callback
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _showAuthenticationDialog();
      }
    });
  }

  void _showAuthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentification bancaire'),
        content: const Text(
            'Avez-vous terminé l\'authentification avec votre banque ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retour à la sélection
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onAuthenticationComplete();
            },
            child: const Text('Terminé'),
          ),
        ],
      ),
    );
  }

  void _onAuthenticationComplete() async {
    // Utiliser l'ID de requisition stocké
    if (_requisitionId == null) {
      setState(() {
        _errorMessage =
            'Erreur: ID de requisition manquant. Veuillez réessayer.';
      });
      return;
    }

    // Sauvegarder la connexion GoCardless
    try {
      final prefsService = PreferencesService();
      await prefsService.saveGoCardlessConnection(
        requisitionId: _requisitionId!,
        institutionData: widget.institution.toJson(),
      );
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la connexion: $e');
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BankAccountsScreen(
            institution: widget.institution,
            requisitionId: _requisitionId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Connexion ${widget.institution.name}'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de connexion',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion ${widget.institution.name}'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _webViewController?.reload(),
            ),
        ],
      ),
      body: Consumer<GoCardlessService>(
        builder: (context, service, child) {
          if (service.isLoading && !_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Préparation de la connexion...'),
                ],
              ),
            );
          }

          if (kIsWeb) {
            // Sur le web, afficher un message informatif
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 64,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Connexion bancaire',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Un nouvel onglet va s\'ouvrir pour vous connecter à votre banque de manière sécurisée.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Sur mobile, afficher WebView
            return Stack(
              children: [
                if (_webViewController != null)
                  WebViewWidget(controller: _webViewController!),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.institution.logo,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.institution.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Connexion sécurisée via GoCardless',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Suivez les instructions de votre banque pour autoriser l\'accès à vos données.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
