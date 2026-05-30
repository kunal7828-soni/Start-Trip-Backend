-- TRIP BUDDY POSTGRESQL DATABASE SCHEMA
-- Host this schema in Supabase under SQL Editor.

-- =========================================================================
-- 1. ENUMS AND EXTENSIONS Setup
-- =========================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE user_role AS ENUM ('user', 'worker');
CREATE TYPE trip_status AS ENUM ('planning', 'upcoming', 'ongoing', 'completed', 'cancelled');
CREATE TYPE booking_type AS ENUM ('train', 'bus');
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled');

-- =========================================================================
-- 2. TABLES CREATION
-- =========================================================================

-- USERS TABLE (Identity profiles)
CREATE TABLE users (
    id UUID PRIMARY KEY, -- Maps to Firebase Auth UID
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    role user_role NOT NULL DEFAULT 'user',
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- WORKERS TABLE (Transit guides / Drivers profiles)
CREATE TABLE workers (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    service_type VARCHAR(50) NOT NULL DEFAULT 'general',
    vehicle_type VARCHAR(50),
    vehicle_number VARCHAR(30),
    rating NUMERIC(3, 2) DEFAULT 5.00 CHECK (rating BETWEEN 0 AND 5),
    is_active BOOLEAN DEFAULT false,
    last_known_lat DOUBLE PRECISION,
    last_known_lng DOUBLE PRECISION,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- TRIPS TABLE (Excursions planning Ledger)
CREATE TABLE trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    budget NUMERIC(12, 2) DEFAULT 0.00,
    status trip_status NOT NULL DEFAULT 'planning',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (end_date >= start_date)
);

-- TRAIN ROUTES TABLE (Static Rail connections query list)
CREATE TABLE train_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    train_number VARCHAR(20) UNIQUE NOT NULL,
    train_name VARCHAR(100) NOT NULL,
    source_station VARCHAR(100) NOT NULL,
    destination_station VARCHAR(100) NOT NULL,
    departure_time TIME NOT NULL,
    postal_stops JSONB NOT NULL, -- Detailed arrays of intermediate stops
    runs_on VARCHAR(15) NOT NULL DEFAULT '1,2,3,4,5,6,7',
    classes TEXT[] NOT NULL DEFAULT '{"3A", "SL"}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- BUS ROUTES TABLE (Static bus connections scheduler)
CREATE TABLE bus_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bus_operator VARCHAR(100) NOT NULL,
    bus_type VARCHAR(50) NOT NULL,
    source VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    fare NUMERIC(10, 2) NOT NULL,
    seats_available INT DEFAULT 40,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- SAVED PLACES TABLE (Custom location bookmarkings)
CREATE TABLE saved_places (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_id VARCHAR(255) NOT NULL,
    place_name VARCHAR(150) NOT NULL,
    formatted_address TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, place_id)
);

-- BOOKINGS TABLE (Tickets ledger matching reservations)
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_type booking_type NOT NULL,
    route_id UUID NOT NULL, -- Logical reference to train_routes or bus_routes
    booking_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    travel_date DATE NOT NULL,
    fare_paid NUMERIC(10, 2) NOT NULL,
    status booking_status NOT NULL DEFAULT 'pending',
    seat_details VARCHAR(50),
    payment_intent_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================================
-- 3. INDEXING Setup (Highly Optimized query access pathways)
-- =========================================================================
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_workers_active ON workers(is_active) WHERE is_active = true;
CREATE INDEX idx_trips_user ON trips(user_id);
CREATE INDEX idx_trains_routing ON train_routes(source_station, destination_station);
CREATE INDEX idx_buses_routing ON bus_routes(source, destination);
CREATE INDEX idx_places_user ON saved_places(user_id);
CREATE INDEX idx_bookings_user ON bookings(user_id);

-- =========================================================================
-- 4. ROW LEVEL SECURITY (RLS) POLICIES Configuration
-- =========================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE train_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bus_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

-- USERS POLICIES
CREATE POLICY "Allow public read for user profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Allow personal profile edits" ON users FOR UPDATE USING (auth.uid() = id);

-- WORKERS POLICIES
CREATE POLICY "Allow public read for active workers" ON workers FOR SELECT USING (true);
CREATE POLICY "Allow worker profile edits" ON workers FOR UPDATE USING (auth.uid() = id);

-- TRIPS POLICIES
CREATE POLICY "Allow personal trips access" ON trips FOR ALL USING (auth.uid() = user_id);

-- STATIC TRANSIT PUBLIC POLICIES
CREATE POLICY "Allow public read for trains" ON train_routes FOR SELECT USING (true);
CREATE POLICY "Allow public read for buses" ON bus_routes FOR SELECT USING (true);

-- SAVED PLACES POLICIES
CREATE POLICY "Allow personal saved places access" ON saved_places FOR ALL USING (auth.uid() = user_id);

-- BOOKINGS POLICIES
CREATE POLICY "Allow personal bookings access" ON bookings FOR ALL USING (auth.uid() = user_id);

-- =========================================================================
-- 5. DYNAMIC TRIGGERS AND FUNCTIONS Setup
-- =========================================================================

-- Auto update updated_at parameter function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_users_timestamp
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_workers_timestamp
BEFORE UPDATE ON workers
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_trips_timestamp
BEFORE UPDATE ON trips
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
