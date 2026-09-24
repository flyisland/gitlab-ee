CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE jh_epic_extends (
    id bigint NOT NULL,
    epic_id bigint,
    milestone_id bigint,
    sprint_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE jh_epic_extends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jh_epic_extends_id_seq OWNED BY jh_epic_extends.id;

CREATE TABLE jh_milestone_extends (
    id bigint NOT NULL,
    milestone_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE jh_milestone_extends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jh_milestone_extends_id_seq OWNED BY jh_milestone_extends.id;

CREATE TABLE jh_sprint_extends (
    id bigint NOT NULL,
    sprint_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE jh_sprint_extends_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jh_sprint_extends_id_seq OWNED BY jh_sprint_extends.id;

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

ALTER TABLE ONLY jh_epic_extends ALTER COLUMN id SET DEFAULT nextval('jh_epic_extends_id_seq'::regclass);

ALTER TABLE ONLY jh_milestone_extends ALTER COLUMN id SET DEFAULT nextval('jh_milestone_extends_id_seq'::regclass);

ALTER TABLE ONLY jh_sprint_extends ALTER COLUMN id SET DEFAULT nextval('jh_sprint_extends_id_seq'::regclass);

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);

ALTER TABLE ONLY jh_epic_extends
    ADD CONSTRAINT jh_epic_extends_pkey PRIMARY KEY (id);

ALTER TABLE ONLY jh_milestone_extends
    ADD CONSTRAINT jh_milestone_extends_pkey PRIMARY KEY (id);

ALTER TABLE ONLY jh_sprint_extends
    ADD CONSTRAINT jh_sprint_extends_pkey PRIMARY KEY (id);

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

CREATE UNIQUE INDEX index_jh_epic_extends_on_epic_id ON jh_epic_extends USING btree (epic_id);

CREATE UNIQUE INDEX index_jh_epic_extends_on_epic_id_and_milestone_id ON jh_epic_extends USING btree (epic_id, milestone_id);

CREATE UNIQUE INDEX index_jh_epic_extends_on_epic_id_and_sprint_id ON jh_epic_extends USING btree (epic_id, sprint_id);

CREATE INDEX index_jh_epic_extends_on_milestone_id ON jh_epic_extends USING btree (milestone_id);

CREATE INDEX index_jh_epic_extends_on_sprint_id ON jh_epic_extends USING btree (sprint_id);

CREATE INDEX index_jh_milestone_extends_on_milestone_id ON jh_milestone_extends USING btree (milestone_id);

CREATE INDEX index_jh_sprint_extends_on_sprint_id ON jh_sprint_extends USING btree (sprint_id);
