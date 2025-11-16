// membership_level.ts

// Enums básicos
export enum MembershipCategory {
  FREEMIUM = 'freemium',
  BASIC = 'basic',
  PREMIUM = 'premium',
  PREMIUM_PLUS = 'premium_plus',
  PRO = 'pro'
}

// Modelo básico sin decoradores
export class MembershipLevel {
  rcpId: string;
  name: string;
  revenueCatProductIds: string[];
  category: MembershipCategory;
  isBetatester: boolean;

  constructor(
    rcpId: string = '',
    name: string = '',
    revenueCatProductIds: string[] = [],
    category: MembershipCategory = MembershipCategory.FREEMIUM,
    isBetatester: boolean = false
  ) {
    this.rcpId = rcpId;
    this.name = name;
    this.revenueCatProductIds = revenueCatProductIds;
    this.category = category;
    this.isBetatester = isBetatester;
  }

  static fromJson(json: any): MembershipLevel {
    // Mapear access_level a category si viene de Supabase
    let category = json.category || MembershipCategory.FREEMIUM;
    if (json.access_level !== undefined) {
      if (json.access_level === 1) category = MembershipCategory.FREEMIUM;
      else if (json.access_level === 2) category = MembershipCategory.PREMIUM;
      else if (json.access_level === 3) category = MembershipCategory.PREMIUM_PLUS;
    }
    
    return new MembershipLevel(
      String(json.wordpress_rcp_id || json.rcp_id || ''),
      json.name || '',
      json.revenuecat_product_ids || json.revenue_cat_product_ids || [],
      category,
      json.is_betatester || false
    );
  }

  toJson(): any {
    return {
      rcp_id: this.rcpId,
      name: this.name,
      revenue_cat_product_ids: this.revenueCatProductIds,
      category: this.category,
      is_betatester: this.isBetatester,
    };
  }
}