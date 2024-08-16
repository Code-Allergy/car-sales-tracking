DECLARE
    rec RECORD;
BEGIN
-- Drop all tables
FOR rec IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
		EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(rec.tablename) || ' CASCADE';
END LOOP;

-- drop all auth
FOR rec IN (SELECT tablename FROM pg_tables WHERE schemaname = 'auth') LOOP
		EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident('auth') || '.' || quote_ident(rec.tablename) || ' CASCADE';
END LOOP;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
PERFORM pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE SCHEMA IF NOT EXISTS "public";

ALTER SCHEMA "public" OWNER TO "pg_database_owner";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" "json",
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);

ALTER TABLE "auth"."audit_log_entries" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."flow_state" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "auth_code" "text" NOT NULL,
    "code_challenge_method" "auth"."code_challenge_method" NOT NULL,
    "code_challenge" "text" NOT NULL,
    "provider_type" "text" NOT NULL,
    "provider_access_token" "text",
    "provider_refresh_token" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" "text" NOT NULL
);

ALTER TABLE "auth"."flow_state" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."identities" (
    "id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "provider_id" text NOT NULL,
    "email" "text" GENERATED ALWAYS AS ("lower"(("identity_data" ->> 'email'::"text"))) STORED
);

ALTER TABLE "auth"."identities" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);

ALTER TABLE "auth"."instances" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."mfa_amr_claims" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" "text" NOT NULL,
    "id" "uuid" NOT NULL
);

ALTER TABLE "auth"."mfa_amr_claims" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."mfa_challenges" (
    "id" "uuid" NOT NULL,
    "factor_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" "inet" NOT NULL
);

ALTER TABLE "auth"."mfa_challenges" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."mfa_factors" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "friendly_name" "text",
    "factor_type" "auth"."factor_type" NOT NULL,
    "status" "auth"."factor_status" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" "text",
    "last_challenged_at" timestamp with time zone,
    "phone" "text"
);

ALTER TABLE "auth"."mfa_factors" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigserial NOT NULL PRIMARY KEY,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);

ALTER TABLE "auth"."refresh_tokens" OWNER TO "supabase_auth_admin";

CREATE SEQUENCE IF NOT EXISTS "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "auth"."refresh_tokens_id_seq" OWNER TO "supabase_auth_admin";

ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";

CREATE TABLE IF NOT EXISTS "auth"."saml_providers" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "entity_id" "text" NOT NULL,
    "metadata_xml" "text" NOT NULL,
    "metadata_url" "text",
    "attribute_mapping" "jsonb",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "entity_id not empty" CHECK (("char_length"("entity_id") > 0)),
    CONSTRAINT "metadata_url not empty" CHECK ((("metadata_url" = NULL::"text") OR ("char_length"("metadata_url") > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK (("char_length"("metadata_xml") > 0))
);

ALTER TABLE "auth"."saml_providers" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."saml_relay_states" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "request_id" "text" NOT NULL,
    "for_email" "text",
    "redirect_to" "text",
    "from_ip_address" "inet",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" "uuid",
    CONSTRAINT "request_id not empty" CHECK (("char_length"("request_id") > 0))
);

ALTER TABLE "auth"."saml_relay_states" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);

ALTER TABLE "auth"."schema_migrations" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" "uuid",
    "aal" "auth"."aal_level",
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" "text",
    "ip" "inet",
    "tag" "text"
);

ALTER TABLE "auth"."sessions" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."sso_domains" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "domain" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK (("char_length"("domain") > 0))
);

ALTER TABLE "auth"."sso_domains" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."sso_providers" (
    "id" "uuid" NOT NULL,
    "resource_id" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK ((("resource_id" = NULL::"text") OR ("char_length"("resource_id") > 0)))
);

ALTER TABLE "auth"."sso_providers" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text" DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text" DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" bool DEFAULT false NOT NULL,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);

ALTER TABLE "auth"."users" OWNER TO "supabase_auth_admin";

CREATE TABLE IF NOT EXISTS "public"."Customers" (
    "id" integer NOT NULL,
    "Name" character varying(255) NOT NULL,
    "City" character varying(255) NOT NULL
);

ALTER TABLE "public"."Customers" OWNER TO "postgres";

ALTER TABLE "public"."Customers" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Customers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."Employees" (
    "id" "uuid" NOT NULL,
    "Name" "text" NOT NULL,
    "EmployeeNumber" "text" NOT NULL,
    "Role" integer NOT NULL,
    "Email" "text" NOT NULL,
    "Avatar" "text" DEFAULT '01.png'::"text" NOT NULL
);

