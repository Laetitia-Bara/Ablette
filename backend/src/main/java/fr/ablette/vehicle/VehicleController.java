package fr.ablette.vehicle;

import java.net.URI;
import java.util.List;
import java.util.UUID;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/vehicles")
@Tag(name = "Garage", description = "Création et consultation des véhicules")
public class VehicleController {
    private final VehicleService service;

    public VehicleController(VehicleService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Lister le garage", description = "Véhicules classés du plus récent au plus ancien.")
    public List<VehicleResponse> list() {
        return service.list();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Consulter un véhicule")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Véhicule trouvé"),
            @ApiResponse(responseCode = "404", description = "Véhicule absent",
                    content = @Content(schema = @Schema(implementation = ProblemDetail.class)))
    })
    public VehicleResponse get(@PathVariable UUID id) {
        return service.get(id);
    }

    @PostMapping
    @Operation(summary = "Ajouter un véhicule", description = "Identifiant et date de création générés par le serveur.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Véhicule créé ; URI dans l'en-tête Location",
                    content = @Content(schema = @Schema(implementation = VehicleResponse.class))),
            @ApiResponse(responseCode = "400", description = "Données invalides",
                    content = @Content(schema = @Schema(implementation = ProblemDetail.class)))
    })
    public ResponseEntity<VehicleResponse> create(@Valid @RequestBody CreateVehicleRequest request) {
        VehicleResponse vehicle = service.create(request);
        return ResponseEntity.created(URI.create("/api/v1/vehicles/" + vehicle.id())).body(vehicle);
    }
}
