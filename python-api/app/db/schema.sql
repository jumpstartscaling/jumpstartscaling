-- God Mode pSEO Factory - PostgreSQL Schema
-- Single source of truth for connection.py and seed_from_exports.py

-- Leads (contact forms, audit survey, n8n form, etc.)
CREATE TABLE IF NOT EXISTS leads (
    id SERIAL PRIMARY KEY,
    source TEXT,
    name TEXT,
    email TEXT,
    phone TEXT,
    website TEXT,
    revenue TEXT,
    budget TEXT,
    problem TEXT,
    form_type TEXT,
    data_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Scaling survey (Moat Audit, detailed survey)
CREATE TABLE IF NOT EXISTS scaling_survey_submissions (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    company TEXT,
    role TEXT,
    current_revenue TEXT,
    target_revenue TEXT,
    team_size TEXT,
    industry TEXT,
    challenges JSONB,
    marketing_spend TEXT,
    channels JSONB,
    biggest_goal TEXT,
    raw_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Request logging (optional, for debugging)
CREATE TABLE IF NOT EXISTS api_logs (
    id SERIAL PRIMARY KEY,
    endpoint TEXT,
    method TEXT,
    status INTEGER,
    payload JSONB,
    response JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Harris matrix (pSEO): locations, services, content
CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT,
    neighborhood TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pseo_services (
    id SERIAL PRIMARY KEY,
    service_type TEXT NOT NULL,
    sub_niche TEXT,
    slug TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS content_matrix (
    id SERIAL PRIMARY KEY,
    location_id INT REFERENCES locations(id),
    service_id INT REFERENCES pseo_services(id),
    slug TEXT UNIQUE,
    title TEXT,
    meta_description TEXT,
    content_json JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
