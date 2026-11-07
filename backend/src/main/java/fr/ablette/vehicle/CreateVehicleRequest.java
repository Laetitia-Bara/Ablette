package fr.ablette.vehicle;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "Véhicule à ajouter au garage ; année au maximum égale à l'année courante + 1.")
public record CreateVehicleRequest(
        @Size(max = 80, message = "Le surnom ne doit pas dépasser 80 caractères.")
        String nickname,
        @NotBlank(message = "La marque est obligatoire.")
        @Size(max = 80, message = "La marque ne doit pas dépasser 80 caractères.")
        @Schema(example = "Renault") String brand,
        @NotBlank(message = "Le modèle est obligatoire.")
        @Size(max = 80, message = "Le modèle ne doit pas dépasser 80 caractères.")
        @Schema(example = "Clio") String model,
        @NotNull(message = "L'année est obligatoire.")
        @Min(value = 1900, message = "L'année doit être au moins égale à 1900.")
        @Schema(example = "2018", minimum = "1900") Integer year,
        @NotBlank(message = "La motorisation est obligatoire.")
        @Size(max = 120, message = "La motorisation ne doit pas dépasser 120 caractères.")
        @Schema(example = "1.5 dCi 90") String engine,
        @NotNull(message = "Le carburant est obligatoire.") Fuel fuel,
        @NotNull(message = "Le kilométrage est obligatoire.")
        @Min(value = 0, message = "Le kilométrage ne peut pas être négatif.")
        @Schema(example = "85000", minimum = "0") Integer currentMileage
) {
    public CreateVehicleRequest {
        nickname = trim(nickname);
        if (nickname != null && nickname.isEmpty()) nickname = null;
        brand = trim(brand);
        model = trim(model);
        engine = trim(engine);
    }

    private static String trim(String value) {
        return value == null ? null : value.strip();
    }
}
