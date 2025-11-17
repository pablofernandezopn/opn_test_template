// membership.ts
import { MembershipLevel } from './membership_level.ts';

// Converter personalizado para fechas
class DateConverter {
  static fromJson(value: string | null): Date | undefined {
    if (!value || value.toLowerCase() === 'none') {
      return undefined;
    }
    return new Date(value);
  }

  static toJson(value: Date | undefined): string | null {
    return value ? value.toISOString() : null;
  }
}

export class Membership {
  id?: string;
  customerId?: string;
  membershipLevel?: MembershipLevel;
  objectId?: string;
  autoRenew: boolean;
  status: string;
  renewedDate?: Date;
  cancellationDate?: Date;
  expirationDate?: Date;
  betatester: boolean;

  constructor(
    autoRenew: boolean = false,
    status: string = '',
    betatester: boolean = false
  ) {
    this.autoRenew = autoRenew;
    this.status = status;
    this.betatester = betatester;
  }

  get isEmpty(): boolean {
    return this.id === '-1';
  }

  // Override para manejar la lógica especial del fromJson de Dart
  static fromJson(json: any): Membership {
    // FIX para procesar membershipLevel
    // TODO: Implementar cuando tengamos el servicio de MembershipLevel
    // let membershipLevel: MembershipLevel | undefined;
    // if (json.object_id && !json.membership_level) {
    //   membershipLevel = MembershipLevelService.parseFromObjectId(json.object_id);
    // }
    // const betatester = MembershipLevelService.isBetatester(json.object_id);
    
    // Crear instancia y asignar propiedades
    const membership = new Membership();
    Object.assign(membership, {
      id: json.id,
      customerId: json.customer_id,
      membershipLevel: json.membership_level,
      objectId: json.object_id,
      autoRenew: json.auto_renew ?? false,
      status: json.status,
      renewedDate: DateConverter.fromJson(json.renewed_date),
      cancellationDate: DateConverter.fromJson(json.cancellation_date),
      expirationDate: DateConverter.fromJson(json.expiration_date),
      betatester: json.betatester ?? false,
    });
    
    return membership;
  }

  toJson(): any {
    const objectId = this.objectId ?? this.membershipLevel?.rcpId;
    return {
      id: this.id,
      customer_id: this.customerId,
      membership_level: this.membershipLevel,
      object_id: objectId,
      auto_renew: this.autoRenew,
      status: this.status,
      renewed_date: DateConverter.toJson(this.renewedDate),
      cancellation_date: DateConverter.toJson(this.cancellationDate),
      expiration_date: DateConverter.toJson(this.expirationDate),
      betatester: this.betatester,
    };
  }

  copyWith(updates: Partial<Membership>): Membership {
    const newMembership = new Membership();
    Object.assign(newMembership, this, updates);
    return newMembership;
  }
}