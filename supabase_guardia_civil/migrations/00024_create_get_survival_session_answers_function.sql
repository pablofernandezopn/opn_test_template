-- Función SQL para obtener todas las respuestas de una sesión de supervivencia
-- Retorna las preguntas, opciones y respuestas seleccionadas desde user_test_answers

CREATE OR REPLACE FUNCTION "public"."get_survival_session_answers"(p_session_id INTEGER)
RETURNS TABLE (
  question_id INTEGER,
  question_text TEXT,
  question_tip TEXT,
  selected_option_id INTEGER,
  was_correct BOOLEAN,
  time_taken_seconds INTEGER,
  option_id INTEGER,
  option_answer TEXT,
  option_order INTEGER,
  option_is_correct BOOLEAN,
  answered_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    q.id::INTEGER AS question_id,
    q.question AS question_text,
    q.tip AS question_tip,
    uta.selected_option_id::INTEGER AS selected_option_id,
    COALESCE(uta.correct, false) AS was_correct,
    uta.time_taken_seconds::INTEGER AS time_taken_seconds,
    qo.id::INTEGER AS option_id,
    qo.answer AS option_answer,
    qo.option_order::INTEGER,
    qo.is_correct AS option_is_correct,
    uta.answered_at AS answered_at
  FROM user_tests ut
  INNER JOIN user_test_answers uta ON uta.user_test_id = ut.id
  INNER JOIN questions q ON q.id = uta.question_id
  INNER JOIN question_options qo ON qo.question_id = q.id
  WHERE ut.survival_session_id = p_session_id
  ORDER BY uta.answered_at ASC, qo.option_order ASC;
END;
$$;

-- Grant access to authenticated users
GRANT EXECUTE ON FUNCTION "public"."get_survival_session_answers"(INTEGER) TO authenticated;

-- Set owner
ALTER FUNCTION "public"."get_survival_session_answers"(INTEGER) OWNER TO "postgres";

-- Comentario
COMMENT ON FUNCTION "public"."get_survival_session_answers"(INTEGER) IS
'Obtiene todas las respuestas de una sesión de supervivencia con sus preguntas y opciones';