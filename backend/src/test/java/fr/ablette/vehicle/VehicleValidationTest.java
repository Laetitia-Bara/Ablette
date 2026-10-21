package fr.ablette.vehicle;

import java.util.Set;
import java.util.stream.Collectors;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class VehicleValidationTest {
    private static final ValidatorFactory FACTORY = Validation.buildDefaultValidatorFactory();
    private static final Validator VALIDATOR = FACTORY.getValidator();

    @AfterAll
    static void closeValidatorFactory() {
        FACTORY.close();
    }

    @Test
    void rejectsMissingRequiredFields() {
        assertThat(invalidFields(new CreateVehicleRequest(null, null, null, null, null, null, null)))
                .containsExactlyInAnyOrder("brand", "model", "year", "engine", "fuel", "currentMileage");
    }

    @Test
    void rejectsNegativeMileageAndPre1900Year() {
        assertThat(invalidFields(new CreateVehicleRequest(null, "Renault", "Clio", 1899, "dCi", Fuel.DIESEL, -1)))
                .containsExactlyInAnyOrder("year", "currentMileage");
    }

    @Test
    void rejectsBlankStringsAndExcessiveNickname() {
        assertThat(invalidFields(new CreateVehicleRequest("a".repeat(81), "  ", "  ", 2018, "  ", Fuel.DIESEL, 1)))
                .containsExactlyInAnyOrder("nickname", "brand", "model", "engine");
    }

    @Test
    void acceptsBoundaryValuesWithoutNickname() {
        assertThat(invalidFields(new CreateVehicleRequest(null, "a".repeat(80), "b".repeat(80), 1900,
                "c".repeat(120), Fuel.OTHER, 0))).isEmpty();
    }

    private Set<String> invalidFields(CreateVehicleRequest request) {
        return VALIDATOR.validate(request).stream().map(violation -> violation.getPropertyPath().toString())
                .collect(Collectors.toSet());
    }
}
