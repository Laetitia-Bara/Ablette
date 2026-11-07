package fr.ablette.vehicle;

import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "vehicles")
public class Vehicle {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(length = 80)
    private String nickname;

    @Column(nullable = false, length = 80)
    private String brand;

    @Column(nullable = false, length = 80)
    private String model;

    @Column(name = "model_year", nullable = false)
    private int year;

    @Column(nullable = false, length = 120)
    private String engine;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Fuel fuel;

    @Column(name = "current_mileage", nullable = false)
    private int currentMileage;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    protected Vehicle() {
        // Required by JPA; application code uses the complete constructor.
    }

    Vehicle(String nickname, String brand, String model, int year, String engine, Fuel fuel,
            int currentMileage, Instant createdAt) {
        this.nickname = nickname;
        this.brand = brand;
        this.model = model;
        this.year = year;
        this.engine = engine;
        this.fuel = fuel;
        this.currentMileage = currentMileage;
        this.createdAt = createdAt;
    }

    public UUID getId() { return id; }
    public String getNickname() { return nickname; }
    public String getBrand() { return brand; }
    public String getModel() { return model; }
    public int getYear() { return year; }
    public String getEngine() { return engine; }
    public Fuel getFuel() { return fuel; }
    public int getCurrentMileage() { return currentMileage; }
    public Instant getCreatedAt() { return createdAt; }
}
