# OPN Index System - Setup Guide

## 📋 Overview

This guide will help you set up the OPN Index ranking system, including:
- Database tables and views
- Edge Function for OPN Index calculation
- Daily cron job for automatic updates

## 🚀 Quick Start

### 1. Apply Database Migrations

Run the migrations in order:

```bash
# Navigate to your project directory
cd /path/to/opn_guardia_civil

# Apply migrations (if using Supabase CLI)
supabase db push

# Or apply manually in Supabase Dashboard > SQL Editor:
# - 20251105000000_create_opn_index_tables.sql
# - 20251105010000_create_opn_index_cron_job.sql
```

### 2. Deploy Edge Function

Deploy the calculate-opn-index edge function:

```bash
# Deploy the function
supabase functions deploy calculate-opn-index

# Verify deployment
supabase functions list
```

### 3. Configure Cron Job Settings

You need to configure the Supabase URL and Service Role Key for the cron job to work.

**Option A: Using psql or Supabase SQL Editor (Recommended)**

```sql
-- Set your Supabase URL
ALTER DATABASE postgres
SET app.settings.supabase_url = 'https://your-project-ref.supabase.co';

-- Set your Service Role Key (keep this secret!)
ALTER DATABASE postgres
SET app.settings.supabase_service_key = 'your-service-role-key-here';

-- Verify the settings
SELECT current_setting('app.settings.supabase_url', true);
SELECT current_setting('app.settings.supabase_service_key', true);
```

**How to get your values:**

1. **Project Reference/URL**:
   - Go to Supabase Dashboard > Project Settings > API
   - Copy the "Project URL" (format: `https://xxxxx.supabase.co`)

2. **Service Role Key**:
   - Go to Supabase Dashboard > Project Settings > API
   - Copy the "service_role" key (NOT the anon key!)
   - ⚠️ Keep this secret! Never expose it in client code

**Option B: Hardcode in Function (Less Secure, for Testing)**

Edit the migration file `20251105010000_create_opn_index_cron_job.sql` and replace the function with hardcoded values. See the ALTERNATIVE section in that file.

### 4. Test the Setup

#### Test Edge Function Manually

```bash
# Test with cURL (replace with your values)
curl -X POST \
  'https://your-project-ref.supabase.co/functions/v1/calculate-opn-index' \
  -H 'Authorization: Bearer YOUR-SERVICE-ROLE-KEY' \
  -H 'Content-Type: application/json' \
  -d '{"recalculate_all": true}'
```

#### Test Cron Trigger Function

```sql
-- Run this in Supabase SQL Editor
SELECT public.trigger_opn_index_calculation();
```

#### Check Cron Job Status

```sql
-- View scheduled jobs
SELECT * FROM cron.job
WHERE jobname = 'calculate-opn-index-daily';

-- View job execution history
SELECT * FROM cron.job_run_details
WHERE jobid = (
  SELECT jobid FROM cron.job
  WHERE jobname = 'calculate-opn-index-daily'
)
ORDER BY start_time DESC
LIMIT 10;
```

## 🗓️ Cron Schedule

The cron job is configured to run:
- **Schedule**: Every day at 02:00 UTC
- **Cron Expression**: `0 2 * * *`

To change the schedule, update the cron job:

```sql
-- Unschedule old job
SELECT cron.unschedule('calculate-opn-index-daily');

-- Create new schedule (example: run at 3:30 AM UTC)
SELECT cron.schedule(
  'calculate-opn-index-daily',
  '30 3 * * *',
  $$SELECT public.trigger_opn_index_calculation();$$
);
```

## 📊 Database Schema

### Tables Created

1. **`user_opn_index_history`**
   - Stores historical OPN Index calculations
   - Columns: `id`, `user_id`, `opn_index`, `quality_trend_score`, `recent_activity_score`, `competitive_score`, `momentum_score`, `global_rank`, `calculated_at`, `created_at`

### Views Created

1. **`user_opn_index_current`**
   - Shows the most recent OPN Index for each user
   - Used for global ranking queries

## 🔍 Useful Queries

### View Top 10 Global Ranking

