-- Añade la columna question_goal a la tabla users
-- Esta columna almacena el objetivo de preguntas semanales que el usuario quiere alcanzar

ALTER TABLE "public"."users"
ADD COLUMN question_goal INTEGER NOT NULL DEFAULT 300;

COMMENT ON COLUMN "public"."users"."question_goal" IS 'Objetivo de preguntas que el usuario quiere alcanzar (por defecto 300)';