import 'package:flutter/material.dart';

/// Palabra secreta con pista relacionada
class SecretWord {
  final String word;
  final String hint; // Palabra relacionada como pista

  const SecretWord({
    required this.word,
    required this.hint,
  });
}

class Category {
  final String id;
  final String name;
  final IconData icon;
  final List<SecretWord> secretWords;
  final bool isSelected;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.secretWords,
    this.isSelected = false,
  });

  /// Obtiene solo las palabras (para compatibilidad)
  List<String> get words => secretWords.map((sw) => sw.word).toList();

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<SecretWord>? secretWords,
    bool? isSelected,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      secretWords: secretWords ?? this.secretWords,
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

/// Categorías predefinidas con palabras y pistas relacionadas
class PredefinedCategories {
  static const List<Category> all = [
    Category(
      id: 'food',
      name: 'Comida',
      icon: Icons.restaurant,
      secretWords: [
        SecretWord(word: 'Pizza', hint: 'Italia'),
        SecretWord(word: 'Sushi', hint: 'Japón'),
        SecretWord(word: 'Hamburguesa', hint: 'Estados Unidos'),
        SecretWord(word: 'Tacos', hint: 'México'),
        SecretWord(word: 'Paella', hint: 'España'),
        SecretWord(word: 'Pasta', hint: 'Fideos'),
        SecretWord(word: 'Ensalada', hint: 'Vegetales'),
        SecretWord(word: 'Helado', hint: 'Frío'),
        SecretWord(word: 'Chocolate', hint: 'Cacao'),
        SecretWord(word: 'Churros', hint: 'Canela'),
        SecretWord(word: 'Empanada', hint: 'Relleno'),
        SecretWord(word: 'Ceviche', hint: 'Limón'),
        SecretWord(word: 'Ramen', hint: 'Caldo'),
        SecretWord(word: 'Curry', hint: 'Especias'),
        SecretWord(word: 'Croissant', hint: 'Francia'),
      ],
    ),
    Category(
      id: 'places',
      name: 'Lugares',
      icon: Icons.place,
      secretWords: [
        SecretWord(word: 'Playa', hint: 'Arena'),
        SecretWord(word: 'Montaña', hint: 'Altura'),
        SecretWord(word: 'Museo', hint: 'Arte'),
        SecretWord(word: 'Parque', hint: 'Árboles'),
        SecretWord(word: 'Cine', hint: 'Películas'),
        SecretWord(word: 'Hospital', hint: 'Doctores'),
        SecretWord(word: 'Aeropuerto', hint: 'Aviones'),
        SecretWord(word: 'Biblioteca', hint: 'Libros'),
        SecretWord(word: 'Estadio', hint: 'Deportes'),
        SecretWord(word: 'Centro comercial', hint: 'Tiendas'),
        SecretWord(word: 'Restaurante', hint: 'Menú'),
        SecretWord(word: 'Iglesia', hint: 'Religión'),
        SecretWord(word: 'Universidad', hint: 'Estudiantes'),
        SecretWord(word: 'Zoológico', hint: 'Animales'),
        SecretWord(word: 'Gimnasio', hint: 'Ejercicio'),
      ],
    ),
    Category(
      id: 'animals',
      name: 'Animales',
      icon: Icons.pets,
      secretWords: [
        SecretWord(word: 'Elefante', hint: 'Trompa'),
        SecretWord(word: 'León', hint: 'Melena'),
        SecretWord(word: 'Delfín', hint: 'Océano'),
        SecretWord(word: 'Águila', hint: 'Volar'),
        SecretWord(word: 'Serpiente', hint: 'Reptil'),
        SecretWord(word: 'Pingüino', hint: 'Antártida'),
        SecretWord(word: 'Koala', hint: 'Australia'),
        SecretWord(word: 'Jirafa', hint: 'Cuello'),
        SecretWord(word: 'Canguro', hint: 'Saltar'),
        SecretWord(word: 'Pulpo', hint: 'Tentáculos'),
        SecretWord(word: 'Tigre', hint: 'Rayas'),
        SecretWord(word: 'Oso', hint: 'Hibernar'),
        SecretWord(word: 'Lobo', hint: 'Manada'),
        SecretWord(word: 'Ballena', hint: 'Gigante'),
        SecretWord(word: 'Cocodrilo', hint: 'Pantano'),
      ],
    ),
    Category(
      id: 'technology',
      name: 'Tecnología',
      icon: Icons.computer,
      secretWords: [
        SecretWord(word: 'Smartphone', hint: 'Llamadas'),
        SecretWord(word: 'Laptop', hint: 'Portátil'),
        SecretWord(word: 'Drone', hint: 'Volar'),
        SecretWord(word: 'Robot', hint: 'Automatización'),
        SecretWord(word: 'Internet', hint: 'Conexión'),
        SecretWord(word: 'Bluetooth', hint: 'Inalámbrico'),
        SecretWord(word: 'WiFi', hint: 'Red'),
        SecretWord(word: 'Impresora', hint: 'Papel'),
        SecretWord(word: 'Videojuego', hint: 'Consola'),
        SecretWord(word: 'Smartwatch', hint: 'Muñeca'),
        SecretWord(word: 'Tablet', hint: 'Táctil'),
        SecretWord(word: 'Auriculares', hint: 'Música'),
        SecretWord(word: 'Cámara', hint: 'Fotos'),
        SecretWord(word: 'USB', hint: 'Memoria'),
        SecretWord(word: 'Inteligencia Artificial', hint: 'Aprendizaje'),
      ],
    ),
    Category(
      id: 'movies',
      name: 'Cine',
      icon: Icons.movie,
      secretWords: [
        SecretWord(word: 'Star Wars', hint: 'Espacio'),
        SecretWord(word: 'Titanic', hint: 'Barco'),
        SecretWord(word: 'Avatar', hint: 'Azul'),
        SecretWord(word: 'Matrix', hint: 'Píldora'),
        SecretWord(word: 'Jurassic Park', hint: 'Dinosaurios'),
        SecretWord(word: 'El Padrino', hint: 'Mafia'),
        SecretWord(word: 'Toy Story', hint: 'Juguetes'),
        SecretWord(word: 'Batman', hint: 'Murciélago'),
        SecretWord(word: 'Harry Potter', hint: 'Magia'),
        SecretWord(word: 'Frozen', hint: 'Hielo'),
        SecretWord(word: 'Inception', hint: 'Sueños'),
        SecretWord(word: 'Gladiator', hint: 'Roma'),
        SecretWord(word: 'Avengers', hint: 'Superhéroes'),
        SecretWord(word: 'Forrest Gump', hint: 'Correr'),
        SecretWord(word: 'El Rey León', hint: 'Simba'),
      ],
    ),
    Category(
      id: 'sports',
      name: 'Deportes',
      icon: Icons.sports_soccer,
      secretWords: [
        SecretWord(word: 'Fútbol', hint: 'Gol'),
        SecretWord(word: 'Baloncesto', hint: 'Canasta'),
        SecretWord(word: 'Tenis', hint: 'Raqueta'),
        SecretWord(word: 'Natación', hint: 'Piscina'),
        SecretWord(word: 'Béisbol', hint: 'Bate'),
        SecretWord(word: 'Golf', hint: 'Hoyo'),
        SecretWord(word: 'Boxeo', hint: 'Guantes'),
        SecretWord(word: 'Ciclismo', hint: 'Bicicleta'),
        SecretWord(word: 'Esquí', hint: 'Nieve'),
        SecretWord(word: 'Surf', hint: 'Olas'),
        SecretWord(word: 'Volleyball', hint: 'Red'),
        SecretWord(word: 'Rugby', hint: 'Tacleo'),
        SecretWord(word: 'Hockey', hint: 'Puck'),
        SecretWord(word: 'Atletismo', hint: 'Carrera'),
        SecretWord(word: 'Gimnasia', hint: 'Acrobacia'),
      ],
    ),
    Category(
      id: 'professions',
      name: 'Profesiones',
      icon: Icons.work,
      secretWords: [
        SecretWord(word: 'Doctor', hint: 'Salud'),
        SecretWord(word: 'Abogado', hint: 'Leyes'),
        SecretWord(word: 'Chef', hint: 'Cocina'),
        SecretWord(word: 'Piloto', hint: 'Avión'),
        SecretWord(word: 'Arquitecto', hint: 'Edificios'),
        SecretWord(word: 'Bombero', hint: 'Fuego'),
        SecretWord(word: 'Policía', hint: 'Seguridad'),
        SecretWord(word: 'Maestro', hint: 'Escuela'),
        SecretWord(word: 'Ingeniero', hint: 'Construcción'),
        SecretWord(word: 'Músico', hint: 'Instrumento'),
        SecretWord(word: 'Actor', hint: 'Teatro'),
        SecretWord(word: 'Científico', hint: 'Laboratorio'),
        SecretWord(word: 'Periodista', hint: 'Noticias'),
        SecretWord(word: 'Veterinario', hint: 'Mascotas'),
        SecretWord(word: 'Diseñador', hint: 'Creatividad'),
      ],
    ),
    Category(
      id: 'countries',
      name: 'Países',
      icon: Icons.flag,
      secretWords: [
        SecretWord(word: 'España', hint: 'Flamenco'),
        SecretWord(word: 'México', hint: 'Mariachi'),
        SecretWord(word: 'Argentina', hint: 'Tango'),
        SecretWord(word: 'Japón', hint: 'Samurái'),
        SecretWord(word: 'Francia', hint: 'Torre Eiffel'),
        SecretWord(word: 'Italia', hint: 'Coliseo'),
        SecretWord(word: 'Brasil', hint: 'Samba'),
        SecretWord(word: 'Alemania', hint: 'Cerveza'),
        SecretWord(word: 'Australia', hint: 'Canguro'),
        SecretWord(word: 'Canadá', hint: 'Maple'),
        SecretWord(word: 'Egipto', hint: 'Pirámides'),
        SecretWord(word: 'India', hint: 'Bollywood'),
        SecretWord(word: 'Rusia', hint: 'Kremlin'),
        SecretWord(word: 'Sudáfrica', hint: 'Safari'),
        SecretWord(word: 'Corea del Sur', hint: 'K-Pop'),
      ],
    ),
  ];
}