```sql
SELECT
  u.username,
  u.avatar_url,
  uoi.opn_index,
  uoi.global_rank,
  uoi.quality_trend_score,
  uoi.competitive_score,
  uoi.calculated_at
FROM user_opn_index_current uoi
JOIN users u ON uoi.user_id = u.id
ORDER BY uoi.opn_index DESC
LIMIT 10;
```

### View User's OPN Index History

```sql
SELECT
  calculated_at::date as fecha,
  opn_index,
  quality_trend_score,
  recent_activity_score,
  competitive_score,
  momentum_score,
  global_rank
FROM user_opn_index_history
WHERE user_id = $1  -- Replace with actual user_id
ORDER BY calculated_at DESC
LIMIT 30;
```

### Get User's Current Ranking and Percentile

```sql
WITH ranking_info AS (
  SELECT
    COUNT(*) as total_usuarios,
    COUNT(*) FILTER (WHERE opn_index < (
      SELECT opn_index FROM user_opn_index_current WHERE user_id = $1
    )) as usuarios_debajo
  FROM user_opn_index_current
)
SELECT
  uoi.opn_index,
  uoi.global_rank,
  ri.total_usuarios,
  ROUND((ri.usuarios_debajo::numeric / ri.total_usuarios) * 100, 2) as percentile
FROM user_opn_index_current uoi
CROSS JOIN ranking_info ri
WHERE uoi.user_id = $1;  -- Replace with actual user_id
```

## 🔧 Troubleshooting

### Edge Function Not Working

1. **Check function logs:**
   ```bash
   supabase functions logs calculate-opn-index
   ```

2. **Verify function is deployed:**
   ```bash
   supabase functions list
   ```

3. **Check environment variables:**
   - Ensure `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are set

### Cron Job Not Running

1. **Verify pg_cron is enabled:**
   ```sql
   SELECT * FROM pg_extension WHERE extname = 'pg_cron';
   ```

2. **Check if job is scheduled:**
   ```sql
   SELECT * FROM cron.job WHERE jobname = 'calculate-opn-index-daily';
   ```

3. **View error logs:**
   ```sql
   SELECT * FROM cron.job_run_details
   WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'calculate-opn-index-daily')
   AND status = 'failed'
   ORDER BY start_time DESC;
   ```

4. **Test the trigger function manually:**
   ```sql
   SELECT public.trigger_opn_index_calculation();
   ```

### Settings Not Persisting

If the `ALTER DATABASE SET` commands don't work, you can hardcode the values directly in the `trigger_opn_index_calculation()` function. See the ALTERNATIVE section in the migration file.

## 📈 Monitoring

### Check Last Calculation

```sql
SELECT
  MAX(calculated_at) as last_calculation,
  COUNT(DISTINCT user_id) as users_calculated
FROM user_opn_index_history
WHERE calculated_at::date = CURRENT_DATE;
```

### View Calculation Performance

```sql
SELECT
  calculated_at::date as date,
  COUNT(DISTINCT user_id) as users_calculated,
  AVG(opn_index) as avg_index,
  MAX(opn_index) as max_index,
  MIN(opn_index) as min_index
FROM user_opn_index_history
GROUP BY calculated_at::date
ORDER BY date DESC
LIMIT 30;
```

## 🔐 Security Notes

- **Never expose Service Role Key** in client-side code
- The Edge Function should only be called by:
  - Cron job (server-side)
  - Admins via service role key
- RLS policies prevent users from modifying their OPN Index
- History is immutable (no updates or deletes allowed)

## 📞 Support

For issues or questions:
- Check the OPN_INDEX_DESIGN.md for system architecture
- Review Supabase Edge Functions docs: https://supabase.com/docs/guides/functions
- Review pg_cron docs: https://supabase.com/docs/guides/database/extensions/pgcron

## 📝 Next Steps

After setup is complete:
1. ✅ Run initial calculation manually to populate data
2. ✅ Verify cron job runs successfully
3. ✅ Build UI components to display rankings
4. ✅ Add user profile pages with OPN Index history
5. ✅ Implement gamification features (badges, challenges, etc.)

See OPN_INDEX_DESIGN.md for UI/UX recommendations and implementation phases.