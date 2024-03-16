create table
  admin (
    id bigint primary key generated always as identity,
    username text not null,
    password text not null
  );

create table
  patient (
    pid bigint primary key generated always as identity,
    fname text not null,
    lname text not null,
    gender text not null,
    email text not null,
    phone text not null,
    password text not null
  );

create table
  appointment (
    pid bigint not null,
    AppID bigint primary key generated always as identity,
    fname text not null,
    lname text not null,
    gender text not null,
    email text not null,
    phone text not null,
    doctor text not null,
    docFees int not null,
    appdate timestamp with time zone not null,
    apptime time with time zone not null,
    userStatus int not null,
    doctorStatus int not null,
    foreign key (pid) references patient (pid)
  );

create table
  doctor (
    id bigint primary key generated always as identity,
    username text not null,
    password text not null,
    email text not null,
    spec text not null,
    docFees int not null
  );

create table
  prescription (
    doctor text not null,
    pid bigint not null,
    AppID bigint not null,
    fname text not null,
    lname text not null,
    appdate timestamp with time zone not null,
    apptime time with time zone not null,
    disease text not null,
    allergy text not null,
    prescription text not null,
    foreign key (pid) references patient (pid),
    foreign key (AppID) references appointment (AppID)
  );
