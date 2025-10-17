create schema if not exists erp;
set search_path to erp;

show search_path ;
set timezone to 'Asia/Tashkent';

select * from person;
create table person(
    id serial primary key,
    full_name varchar,
    age int,
    email varchar

);
drop table person;


create table if not exists profiles(
    id serial primary key,
    username varchar(50) not null unique,
    password varchar(255) not null,
    role varchar(15) not null
    check ( role in ('teacher', 'student', 'support') )
    default 'student'
);

alter table profiles
    add column created_at timestamptz default current_timestamp;

insert into profiles (username, password, role)
values ('jasurmavlonov', 'admin123', 'teacher'),
       ('ibrqayumov', 'inr123', 'student'),
       ('muhammadali', 'ali123', 'student'),
       ('najottalim', 'talim123', 'support')
;

select *from profiles;


create table if not exists teachers(
    id serial primary key,
    full_name varchar(255) not null ,
    phone varchar(15) not null unique ,
    specialization text,
    profile_id int references profiles(id)
);

insert into teachers(full_name, phone, specialization, profile_id)
values ('Jasur Mavlonov', '+998999999999', 'Pyhton', 1),
       ('Humoyun Hayitov', '+998977777777', 'Django', 2);

select * from teachers;


create table if not exists courses(
    id serial primary key ,
    name varchar(255) not null ,
    description text,
    duration int default 3,
    price decimal(14,2) not null
);

insert into courses (name, description, duration, price)
values ('Pyhton', 'Dasturlash. Backend', 8, 1400000),
       ('Grafik Dizayn', 'Standard grafik dizayn', 6, 15000000),
       ('Suniy intellekt asoslari', 'Machine Learning. Neyron tarmoqlar...', 2, 2000000);

select * from courses;

create table if not exists "groups"(
    id serial primary key ,
    name varchar(255) not null unique ,
    room_number varchar(255) unique ,
    started_at date,
    ended_at date,
    teacher_id int,
    course_id int,
    constraint teachers_id_fk
        foreign key (teacher_id)
                    references teachers(id)
                            on delete set null ,
    constraint courses_id_fk
        foreign key (course_id)
                    references courses(id)
                            on delete set null
);

insert into "groups" (name, room_number, started_at, ended_at, teacher_id, course_id)
values ('n70', 'microsoft', '2025-06-13', '2026-01-25', '1', '1'),
       ('n69', 'google', '2025-05-10', '2025-12-25', 2, 2);

select * from "groups";

create table if not exists students(
    id serial primary key,
    full_name varchar(255) not null ,
    phone varchar(15) not null unique ,
    address text,
    age int check ( age > 13 ),
    group_id int references "groups"(id),
    profile_id int references profiles(id)
);

insert into students (full_name, phone, address, age, group_id, profile_id)
values ('Ibrohim Qayumov', '+998901361360', 'yunusobod 15-15-15', 27, 1, 1),
       ('Muhammadali Abd', '+998772121110', 'chilonzor 1-1-1', 16, 2, 2),
       ('Valijon Valiyev', '+998944040404', 'yashnobod 8-8-8', 20, 2,2);

select * from students;

create table if not exists subjects(
                                       id serial primary key,
                                       name varchar(255) not null ,
                                       file_url varchar(255),
                                       started_at date,
                                       ended_at date,
                                       subject_date date,
                                       group_id int,
                                        foreign key (group_id) references "groups"(id)
);


create table if not exists exams(
                                    id serial primary key,
                                    file_url varchar(255),
                                    description text,
                                    started_at date,
                                    ended_at date,
                                    group_id int,
                                    foreign key (group_id) references "groups"(id)
);

insert into exams (file_url, description, started_at, ended_at, group_id)
values ('C:\python\4-modul', 'Pyhton. 4-modul imtixoni', '2025-09-06', '2025-09-07', 1),
       ('C:\grafik_dizayn\3-modul', 'Grafik Dizayn. 3-modul imtixoni', '2025-04-12', '2025-04-13', 2)
;

select * FROM exams;

create table if not exists results(
    id serial primary key,
    rate int check ( rate between 1 and 100),
    status varchar(20) check ( status in ('passed', 'failed') ),
    ended_at date,
    student_id int references students(id)

);

