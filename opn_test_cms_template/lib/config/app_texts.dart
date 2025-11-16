/// 📝 Textos Específicos de la Aplicación
///
/// Este archivo contiene SOLO los textos específicos que cambiarían
/// de una app a otra (nombres propios, URLs, marcas, etc.).
/// NO incluye textos genéricos como "Correo electrónico", "Contraseña", etc.
///
/// **Uso:**
/// ```dart
/// Text(AppTexts.appName)
/// Text(AppTexts.welcome.subtitle)
/// ```
class AppTexts {
  // ==========================================
  // 📱 IDENTIDAD DE LA APP
  // ==========================================

  /// Nombre de la aplicación
  static const String appName = 'Guardia Civil CMS';

  /// Nombre de la organización/empresa
  static const String organizationName = 'Oposiciones Guardia Civil';

  /// URL del sitio web principal
  static const String websiteUrl = 'www.oposicionesguardiacivil.online.com';

  static const String domain = 'oposicionesguardiacivil.online.com';

  /// Ruta del logo principal
  static const String logoPath = 'assets/images/opn_logos/opn-logo-shadow.png';

  // ==========================================
  // 🔐 PANTALLA DE INICIO DE SESIÓN
  // ==========================================

  /// Título de la pantalla de inicio de sesión
  static const String signInTitle = 'Iniciar Sesión';

  /// Label del campo de email
  static const String emailLabel = 'Email';

  /// Label del campo de contraseña
  static const String passwordLabel = 'Contraseña';

  /// Texto del botón de acceder
  static const String signInButton = 'Acceder';

  /// Texto informativo sobre las credenciales
  static const String informationText = 'Tus datos de acceso son los mismos que en';

  /// URL del sitio web para mostrar en la información
  static const String website = 'www.$domain';

  /// Pregunta sobre contraseña olvidada
  static const String forgotPasswordQuestion = '¿Has olvidado tu contraseña?';

  /// Texto del enlace para recuperar contraseña
  static const String recoverPassword = 'RECUPERAR CONTRASEÑA';

  /// URL para recuperar contraseña
  static const String recoverPasswordUrl = 'https://$domain/wp-login.php?action=lostpassword';

  /// Descargo de responsabilidad
  static const String disclaimer = 'Descargo de responsabilidad: Esta aplicación es una herramienta de estudio independiente y no representa a ninguna entidad gubernamental ni está afiliada con el Cuerpo Nacional de Policía. Toda la información y el temario proporcionados se basan en fuentes públicas oficiales, como el Boletín Oficial del Estado (BOE) y las convocatorias oficiales del Ministerio del Interior.';

  // ==========================================
  // 🏠 PANTALLA DE BIENVENIDA
  // ==========================================
  static const welcome = WelcomeTexts();
}

// ==========================================
// 🏠 TEXTOS DE BIENVENIDA
// ==========================================
class WelcomeTexts {
  const WelcomeTexts();

  /// Subtítulo descriptivo específico de la app
  String get subtitle => 'Consigue tu apto para la Guardia Civil';

  /// Mensaje sobre las credenciales
  String get credentialsInfo => 'Tus datos de acceso son los mismos que en';
}
