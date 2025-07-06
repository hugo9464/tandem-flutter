import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(
              Icons.support_agent,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Nous Contacter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nous sommes là pour vous aider ! Contactez-nous via l\'un des canaux suivants :',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _ContactItem(
              icon: Icons.email,
              title: 'E-mail',
              subtitle: 'support@tandem.com',
              onTap: () {},
            ),
            _ContactItem(
              icon: Icons.phone,
              title: 'Téléphone',
              subtitle: '+1 (800) 123-4567',
              onTap: () {},
            ),
            _ContactItem(
              icon: Icons.chat,
              title: 'Chat en Direct',
              subtitle: 'Disponible 24h/24 et 7j/7',
              onTap: () {},
            ),
            const Spacer(),
            const Text(
              'Heures d\'ouverture : Lun-Ven 9h-18h CET',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}