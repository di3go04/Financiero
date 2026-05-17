import 'package:flutter/material.dart';
import 'widgets/landing_hero.dart';
import 'widgets/landing_features.dart';
import 'widgets/landing_how_it_works.dart';

import 'widgets/landing_pricing.dart';
import 'widgets/landing_customization.dart';
import 'widgets/landing_footer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            LandingHero(),
            LandingFeatures(),
            LandingHowItWorks(),
            LandingPricing(),
            LandingCustomization(),
            LandingFooter(),
          ],
        ),
      ),
    );
  }
}
