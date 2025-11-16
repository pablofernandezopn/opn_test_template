// framework/request_utils.ts

export function extractPath(request: Request): string {
  const url = new URL(request.url);
  const pathname = url.pathname;
  
  // Para URLs de Supabase: /functions/v1/login-register/v1/endpoint
  // Extraemos todo después de /login-register/
  const loginRegisterPrefix = "/login-register/";
  const prefixIndex = pathname.indexOf(loginRegisterPrefix);
  
  if (prefixIndex !== -1) {
    return pathname.substring(prefixIndex + loginRegisterPrefix.length);
  } else {
    // Fallback: si no encontramos el prefijo, usar el path completo
    return pathname.startsWith('/') ? pathname.substring(1) : pathname;
  }
}

export function extractApiVersion(request: Request): string {
  const path = extractPath(request);
  
  if (path.includes('/')) {
    return path.split('/')[0];
  } else {
    throw new Error("Invalid request without API version");
  }
}

export function extractConcretePath(version: string, path: string): string {
  return path.substring(version.length + 1);
}