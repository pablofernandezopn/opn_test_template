// framework/fn_response.ts

export class FnResponse {
  body?: any;
  headers?: Record<string, string>;
  status: number;
  statusText?: string;

  constructor(
    body?: any,
    options?: {
      headers?: Record<string, string>;
      status?: number;
      statusText?: string;
    }
  ) {
    this.body = body;
    this.headers = options?.headers;
    this.status = options?.status ?? 200;
    this.statusText = options?.statusText;
  }

  // Método helper para convertir a Response nativa de Deno
  toResponse(): Response {
    let responseBody: BodyInit | null = null;
    const headers: Record<string, string> = this.headers || {};

    // Convertir el body según su tipo
    if (this.body !== undefined && this.body !== null) {
      if (typeof this.body === 'string') {
        responseBody = this.body;
      } else if (typeof this.body === 'object') {
        responseBody = JSON.stringify(this.body);
        headers['Content-Type'] = headers['Content-Type'] || 'application/json';
      } else {
        responseBody = String(this.body);
      }
    }

    return new Response(responseBody, {
      status: this.status,
      statusText: this.statusText,
      headers,
    });
  }
}