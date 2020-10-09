--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.19
-- Dumped by pg_dump version 9.6.19

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: apps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apps (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(30) NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    repo text,
    exposure text DEFAULT 'private'::text NOT NULL,
    certs json,
    maintenance boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    name text,
    certificate_chain text,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now())
);


--
-- Name: configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    vars public.hstore,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now())
);


--
-- Name: domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.domains (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    hostname text NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now())
);


--
-- Name: ecs_environment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ecs_environment (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    environment json NOT NULL
);


--
-- Name: ports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    port integer,
    app_id uuid,
    taken text
);


--
-- Name: releases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.releases (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id uuid NOT NULL,
    config_id uuid NOT NULL,
    slug_id uuid NOT NULL,
    version integer NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    formation json NOT NULL
);


--
-- Name: scheduler_migration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduler_migration (
    app_id text NOT NULL,
    backend text NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version integer NOT NULL
);


--
-- Name: slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.slugs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    image text NOT NULL,
    procfile bytea NOT NULL
);


--
-- Name: stacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stacks (
    app_id text NOT NULL,
    stack_name text NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    deleted_at timestamp without time zone
);


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: configs configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configs
    ADD CONSTRAINT configs_pkey PRIMARY KEY (id);


--
-- Name: domains domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- Name: ecs_environment ecs_environment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ecs_environment
    ADD CONSTRAINT ecs_environment_pkey PRIMARY KEY (id);


--
-- Name: ports ports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: slugs slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.slugs
    ADD CONSTRAINT slugs_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_certificates_on_app_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_certificates_on_app_id ON public.certificates USING btree (app_id);


--
-- Name: index_configs_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_configs_on_created_at ON public.configs USING btree (created_at);


--
-- Name: index_domains_on_app_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_domains_on_app_id ON public.domains USING btree (app_id);


--
-- Name: index_domains_on_hostname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_domains_on_hostname ON public.domains USING btree (hostname);


--
-- Name: index_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_username ON public.users USING btree (username);


--
-- Name: index_releases_on_app_id_and_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_releases_on_app_id_and_version ON public.releases USING btree (app_id, version);


--
-- Name: index_stacks_on_app_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stacks_on_app_id ON public.stacks USING btree (app_id);


--
-- Name: index_stacks_on_stack_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_stacks_on_stack_name ON public.stacks USING btree (stack_name);


--
-- Name: unique_app_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_app_name ON public.apps USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: certificates certificates_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: configs configs_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configs
    ADD CONSTRAINT configs_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: domains domains_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.domains
    ADD CONSTRAINT domains_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: ports ports_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE SET NULL;


--
-- Name: releases releases_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases
    ADD CONSTRAINT releases_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.apps(id) ON DELETE CASCADE;


--
-- Name: releases releases_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases
    ADD CONSTRAINT releases_config_id_fkey FOREIGN KEY (config_id) REFERENCES public.configs(id) ON DELETE CASCADE;


--
-- Name: releases releases_slug_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.releases
    ADD CONSTRAINT releases_slug_id_fkey FOREIGN KEY (slug_id) REFERENCES public.slugs(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

