package fr.ablette.vehicle;

import java.util.Map;

public class InvalidVehicleException extends RuntimeException {
    private final Map<String, String> errors;

    InvalidVehicleException(String field, String message) {
        super(message);
        errors = Map.of(field, message);
    }

    public Map<String, String> getErrors() {
        return errors;
    }
}
