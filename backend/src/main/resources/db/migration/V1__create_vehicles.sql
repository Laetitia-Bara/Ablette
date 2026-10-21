CREATE TABLE vehicles (
    id UUID PRIMARY KEY,
    nickname VARCHAR(80),
    brand VARCHAR(80) NOT NULL,
    model VARCHAR(80) NOT NULL,
    model_year INTEGER NOT NULL,
    engine VARCHAR(120) NOT NULL,
    fuel VARCHAR(20) NOT NULL,
    current_mileage INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT vehicles_brand_not_blank CHECK (length(btrim(brand)) > 0),
    CONSTRAINT vehicles_model_not_blank CHECK (length(btrim(model)) > 0),
    CONSTRAINT vehicles_engine_not_blank CHECK (length(btrim(engine)) > 0),
    CONSTRAINT vehicles_year_range CHECK (model_year BETWEEN 1900 AND 2100),
    CONSTRAINT vehicles_mileage_non_negative CHECK (current_mileage >= 0),
    CONSTRAINT vehicles_fuel_valid CHECK (fuel IN ('PETROL', 'DIESEL', 'HYBRID', 'ELECTRIC', 'LPG', 'OTHER'))
);

CREATE INDEX vehicles_created_at_idx ON vehicles (created_at DESC, id ASC);
