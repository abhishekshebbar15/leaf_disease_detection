import 'dart:convert';

class RemedyModel {
  final String id;
  final String diseaseName;
  final String scientificDescription;
  final List<String> chemicalRemedies;
  final List<String> organicRemedies;

  RemedyModel({
    required this.id,
    required this.diseaseName,
    required this.scientificDescription,
    required this.chemicalRemedies,
    required this.organicRemedies,
  });

  factory RemedyModel.fromMap(Map<String, dynamic> map) {
    return RemedyModel(
      id: map['id'] as String,
      diseaseName: map['disease_name'] as String,
      scientificDescription: map['scientific_description'] as String,
      chemicalRemedies: List<String>.from(jsonDecode(map['chemical_remedies'] as String)),
      organicRemedies: List<String>.from(jsonDecode(map['organic_remedies'] as String)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disease_name': diseaseName,
      'scientific_description': scientificDescription,
      'chemical_remedies': jsonEncode(chemicalRemedies),
      'organic_remedies': jsonEncode(organicRemedies),
    };
  }
}