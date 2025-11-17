#!/bin/bash

# =====================================================
# OPN Index System - Setup Script
# =====================================================
# Description: Helper script to deploy OPN Index system
# =====================================================

set -e  # Exit on error

echo "🚀 OPN Index System Setup"
echo "========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}Error: Supabase CLI is not installed${NC}"
    echo "Install it from: https://supabase.com/docs/guides/cli"
    exit 1
fi

echo -e "${GREEN}✓ Supabase CLI found${NC}"
echo ""

# Step 1: Apply migrations
echo "📦 Step 1: Applying database migrations..."
echo "==========================================="
echo ""

read -p "Do you want to apply the OPN Index migrations? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Applying migrations..."
    supabase db push
    echo -e "${GREEN}✓ Migrations applied successfully${NC}"
else
    echo -e "${YELLOW}⚠ Skipping migrations${NC}"
fi
echo ""

# Step 2: Deploy edge function
echo "🔧 Step 2: Deploying Edge Function..."
echo "======================================"
echo ""

read -p "Do you want to deploy the calculate-opn-index edge function? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deploying edge function..."
    supabase functions deploy calculate-opn-index
    echo -e "${GREEN}✓ Edge function deployed successfully${NC}"
else
    echo -e "${YELLOW}⚠ Skipping edge function deployment${NC}"
fi
echo ""

# Step 3: Configuration instructions
echo "⚙️  Step 3: Configure Cron Job Settings"
echo "========================================"
echo ""
echo -e "${YELLOW}IMPORTANT: You need to configure the following settings in Supabase SQL Editor:${NC}"
echo ""
echo "1. Get your Project URL and Service Role Key from:"
echo "   Supabase Dashboard > Project Settings > API"
echo ""
echo "2. Run these SQL commands in Supabase SQL Editor:"
echo ""
echo -e "${GREEN}-- Set your Supabase URL"
echo "ALTER DATABASE postgres"
echo "SET app.settings.supabase_url = 'https://YOUR-PROJECT-REF.supabase.co';"
echo ""
echo "-- Set your Service Role Key"
echo "ALTER DATABASE postgres"
echo "SET app.settings.supabase_service_key = 'YOUR-SERVICE-ROLE-KEY';"
echo ""
echo "-- Verify the settings"
echo "SELECT current_setting('app.settings.supabase_url', true);"
echo -e "SELECT current_setting('app.settings.supabase_service_key', true);${NC}"
echo ""

read -p "Press Enter when you have completed the configuration..."
echo ""

# Step 4: Test
echo "🧪 Step 4: Testing Setup"
echo "========================"
echo ""

read -p "Do you want to test the OPN Index calculation? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Please run this in Supabase SQL Editor to test:"
    echo ""
    echo -e "${GREEN}SELECT public.trigger_opn_index_calculation();${NC}"
    echo ""
    echo "Or use this curl command (replace with your values):"
    echo ""
    echo -e "${GREEN}curl -X POST \\"
    echo "  'https://YOUR-PROJECT-REF.supabase.co/functions/v1/calculate-opn-index' \\"
    echo "  -H 'Authorization: Bearer YOUR-SERVICE-ROLE-KEY' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo -e "  -d '{\"recalculate_all\": true}'${NC}"
    echo ""
fi

# Step 5: Final instructions
echo ""
echo "✅ Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. ✓ Migrations applied"
echo "2. ✓ Edge function deployed"
echo "3. ⚠ Configure cron job settings (see above)"
echo "4. ⚠ Test the calculation"
echo "5. ⚠ Verify cron job runs daily"
echo ""
echo "For detailed instructions, see: supabase/OPN_INDEX_SETUP.md"
echo ""
echo -e "${GREEN}Thank you for using OPN Index System! 🎉${NC}"
echo ""