ALTER TABLE "public"."Employees" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."Financing" (
    "id" integer NOT NULL,
    "Method" "text" NOT NULL
);

ALTER TABLE "public"."Financing" OWNER TO "postgres";

ALTER TABLE "public"."Financing" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Financing_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."MonthlySales" (
    "id" integer NOT NULL,
    "TimePeriod" timestamp with time zone NOT NULL,
    "GrossProfit" numeric(10,2) NOT NULL,
    "FinAndInsurance" numeric(10,2) NOT NULL,
    "Holdback" numeric(10,2) NOT NULL,
    "Total" numeric(10,2) NOT NULL
);

ALTER TABLE "public"."MonthlySales" OWNER TO "postgres";

ALTER TABLE "public"."MonthlySales" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."MonthlySales_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."Notifications" (
    "id" bigint NOT NULL,
    "Sale" integer NOT NULL,
    "Employee" "uuid" NOT NULL
);

ALTER TABLE "public"."Notifications" OWNER TO "postgres";

ALTER TABLE "public"."Notifications" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Notifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."ReferencePages" (
    "id" bigint NOT NULL,
    "pagename" character varying DEFAULT ''::character varying NOT NULL,
    "pagebody" character varying DEFAULT ''::character varying NOT NULL
);

ALTER TABLE "public"."ReferencePages" OWNER TO "postgres";

ALTER TABLE "public"."ReferencePages" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."ReferencePages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."Roles" (
    "id" integer NOT NULL,
    "RoleName" "text" NOT NULL,
    "ReadPermission" boolean DEFAULT false NOT NULL,
    "WritePermission" boolean DEFAULT false NOT NULL,
    "ModifySelfPermission" boolean DEFAULT false NOT NULL,
    "ModifyAllPermission" boolean DEFAULT false NOT NULL,
    "EmployeePermission" boolean DEFAULT false NOT NULL,
    "DatabasePermission" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."Roles" OWNER TO "postgres";

ALTER TABLE "public"."Roles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Roles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."Sales" (
    "id" integer NOT NULL,
    "StockNumber" "text" NOT NULL,
    "VehicleMake" "text" NOT NULL,
    "ActualCashValue" numeric(10,2) NOT NULL,
    "GrossProfit" numeric(10,2) NOT NULL,
    "FinAndInsurance" numeric(10,2) NOT NULL,
    "SaleTime" timestamp with time zone DEFAULT "now"(),
    "NewSale" boolean,
    "Holdback" numeric(10,2),
    "LotPack" numeric(10,2),
    "DaysInStock" integer,
    "DealerCost" numeric(10,2),
    "ROI" numeric(3,2),
    "Total" numeric(10,2) NOT NULL,
    "CustomerID" integer NOT NULL,
    "FinancingID" integer,
    "TradeInID" integer,
    "EmployeeID" "uuid" DEFAULT "auth"."uid"()
);

ALTER TABLE "public"."Sales" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."SalesGoals" (
    "id" integer NOT NULL,
    "Name" character varying(255) NOT NULL,
    "Description" "text" DEFAULT ''::"text",
    "StartDate" timestamp with time zone NOT NULL,
    "EndDate" timestamp with time zone NOT NULL,
    "TotalGoal" numeric(10,2) NOT NULL,
    "Creator" "uuid"
);

ALTER TABLE "public"."SalesGoals" OWNER TO "postgres";

ALTER TABLE "public"."SalesGoals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."SalesGoals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE "public"."Sales" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Sales_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."Tasks" (
    "id" integer NOT NULL,
    "Name" character varying(255) NOT NULL,
    "Description" "text",
    "StartDate" timestamp without time zone DEFAULT "now"() NOT NULL,
    "EndDate" timestamp without time zone DEFAULT "now"() NOT NULL,
    "Assignee" "uuid",
    "Creator" "uuid" NOT NULL,
    "Status" "public"."Task Status" DEFAULT 'IN_PROGRESS'::"public"."Task Status" NOT NULL
);

ALTER TABLE "public"."Tasks" OWNER TO "postgres";

ALTER TABLE "public"."Tasks" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."Tasks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."TradeIns" (
    "id" integer NOT NULL,
    "Trade" character varying(255) NOT NULL,
    "ActualCashValue" numeric(10,2) NOT NULL
);

ALTER TABLE "public"."TradeIns" OWNER TO "postgres";

ALTER TABLE "public"."TradeIns" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."TradeIns_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

