class CategorizationEngine {
  static const Map<String, List<String>> rules = {
    'Comida': ['mercadona', 'carrefour', 'lidl', 'aldi', 'uber eats', 'glovo', 'restaurante', 'burger king', 'mcdonalds'],
    'Transporte': ['uber', 'cabify', 'gasolinera', 'renfe', 'metro', 'emt', 'parking'],
    'Vivienda': ['alquiler', 'hipoteca', 'endesa', 'naturgy', 'iberdrola', 'agua', 'comunidad'],
    'Ocio': ['netflix', 'spotify', 'hbo', 'cine', 'teatro', 'concierto', 'steam', 'playstation'],
    'Salud': ['farmacia', 'hospital', 'dentista', 'sanitas', 'adeslas'],
    'Suscripciones': ['amazon prime', 'disney+', 'apple services', 'gym', 'gimnasio'],
  };

  static String categorize(String transactionName) {
    final nameLower = transactionName.toLowerCase();
    
    for (var entry in rules.entries) {
      for (var keyword in entry.value) {
        if (nameLower.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return 'Otros';
  }
}


