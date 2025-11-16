import 'package:json_annotation/json_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue(1)
  superAdmin(1, 'Super Admin'),

  @JsonValue(2)
  admin(2, 'Admin'),

  @JsonValue(3)
  tutor(3, 'Tutor'),

  @JsonValue(4)
  user(4, 'User');

  final int id;
  final String displayName;

  const UserRole(this.id, this.displayName);

  static UserRole fromId(int id) {
    return UserRole.values.firstWhere(
      (role) => role.id == id,
      orElse: () => UserRole.user,
    );
  }

  bool get isSuperAdmin => this == UserRole.superAdmin;
  bool get isAdmin => this == UserRole.admin || isSuperAdmin;
  bool get isTutor => this == UserRole.tutor || isAdmin;
}

@JsonSerializable()
class CmsUser {
  final int id;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'user_uuid')
  final String? userUuid;

  @JsonKey(name: 'academy_id', defaultValue: 1)
  final int academyId;

  @JsonKey(name: 'token', includeFromJson: false, includeToJson: false)
  final String? token;

  final String username;

  @JsonKey(name: 'nombre')
  final String name;

  @JsonKey(name: 'apellido')
  final String lastName;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  final String? email;

  final String? phone;

  final String? address;

  @JsonKey(name: 'role_id')
  final int roleId;

  @JsonKey(name: 'specialty_id')
  final int? specialtyId;

  final Specialty? specialty;

  const CmsUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.userUuid,
    this.academyId = 1,
    this.token,
    required this.username,
    required this.name,
    required this.lastName,
    this.avatarUrl,
    this.email,
    this.phone,
    this.address,
    required this.roleId,
    this.specialtyId,
    this.specialty,
  });

  static const CmsUser empty = CmsUser(
    id: 0,
    createdAt: null,
    updatedAt: null,
    userUuid: null,
    academyId: 1,
    token: null,
    username: 'sin usuario',
    name: 'sin nombre',
    lastName: 'sin apellido',
    avatarUrl: null,
    email: null,
    phone: null,
    address: null,
    roleId: 4,
    specialtyId: null,
    specialty: null,
  );

  factory CmsUser.fromJson(Map<String, dynamic> json) =>
      _$CmsUserFromJson(json);

  Map<String, dynamic> toJson() => _$CmsUserToJson(this);

  CmsUser copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userUuid,
    int? academyId,
    String? token,
    String? username,
    String? nombre,
    String? apellido,
    String? avatarUrl,
    String? email,
    String? phone,
    String? address,
    int? roleId,
    int? specialtyId,
    Specialty? specialty,
  }) {
    return CmsUser(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userUuid: userUuid ?? this.userUuid,
      academyId: academyId ?? this.academyId,
      token: token ?? this.token,
      username: username ?? this.username,
      name: nombre ?? this.name,
      lastName: apellido ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      roleId: roleId ?? this.roleId,
      specialtyId: specialtyId ?? this.specialtyId,
      specialty: specialty ?? this.specialty,
    );
  }

  // ============================================
  // HELPERS PARA ROLES
  // ============================================

  /// Obtiene el rol del usuario
  UserRole get role => UserRole.fromId(roleId);

  /// Nombre completo del usuario
  String get fullName => '$name $lastName'.trim();

  /// Iniciales del usuario
  String get initials {
    final firstName = name.trim();
    final lastName = this.lastName.trim();

    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
  }

  /// Usuario es SuperAdmin
  bool get isSuperAdmin => role.isSuperAdmin;

  /// Usuario es Admin o superior
  bool get isAdmin => role.isAdmin;

  /// Usuario es Tutor o superior
  bool get isTutor => role.isTutor;

  /// Usuario es solo User (rol básico)
  bool get isBasicUser => role == UserRole.user;

  /// Verifica si tiene permiso de administración
  bool get hasAdminAccess => isAdmin;

  /// Verifica si puede editar contenido
  bool get canEdit => isAdmin;

  /// Nombre del rol para mostrar
  String get roleName => role.displayName;

  /// Verifica si el usuario está vacío
  bool get isEmpty => id == 0 && username == 'sin usuario';

  /// Para debugging - imprime el estado del usuario
  void debugUserStatus() {
    print('═══════════════════════════════════════');
    print('🔍 DEBUG: CMS User Status');
    print('═══════════════════════════════════════');
    print('User ID: $id');
    print('UUID: $userUuid');
    print('Username: $username');
    print('Full Name: $fullName');
    print('Email: $email');
    print('Academy ID: $academyId');
    print('Role ID: $roleId');
    print('Role: $roleName');
    print('Is Admin: $isSuperAdmin');
    print('Is Editor: $isAdmin');
    print('Is Tutor: $isTutor');
    print('Has Admin Access: $hasAdminAccess');
    print('Can Edit: $canEdit');
    print('Created: $createdAt');
    print('Updated: $updatedAt');
    print('═══════════════════════════════════════\n');
  }
}
