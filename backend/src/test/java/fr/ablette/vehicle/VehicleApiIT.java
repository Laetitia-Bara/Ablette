package fr.ablette.vehicle;

import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = "DB_PASSWORD=unused-test-property")
@AutoConfigureMockMvc
@ActiveProfiles("local")
@Testcontainers
class VehicleApiIT {
    @Container
    @ServiceConnection
    static final PostgreSQLContainer POSTGRES = new PostgreSQLContainer("postgres:17.11-alpine");

    private static final String VEHICLE = """
            {"nickname":"  Ablette  ","brand":" Renault ","model":" Clio ","year":2018,
             "engine":"1.5 dCi 90","fuel":"DIESEL","currentMileage":85000}
            """;

    @Autowired MockMvc api;
    @Autowired JdbcTemplate jdbc;
    @Autowired VehicleRepository repository;

    @BeforeEach
    void clearGarage() {
        repository.deleteAll();
    }

    @Test
    void createsAndRetrievesVehiclePersistedInPostgresql() throws Exception {
        MvcResult creation = api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content(VEHICLE))
                .andExpect(status().isCreated())
                .andExpect(header().exists("Location"))
                .andExpect(jsonPath("$.id").isString())
                .andExpect(jsonPath("$.createdAt").isString())
                .andExpect(jsonPath("$.nickname").value("Ablette"))
                .andExpect(jsonPath("$.brand").value("Renault"))
                .andReturn();

        String location = creation.getResponse().getHeader("Location");
        UUID id = UUID.fromString(location.substring(location.lastIndexOf('/') + 1));
        assertThat(jdbc.queryForObject("SELECT current_mileage FROM vehicles WHERE id = ?", Integer.class, id))
                .isEqualTo(85000);

        api.perform(get(location)).andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(id.toString()))
                .andExpect(jsonPath("$.fuel").value("DIESEL"));
        api.perform(get("/api/v1/vehicles")).andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1))).andExpect(jsonPath("$[0].id").value(id.toString()));
    }

    @Test
    void listsNewestVehicleFirst() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content(VEHICLE))
                .andExpect(status().isCreated());
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("Clio", "Megane"))).andExpect(status().isCreated());

        api.perform(get("/api/v1/vehicles")).andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].model").value("Megane"));
    }

    @Test
    void returnsEmptyArrayForEmptyGarage() throws Exception {
        api.perform(get("/api/v1/vehicles")).andExpect(status().isOk()).andExpect(content().json("[]"));
    }

    @Test
    void acceptsOptionalNicknameAndBoundaryValues() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("\"nickname\":\"  Ablette  \",", "")
                                .replace("2018", "1900").replace("85000", "0")))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.currentMileage").value(0))
                .andExpect(jsonPath("$.year").value(1900));
    }

    @Test
    void rejectsNegativeMileageWithoutPersisting() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("85000", "-1")))
                .andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith("application/problem+json"))
                .andExpect(jsonPath("$.errors.currentMileage").isString());
        assertThat(repository.count()).isZero();
    }

    @Test
    void rejectsMissingAndBlankRequiredFields() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.year").isString())
                .andExpect(jsonPath("$.errors.fuel").isString());
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("Renault", "   ")))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.errors.brand").isString());
        assertThat(repository.count()).isZero();
    }

    @Test
    void rejectsExcessiveModelYearWithBusinessError() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("2018", "2099")))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.errors.year").isString());
        assertThat(repository.count()).isZero();
    }

    @Test
    void rejectsInvalidFuelAndMalformedJson() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("DIESEL", "INVALID")))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.errors._request").isString());
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON).content("{"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.errors._request").isString());
    }

    @Test
    void rejectsFractionalMileageAndServerControlledProperties() throws Exception {
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("85000", "85000.8")))
                .andExpect(status().isBadRequest());
        api.perform(post("/api/v1/vehicles").contentType(APPLICATION_JSON)
                        .content(VEHICLE.replace("{", "{\"id\":\"" + UUID.randomUUID() + "\",")))
                .andExpect(status().isBadRequest());
        assertThat(repository.count()).isZero();
    }

    @Test
    void returns404ForMissingVehicleAnd400ForMalformedIdentifier() throws Exception {
        api.perform(get("/api/v1/vehicles/" + UUID.randomUUID())).andExpect(status().isNotFound())
                .andExpect(jsonPath("$.title").value("Véhicule introuvable"));
        api.perform(get("/api/v1/vehicles/not-a-uuid")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.errors.id").isString());
    }

    @Test
    void appliesFlywaySchemaAndDatabaseConstraints() {
        assertThat(jdbc.queryForObject("SELECT count(*) FROM flyway_schema_history WHERE success = true", Integer.class))
                .isEqualTo(1);
        assertThatThrownBy(() -> jdbc.update("""
                INSERT INTO vehicles (id,brand,model,model_year,engine,fuel,current_mileage,created_at)
                VALUES (?, 'Renault', 'Clio', 2018, 'dCi', 'DIESEL', -1, now())
                """, UUID.randomUUID())).isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void exposesOpenapiAndHealthButDeniesOtherRoutesAndMethods() throws Exception {
        api.perform(get("/v3/api-docs")).andExpect(status().isOk())
                .andExpect(jsonPath("$.paths['/api/v1/vehicles'].post").exists());
        api.perform(get("/actuator/health")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("UP"));
        api.perform(get("/api/v1/accounts")).andExpect(status().isForbidden());
        api.perform(put("/api/v1/vehicles").contentType(APPLICATION_JSON).content(VEHICLE))
                .andExpect(status().isForbidden());
    }
}
