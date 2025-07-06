import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tandem Banking',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const Text(
              'Tandem est votre compagnon bancaire personnel, offrant une expérience fluide pour gérer vos comptes et transactions.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Fonctionnalités :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Visualisez tous vos comptes en un seul endroit'),
            const Text('• Suivez vos transactions avec un filtrage avancé'),
            const Text('• Mises à jour des soldes en temps réel'),
            const Text('• Sécurisé et privé'),
            const SizedBox(height: 24),
            const Text(
              'Développé avec Flutter',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}