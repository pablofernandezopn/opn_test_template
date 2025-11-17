// wp_json_error.ts
export class WpJsonError {
  errors?: Record<string, any>;
  errorData?: Record<string, any>;

  constructor(
    errors?: Record<string, any>,
    errorData?: Record<string, any>
  ) {
    this.errors = errors;
    this.errorData = errorData;
  }

  static fromJson(json: any): WpJsonError {
    return new WpJsonError(
      json.errors,
      json.errorData
    );
  }

  toJson(): any {
    return {
      errors: this.errors,
      errorData: this.errorData,
    };
  }
}