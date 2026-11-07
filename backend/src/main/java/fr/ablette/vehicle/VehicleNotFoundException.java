package fr.ablette.vehicle;

import java.util.UUID;

public class VehicleNotFoundException extends RuntimeException {
    public VehicleNotFoundException(UUID id) {
        super("Le véhicule " + id + " n'existe pas.");
    }
}
