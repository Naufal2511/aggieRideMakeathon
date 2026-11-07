-- ====================================================================
-- AggieRide — Supabase Database Schema & Storage Setup
-- Texas A&M Makeathon 2026 (Free Tier Compatible)
-- ====================================================================

-- 1. Enable UUID extension
create extension if not exists "uuid-ossp";

-- 2. Create Users Table
create table if not exists public.users (
  user_id text primary key,
  name text not null,
  email text not null,
  class_year text,
  major text,
  is_tamu_verified boolean default false,
  avatar text default 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
  bio text default '',
  car_model text,
  rides_offered int default 0,
  rides_joined int default 0,
  rating numeric(3,2) default 5.0,
  reviews_count int default 0,
  on_time_rate text default '100%',
  joined_date text default 'Fall 2024',
  created_at timestamptz default now()
);

-- 3. Create Rides Table
create table if not exists public.rides (
  ride_id text primary key,
  driver_id text not null references public.users(user_id) on delete cascade,
  origin text not null,
  destination text not null,
  departure_date text not null,
  departure_time text not null,
  available_seats int not null default 1,
  total_seats int not null default 1,
  contribution int not null default 0,
  category text not null default 'Shopping',
  is_recurring boolean default false,
  recurring_days text[] default array[]::text[],
  notes text default '',
  pickup_spot text default '',
  status text not null default 'ACTIVE',
  passengers text[] default array[]::text[],
  created_at timestamptz default now()
);

-- 4. Create Ride Requests Table
create table if not exists public.requests (
  request_id text primary key,
  ride_id text not null references public.rides(ride_id) on delete cascade,
  passenger_id text not null references public.users(user_id) on delete cascade,
  driver_id text not null references public.users(user_id) on delete cascade,
  seats_requested int default 1,
  status text not null default 'PENDING', -- 'PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED'
  message text default '',
  requested_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 5. Create In-App Notifications Table
create table if not exists public.notifications (
  notification_id text primary key,
  user_id text not null references public.users(user_id) on delete cascade,
  title text not null,
  body text not null,
  type text not null default 'INFO',
  ride_id text,
  is_read boolean default false,
  created_at timestamptz default now()
);

-- 6. Enable Row Level Security (RLS)
alter table public.users enable row level security;
alter table public.rides enable row level security;
alter table public.requests enable row level security;
alter table public.notifications enable row level security;

-- Free Tier Open Policies for TAMU Makeathon Prototype
create policy "Allow all read on users" on public.users for select using (true);
create policy "Allow all write on users" on public.users for all using (true);

create policy "Allow all read on rides" on public.rides for select using (true);
create policy "Allow all write on rides" on public.rides for all using (true);

create policy "Allow all read on requests" on public.requests for select using (true);
create policy "Allow all write on requests" on public.requests for all using (true);

create policy "Allow all read on notifications" on public.notifications for select using (true);
create policy "Allow all write on notifications" on public.notifications for all using (true);

-- 7. Realtime Replication for Instant Feed Updates
alter publication supabase_realtime add table public.rides;
alter publication supabase_realtime add table public.requests;
alter publication supabase_realtime add table public.notifications;

-- 8. Storage Buckets (Avatars & Vehicle Photos)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true), ('vehicles', 'vehicles', true)
on conflict (id) do nothing;

create policy "Public Access to Avatars" on storage.objects
  for select using (bucket_id = 'avatars');
create policy "Upload Access to Avatars" on storage.objects
  for insert with check (bucket_id = 'avatars');

create policy "Public Access to Vehicles" on storage.objects
  for select using (bucket_id = 'vehicles');
create policy "Upload Access to Vehicles" on storage.objects
  for insert with check (bucket_id = 'vehicles');

