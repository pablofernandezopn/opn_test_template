// =====================================================
// OPN Index Calculation Edge Function
// =====================================================
// Description: Calculates OPN Index (0-1000 pts) for users based on:
//              - Quality Trend (400 pts): Improvement in accuracy over time
//              - Recent Activity (300 pts): Practice volume in last 30 days
//              - Competitiveness (200 pts): Positions in Mock rankings
//              - Momentum (100 pts): Acceleration and recent improvement
// =====================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// =====================================================
// Types
// =====================================================

interface UserStats {
  last_7d: TimeWindowStats;
  last_30d: TimeWindowStats;
  last_90d: TimeWindowStats;
  historical: HistoricalStats;
}

interface TimeWindowStats {
  correctas: number;
  incorrectas: number;
  total_preguntas: number;
  tests_finalizados: number;
  dias_activos: number;
}

interface HistoricalStats {
  rightQuestions: number;
  wrongQuestions: number;
  created_at: string;
}

interface OPNIndexResult {
  user_id: number;
  opn_index: number;
  quality_trend_score: number;
  recent_activity_score: number;
  competitive_score: number;
  momentum_score: number;
}

// =====================================================
// Main Handler
// =====================================================

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client with service role
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Parse request body
    const { user_id, recalculate_all = false } = await req.json().catch(() => ({}));

    console.log(`Starting OPN Index calculation...`);
    console.log(`Mode: ${recalculate_all ? "ALL USERS" : `Single user (${user_id})`}`);

    // Get users to calculate
    let userIds: number[] = [];

    if (recalculate_all) {
      // Get all active users
      const { data: users, error } = await supabase
        .from("users")
        .select("id")
        .order("id");

      if (error) throw error;
      userIds = users.map(u => u.id);
      console.log(`Found ${userIds.length} users to process`);
    } else if (user_id) {
      userIds = [user_id];
    } else {
      return new Response(
        JSON.stringify({ error: "Must provide user_id or recalculate_all=true" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Calculate OPN Index for each user
    const results: OPNIndexResult[] = [];

    for (const userId of userIds) {
      try {
        const result = await calculateOPNIndexForUser(supabase, userId);
        results.push(result);
        console.log(`✓ User ${userId}: ${result.opn_index} pts`);
      } catch (error) {
        console.error(`✗ Error calculating for user ${userId}:`, error);
      }
    }

    // Recalculate global rankings
    await recalculateGlobalRanks(supabase);
    console.log(`✓ Global rankings updated`);

    return new Response(
      JSON.stringify({
        success: true,
        users_processed: results.length,
        timestamp: new Date().toISOString(),
        results: recalculate_all ? undefined : results[0],
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("Error in OPN Index calculation:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// =====================================================
// Calculate OPN Index for a single user
// =====================================================

async function calculateOPNIndexForUser(supabase: any, userId: number): Promise<OPNIndexResult> {
  // 1. Get user stats in different time windows
  const stats = await getUserStats(supabase, userId);

  // 2. Calculate each component
  const quality_trend_score = calculateQualityTrend(stats);
  const recent_activity_score = calculateRecentActivity(stats);
  const competitive_score = await calculateCompetitive(supabase, userId);
  const momentum_score = calculateMomentum(stats);

  // 3. Calculate total OPN Index
  const opn_index = Math.round(
    quality_trend_score + recent_activity_score + competitive_score + momentum_score
  );

  // 4. Save to history
  const { error } = await supabase
    .from("user_opn_index_history")
    .insert({
      user_id: userId,
      opn_index,
      quality_trend_score,
      recent_activity_score,
      competitive_score,
      momentum_score,
    });

  if (error) throw error;

  return {
    user_id: userId,
    opn_index,
    quality_trend_score,
    recent_activity_score,
    competitive_score,
    momentum_score,
  };
}

// =====================================================
// Get user stats in different time windows
// =====================================================

async function getUserStats(supabase: any, userId: number): Promise<UserStats> {
  const now = new Date();

  // Get user data
  const { data: user, error: userError } = await supabase
    .from("users")
    .select("rightQuestions, wrongQuestions, createdAt")
    .eq("id", userId)
    .single();

  if (userError) throw userError;

  // Get stats for different time windows
  const last_7d = await getStatsWindow(supabase, userId, 7);
  const last_30d = await getStatsWindow(supabase, userId, 30);
  const last_90d = await getStatsWindow(supabase, userId, 90);

  return {
    last_7d,
    last_30d,
    last_90d,
    historical: {
      rightQuestions: user.rightQuestions || 0,
      wrongQuestions: user.wrongQuestions || 0,
      created_at: user.createdAt,
    },
  };
}

// =====================================================
// Get stats for a specific time window
// =====================================================

async function getStatsWindow(supabase: any, userId: number, days: number): Promise<TimeWindowStats> {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);

  // Get tests in this window
  const { data: tests, error } = await supabase
    .from("user_tests")
    .select("right_questions, wrong_questions, question_count, created_at")
    .eq("user_id", userId)
    .gte("created_at", cutoffDate.toISOString());

  if (error) throw error;

  // Calculate stats
  const correctas = tests.reduce((sum: number, t: any) => sum + (t.right_questions || 0), 0);
  const incorrectas = tests.reduce((sum: number, t: any) => sum + (t.wrong_questions || 0), 0);
  const total_preguntas = tests.reduce((sum: number, t: any) => sum + (t.question_count || 0), 0);
  const tests_finalizados = tests.length;

  // Count unique active days
  const uniqueDays = new Set(tests.map((t: any) => t.created_at.split('T')[0]));
  const dias_activos = uniqueDays.size;

  return {
    correctas,
    incorrectas,
    total_preguntas,
    tests_finalizados,
    dias_activos,
  };
}

// =====================================================
// 1. Quality Trend Score (0-400 pts)
// =====================================================

function calculateQualityTrend(stats: UserStats): number {
  // 1.1 Evolution of Success Rate (0-250 pts)
  const evolution_score = calculateSuccessRateEvolution(stats);

  // 1.2 Progress in Mock Rankings (0-150 pts)
  // This is calculated separately in calculateCompetitive
  // For now, we only calculate the success rate part here

  return Math.min(evolution_score, 400);
}

function calculateSuccessRateEvolution(stats: UserStats): number {
  // Calculate success rates in different windows
  const tasa_30d = calculateSuccessRate(stats.last_30d.correctas, stats.last_30d.incorrectas);
  const tasa_90d = calculateSuccessRate(stats.last_90d.correctas, stats.last_90d.incorrectas);
  const tasa_historica = calculateSuccessRate(
    stats.historical.rightQuestions,
    stats.historical.wrongQuestions
  );

  // Calculate relative improvements
  const mejora_30vs90 = tasa_90d > 0 ? (tasa_30d - tasa_90d) / tasa_90d : 0;
  const mejora_30vs_historico = tasa_historica > 0 ? (tasa_30d - tasa_historica) / tasa_historica : 0;

  // Points for improvement (only positive)
  const puntos_tendencia = 100 * Math.max(0, mejora_30vs90) + 50 * Math.max(0, mejora_30vs_historico);

  // Base points for current rate
  const puntos_base = tasa_30d * 100;

  // Total (max 250)
  return Math.min(puntos_tendencia + puntos_base, 250);
}

function calculateSuccessRate(correctas: number, incorrectas: number): number {
  const total = correctas + incorrectas;
  return total > 0 ? correctas / total : 0;
}

// =====================================================
// 2. Recent Activity Score (0-300 pts)
// =====================================================

function calculateRecentActivity(stats: UserStats): number {
  // 2.1 Tests finished in last 30 days (0-150 pts)
  const tests_score = calculateTestsScore(stats);

  // 2.2 Questions answered in last 30 days (0-100 pts)
  const questions_score = calculateQuestionsScore(stats.last_30d.total_preguntas);

  // 2.3 Active days in last 30 days (0-50 pts)
  const days_score = calculateActiveDaysScore(stats.last_30d.dias_activos);

  return Math.min(tests_score + questions_score + days_score, 300);
}

function calculateTestsScore(stats: UserStats): number {
  const tests_30d = stats.last_30d.tests_finalizados;

  // Calculate days since registration
  const diasDesdeRegistro = Math.max(1, Math.floor(
    (Date.now() - new Date(stats.historical.created_at).getTime()) / (1000 * 60 * 60 * 24)
  ));

  // Calculate activity ratio normalized
  const tests_por_mes = tests_30d / (diasDesdeRegistro / 30);
  const ratio_actividad = tests_por_mes / 30; // 1 test/day = ratio 1.0

  // Scale to points (max 150)
  return Math.min(ratio_actividad * 150, 150);
}

function calculateQuestionsScore(preguntas_30d: number): number {
  // 500 questions/month = objective (~17 questions/day)
  return Math.min((preguntas_30d / 500) * 100, 100);
}

function calculateActiveDaysScore(dias_activos_30d: number): number {
  // 30 active days = 50 points (perfect)
  return (dias_activos_30d / 30) * 50;
}

// =====================================================
// 3. Competitive Score (0-200 pts)
// =====================================================

async function calculateCompetitive(supabase: any, userId: number): Promise<number> {
  // Get user's Mock rankings
  const { data: rankings, error } = await supabase
    .from("topic_mock_rankings")
    .select("topic_id, first_score, rank_position")
    .eq("user_id", userId);

  if (error) throw error;
  if (!rankings || rankings.length === 0) return 0;

  // 3.1 Positions in Rankings (0-150 pts)
  const position_score = calculatePositionScore(rankings);

  // 3.2 Diversity in Rankings (0-50 pts)
  const diversity_score = await calculateDiversityScore(supabase, rankings);

  return Math.min(position_score + diversity_score, 200);
}

function calculatePositionScore(rankings: any[]): number {
  const puntos_por_posicion = (position: number): number => {
    if (position <= 1) return 15;
    if (position <= 3) return 12;
    if (position <= 5) return 10;
    if (position <= 10) return 8;
    if (position <= 25) return 5;
    if (position <= 50) return 3;
    return 1;
  };

  const total_puntos = rankings.reduce((sum, r) => sum + puntos_por_posicion(r.rank_position || 999), 0);
  return Math.min(total_puntos, 150);
}

async function calculateDiversityScore(supabase: any, rankings: any[]): Promise<number> {
  // Count unique topics attempted
  const topics_distintos = new Set(rankings.map(r => r.topic_id)).size;

  // Get total available Mock topics
  const { count, error } = await supabase
    .from("topics")
    .select("id", { count: "exact", head: true })
    .eq("mode", "Mock");

  if (error || !count) return 0;

  // Calculate diversity score
  return (topics_distintos / count) * 50;
}

// =====================================================
// 4. Momentum Score (0-100 pts)
// =====================================================

function calculateMomentum(stats: UserStats): number {
  // 4.1 Activity Acceleration (0-60 pts)
  const acceleration_score = calculateActivityAcceleration(stats);

  // 4.2 Recent Improvement (0-40 pts)
  const improvement_score = calculateRecentImprovement(stats);

  return Math.min(acceleration_score + improvement_score, 100);
}

function calculateActivityAcceleration(stats: UserStats): number {
  const preguntas_por_dia_7d = stats.last_7d.total_preguntas / 7;
  const preguntas_por_dia_30d = stats.last_30d.total_preguntas / 30;

  if (preguntas_por_dia_30d === 0) return 0;

  // Calculate acceleration (% increase)
  const aceleracion = (preguntas_por_dia_7d - preguntas_por_dia_30d) / preguntas_por_dia_30d;

  // Only positive bonuses
  return Math.max(0, Math.min(aceleracion * 60, 60));
}

function calculateRecentImprovement(stats: UserStats): number {
  const tasa_7d = calculateSuccessRate(stats.last_7d.correctas, stats.last_7d.incorrectas);
  const tasa_30d = calculateSuccessRate(stats.last_30d.correctas, stats.last_30d.incorrectas);

  if (tasa_30d === 0) return 0;

  // Calculate improvement
  const mejora = (tasa_7d - tasa_30d) / tasa_30d;

  // Only positive bonuses
  return Math.max(0, Math.min(mejora * 100, 40));
}

// =====================================================
// Recalculate Global Rankings
// =====================================================

async function recalculateGlobalRanks(supabase: any): Promise<void> {
  // Get the latest OPN index for each user from user_opn_index_current view
  const { data: currentIndexes, error: fetchError } = await supabase
    .from("user_opn_index_current")
    .select("user_id, opn_index, calculated_at")
    .order("opn_index", { ascending: false });

  if (fetchError) {
    console.error("Error fetching current indexes:", fetchError);
    throw fetchError;
  }

  if (!currentIndexes || currentIndexes.length === 0) {
    console.log("No current indexes found");
    return;
  }

  // Get the latest history record for each user
  const userIds = currentIndexes.map(idx => idx.user_id);

  // Fetch latest record for each user
  for (let i = 0; i < currentIndexes.length; i++) {
    const userId = currentIndexes[i].user_id;
    const rank = i + 1;

    // Get the latest record for this user
    const { data: latestRecord, error: recordError } = await supabase
      .from("user_opn_index_history")
      .select("id")
      .eq("user_id", userId)
      .order("calculated_at", { ascending: false })
      .limit(1)
      .single();

    if (recordError || !latestRecord) {
      console.error(`Error getting latest record for user ${userId}:`, recordError);
      continue;
    }

    // Update the rank
    const { error: updateError } = await supabase
      .from("user_opn_index_history")
      .update({ global_rank: rank })
      .eq("id", latestRecord.id);

    if (updateError) {
      console.error(`Error updating rank for user ${userId}:`, updateError);
    }
  }

  console.log(`Updated ${currentIndexes.length} user rankings`);
}