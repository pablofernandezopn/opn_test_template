import 'package:json_annotation/json_annotation.dart';
import '../../../features/opn_ranking/model/user_opn_index_current_model.dart';
import 'memberships.dart';
import 'user_membership.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String? email;

  @JsonKey(name: 'specialty_id')
  final int? specialtyId;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  final String? phone;

  @JsonKey(name: 'totalQuestions')
  final int totalQuestions;

  @JsonKey(name: 'rightQuestions')
  final int rightQuestions;

  @JsonKey(name: 'wrongQuestions')
  final int wrongQuestions;

  @JsonKey(name: 'question_goal')
  final int questionGoal;

  @JsonKey(name: 'opn_index')
  final int? opnIndex;

  @JsonKey(name: 'opn_global_rank')
  final int? opnGlobalRank;

  final bool? tester;

  @JsonKey(name: 'lastUsed')
  final DateTime? lastUsed;

  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  @JsonKey(name: 'fid_token')
  final String? fidToken;

  @JsonKey(name: 'profile_image')
  final String? profileImage;

  @JsonKey(name: 'unlocked_at')
  final DateTime? unlockedAt;

  @JsonKey(name: 'unlock_duration_minutes')
  final int? unlockDurationMinutes;

  final bool? enabled;

  final bool? tutorial;

  @JsonKey(name: 'wordpress_user_id')
  final int? wordpressUserId;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'academy_id')
  final int academyId;

  // Token de autenticación del usuario
  final String? token;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  // Relación con user_memberships
  @JsonKey(name: 'user_memberships')
  final List<UserMembership> userMemberships;

  @JsonKey(name: 'opn_index_data')
  final UserOpnIndexCurrent? opnIndexData;

  const User({
    this.opnIndexData,
    this.specialtyId,
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.totalQuestions = 0,
    this.rightQuestions = 0,
    this.wrongQuestions = 0,
    this.questionGoal = 300,
    this.opnIndex,
    this.opnGlobalRank,
    this.tester = false,
    this.lastUsed,
    this.fcmToken,
    this.fidToken,
    this.profileImage,
    this.unlockedAt,
    this.unlockDurationMinutes = 0,
    this.enabled = true,
    this.tutorial = false,
    this.wordpressUserId,
    this.displayName,
    this.academyId = 1,
    this.token,
    required this.createdAt,
    required this.updatedAt,
    this.userMemberships = const [],
  });

  static const User empty = User(
    id: 0,
    username: '',
    email: null,
    firstName: null,
    lastName: null,
    phone: null,
    totalQuestions: 0,
    rightQuestions: 0,
    wrongQuestions: 0,
    questionGoal: 300,
    opnIndex: null,
    opnGlobalRank: null,
    tester: false,
    lastUsed: null,
    fcmToken: null,
    fidToken: null,
    profileImage: null,
    unlockedAt: null,
    unlockDurationMinutes: 0,
    enabled: true,
    tutorial: false,
    wordpressUserId: null,
    displayName: null,
    academyId: 1,
    token: null,
    userMemberships: const [],
    createdAt: null,
    updatedAt: null,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? username,
    String? email,
    int? specialtyId,
    String? firstName,
    String? lastName,
    String? phone,
    int? totalQuestions,
    int? rightQuestions,
    int? wrongQuestions,
    int? questionGoal,
    int? opnIndex,
    int? opnGlobalRank,
    bool? tester,
    DateTime? lastUsed,
    String? fcmToken,
    String? fidToken,
    String? profileImage,
    DateTime? unlockedAt,
    int? unlockDurationMinutes,
    bool? enabled,
    bool? tutorial,
    int? wordpressUserId,
    String? displayName,
    int? academyId,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserMembership>? userMemberships,
    UserOpnIndexCurrent? opnIndexData,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      specialtyId: specialtyId ?? this.specialtyId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      rightQuestions: rightQuestions ?? this.rightQuestions,
      wrongQuestions: wrongQuestions ?? this.wrongQuestions,
      questionGoal: questionGoal ?? this.questionGoal,
      opnIndex: opnIndex ?? this.opnIndex,
      opnGlobalRank: opnGlobalRank ?? this.opnGlobalRank,
      tester: tester ?? this.tester,
      lastUsed: lastUsed ?? this.lastUsed,
      fcmToken: fcmToken ?? this.fcmToken,
      fidToken: fidToken ?? this.fidToken,
      profileImage: profileImage ?? this.profileImage,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockDurationMinutes:
          unlockDurationMinutes ?? this.unlockDurationMinutes,
      enabled: enabled ?? this.enabled,
      tutorial: tutorial ?? this.tutorial,
      wordpressUserId: wordpressUserId ?? this.wordpressUserId,
      displayName: displayName ?? this.displayName,
      academyId: academyId ?? this.academyId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userMemberships: userMemberships ?? this.userMemberships,
      opnIndexData: opnIndexData ?? this.opnIndexData,
    );
  }

  // ============================================
  // HELPERS PARA NIVELES DE MEMBRESÍA
  // ============================================

  /// Obtiene solo las membresías válidas y activas
  List<UserMembership> get activeMemberships {
    return userMemberships
        .where((um) => um.isValidAndActive && um.membershipLevel != null)
        .toList();
  }

  /// Obtiene los niveles de membresía activos
  List<MembershipLevel> get membershipLevels {
    return activeMemberships
        .map((um) => um.membershipLevel!)
        .where((ml) => ml.isActive ?? false)
        .toList();
  }

  /// Obtiene el nivel de acceso más alto de todas las membresías activas
  int get maxAccessLevel {
    if (membershipLevels.isEmpty) return 1; // Freemium por defecto

    return membershipLevels
        .map((ml) => ml.accessLevel)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Usuario tiene acceso Premium+ (nivel 3)
  bool get isPremiumPlus => maxAccessLevel == 3;

  /// Usuario tiene acceso Premium (nivel 2 o superior)
  bool get isPremium => maxAccessLevel >= 2;

  /// Usuario es Freemium (nivel 1, sin membresías activas)
  bool get isFreemium => maxAccessLevel == 1;

  /// Usuario tiene alguna membresía de pago activa (Premium o Premium+)
  bool get isPremiumOrBasic => maxAccessLevel >= 2;

  /// Usuario tiene al menos una membresía activa
  bool get hasActiveMembership => activeMemberships.isNotEmpty;

  /// Obtiene la membresía con el nivel más alto
  MembershipLevel? get highestMembership {
    if (membershipLevels.isEmpty) return null;

    return membershipLevels.reduce((current, next) =>
        next.accessLevel > current.accessLevel ? next : current);
  }

  /// Verifica si el usuario tiene acceso a un nivel específico
  bool hasAccessLevel(int level) => maxAccessLevel >= level;

  /// Verifica si tiene una membresía recurrente activa
  bool get hasRecurringMembership {
    return activeMemberships.any((um) => um.autoRenews ?? false);
  }

  /// Obtiene el nombre del nivel actual del usuario
  String get membershipLevelName {
    if (isPremiumPlus) return 'Premium+';
    if (isPremium) return 'Premium';
    return 'Freemium';
  }

  /// Obtiene las membresías que están por expirar (menos de 7 días)
  List<UserMembership> get expiringMemberships {
    return activeMemberships.where((um) {
      final days = um.daysUntilExpiration;
      return days != null && days <= 7 && days > 0;
    }).toList();
  }

  /// Verifica si tiene alguna membresía en período de gracia
  bool get hasGracePeriodMembership {
    return userMemberships.any((um) => um.isInGracePeriod);
  }

  /// Para debugging - imprime el estado de membresías
  void debugMembershipStatus() {
    print('═══════════════════════════════════════');
    print('🔍 DEBUG: User Membership Status');
    print('═══════════════════════════════════════');
    print('User ID: $id');
    print('Username: $username');
    print('Total User Memberships: ${userMemberships.length}');
    print('Active Memberships: ${activeMemberships.length}');
    print('Max Access Level: $maxAccessLevel');
    print('Membership Level: $membershipLevelName');
    print('Is Premium+: $isPremiumPlus');
    print('Is Premium: $isPremium');
    print('Is Freemium: $isFreemium');
    print('Has Recurring: $hasRecurringMembership');
    print('Expiring Soon: ${expiringMemberships.length}');
    print('In Grace Period: $hasGracePeriodMembership');

    if (activeMemberships.isNotEmpty) {
      print('\nActive Memberships:');
      for (final um in activeMemberships) {
        final ml = um.membershipLevel;
        print('  - ${ml?.name} (Level ${ml?.accessLevel})');
        print('    Status: ${um.status}');
        print('    Expires: ${um.expiresAt}');
        print('    Auto-renews: ${um.autoRenews}');
        print('    Source: ${um.sourceName}');
      }
    }

    if (highestMembership != null) {
      print('\nHighest Membership: ${highestMembership!.name}');
    }

    print('═══════════════════════════════════════\n');
  }

  /// Getter de compatibilidad
  bool get isEmpty => id == 0 && username.isEmpty;

  bool get isBetaTester => hasAccessLevel(4);
}
