import 'package:equatable/equatable.dart';

class Genre extends Equatable {
  final int malId;
  final String type;
  final String name;
  final String url;

  const Genre({
    required this.malId,
    required this.type,
    required this.name,
    required this.url,
  });

  @override
  List<Object?> get props => [malId, type, name, url];
}