ALTER TABLE ONLY "public"."MonthlySales"
    ADD CONSTRAINT "MonthlySales_TimePeriod_key" UNIQUE ("TimePeriod");

ALTER TABLE ONLY "public"."ReferencePages"
    ADD CONSTRAINT "ReferencePages_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."SalesGoals"
    ADD CONSTRAINT "SalesGoals_EndDate_key" UNIQUE ("EndDate");

ALTER TABLE ONLY "public"."SalesGoals"
    ADD CONSTRAINT "SalesGoals_StartDate_key" UNIQUE ("StartDate");

ALTER TABLE ONLY "public"."Customers"
    ADD CONSTRAINT "customers_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Employees"
    ADD CONSTRAINT "employees_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Financing"
    ADD CONSTRAINT "financing_method_key" UNIQUE ("Method");

ALTER TABLE ONLY "public"."Financing"
    ADD CONSTRAINT "financing_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."MonthlySales"
    ADD CONSTRAINT "monthlysales_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Roles"
    ADD CONSTRAINT "roles_rolename_key" UNIQUE ("RoleName");

ALTER TABLE ONLY "public"."Sales"
    ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."SalesGoals"
    ADD CONSTRAINT "salesgoals_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."Tasks"
    ADD CONSTRAINT "tasks_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."TradeIns"
    ADD CONSTRAINT "tradeins_pkey" PRIMARY KEY ("id");

CREATE OR REPLACE TRIGGER "on_auth_user_created" AFTER INSERT ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();

CREATE OR REPLACE TRIGGER "update_employee_trigger" AFTER UPDATE ON "auth"."users" FOR EACH ROW EXECUTE FUNCTION "public"."handle_update_user"();

CREATE OR REPLACE TRIGGER "after_sale_insert" AFTER INSERT ON "public"."Sales" FOR EACH ROW EXECUTE FUNCTION "public"."after_sale_insert_trigger"();

CREATE OR REPLACE TRIGGER "handle_sale_deletion_trigger" AFTER DELETE ON "public"."Sales" FOR EACH ROW EXECUTE FUNCTION "public"."handle_sale_deletion"();

ALTER TABLE ONLY "public"."Notifications"
    ADD CONSTRAINT "Notifications_Sale_fkey" FOREIGN KEY ("Sale") REFERENCES "public"."Sales"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."SalesGoals"
    ADD CONSTRAINT "SalesGoals_Creator_fkey" FOREIGN KEY ("Creator") REFERENCES "public"."Employees"("id") ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE ONLY "public"."Sales"
    ADD CONSTRAINT "Sales_EmployeeID_fkey" FOREIGN KEY ("EmployeeID") REFERENCES "public"."Employees"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;

ALTER TABLE ONLY "public"."Sales"
    ADD CONSTRAINT "Sales_FinancingID_fkey" FOREIGN KEY ("FinancingID") REFERENCES "public"."Financing"("id");

ALTER TABLE ONLY "public"."Employees"
    ADD CONSTRAINT "employees_role_fkey" FOREIGN KEY ("Role") REFERENCES "public"."Roles"("id") ON UPDATE CASCADE;

ALTER TABLE ONLY "public"."Notifications"
    ADD CONSTRAINT "notifications_employee_fkey" FOREIGN KEY ("Employee") REFERENCES "public"."Employees"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Sales"
    ADD CONSTRAINT "sales_customerid_fkey" FOREIGN KEY ("CustomerID") REFERENCES "public"."Customers"("id");

ALTER TABLE ONLY "public"."Sales"
    ADD CONSTRAINT "sales_tradeinid_fkey" FOREIGN KEY ("TradeInID") REFERENCES "public"."TradeIns"("id");

ALTER TABLE ONLY "public"."Tasks"
    ADD CONSTRAINT "tasks_assignee_fkey" FOREIGN KEY ("Assignee") REFERENCES "public"."Employees"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."Tasks"
    ADD CONSTRAINT "tasks_creator_fkey" FOREIGN KEY ("Creator") REFERENCES "public"."Employees"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Customers" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Employees" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable all access for all authenticated users -- tmp" ON "public"."Customers" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for all authenticated users -- tmp" ON "public"."Financing" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for all authenticated users -- tmp" ON "public"."MonthlySales" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for all users -- tmp" ON "public"."SalesGoals" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable all for auth users -- tmp - need employee reference?" ON "public"."Roles" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable delete for users based on Creator | Assignee -- temp?" ON "public"."Tasks" FOR DELETE TO "authenticated" USING ((("auth"."uid"() = "Creator") OR ("auth"."uid"() = "Assignee")));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."TradeIns" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users to insert for themselves." ON "public"."Tasks" FOR INSERT TO "authenticated" WITH CHECK (("Creator" = "auth"."uid"()));

