package fr.ablette.vehicle;

import java.time.Instant;
import java.util.UUID;

public record VehicleResponse(UUID id, String nickname, String brand, String model, int year,
                              String engine, Fuel fuel, int currentMileage, Instant createdAt) {
    static VehicleResponse from(Vehicle vehicle) {
        return new VehicleResponse(vehicle.getId(), vehicle.getNickname(), vehicle.getBrand(), vehicle.getModel(),
                vehicle.getYear(), vehicle.getEngine(), vehicle.getFuel(), vehicle.getCurrentMileage(), vehicle.getCreatedAt());
    }
}
