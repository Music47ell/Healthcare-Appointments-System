-- Create table for storing appointment statuses
CREATE TYPE appointment_status AS ENUM ('scheduled', 'cancelled', 'completed');
CREATE TYPE DOCTOR_STATUS AS ENUM ('ONLINE', 'OFFLINE');
CREATE TYPE DOCTOR_APPROVAL AS ENUM ('APPROVED', 'DENIED', 'PENDING');

create table public.admins (
  id bigint primary key generated always as identity,
  user_id uuid not null references auth.users on delete cascade,
  name    text
);

create table public.doctors (
  id bigint primary key generated always as identity,
  user_id uuid not null unique references auth.users on delete cascade,
  name    text,
  fees   integer,
  specialty text,
  approved doctor_approval default 'PENDING',
  status text default 'offline'
);

create table public.patients (
  id bigint primary key generated always as identity,
  user_id uuid not null unique references auth.users on delete cascade,
  name    text,
  dob     DATE,
  gender  text
);

CREATE TABLE public.appointments (
  id UUID NOT NULL DEFAULT uuid_generate_v4(),
  patient_id UUID NOT NULL REFERENCES public.patients(user_id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES public.doctors(id) ON DELETE CASCADE,
  time TIMESTAMPZ NOT NULL,
  purpose TEXT,
  status appointment_status DEFAULT 'scheduled'::appointment_status,
  PRIMARY KEY (id)
);

alter table public.appointments enable row level security;
alter table public.admins enable row level security;
alter table public.patients enable row level security;
alter table public.doctors enable row level security;

CREATE POLICY admin_all_policy ON admins FOR ALL
USING (TRUE);

create policy "doctors are viewable by everyone."
  on doctors for select
  using ( true );

create policy "doctors can insert their own profile."
  on doctors for insert
  with check ( auth.uid() = user_id );

create policy "doctors can update own profile."
  on doctors for update
  using ( auth.uid() = user_id );

create policy "doctors can delete own profile."
  on doctors for delete
  using ( auth.uid() = user_id );

-- Policy for doctor appointments - SELECT
CREATE POLICY doctor_appointments_select_policy ON appointments FOR SELECT
USING (auth.uid() IN (SELECT user_id FROM doctors WHERE user_id = doctor_id));

-- Policy for doctor appointments - UPDATE
CREATE POLICY doctor_appointments_update_policy ON appointments FOR UPDATE
USING (auth.uid() IN (SELECT user_id FROM doctors WHERE user_id = doctor_id));

-- Policy for patients - SELECT
CREATE POLICY patient_select_policy ON patients FOR SELECT
USING (auth.uid() = user_id);

-- Policy for patients - INSERT
CREATE POLICY patient_insert_policy ON patients FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy for patients - UPDATE
CREATE POLICY patient_update_policy ON patients FOR UPDATE
USING (auth.uid() = user_id);

-- Policy for patients - DELETE
CREATE POLICY patient_delete_policy ON patients FOR DELETE
USING (auth.uid() = user_id);

-- Policy for patient appointments - SELECT
CREATE POLICY patient_appointments_select_policy ON appointments FOR SELECT
USING (auth.uid() IN (SELECT user_id FROM patients WHERE user_id = patient_id));

-- Policy for patient appointments - INSERT
CREATE POLICY patient_appointments_insert_policy ON appointments FOR INSERT
WITH CHECK (auth.uid() IN (SELECT user_id FROM patients WHERE user_id = patient_id));

-- Policy for patient appointments - UPDATE
CREATE POLICY patient_appointments_update_policy ON appointments FOR UPDATE
USING (auth.uid() IN (SELECT user_id FROM patients WHERE user_id = patient_id));

-- Policy for patient appointments - DELETE
CREATE POLICY patient_appointments_delete_policy ON appointments FOR DELETE
USING (auth.uid() IN (SELECT user_id FROM patients WHERE user_id = patient_id));

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Check the role and insert into appropriate table
    IF NEW.raw_user_meta_data ->> 'role' = 'admin' THEN
        INSERT INTO public.admins (user_id, name)
        VALUES (NEW.id, NEW.raw_user_meta_data ->> 'name');
    ELSIF NEW.raw_user_meta_data ->> 'role' = 'doctor' THEN
        INSERT INTO public.doctors (user_id, name, fees, specialty)
        VALUES (NEW.id, NEW.raw_user_meta_data ->> 'name', NEW.raw_user_meta_data['fees']::integer, NEW.raw_user_meta_data ->> 'specialty');
    ELSIF NEW.raw_user_meta_data ->> 'role' = 'patient' THEN
        INSERT INTO public.patients (user_id, name, dob, gender)
        VALUES (NEW.id, NEW.raw_user_meta_data ->> 'name', (NEW.raw_user_meta_data ->> 'dob')::date, NEW.raw_user_meta_data ->> 'gender');
    END IF;

    RETURN NEW;
END;
$$;

-- trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