CREATE POLICY "Enable read access for all authenticated users" ON "public"."Employees" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all authenticated users --tmp" ON "public"."Tasks" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "Assignee"));

CREATE POLICY "Enable read access for all users -- tmp" ON "public"."Sales" TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable read for authenticated users only" ON "public"."TradeIns" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read for users based on user_id" ON "public"."Notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "Employee"));

CREATE POLICY "Enable update for authenticated users only" ON "public"."TradeIns" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);

CREATE POLICY "Enable update for users based on their creator" ON "public"."Tasks" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "Creator")) WITH CHECK (("auth"."uid"() = "Creator"));

ALTER TABLE "public"."Financing" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."MonthlySales" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Notifications" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."ReferencePages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Roles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Sales" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."SalesGoals" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."Tasks" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."TradeIns" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "enable all access for users -- tmp" ON "public"."ReferencePages" TO "authenticated" USING (true) WITH CHECK (true);

GRANT USAGE ON SCHEMA "auth" TO "anon";
GRANT USAGE ON SCHEMA "auth" TO "authenticated";
GRANT USAGE ON SCHEMA "auth" TO "service_role";
GRANT ALL ON SCHEMA "auth" TO "supabase_auth_admin";
GRANT ALL ON SCHEMA "auth" TO "dashboard_user";
GRANT ALL ON SCHEMA "auth" TO "postgres";

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "auth"."email"() TO "dashboard_user";

GRANT ALL ON FUNCTION "auth"."jwt"() TO "postgres";
GRANT ALL ON FUNCTION "auth"."jwt"() TO "dashboard_user";

GRANT ALL ON FUNCTION "auth"."role"() TO "dashboard_user";

