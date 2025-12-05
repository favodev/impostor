import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final List<String> words;
  final bool isSelected;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.words,
    this.isSelected = false,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<String>? words,
    bool? isSelected,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      words: words ?? this.words,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Categorías
class PredefinedCategories {
  static const List<Category> all = [
    Category(
      id: 'food',
      name: 'Comida',
      icon: Icons.restaurant,
      words: [
        'Pizza',
        'Sushi',
        'Hamburguesa',
        'Tacos',
        'Paella',
        'Pasta',
        'Ensalada',
        'Helado',
        'Chocolate',
        'Churros',
        'Empanada',
        'Ceviche',
        'Ramen',
        'Curry',
        'Croissant',
      ],
    ),
    Category(
      id: 'places',
      name: 'Lugares',
      icon: Icons.place,
      words: [
        'Playa',
        'Montaña',
        'Museo',
        'Parque',
        'Cine',
        'Hospital',
        'Aeropuerto',
        'Biblioteca',
        'Estadio',
        'Centro comercial',
        'Restaurante',
        'Iglesia',
        'Universidad',
        'Zoológico',
        'Gimnasio',
      ],
    ),
    Category(
      id: 'animals',
      name: 'Animales',
      icon: Icons.pets,
      words: [
        'Elefante',
        'León',
        'Delfín',
        'Águila',
        'Serpiente',
        'Pingüino',
        'Koala',
        'Jirafa',
        'Canguro',
        'Pulpo',
        'Tigre',
        'Oso',
        'Lobo',
        'Ballena',
        'Cocodrilo',
      ],
    ),
    Category(
      id: 'technology',
      name: 'Tecnología',
      icon: Icons.computer,
      words: [
        'Smartphone',
        'Laptop',
        'Drone',
        'Robot',
        'Internet',
        'Bluetooth',
        'WiFi',
        'Impresora',
        'Videojuego',
        'Smartwatch',
        'Tablet',
        'Auriculares',
        'Cámara',
        'USB',
        'Inteligencia Artificial',
      ],
    ),
    Category(
      id: 'movies',
      name: 'Cine',
      icon: Icons.movie,
      words: [
        'Star Wars',
        'Titanic',
        'Avatar',
        'Matrix',
        'Jurassic Park',
        'El Padrino',
        'Toy Story',
        'Batman',
        'Harry Potter',
        'Frozen',
        'Inception',
        'Gladiator',
        'Avengers',
        'Forrest Gump',
        'El Rey León',
      ],
    ),
    Category(
      id: 'sports',
      name: 'Deportes',
      icon: Icons.sports_soccer,
      words: [
        'Fútbol',
        'Baloncesto',
        'Tenis',
        'Natación',
        'Béisbol',
        'Golf',
        'Boxeo',
        'Ciclismo',
        'Esquí',
        'Surf',
        'Volleyball',
        'Rugby',
        'Hockey',
        'Atletismo',
        'Gimnasia',
      ],
    ),
    Category(
      id: 'professions',
      name: 'Profesiones',
      icon: Icons.work,
      words: [
        'Doctor',
        'Abogado',
        'Chef',
        'Piloto',
        'Arquitecto',
        'Bombero',
        'Policía',
        'Maestro',
        'Ingeniero',
        'Músico',
        'Actor',
        'Científico',
        'Periodista',
        'Veterinario',
        'Diseñador',
      ],
    ),
    Category(
      id: 'countries',
      name: 'Países',
      icon: Icons.flag,
      words: [
        'España',
        'México',
        'Argentina',
        'Japón',
        'Francia',
        'Italia',
        'Brasil',
        'Alemania',
        'Australia',
        'Canadá',
        'Egipto',
        'India',
        'Rusia',
        'Sudáfrica',
        'Corea del Sur',
      ],
    ),
  ];
}
