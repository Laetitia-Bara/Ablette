package fr.ablette.vehicle;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import fr.ablette.config.SecurityConfiguration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(VehicleController.class)
@Import(SecurityConfiguration.class)
@ActiveProfiles("local")
class VehicleControllerTest {
    private static final String VALID_REQUEST = """
            {"brand":"Renault","model":"Clio","year":2018,"engine":"dCi","fuel":"DIESEL","currentMileage":85000}
            """;

    @Autowired MockMvc api;
    @MockitoBean VehicleService service;

    @Test
    void returnsCreatedVehicleAndLocation() throws Exception {
        UUID id = UUID.randomUUID();
        when(service.create(any())).thenReturn(new VehicleResponse(id, null, "Renault", "Clio", 2018,
                "dCi", Fuel.DIESEL, 85000, Instant.parse("2026-10-21T12:00:00Z")));

        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content(VALID_REQUEST))
                .andExpect(status().isCreated()).andExpect(header().string("Location", "/api/v1/vehicles/" + id))
                .andExpect(jsonPath("$.id").value(id.toString()))
                .andExpect(jsonPath("$.createdAt").value("2026-10-21T12:00:00Z"));
    }

    @Test
    void returnsArrayForGarage() throws Exception {
        when(service.list()).thenReturn(List.of());
        api.perform(get("/api/v1/vehicles")).andExpect(status().isOk()).andExpect(content().json("[]"));
    }

    @Test
    void returnsFieldErrorsWithoutCallingServiceForInvalidInput() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith("application/problem+json"))
                .andExpect(jsonPath("$.errors.brand").value("La marque est obligatoire."))
                .andExpect(jsonPath("$.errors.currentMileage").isString());
        verifyNoInteractions(service);
    }

    @Test
    void rejectsFractionalMileageUnknownFieldsAndMalformedJson() throws Exception {
        for (String body : List.of(VALID_REQUEST.replace("85000", "85000.8"),
                VALID_REQUEST.replace("{", "{\"id\":\"client-controlled\","), "{")) {
            api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content(body))
                    .andExpect(status().isBadRequest()).andExpect(jsonPath("$.errors._request").isString());
        }
        verifyNoInteractions(service);
    }

    @Test
    void returns404ForMissingVehicle() throws Exception {
        UUID id = UUID.randomUUID();
        when(service.get(id)).thenThrow(new VehicleNotFoundException(id));
        api.perform(get("/api/v1/vehicles/" + id)).andExpect(status().isNotFound())
                .andExpect(jsonPath("$.title").value("Véhicule introuvable"));
    }

    @Test
    void rejectsMalformedVehicleIdentifier() throws Exception {
        api.perform(get("/api/v1/vehicles/not-a-uuid")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.id").isString());
        verifyNoInteractions(service);
    }
}
