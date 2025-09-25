class Recom{
  final int id;
  final String imagen;
  final String titulo;
  final String descripcion;

  const Recom({
    required this.imagen,
    required this.titulo,
    required this.descripcion,
    required this.id,
  });
  factory Recom.fromJson(Map<String, dynamic> json) {
    return Recom(
      imagen: json['imagen'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagen': imagen,
      'titulo': titulo,
      'descripcion': descripcion,
      'id': id,
    };
  }
  Recom copy() => Recom(
      imagen: imagen,
      titulo: titulo,
      descripcion: descripcion,
      id: id,
    );
}