-- 9. Insert Initial Texas A&M Seed Personas
insert into public.users (user_id, name, email, class_year, major, is_tamu_verified, avatar, bio, car_model, rides_offered, rides_joined, rating, reviews_count, on_time_rate, joined_date)
values
  ('user-maya', 'Maya Reed', 'm.reed25@tamu.edu', '''25 (Senior)', 'Computer Science', true, 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80', 'Senior CS student at TAMU. Safe driver with clean record!', '2022 Honda Civic (White)', 18, 4, 5.0, 16, '100%', 'August 2024'),
  ('user-carlos', 'Carlos Hernandez', 'carlos.h@tamu.edu', '''26 (Sophomore)', 'Industrial Engineering', true, 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80', 'Sophomore living at Park West. No car this semester, prompt with gas splits!', null, 2, 14, 4.9, 12, '98%', 'September 2024'),
  ('user-david', 'David Miller', 'd.miller@tamu.edu', '''24 (Graduate)', 'Mays Business School', true, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80', 'MBA student commuting daily from The Barracks to Wehner.', '2021 Toyota RAV4 (Silver)', 31, 3, 5.0, 28, '100%', 'January 2024'),
  ('user-priya', 'Priya Patel', 'priya.patel@tamu.edu', '''25 (Junior)', 'Biomedical Sciences', true, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80', 'Pre-med Aggie! Regular trips to Target and Post Oak Mall.', '2023 Hyundai Elantra (Maroon)', 12, 8, 4.8, 10, '96%', 'February 2024'),
  ('user-sarah', 'Sarah Chen', 'sarah.chen@tamu.edu', '''27 (Freshman)', 'General Engineering', false, 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80', 'Freshman at Hullabaloo Hall looking for friendly Aggie rides.', null, 0, 1, 5.0, 1, '100%', 'November 2026')
on conflict (user_id) do nothing;

-- 10. Insert 11 Bryan-College Station Corridor Rides
insert into public.rides (ride_id, driver_id, origin, destination, departure_date, departure_time, available_seats, total_seats, contribution, category, is_recurring, recurring_days, notes, pickup_spot, status)
values
  ('ride-1', 'user-maya', 'Park West Apartments', 'Walmart Supercenter (Bryan/College Station)', 'Saturday, Nov 8', '11:00 AM', 2, 3, 3, 'Shopping', false, '{}', 'Heading to Walmart for weekly groceries! Leaving from Tower 1 circle. Trunk has plenty of room.', 'Park West Tower 1 Circle', 'ACTIVE'),
  ('ride-2', 'user-maya', 'Northgate (Traditions Area)', 'Texas A&M Campus (Zachry Engineering Complex)', 'Monday, Nov 10', '8:00 AM', 2, 2, 0, 'Campus', true, '{"Mon","Wed","Fri"}', 'Regular morning commute to Zachry for 8:30 AM lecture. Dropping off at Bizzell St passenger circle. Aggies ride free!', 'Corner of College Main & University Dr', 'ACTIVE'),
  ('ride-3', 'user-david', 'The Barracks Townhomes', 'H-E-B (Jones Crossing / Wellborn Rd)', 'Saturday, Nov 8', '2:00 PM', 3, 3, 2, 'Groceries', false, '{}', 'Quick 45-minute grocery trip to H-E-B Jones Crossing. Will bring you back afterwards! Plenty of space.', 'The Barracks Clubhouse / Cove Pool', 'ACTIVE'),
  ('ride-4', 'user-priya', 'University Apartments (Hensel Dr)', 'CVS Pharmacy (Texas Ave)', 'Today', '5:00 PM', 1, 2, 0, 'Pharmacy', false, '{}', 'Picking up a prescription and supplies at CVS on Texas Ave. Free ride for anyone needing medicine!', 'Community Center Parking Lot', 'ACTIVE'),
  ('ride-5', 'user-david', 'South College Station', 'Post Oak Mall (Dillard''s / H&M)', 'Sunday, Nov 9', '1:00 PM', 2, 3, 3, 'Shopping', false, '{}', 'Mall trip for winter clothes & dining at BJ''s Brewhouse.', 'Sonterra Apartments Entrance', 'ACTIVE'),
  ('ride-6', 'user-maya', 'Northgate / Cherry St', 'Target (University Dr)', 'Saturday, Nov 8', '4:00 PM', 2, 3, 0, 'Shopping', false, '{}', 'Heading to Target for dorm supplies and Starbucks. Happy to give Aggies a lift.', 'Northgate Post Office Bus Stop', 'ACTIVE'),
  ('ride-7', 'user-priya', 'Park West Apartments', 'Texas A&M Campus (MSC Circle)', 'Tuesday, Nov 11', '9:00 AM', 1, 2, 2, 'Campus', true, '{"Tue","Thu"}', 'Morning ride to Memorial Student Center for study groups. Drop-off at Joe Routt Blvd.', 'Park West Tower 2 Entrance', 'ACTIVE'),
  ('ride-8', 'user-david', 'The Barracks Townhomes', 'Costco Wholesale (Midtown Bryan)', 'Sunday, Nov 9', '11:00 AM', 3, 3, 4, 'Groceries', false, '{}', 'Bulk shopping run at Costco! I have an Executive Membership so you can shop with me.', 'The Barracks Central Mail Kiosk', 'ACTIVE'),
  ('ride-9', 'user-priya', 'The London Apartments', 'Sam''s Club (Harvey Rd)', 'Saturday, Nov 8', '1:30 PM', 2, 2, 2, 'Shopping', false, '{}', 'Quick run to Sam''s Club for bulk pantry snacks. Splitting gas is appreciated!', 'Front leasing office roundabout', 'ACTIVE'),
  ('ride-10', 'user-david', 'The Cottages of College Station', 'Century Square (Hopdoddy & Sweet Paris)', 'Tonight', '7:00 PM', 3, 3, 0, 'Dining', false, '{}', 'Dinner at Century Square with friends. Anyone wanting to grab burgers is welcome to ride along!', 'Cottages Clubhouse Entrance', 'ACTIVE'),
  ('ride-11', 'user-maya', 'Callaway House', 'H-E-B (Texas Ave & Villa Maria / Bryan)', 'Sunday, Nov 9', '4:00 PM', 2, 3, 2, 'Groceries', false, '{}', 'Heading to the large Bryan H-E-B on Texas Ave for specialty groceries.', 'Callaway Porte-Cochere', 'ACTIVE')
on conflict (ride_id) do nothing;

-- 11. Insert Sample Flow 1 Request
insert into public.requests (request_id, ride_id, passenger_id, driver_id, seats_requested, status, message)
values
  ('req-1', 'ride-1', 'user-carlos', 'user-maya', 1, 'PENDING', 'Howdy Maya! Need to grab groceries & snacks for my apartment. Can meet at Tower 1 circle!')
on conflict (request_id) do nothing;