insert into results (rate, status, ended_at, student_id)
values (72, 'passed', '2025-09-06', 1),
       (27, 'failed', '2025-04-13', 3),
       (90, 'passed', '2025-09-06', 2);

select *from results;

create table if not exists attendances(
    id serial primary key ,
    attendance_date date,
    status varchar(20) check ( status in ('present', 'absent', 'late') ),
    student_id int references students(id),
    subject_id int references subjects(id)
);

alter table attendances
    alter column status set default 'absent';

-- insert into attendances (attendance_date, status, student_id, subject_id)
-- values ('2025-09-15', 'absent', 1, 1),
--        ('2025-09-22', 'present', 1, 1),
--        ('2025-07-13', 'late', 2, 2);
-- shu yerda xatolikni topa olmadim

create table if not exists payments(
    id serial primary key ,
    student_id int references students(id),
    payment_date date,
    method varchar(10) check ( method in ('cash', 'card', 'online') ),
    amount int,
    status varchar(10) check ( status in ('paid', 'unpaid') ) default 'unpaid'
);

insert into payments (student_id, payment_date, method, amount, status)
values (1, '2025-09-22', 'card', '700000', 'paid'),
       (2, '2025-09-01', 'cash', '1400000', 'paid');

select * from payments;
show search_path ;


-- 1. har bir guruhdagi talabalar sonini ko'rsatadi:

select g.name as group_name, count(s.id) as students_count
from "groups" g
left join students s on g.id = s.group_id
group by g.name;


-- 2. har bir kurs bo'yicha nechta guruh borligini ko'rsatadi:

select c.name as course_name, count(g.id) as groups_count
from courses c
left join "groups" g on c.id = g.course_id
group by c.name;


-- 3. har bir o'qituvchi qaysi kurslarni olib borishini ko'rsatadi:

select t.full_name as teacher, c.name as course_name, g.name as group_name
from teachers t
join "groups" g on t.id = g.teacher_id
join courses c on g.course_id = c.id;


-- 4. har bir talaba va exam natijalari:

select s.full_name, r.rate, r.status, r.ended_at
from students s
left join results r on s.id = r.student_id
order by r.ended_at desc;


-- 5. o'rtacha baho:

select s.full_name, avg(r.rate) as average_rate
from students s
left join results r on s.id = r.student_id
group by s.full_name;


-- 6. guruh bo'yicha o'rtacha baho:

select g.name as group_name, avg(r.rate) as average_rate
from "groups" g
join students s on g.id = s.group_id
join results r on s.id = r.student_id
group by g.name;

-- 7. to'lov qilmagan talabalar:

select s.full_name, p.status
from students s
left join payments p on s.id = p.student_id
where p.status is null or p.status = 'unpaid';

-- 8.

select c.name as course_name, sum(p.amount) as total_payments
from courses c
join "groups" g on c.id = g.course_id
join students s on g.id = s.group_id
join payments p on s.id = p.student_id
group by c.name;

-- 9.

select g.name as group_name, sub.name as subject_name
from "groups" g
left join subjects sub on g.id = sub.group_id;

-- 10.

select t.full_name as teacher, c.name as course_name, g.name as group_name
from teachers t
join "groups" g on t.id = g.teacher_id
join courses c on g.course_id = c.id;


-- 11.

select t.full_name as teacher, count(s.id) as students_count
from teachers t
join "groups" g on t.id = g.teacher_id
join students s on g.id = s.group_id
group by t.full_name;

-- 12.

select s.full_name, c.name as course_name, t.full_name as teacher_name
from students s
join "groups" g on s.group_id = g.id
join courses c on g.course_id = c.id
join teachers t on g.teacher_id = t.id;

-- 13. max top 5

select s.full_name, r.rate
from results r
join students s on r.student_id = s.id
order by r.rate desc
limit 5;

-- 14. min top 5

select s.full_name, r.rate
from results r
join students s on r.student_id = s.id
order by r.rate asc
limit 5;

-- 15.

select s.full_name, sub.name as subject, a.attendance_date, a.status
from attendances a
join students s on a.student_id = s.id
join subjects sub on a.subject_id = sub.id
order by a.attendance_date desc;