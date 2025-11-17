-- Función para actualizar automáticamente el campo updated_at en la tabla challenge
CREATE OR REPLACE FUNCTION "public"."update_challenge_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Asignar permisos
ALTER FUNCTION "public"."update_challenge_updated_at"() OWNER TO "postgres";

GRANT ALL ON FUNCTION "public"."update_challenge_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_challenge_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_challenge_updated_at"() TO "service_role";

-- Trigger para INSERT y UPDATE en la tabla challenge
CREATE OR REPLACE TRIGGER "trigger_update_challenge_updated_at"
BEFORE INSERT OR UPDATE ON "public"."challenge"
FOR EACH ROW
EXECUTE FUNCTION "public"."update_challenge_updated_at"();

-- Comentario explicativo
COMMENT ON TRIGGER "trigger_update_challenge_updated_at" ON "public"."challenge" IS
'Actualiza automáticamente el campo updated_at con la fecha y hora actual cuando se inserta o actualiza un registro en la tabla challenge';