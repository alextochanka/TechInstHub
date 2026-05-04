--
-- PostgreSQL database dump
--

\restrict XXm0ORLTM9meaJAL6dSHbaXJrGC062grqvre2AB7rOpSmG7EMVOi4wWH9X8r0gZ

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
    updated_at timestamp without time zone
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
\.


--
-- Data for Name: chat_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_members (id, chat_id, user_id, created_at) FROM stdin;
3	77f27250-b186-499e-b9dd-bf165c6a1f9c	52174e17-fed4-4ec9-8bc6-e7377ebfb390	2026-05-04 16:53:36.022266
4	77f27250-b186-499e-b9dd-bf165c6a1f9c	1b96963f-36fd-43e4-a8e3-f2b215634c8d	2026-05-04 16:53:36.022266
5	77f27250-b186-499e-b9dd-bf165c6a1f9c	f6c29627-c1b5-4d01-8cc6-82a03604712c	2026-05-04 16:53:38.289976
\.


--
-- Data for Name: chats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chats (id, name, is_group, last_message, created_at, updated_at) FROM stdin;
3d0dd027-8344-4cc0-9473-b15e1084f512	asddsasd	t	asdasdas	2026-05-03 20:29:17.587832	2026-05-03 20:29:30.896219
77f27250-b186-499e-b9dd-bf165c6a1f9c	dassasa	t	ree	2026-05-04 16:53:36.022266	2026-05-04 17:35:59.046665
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images (id, entity_type, entity_id, image_url, image_type, sort_order, is_active, created_at, updated_at, file_name, file_size) FROM stdin;
607be416-270f-463f-98d2-c728aee3b167	project	b2c7641c-7415-467e-bbd3-f9fa1f68c2e1	uploads/55b0d743140f40d4bf0820f1c49eee90_2026-05-03_172047.png	main	0	t	2026-05-04 17:39:23.555274	2026-05-04 17:39:23.555274	\N	\N
d422ccd0-8fa1-4650-82d2-d9768d12befb	project	b2c7641c-7415-467e-bbd3-f9fa1f68c2e1	uploads/2da6b60f268b4a829f2a603ad537c040_2026-05-03_150134.png	main	0	t	2026-05-04 17:39:30.87756	2026-05-04 17:39:30.87756	\N	\N
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, user_id, action, details, ip_address, created_at) FROM stdin;
3	\N	logout	Выход из системы	\N	2026-05-03 20:25:32.453596
6	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-03 20:27:03.612968
7	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_user	Удалён пользователь 6bf6eb1a-20df-467d-bf2c-25d3b68f463c	\N	2026-05-03 20:27:17.761557
8	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_user	Создан teacher: you@yandex.ru	\N	2026-05-03 20:27:33.922107
9	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-03 20:27:35.683146
19	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-03 20:29:46.232418
20	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-03 20:31:12.77343
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
38	52174e17-fed4-4ec9-8bc6-e7377ebfb390	login	Вход в систему	\N	2026-05-04 16:43:06.118015
39	52174e17-fed4-4ec9-8bc6-e7377ebfb390	update_profile	Изменено поле about	\N	2026-05-04 16:43:46.593109
40	52174e17-fed4-4ec9-8bc6-e7377ebfb390	add_project	Создан проект dassasa	\N	2026-05-04 16:44:39.292197
41	52174e17-fed4-4ec9-8bc6-e7377ebfb390	edit_project	Изменён проект c96b9cea-ef06-4103-a549-ae1793634cf0	\N	2026-05-04 16:44:46.552635
42	52174e17-fed4-4ec9-8bc6-e7377ebfb390	logout	Выход из системы	\N	2026-05-04 16:49:06.022196
43	f6c29627-c1b5-4d01-8cc6-82a03604712c	register	Регистрация студента	\N	2026-05-04 16:49:40.715795
44	f6c29627-c1b5-4d01-8cc6-82a03604712c	apply	Заявка на проект c96b9cea-ef06-4103-a549-ae1793634cf0	\N	2026-05-04 16:49:46.85543
45	f6c29627-c1b5-4d01-8cc6-82a03604712c	add_review	Отзыв для 52174e17-fed4-4ec9-8bc6-e7377ebfb390	\N	2026-05-04 16:52:24.857721
46	f6c29627-c1b5-4d01-8cc6-82a03604712c	logout	Выход из системы	\N	2026-05-04 16:52:34.899598
47	1b96963f-36fd-43e4-a8e3-f2b215634c8d	register	Регистрация студента	\N	2026-05-04 16:53:03.43855
48	1b96963f-36fd-43e4-a8e3-f2b215634c8d	apply	Заявка на проект c96b9cea-ef06-4103-a549-ae1793634cf0	\N	2026-05-04 16:53:08.00453
49	1b96963f-36fd-43e4-a8e3-f2b215634c8d	logout	Выход из системы	\N	2026-05-04 16:53:09.759179
50	52174e17-fed4-4ec9-8bc6-e7377ebfb390	login	Вход в систему	\N	2026-05-04 16:53:24.011536
51	52174e17-fed4-4ec9-8bc6-e7377ebfb390	accept_application	Принята заявка 4a2787d7-95ea-4721-9b15-28f93258684f	\N	2026-05-04 16:53:36.182828
52	52174e17-fed4-4ec9-8bc6-e7377ebfb390	accept_application	Принята заявка e8580d4d-3534-4f6b-8870-2955c1465e3e	\N	2026-05-04 16:53:38.490889
53	52174e17-fed4-4ec9-8bc6-e7377ebfb390	logout	Выход из системы	\N	2026-05-04 16:58:49.829753
54	f6c29627-c1b5-4d01-8cc6-82a03604712c	login	Вход в систему	\N	2026-05-04 16:58:59.345227
55	f6c29627-c1b5-4d01-8cc6-82a03604712c	complete_project	Проект c96b9cea-ef06-4103-a549-ae1793634cf0 завершён	\N	2026-05-04 16:59:03.781258
56	f6c29627-c1b5-4d01-8cc6-82a03604712c	logout	Выход из системы	\N	2026-05-04 16:59:15.582107
57	1b96963f-36fd-43e4-a8e3-f2b215634c8d	login	Вход в систему	\N	2026-05-04 16:59:32.066136
58	1b96963f-36fd-43e4-a8e3-f2b215634c8d	logout	Выход из системы	\N	2026-05-04 17:00:19.138856
59	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 17:00:27.368796
60	ee3c8434-e840-499f-98f4-9cc8542ccd9b	delete_news	Удалена новость 49f6fa03-a77f-4b25-a3d5-ed7e2ad21048	\N	2026-05-04 17:34:43.504413
61	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 17:35:17.023619
62	1b96963f-36fd-43e4-a8e3-f2b215634c8d	login	Вход в систему	\N	2026-05-04 17:35:28.485273
63	1b96963f-36fd-43e4-a8e3-f2b215634c8d	update_profile	Изменено поле about	\N	2026-05-04 17:37:51.327438
64	1b96963f-36fd-43e4-a8e3-f2b215634c8d	logout	Выход из системы	\N	2026-05-04 17:37:53.841678
65	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 17:38:03.403852
66	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_user	Создан teacher: andreikholm@gmail.com	\N	2026-05-04 17:38:33.62837
67	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 17:38:35.599576
68	56986cf6-544b-4e33-85bf-796f31a3a902	login	Вход в систему	\N	2026-05-04 17:38:45.689348
69	56986cf6-544b-4e33-85bf-796f31a3a902	add_project	Создан проект dassa	\N	2026-05-04 17:39:23.665034
70	56986cf6-544b-4e33-85bf-796f31a3a902	edit_project	Изменён проект b2c7641c-7415-467e-bbd3-f9fa1f68c2e1	\N	2026-05-04 17:39:31.10095
71	56986cf6-544b-4e33-85bf-796f31a3a902	edit_project	Изменён проект b2c7641c-7415-467e-bbd3-f9fa1f68c2e1	\N	2026-05-04 17:39:35.554715
72	56986cf6-544b-4e33-85bf-796f31a3a902	update_profile	Изменено поле about	\N	2026-05-04 17:40:11.664122
73	56986cf6-544b-4e33-85bf-796f31a3a902	update_profile	Изменено поле about	\N	2026-05-04 17:40:22.150884
74	56986cf6-544b-4e33-85bf-796f31a3a902	logout	Выход из системы	\N	2026-05-04 17:40:28.517073
75	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 17:40:35.17541
76	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_review	Отзыв для 1b96963f-36fd-43e4-a8e3-f2b215634c8d	\N	2026-05-04 17:51:22.635245
77	ee3c8434-e840-499f-98f4-9cc8542ccd9b	add_review	Отзыв для f6c29627-c1b5-4d01-8cc6-82a03604712c	\N	2026-05-04 17:51:27.873396
78	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 18:01:14.871341
79	1b96963f-36fd-43e4-a8e3-f2b215634c8d	login	Вход в систему	\N	2026-05-04 18:01:27.189548
80	1b96963f-36fd-43e4-a8e3-f2b215634c8d	add_review	Отзыв для 52174e17-fed4-4ec9-8bc6-e7377ebfb390	\N	2026-05-04 18:01:35.120685
81	1b96963f-36fd-43e4-a8e3-f2b215634c8d	add_review	Отзыв для 56986cf6-544b-4e33-85bf-796f31a3a902	\N	2026-05-04 18:01:42.682857
82	1b96963f-36fd-43e4-a8e3-f2b215634c8d	logout	Выход из системы	\N	2026-05-04 18:01:48.664773
83	56986cf6-544b-4e33-85bf-796f31a3a902	login	Вход в систему	\N	2026-05-04 18:02:00.390299
84	56986cf6-544b-4e33-85bf-796f31a3a902	add_review	Отзыв для 1b96963f-36fd-43e4-a8e3-f2b215634c8d	\N	2026-05-04 18:02:22.766494
85	56986cf6-544b-4e33-85bf-796f31a3a902	add_review	Отзыв для f6c29627-c1b5-4d01-8cc6-82a03604712c	\N	2026-05-04 18:02:35.175761
86	56986cf6-544b-4e33-85bf-796f31a3a902	logout	Выход из системы	\N	2026-05-04 18:05:13.518383
87	ee3c8434-e840-499f-98f4-9cc8542ccd9b	login	Вход в систему	\N	2026-05-04 18:05:20.308302
88	ee3c8434-e840-499f-98f4-9cc8542ccd9b	admin_delete_project	Удалён проект c96b9cea-ef06-4103-a549-ae1793634cf0	\N	2026-05-04 18:07:21.298362
89	ee3c8434-e840-499f-98f4-9cc8542ccd9b	logout	Выход из системы	\N	2026-05-04 18:12:34.981618
\.


