class IdConflict implements Exception {
  const IdConflict(this.id);

  final int id;

  @override
  String toString() =>
      "The id $id has already been used by another request! Not sending req ...";
}
