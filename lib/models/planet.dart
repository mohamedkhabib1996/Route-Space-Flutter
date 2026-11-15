import 'dart:convert';

import 'package:flutter/services.dart';

class PlanetFact {
  const PlanetFact({required this.label, required this.value});

  final String label;
  final String value;

  factory PlanetFact.fromJson(Map<String, dynamic> json) => PlanetFact(
    label: json['label'] as String,
    value: json['value'] as String,
  );
}

class Planet {
  const Planet({
    required this.name,
    required this.image,
    required this.model,
    required this.title,
    required this.about,
    required this.facts,
  });

  final String name;
  final String image;
  final String model;
  final String title;
  final String about;
  final List<PlanetFact> facts;

  factory Planet.fromJson(Map<String, dynamic> json) => Planet(
    name: json['name'] as String,
    image: json['image'] as String,
    model: json['model'] as String,
    title: json['title'] as String,
    about: json['about'] as String,
    facts: List.unmodifiable(
      (json['facts'] as List<dynamic>).map(
        (item) => PlanetFact.fromJson(item as Map<String, dynamic>),
      ),
    ),
  );
}

Future<List<Planet>> loadPlanets() async {
  final text = await rootBundle.loadString('assets/data/planets.json');
  final rows = jsonDecode(text) as List<dynamic>;
  final planets = rows.map(
    (row) => Planet.fromJson(row as Map<String, dynamic>),
  );
  if (rows.isEmpty) throw const FormatException('The planet list is empty.');
  return List.unmodifiable(planets);
}