--
-- Data for Name: message_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_attachments (id, message_id, file_url, file_name, file_size, created_at) FROM stdin;
fd95c71b-8247-40ba-a859-c66114279c11	012338c5-1a08-4eb9-97af-bb118718350c	uploads/2b1cf865ffd440199212d0ba511d1016_images.jpg	images.jpg	4910	2026-05-04 16:57:38.647986
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, chat_id, sender_id, content, is_read, sent_at, updated_at) FROM stdin;
aa36d34b-a21e-4798-a2bf-5b972317bef6	77f27250-b186-499e-b9dd-bf165c6a1f9c	1b96963f-36fd-43e4-a8e3-f2b215634c8d	ree	f	2026-05-04 17:35:59.046665	2026-05-04 17:35:59.046665
012338c5-1a08-4eb9-97af-bb118718350c	77f27250-b186-499e-b9dd-bf165c6a1f9c	52174e17-fed4-4ec9-8bc6-e7377ebfb390	assadassa	t	2026-05-04 16:57:38.647986	2026-05-04 16:57:38.647986
\.


--
-- Data for Name: news_feed; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.news_feed (id, type, title, content, image_url, published_at, created_at, updated_at) FROM stdin;
ea9c6630-71af-48a6-ba0a-bba9d9a623ab	news	ddassads	saddasdasdsad	uploads/52477852333240e2aa10f6bc139d28e7_images_3.jpg	2026-05-04 15:19:36.725713	2026-05-04 15:19:36.725713	2026-05-04 15:19:36.725713
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, id_tutor, title, description, requirements, details, topic_id, difficulty, deadline, status, max_students, created_at, updated_at) FROM stdin;
b2c7641c-7415-467e-bbd3-f9fa1f68c2e1	56986cf6-544b-4e33-85bf-796f31a3a902	dassa	sadasdasd	sadsaadd	asdasdasd	4	средний	2004-12-23	открыт	1	2026-05-04 17:39:23.555274	2026-05-04 17:39:35.458975
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, author_id, recipient_id, rating, comment, created_at, updated_at) FROM stdin;
bf3d27ce-d698-4655-8a38-07d586a69c5a	f6c29627-c1b5-4d01-8cc6-82a03604712c	52174e17-fed4-4ec9-8bc6-e7377ebfb390	5		2026-05-04 16:52:24.785117	2026-05-04 16:52:24.785117
653bf04e-a1c9-46a4-956c-b829ae96fab2	ee3c8434-e840-499f-98f4-9cc8542ccd9b	1b96963f-36fd-43e4-a8e3-f2b215634c8d	5		2026-05-04 17:51:22.540145	2026-05-04 17:51:22.540145
eb3db152-ab5c-4a19-8a65-07cf6b27d0fd	ee3c8434-e840-499f-98f4-9cc8542ccd9b	f6c29627-c1b5-4d01-8cc6-82a03604712c	3		2026-05-04 17:51:27.800147	2026-05-04 17:51:27.800147
4c59c230-e6ff-4318-bc48-583883e97d47	1b96963f-36fd-43e4-a8e3-f2b215634c8d	52174e17-fed4-4ec9-8bc6-e7377ebfb390	3		2026-05-04 18:01:35.044864	2026-05-04 18:01:35.044864
235f90fc-1f3c-4ac4-bd7e-de6a9a4ed3c7	1b96963f-36fd-43e4-a8e3-f2b215634c8d	56986cf6-544b-4e33-85bf-796f31a3a902	1		2026-05-04 18:01:42.60162	2026-05-04 18:01:42.60162
6cd8a143-8f53-41dc-9e7f-21fdfed1e7b0	56986cf6-544b-4e33-85bf-796f31a3a902	1b96963f-36fd-43e4-a8e3-f2b215634c8d	1	Не очень хороший человек!!!	2026-05-04 18:02:22.651054	2026-05-04 18:02:22.651054
8b483d1c-c53c-4744-8009-68deb4070e77	56986cf6-544b-4e33-85bf-796f31a3a902	f6c29627-c1b5-4d01-8cc6-82a03604712c	5	Отличный студент!!!	2026-05-04 18:02:35.06436	2026-05-04 18:02:35.06436
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, user_id, student_id, course, created_at, updated_at) FROM stdin;
3	f6c29627-c1b5-4d01-8cc6-82a03604712c	STU20260504f6c2	2	2026-05-04 16:49:40.651114	2026-05-04 16:49:40.651114
4	1b96963f-36fd-43e4-a8e3-f2b215634c8d	STU202605041b96	4	2026-05-04 16:53:03.336523	2026-05-04 16:53:03.336523
\.


