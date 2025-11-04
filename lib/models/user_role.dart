enum UserRole {
  paciente,
  psicologo,
}

extension UserRoleX on UserRole {
  String get key => this == UserRole.psicologo ? 'psicologo' : 'paciente';
  static UserRole from(String? v) {
    return v == 'psicologo' ? UserRole.psicologo : UserRole.paciente;
  }
}