GRANT ALL ON FUNCTION "auth"."uid"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."armor"("bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."crypt"("text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."dearmor"("text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."digest"("bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."digest"("text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."gen_random_uuid"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."gen_salt"("text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."gen_salt"("text", integer) FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."url_decode"("data" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v1"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v4"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_nil"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_ns_dns"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_ns_oid"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_ns_url"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."uuid_ns_x500"() FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "dashboard_user";

REVOKE ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") FROM "postgres";
GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";

GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "postgres";
GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "service_role";

GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea") TO "service_role";

GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea") TO "service_role";

GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() TO "service_role";

GRANT ALL ON FUNCTION "public"."after_sale_insert_trigger"() TO "anon";
GRANT ALL ON FUNCTION "public"."after_sale_insert_trigger"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."after_sale_insert_trigger"() TO "service_role";

GRANT ALL ON FUNCTION "public"."create_new_sale"("sale" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_new_sale"("sale" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_new_sale"("sale" "jsonb") TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_sale_deletion"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_sale_deletion"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_sale_deletion"() TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_update_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_update_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_update_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."update_new_sale"("sale" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_new_sale"("sale" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_new_sale"("sale" "jsonb") TO "service_role";

GRANT ALL ON TABLE "auth"."audit_log_entries" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."audit_log_entries" TO "postgres";

GRANT ALL ON TABLE "auth"."flow_state" TO "postgres";
GRANT ALL ON TABLE "auth"."flow_state" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."identities" TO "postgres";
GRANT ALL ON TABLE "auth"."identities" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."instances" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."instances" TO "postgres";

GRANT ALL ON TABLE "auth"."mfa_amr_claims" TO "postgres";
GRANT ALL ON TABLE "auth"."mfa_amr_claims" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."mfa_challenges" TO "postgres";
GRANT ALL ON TABLE "auth"."mfa_challenges" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."mfa_factors" TO "postgres";
GRANT ALL ON TABLE "auth"."mfa_factors" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."refresh_tokens" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."refresh_tokens" TO "postgres";

GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "dashboard_user";
GRANT ALL ON SEQUENCE "auth"."refresh_tokens_id_seq" TO "postgres";

GRANT ALL ON TABLE "auth"."saml_providers" TO "postgres";
GRANT ALL ON TABLE "auth"."saml_providers" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."saml_relay_states" TO "postgres";
GRANT ALL ON TABLE "auth"."saml_relay_states" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."schema_migrations" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."schema_migrations" TO "postgres";

GRANT ALL ON TABLE "auth"."sessions" TO "postgres";
GRANT ALL ON TABLE "auth"."sessions" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."sso_domains" TO "postgres";
GRANT ALL ON TABLE "auth"."sso_domains" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."sso_providers" TO "postgres";
GRANT ALL ON TABLE "auth"."sso_providers" TO "dashboard_user";

GRANT ALL ON TABLE "auth"."users" TO "dashboard_user";
GRANT ALL ON TABLE "auth"."users" TO "postgres";

REVOKE ALL ON TABLE "extensions"."pg_stat_statements" FROM "postgres";
GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "dashboard_user";

REVOKE ALL ON TABLE "extensions"."pg_stat_statements_info" FROM "postgres";
GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "postgres" WITH GRANT OPTION;
GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "dashboard_user";

GRANT ALL ON TABLE "pgsodium"."decrypted_key" TO "pgsodium_keyholder";

GRANT ALL ON TABLE "pgsodium"."masking_rule" TO "pgsodium_keyholder";

GRANT ALL ON TABLE "pgsodium"."mask_columns" TO "pgsodium_keyholder";

GRANT ALL ON TABLE "public"."Customers" TO "anon";
GRANT ALL ON TABLE "public"."Customers" TO "authenticated";
GRANT ALL ON TABLE "public"."Customers" TO "service_role";

GRANT ALL ON SEQUENCE "public"."Customers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Customers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Customers_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."Employees" TO "anon";
GRANT ALL ON TABLE "public"."Employees" TO "authenticated";
GRANT ALL ON TABLE "public"."Employees" TO "service_role";

GRANT ALL ON TABLE "public"."Financing" TO "anon";
GRANT ALL ON TABLE "public"."Financing" TO "authenticated";
GRANT ALL ON TABLE "public"."Financing" TO "service_role";

GRANT ALL ON SEQUENCE "public"."Financing_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Financing_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Financing_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."MonthlySales" TO "anon";
GRANT ALL ON TABLE "public"."MonthlySales" TO "authenticated";
GRANT ALL ON TABLE "public"."MonthlySales" TO "service_role";

GRANT ALL ON SEQUENCE "public"."MonthlySales_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."MonthlySales_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."MonthlySales_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."Notifications" TO "anon";
GRANT ALL ON TABLE "public"."Notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."Notifications" TO "service_role";

GRANT ALL ON SEQUENCE "public"."Notifications_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Notifications_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Notifications_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."ReferencePages" TO "anon";
GRANT ALL ON TABLE "public"."ReferencePages" TO "authenticated";
GRANT ALL ON TABLE "public"."ReferencePages" TO "service_role";

GRANT ALL ON SEQUENCE "public"."ReferencePages_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."ReferencePages_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."ReferencePages_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."Roles" TO "anon";
GRANT ALL ON TABLE "public"."Roles" TO "authenticated";
GRANT ALL ON TABLE "public"."Roles" TO "service_role";

GRANT ALL ON SEQUENCE "public"."Roles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Roles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Roles_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."Sales" TO "anon";
GRANT ALL ON TABLE "public"."Sales" TO "authenticated";
GRANT ALL ON TABLE "public"."Sales" TO "service_role";

GRANT ALL ON TABLE "public"."SalesGoals" TO "anon";
GRANT ALL ON TABLE "public"."SalesGoals" TO "authenticated";
GRANT ALL ON TABLE "public"."SalesGoals" TO "service_role";

GRANT ALL ON SEQUENCE "public"."SalesGoals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."SalesGoals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."SalesGoals_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."Sales_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Sales_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Sales_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."Tasks" TO "anon";
GRANT ALL ON TABLE "public"."Tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."Tasks" TO "service_role";

GRANT ALL ON SEQUENCE "public"."Tasks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."Tasks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."Tasks_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."TradeIns" TO "anon";
GRANT ALL ON TABLE "public"."TradeIns" TO "authenticated";
GRANT ALL ON TABLE "public"."TradeIns" TO "service_role";

GRANT ALL ON SEQUENCE "public"."TradeIns_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."TradeIns_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."TradeIns_id_seq" TO "service_role";

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON SEQUENCES  TO "dashboard_user";

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON FUNCTIONS  TO "dashboard_user";

ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_auth_admin" IN SCHEMA "auth" GRANT ALL ON TABLES  TO "dashboard_user";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

INSERT INTO "public"."Roles" ("id", "RoleName", "ReadPermission", "WritePermission", "ModifySelfPermission", "ModifyAllPermission", "EmployeePermission", "DatabasePermission") VALUES
(1, 'Default', false, false, false, false, false, false),
(2, 'Administrator', true, true, true, true, true, true);

END;