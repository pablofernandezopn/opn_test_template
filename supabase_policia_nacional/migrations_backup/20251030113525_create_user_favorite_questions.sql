-- Create table for user favorite questions
CREATE TABLE IF NOT EXISTS "public"."user_favorite_questions" (
    "id" bigserial PRIMARY KEY,
    "user_id" bigint NOT NULL,
    "question_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT "user_favorite_questions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE,
    CONSTRAINT "user_favorite_questions_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."questions"("id") ON DELETE CASCADE,
    CONSTRAINT "user_favorite_questions_unique" UNIQUE ("user_id", "question_id")
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS "idx_user_favorite_questions_user_id" ON "public"."user_favorite_questions" ("user_id");
CREATE INDEX IF NOT EXISTS "idx_user_favorite_questions_question_id" ON "public"."user_favorite_questions" ("question_id");

-- Set ownership
ALTER TABLE "public"."user_favorite_questions" OWNER TO "postgres";

-- Note: RLS is not enabled as the application handles authentication at the app level
-- using WordPress tokens. Security checks should be performed in the application layer.

-- Grant necessary permissions
GRANT ALL ON TABLE "public"."user_favorite_questions" TO "anon";
GRANT ALL ON TABLE "public"."user_favorite_questions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_favorite_questions" TO "service_role";

-- Comment on table
COMMENT ON TABLE "public"."user_favorite_questions" IS 'Stores user favorite questions for quick access';