--
-- Data for Name: teachers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teachers (id, user_id, "position", created_at, updated_at) FROM stdin;
3	52174e17-fed4-4ec9-8bc6-e7377ebfb390	Преподаватель	2026-05-04 16:41:55.724733	2026-05-04 16:41:55.724733
4	56986cf6-544b-4e33-85bf-796f31a3a902	Преподаватель	2026-05-04 17:38:33.4899	2026-05-04 17:38:33.4899
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topics (id, name, created_at) FROM stdin;
4	Интересно	2026-05-04 16:42:15.50654
5	yfghgfhgf	2026-05-04 16:42:17.684674
6	NVIDIA	2026-05-04 16:42:20.617027
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, first_name, last_name, group_number, course, about, role, is_active, is_verified, rating, created_at, updated_at, avatar_url) FROM stdin;
ee3c8434-e840-499f-98f4-9cc8542ccd9b	admin@techinsthub.com	pbkdf2:sha256:600000$mEeVyTKGIUEv8uTk$368c97b606696bc557457c08f9325172014f1381f24c603d6d065562e9d04cc7	Администратор	Системы	\N	\N		admin	t	t	0.00	2026-05-03 20:17:56.376681	2026-05-04 16:41:07.616094	avatars/48c81152b19343eebc191837452e18f7_crocus_04.jpg
52174e17-fed4-4ec9-8bc6-e7377ebfb390	you@yandex.ru	pbkdf2:sha256:600000$yM6drX0BKetJqNwW$908107e66424fecc02f43257ad3e116cd16627dd182408b6de1ee6f2bdfa5623	Игорь	Ананченко	\N	\N	adsdsdsdsdsdsdsdsdsdsdsdsdsds	teacher	t	t	0.00	2026-05-04 16:41:55.724733	2026-05-04 16:43:46.495365	avatars/3381a690e7ef47dab2da4bcc27f64497_images.jpg
f6c29627-c1b5-4d01-8cc6-82a03604712c	kaverzin@yandex.ru	pbkdf2:sha256:600000$ppP1bFU9r4nxDMjf$cb538196c813022d3b5d5c90e68e7b025733f6c702d283794c4855da47c55ab3	Илья	Каверзин	437	2	\N	student	t	f	0.00	2026-05-04 16:49:40.651114	2026-05-04 16:49:40.651114	avatars/e4421a3294be40b8bc8fbd472d72b1f6_1.png
1b96963f-36fd-43e4-a8e3-f2b215634c8d	damir@yandex.ru	pbkdf2:sha256:600000$OgirwOFfLRgwVp88$cbe1bb5cecf387b2db5a860eebce6cc3dd338718608cee9a61299ac2e8a2ad34	Алексис	Маккалистер	234	4	213sdd2	student	t	f	0.00	2026-05-04 16:53:03.336523	2026-05-04 17:37:51.233068	avatars/60d4911b4f124af689674a57fe11329c_scale_1200.jpeg
56986cf6-544b-4e33-85bf-796f31a3a902	andreikholm@gmail.com	pbkdf2:sha256:600000$069LPdg6hrZwwG38$25ecc3b27a05a5570e67abe7691465d9e1b172961dd5353fb737cf6fd1163076	Андрей	Холмогоров	\N	\N	wq2	teacher	t	t	0.00	2026-05-04 17:38:33.4899	2026-05-04 17:40:22.021696	avatars/43ca9fdd0122432795b7a14d06bc70b2_Sergiu.webp
\.


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: chat_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_members_id_seq', 5, true);


--
-- Name: logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.logs_id_seq', 89, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 4, true);


--
-- Name: teachers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teachers_id_seq', 4, true);


--
-- Name: topics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.topics_id_seq', 6, true);


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

\unrestrict XXm0ORLTM9meaJAL6dSHbaXJrGC062grqvre2AB7rOpSmG7EMVOi4wWH9X8r0gZ

