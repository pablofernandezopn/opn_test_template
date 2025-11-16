// wp_exception.ts
export class WpException extends Error {
  status: number;
  reason?: string;
  errorMsg: string;
  errorData?: string;

  constructor(
    status: number = 0,
    errorMsg: string = '',
    reason?: string,
    errorData?: string
  ) {
    super(errorMsg);
    this.name = 'WpException';
    this.status = status;
    this.reason = reason;
    this.errorMsg = errorMsg;
    this.errorData = errorData;
  }

  static fromJson(json: any): WpException {
    return new WpException(
      json.status || 0,
      json.errorMsg || '',
      json.reason,
      json.errorData
    );
  }

  toJson(): any {
    return {
      status: this.status,
      reason: this.reason,
      errorMsg: this.errorMsg,
      errorData: this.errorData,
    };
  }
}