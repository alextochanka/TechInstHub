--
-- PostgreSQL database dump
--

\restrict DC5pE9S7JGTIImSLLzasgpJvXkXq8E7ySw7f6oABwoeEMBgiQjaN1JLpgqCrgHV

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    user_id uuid,
    admin_level integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admins_id_seq OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applications (
    id uuid NOT NULL,
    project_id uuid,
    student_id uuid,
    status character varying(20) DEFAULT 'pending'::character varying,
    applied_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT applications_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'rejected'::character varying])::text[])))
);


ALTER TABLE public.applications OWNER TO postgres;

--
-- Name: chat_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_members (
    id integer NOT NULL,
    chat_id uuid,
    user_id uuid,
    created_at timestamp without time zone
);


ALTER TABLE public.chat_members OWNER TO postgres;

--
-- Name: chat_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_members_id_seq OWNER TO postgres;

--
-- Name: chat_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_members_id_seq OWNED BY public.chat_members.id;


--
-- Name: chats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chats (
    id uuid NOT NULL,
    name character varying(200),
    is_group boolean DEFAULT false,
    last_message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.chats OWNER TO postgres;

--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    id uuid NOT NULL,
    entity_type character varying(50),
    entity_id uuid,
    image_url character varying(500),
    image_type character varying(50),
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file_name character varying(255),
    file_size integer
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id integer NOT NULL,
    user_id uuid,
    action character varying(200),
    details text,
    ip_address character varying(45),
    created_at timestamp without time zone
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.logs_id_seq OWNER TO postgres;

--
-- Name: logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.logs_id_seq OWNED BY public.logs.id;


--
-- Name: message_attachments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_attachments (
    id uuid NOT NULL,
    message_id uuid,
    file_url character varying(500) NOT NULL,
    file_name character varying(255),
    file_size integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.message_attachments OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id uuid NOT NULL,
    chat_id uuid,
    sender_id uuid,
    content text NOT NULL,
    is_read boolean DEFAULT false,
    sent_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: news_feed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.news_feed (
    id uuid NOT NULL,
    type character varying(20) DEFAULT 'news'::character varying,
    title character varying(200) NOT NULL,
    content text,
    image_url character varying(500),
    published_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    event_date date,
    event_location character varying(500)
);


ALTER TABLE public.news_feed OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    id_tutor uuid,
    title character varying(200) NOT NULL,
    description text,
    requirements text,
    details text,
    topic_id integer,
    difficulty character varying(20),
    deadline date,
    status character varying(20) DEFAULT 'открыт'::character varying,
    max_students integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT projects_difficulty_check CHECK (((difficulty)::text = ANY ((ARRAY['легкий'::character varying, 'средний'::character varying, 'сложный'::character varying])::text[])))
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id uuid NOT NULL,
    author_id uuid,
    recipient_id uuid,
    rating integer,
    comment text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id integer NOT NULL,
    user_id uuid,
    student_id character varying(50),
    course integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.students OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.students_id_seq OWNER TO postgres;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: teachers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teachers (
    id integer NOT NULL,
    user_id uuid,
    "position" character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.teachers OWNER TO postgres;

--
-- Name: teachers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teachers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teachers_id_seq OWNER TO postgres;

--
-- Name: teachers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teachers_id_seq OWNED BY public.teachers.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topics (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.topics OWNER TO postgres;

--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.topics_id_seq OWNER TO postgres;

--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.topics_id_seq OWNED BY public.topics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    group_number character varying(50),
    course integer,
    about text,
    role character varying(20) NOT NULL,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    rating numeric(3,2) DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    avatar_url character varying(500),
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['student'::character varying, 'teacher'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: chat_members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members ALTER COLUMN id SET DEFAULT nextval('public.chat_members_id_seq'::regclass);


--
-- Name: logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs ALTER COLUMN id SET DEFAULT nextval('public.logs_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: teachers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers ALTER COLUMN id SET DEFAULT nextval('public.teachers_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics ALTER COLUMN id SET DEFAULT nextval('public.topics_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, user_id, admin_level, created_at, updated_at) FROM stdin;
1	ee3c8434-e840-499f-98f4-9cc8542ccd9b	1	2026-05-03 20:17:56.376681	2026-05-03 20:17:56.376681
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applications (id, project_id, student_id, status, applied_at, updated_at) FROM stdin;
b0717067-b6b0-4769-8cb1-e8cad5397a7e	5fc70644-6800-4033-a1c1-9b7d9b3f8023	628d35df-ade3-4b26-aab4-310f27a71a91	accepted	2026-05-30 01:58:34.509006	2026-05-30 01:59:07.939907
\.


--
-- Data for Name: chat_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_members (id, chat_id, user_id, created_at) FROM stdin;
6	8d45be34-ba00-40f8-a227-acfa18be2157	1e2c3d0b-2267-4c17-acdf-cff20ac59965	2026-05-30 01:59:08.040818
7	8d45be34-ba00-40f8-a227-acfa18be2157	628d35df-ade3-4b26-aab4-310f27a71a91	2026-05-30 01:59:08.040818
\.


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chats (id, name, is_group, last_message, created_at, updated_at) FROM stdin;
3d0dd027-8344-4cc0-9473-b15e1084f512	asddsasd	t	asdasdas	2026-05-03 20:29:17.587832	2026-05-03 20:29:30.896219
77f27250-b186-499e-b9dd-bf165c6a1f9c	dassasa	t	ree	2026-05-04 16:53:36.022266	2026-05-04 17:35:59.046665
8d45be34-ba00-40f8-a227-acfa18be2157	saddsaas	t	\N	2026-05-30 01:59:08.040818	2026-05-30 01:59:08.040818
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images (id, entity_type, entity_id, image_url, image_type, sort_order, is_active, created_at, updated_at, file_name, file_size) FROM stdin;
265928cc-5ad7-4c9a-bec9-f5b59b52a080	project	5fc70644-6800-4033-a1c1-9b7d9b3f8023	uploads/42235de04e6144b29c74c670e17bd470_2026-05-29_143417.png	main	0	t	2026-05-30 01:57:50.829208	2026-05-30 01:57:50.829208	\N	\N
15995b3e-b9eb-42bb-b283-54159af1c276	project	5fc70644-6800-4033-a1c1-9b7d9b3f8023	uploads/e9f12af9d4a143d1a399d68907028092_2026-05-29_221848.png	main	0	t	2026-05-30 01:57:58.285752	2026-05-30 01:57:58.285752	\N	\N
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, user_id, action, details, ip_address, created_at) FROM stdin;
123	628d35df-ade3-4b26-aab4-310f27a71a91	register	Регистрация студента	\N	2026-05-30 00:41:09.475375
125	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:41:26.171255
3	\N	logout	Выход из системы	\N	2026-05-03 20:25:32.453596
127	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_news	news: dsfdsfsdfdsfsdf	\N	2026-05-30 00:54:51.123092
129	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:56:56.882906
6	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-03 20:27:03.612968
7	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 6bf6eb1a-20df-467d-bf2c-25d3b68f463c	\N	2026-05-03 20:27:17.761557
8	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_user	Создан teacher: you@yandex.ru	\N	2026-05-03 20:27:33.922107
9	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-03 20:27:35.683146
131	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 01:20:52.918902
133	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена публикация fd19a205-075b-43f4-a734-c6c6c6306202	\N	2026-05-30 01:36:25.198104
135	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 01:39:23.297812
137	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 01:40:58.398115
139	628d35df-ade3-4b26-aab4-310f27a71a91	login	Вход в систему	\N	2026-05-30 01:42:36.233293
141	628d35df-ade3-4b26-aab4-310f27a71a91	logout	Выход из системы	\N	2026-05-30 01:43:40.444266
143	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 01:49:04.114842
145	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 01:56:21.638883
147	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_user	Создан teacher: damir@yandex.ru	\N	2026-05-30 01:57:00.213939
19	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-03 20:29:46.232418
20	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-03 20:31:12.77343
149	1e2c3d0b-2267-4c17-acdf-cff20ac59965	login	Вход в систему	\N	2026-05-30 01:57:17.612877
151	1e2c3d0b-2267-4c17-acdf-cff20ac59965	edit_project	Изменён проект 5fc70644-6800-4033-a1c1-9b7d9b3f8023	\N	2026-05-30 01:57:58.375896
153	1e2c3d0b-2267-4c17-acdf-cff20ac59965	logout	Выход из системы	\N	2026-05-30 01:58:13.587848
155	628d35df-ade3-4b26-aab4-310f27a71a91	apply	Заявка на проект 5fc70644-6800-4033-a1c1-9b7d9b3f8023	\N	2026-05-30 01:58:34.601755
157	1e2c3d0b-2267-4c17-acdf-cff20ac59965	login	Вход в систему	\N	2026-05-30 01:58:53.830854
159	1e2c3d0b-2267-4c17-acdf-cff20ac59965	update_profile	Изменено поле about	\N	2026-05-30 02:02:54.89766
161	1e2c3d0b-2267-4c17-acdf-cff20ac59965	logout	Выход из системы	\N	2026-05-30 02:04:29.87052
26	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 15:19:11.480972
27	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_news	Новость: ddassads	\N	2026-05-04 15:19:36.829949
28	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 15:20:05.88455
29	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 15:24:54.413867
30	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 15:26:00.784623
31	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 16:39:31.512744
32	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь b3dd4c64-f532-4345-9132-45c9210e7825	\N	2026-05-04 16:40:53.350267
33	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 3f5b4d4f-cf01-404d-a1c1-b1268ff25e58	\N	2026-05-04 16:40:56.231651
34	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 3f4d5560-d84d-4e7d-87df-ba7617cf6748	\N	2026-05-04 16:40:58.783748
35	ee3c8434-e840-499f-98f4-9cc8542ccd9b	update_profile	Изменено поле about	\N	2026-05-04 16:41:07.708441
36	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_user	Создан teacher: you@yandex.ru	\N	2026-05-04 16:41:55.812787
37	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 16:42:58.659323
124	628d35df-ade3-4b26-aab4-310f27a71a91	logout	Выход из системы	\N	2026-05-30 00:41:18.310427
126	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:54:04.405509
128	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 00:56:37.572723
130	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена новость 9f1ca720-c1f9-4a4b-9a2b-bbba16046999	\N	2026-05-30 01:09:42.743198
59	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 17:00:27.368796
60	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена новость 49f6fa03-a77f-4b25-a3d5-ed7e2ad21048	\N	2026-05-04 17:34:43.504413
61	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 17:35:17.023619
132	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_news	internship: sadasdas	\N	2026-05-30 01:33:20.293383
134	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_news	internship: вввыавыавыа	\N	2026-05-30 01:37:06.398393
136	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 01:40:49.709957
65	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 17:38:03.403852
66	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_user	Создан teacher: andreikholm@gmail.com	\N	2026-05-04 17:38:33.62837
67	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 17:38:35.599576
138	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 01:42:28.167085
140	628d35df-ade3-4b26-aab4-310f27a71a91	update_profile	Изменено поле about	\N	2026-05-30 01:43:10.198424
142	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 01:43:48.582668
144	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 01:50:22.348516
146	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 01:56:31.170229
148	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 01:57:06.311797
150	1e2c3d0b-2267-4c17-acdf-cff20ac59965	add_project	Создан проект saddsaas	\N	2026-05-30 01:57:50.942198
75	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 17:40:35.17541
76	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_review	Отзыв для 1b96963f-36fd-43e4-a8e3-f2b215634c8d	\N	2026-05-04 17:51:22.635245
77	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_review	Отзыв для f6c29627-c1b5-4d01-8cc6-82a03604712c	\N	2026-05-04 17:51:27.873396
78	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 18:01:14.871341
152	1e2c3d0b-2267-4c17-acdf-cff20ac59965	edit_project	Изменён проект 5fc70644-6800-4033-a1c1-9b7d9b3f8023	\N	2026-05-30 01:58:02.836523
154	628d35df-ade3-4b26-aab4-310f27a71a91	login	Вход в систему	\N	2026-05-30 01:58:22.02087
156	628d35df-ade3-4b26-aab4-310f27a71a91	logout	Выход из системы	\N	2026-05-30 01:58:44.71393
158	1e2c3d0b-2267-4c17-acdf-cff20ac59965	accept_application	Принята заявка b0717067-b6b0-4769-8cb1-e8cad5397a7e	\N	2026-05-30 01:59:08.136568
160	1e2c3d0b-2267-4c17-acdf-cff20ac59965	update_profile	Изменено поле about	\N	2026-05-30 02:03:02.047296
162	1e2c3d0b-2267-4c17-acdf-cff20ac59965	login	Вход в систему	\N	2026-05-30 02:04:52.877442
87	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 18:05:20.308302
88	ee3c8434-e840-499f-98f4-9cc8542ccd9b	admin_delete_project	Удалён проект c96b9cea-ef06-4103-a549-ae1793634cf0	\N	2026-05-04 18:07:21.298362
89	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 18:12:34.981618
90	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-05 13:46:13.723036
91	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-05 13:47:30.100734
92	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-06 14:50:57.006084
93	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_news	Новость: czxzccxz	\N	2026-05-06 14:52:26.703712
94	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-06 14:53:35.153403
95	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-12 12:22:17.480119
96	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-15 20:30:40.632104
97	ee3c8434-e840-499f-98f4-9cc8542ccd9b	update_profile	Изменено поле about	\N	2026-05-15 20:37:48.094958
98	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-15 21:09:57.670074
99	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-15 21:10:06.312953
100	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-15 21:10:35.096793
101	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-15 21:10:51.472999
102	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-28 00:26:32.152598
103	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-28 00:30:02.388351
104	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-28 00:32:18.916944
105	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-28 00:54:04.246433
106	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-28 14:43:06.281274
107	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-28 15:15:14.405994
108	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-28 15:15:55.692811
109	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-29 23:52:38.376192
110	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 00:18:23.861941
111	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:18:34.239939
112	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:31:54.958866
113	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:32:08.440506
114	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 52174e17-fed4-4ec9-8bc6-e7377ebfb390	\N	2026-05-30 00:34:07.798133
115	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 56986cf6-544b-4e33-85bf-796f31a3a902	\N	2026-05-30 00:34:16.555734
116	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 1b96963f-36fd-43e4-a8e3-f2b215634c8d	\N	2026-05-30 00:34:19.155233
117	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь f6c29627-c1b5-4d01-8cc6-82a03604712c	\N	2026-05-30 00:34:21.423297
118	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-30 00:34:47.853916
119	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-30 00:34:56.807635
120	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена новость 38db64e5-f4c4-4dbd-97dd-afccaa22702c	\N	2026-05-30 00:36:33.157942
121	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена новость ea9c6630-71af-48a6-ba0a-bba9d9a623ab	\N	2026-05-30 00:36:34.355798
122	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена новость ea9c6630-71af-48a6-ba0a-bba9d9a623ab	\N	2026-05-30 00:36:36.018066
\.


--
-- Data for Name: message_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_attachments (id, message_id, file_url, file_name, file_size, created_at) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, chat_id, sender_id, content, is_read, sent_at, updated_at) FROM stdin;
\.


--
-- Data for Name: news_feed; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.news_feed (id, type, title, content, image_url, published_at, created_at, updated_at, event_date, event_location) FROM stdin;
272f4fd3-4774-4967-abbe-2203a23dbe35	internship	вввыавыавыа	выавыаываваы	uploads/d9b2a8fa60fd4f6f9d1d530e47cdcccb_2026-05-29_142802.png	2026-05-30 01:37:06.320491	2026-05-30 01:37:06.320491	2026-05-30 01:37:06.320491	\N	\N
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, id_tutor, title, description, requirements, details, topic_id, difficulty, deadline, status, max_students, created_at, updated_at) FROM stdin;
5fc70644-6800-4033-a1c1-9b7d9b3f8023	1e2c3d0b-2267-4c17-acdf-cff20ac59965	saddsaas	asdadasdsadas	dsdasdsadsadas	dsaasdasdsaddsadsdsad	8	легкий	2004-12-23	открыт	4	2026-05-30 01:57:50.829208	2026-05-30 01:58:02.736166
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, author_id, recipient_id, rating, comment, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, user_id, student_id, course, created_at, updated_at) FROM stdin;
5	628d35df-ade3-4b26-aab4-310f27a71a91	STU20260530628d	3	2026-05-30 00:41:09.394471	2026-05-30 00:41:09.394471
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teachers (id, user_id, "position", created_at, updated_at) FROM stdin;
5	1e2c3d0b-2267-4c17-acdf-cff20ac59965	Преподаватель	2026-05-30 01:57:00.13498	2026-05-30 01:57:00.13498
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topics (id, name, created_at) FROM stdin;
8	sadsadsadas	2026-05-30 01:41:57.656499
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, first_name, last_name, group_number, course, about, role, is_active, is_verified, rating, created_at, updated_at, avatar_url) FROM stdin;
1e2c3d0b-2267-4c17-acdf-cff20ac59965	damir@yandex.ru	pbkdf2:sha256:600000$o2Kyq5jctKlRjS25$e21987d413c090894acc01021fbb4cb66621d36d218bc469eda789e7c6fa96a5	Дамир	Гаштов	\N	\N	ваывыптаравыямяв	teacher	t	t	0.00	2026-05-30 01:57:00.13498	2026-05-30 02:03:01.919057	avatars/00a42fb2e59e45f2a42d6930c2ceabdf_2026-05-29_143417.png
ee3c8434-e840-499f-98f4-9cc8542ccd9b	admin@techinsthub.com	pbkdf2:sha256:600000$mEeVyTKGIUEv8uTk$368c97b606696bc557457c08f9325172014f1381f24c603d6d065562e9d04cc7	Администратор	Системы	\N	\N	sfgdggfgg	admin	t	t	0.00	2026-05-03 20:17:56.376681	2026-05-15 20:37:48.022882	avatars/48c81152b19343eebc191837452e18f7_crocus_04.jpg
628d35df-ade3-4b26-aab4-310f27a71a91	alexeycherevkov@yandex.ru	pbkdf2:sha256:600000$c0EONHbNnjM70GKn$c6a1ad83fc504ff3edd0d776c7c24a3d7731a4d8361d0b2b4e3cb5c4f5690403	Иван	Иванов	438	3		student	t	f	0.00	2026-05-30 00:41:09.394471	2026-05-30 01:43:10.103217	avatars/3a3b20f3515a439fa8b103ab9603dc08_scale_1200.jpeg
\.


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: chat_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_members_id_seq', 7, true);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logs_id_seq', 162, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 5, true);


--
-- Name: teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teachers_id_seq', 5, true);


--
-- Name: topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.topics_id_seq', 8, true);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: chat_members chat_members_chat_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_chat_id_user_id_key UNIQUE (chat_id, user_id);


--
-- Name: chat_members chat_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_pkey PRIMARY KEY (id);


--
-- Name: chats chats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chats
    ADD CONSTRAINT chats_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: message_attachments message_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_attachments
    ADD CONSTRAINT message_attachments_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: news_feed news_feed_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_feed
    ADD CONSTRAINT news_feed_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: students students_student_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_student_id_key UNIQUE (student_id);


--
-- Name: teachers teachers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_pkey PRIMARY KEY (id);


--
-- Name: topics topics_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_name_key UNIQUE (name);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_applications_project; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_applications_project ON public.applications USING btree (project_id);


--
-- Name: idx_applications_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_applications_status ON public.applications USING btree (status);


--
-- Name: idx_applications_student; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_applications_student ON public.applications USING btree (student_id);


--
-- Name: idx_chat_members_chat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_members_chat ON public.chat_members USING btree (chat_id);


--
-- Name: idx_chat_members_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_members_user ON public.chat_members USING btree (user_id);


--
-- Name: idx_images_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_images_entity ON public.images USING btree (entity_type, entity_id);


--
-- Name: idx_logs_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_logs_created ON public.logs USING btree (created_at);


--
-- Name: idx_logs_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_logs_user ON public.logs USING btree (user_id);


--
-- Name: idx_messages_chat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_chat ON public.messages USING btree (chat_id);


--
-- Name: idx_messages_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_sender ON public.messages USING btree (sender_id);


--
-- Name: idx_news_feed_published; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_news_feed_published ON public.news_feed USING btree (published_at);


--
-- Name: idx_projects_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_projects_status ON public.projects USING btree (status);


--
-- Name: idx_projects_topic; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_projects_topic ON public.projects USING btree (topic_id);


--
-- Name: idx_projects_tutor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_projects_tutor ON public.projects USING btree (id_tutor);


--
-- Name: idx_reviews_author; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_author ON public.reviews USING btree (author_id);


--
-- Name: idx_reviews_recipient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_recipient ON public.reviews USING btree (recipient_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: admins admins_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: applications applications_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: applications applications_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: chat_members chat_members_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;


--
-- Name: chat_members chat_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_members
    ADD CONSTRAINT chat_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: logs logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: message_attachments message_attachments_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_attachments
    ADD CONSTRAINT message_attachments_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE CASCADE;


--
-- Name: messages messages_chat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.chats(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: projects projects_id_tutor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_id_tutor_fkey FOREIGN KEY (id_tutor) REFERENCES public.users(id);


--
-- Name: projects projects_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: reviews reviews_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: reviews reviews_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.users(id);


--
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: teachers teachers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teachers
    ADD CONSTRAINT teachers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict DC5pE9S7JGTIImSLLzasgpJvXkXq8E7ySw7f6oABwoeEMBgiQjaN1JLpgqCrgHV

