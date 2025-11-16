-- =====================================================
-- OPN Index Cron Job Configuration
-- =====================================================
-- Description: Configures daily cron job to calculate OPN Index for all users
-- Schedule: Every day at 02:00 UTC
-- =====================================================

-- =====================================================
-- 1. Enable required extensions
-- =====================================================

-- Enable pg_cron for scheduled jobs (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Enable pg_net for HTTP requests (if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

-- =====================================================
-- 2. Create helper function to call Edge Function
-- =====================================================

-- This function will be called by the cron job
-- It makes an HTTP POST request to the calculate-opn-index edge function

CREATE OR REPLACE FUNCTION public.trigger_opn_index_calculation()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  supabase_url text;
  service_role_key text;
  request_id bigint;
BEGIN
  -- Get Supabase URL and Service Role Key from environment/secrets
  -- NOTE: These should be configured in Supabase Dashboard > Project Settings > API
  -- For now, we'll use a placeholder that needs to be replaced

  -- IMPORTANT: Replace these values in Supabase Dashboard or via psql:
  -- UPDATE pg_catalog.pg_settings SET setting = 'your-project-ref' WHERE name = 'app.settings.supabase_project_ref';
  -- UPDATE pg_catalog.pg_settings SET setting = 'your-service-key' WHERE name = 'app.settings.supabase_service_key';

  -- For Supabase Cloud projects, the URL format is:
  -- https://[PROJECT_REF].supabase.co

  -- Get configuration from custom settings (you need to set these up)
  supabase_url := current_setting('app.settings.supabase_url', true);
  service_role_key := current_setting('app.settings.supabase_service_key', true);

  -- Fallback: Try to construct URL from project reference
  IF supabase_url IS NULL THEN
    RAISE NOTICE 'Supabase URL not configured. Please set app.settings.supabase_url';
    RETURN;
  END IF;

  IF service_role_key IS NULL THEN
    RAISE NOTICE 'Service role key not configured. Please set app.settings.supabase_service_key';
    RETURN;
  END IF;

  -- Make HTTP POST request to Edge Function
  SELECT INTO request_id extensions.http_post(
    url := supabase_url || '/functions/v1/calculate-opn-index',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || service_role_key
    ),
    body := jsonb_build_object(
      'recalculate_all', true
    )
  );

  RAISE NOTICE 'OPN Index calculation triggered. Request ID: %', request_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error triggering OPN Index calculation: %', SQLERRM;
END;
$$;

-- Add comment
COMMENT ON FUNCTION public.trigger_opn_index_calculation() IS
'Triggers the Edge Function to calculate OPN Index for all users. Called by cron job daily.';

-- =====================================================
-- 3. Schedule the cron job
-- =====================================================

-- Schedule: Every day at 02:00 UTC
-- Cron format: minute hour day month day_of_week

SELECT cron.schedule(
  'calculate-opn-index-daily',           -- Job name
  '0 2 * * *',                           -- Every day at 02:00 UTC
  $$SELECT public.trigger_opn_index_calculation();$$
);

-- =====================================================
-- 4. Verify cron job was created
-- =====================================================

-- You can check the cron job status with:
-- SELECT * FROM cron.job WHERE jobname = 'calculate-opn-index-daily';

-- =====================================================
-- 5. Grant necessary permissions
-- =====================================================

-- Grant execute permission on the trigger function to postgres
GRANT EXECUTE ON FUNCTION public.trigger_opn_index_calculation() TO postgres;

-- =====================================================
-- IMPORTANT SETUP INSTRUCTIONS
-- =====================================================

-- After running this migration, you MUST configure the following settings
-- using psql or the Supabase SQL Editor:

-- 1. Set your Supabase URL:
--    ALTER DATABASE postgres SET app.settings.supabase_url = 'https://your-project-ref.supabase.co';

-- 2. Set your Service Role Key (keep this secret!):
--    ALTER DATABASE postgres SET app.settings.supabase_service_key = 'your-service-role-key-here';

-- 3. Verify the settings:
--    SELECT current_setting('app.settings.supabase_url', true);
--    SELECT current_setting('app.settings.supabase_service_key', true);

-- 4. Test the function manually (optional):
--    SELECT public.trigger_opn_index_calculation();

-- 5. Check cron job status:
--    SELECT * FROM cron.job WHERE jobname = 'calculate-opn-index-daily';

-- 6. View cron job execution history:
--    SELECT * FROM cron.job_run_details WHERE jobid = (
--      SELECT jobid FROM cron.job WHERE jobname = 'calculate-opn-index-daily'
--    ) ORDER BY start_time DESC LIMIT 10;

-- =====================================================
-- ALTERNATIVE: Manual Configuration
-- =====================================================

-- If you prefer not to use ALTER DATABASE, you can modify the
-- trigger_opn_index_calculation() function directly to hardcode
-- the values (less secure, but simpler for testing):

-- CREATE OR REPLACE FUNCTION public.trigger_opn_index_calculation()
-- RETURNS void
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- DECLARE
--   request_id bigint;
-- BEGIN
--   SELECT INTO request_id extensions.http_post(
--     url := 'https://YOUR-PROJECT-REF.supabase.co/functions/v1/calculate-opn-index',
--     headers := jsonb_build_object(
--       'Content-Type', 'application/json',
--       'Authorization', 'Bearer YOUR-SERVICE-ROLE-KEY'
--     ),
--     body := jsonb_build_object('recalculate_all', true)
--   );
--   RAISE NOTICE 'OPN Index calculation triggered. Request ID: %', request_id;
-- END;
-- $$;