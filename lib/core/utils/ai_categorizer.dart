class AICategorizer {
  static const Map<String, String> _patterns = {
    'starbucks': 'Comida/Café',
    'netflix': 'Suscripciones',
    'spotify': 'Suscripciones',
    'amazon': 'Compras',
    'mercadona': 'Supermercado',
    'lidl': 'Supermercado',
    'uber': 'Transporte',
    'cabify': 'Transporte',
    'gasolinera': 'Transporte',
    'alquiler': 'Vivienda',
    'nomina': 'Salario',
  };

  static String suggestCategory(String description) {
    final desc = description.toLowerCase();
    for (var entry in _patterns.entries) {
      if (desc.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Otros';
  }
}
