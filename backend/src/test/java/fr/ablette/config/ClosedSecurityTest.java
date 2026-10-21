package fr.ablette.config;

import fr.ablette.vehicle.VehicleController;
import fr.ablette.vehicle.VehicleService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.verifyNoInteractions;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(VehicleController.class)
@Import(SecurityConfiguration.class)
@ActiveProfiles("closed-test")
class ClosedSecurityTest {
    @Autowired MockMvc api;
    @MockitoBean VehicleService service;

    @Test
    void deniesGarageWithoutExplicitLocalProfile() throws Exception {
        api.perform(get("/api/v1/vehicles")).andExpect(status().isForbidden());
        api.perform(post("/api/v1/vehicles")).andExpect(status().isForbidden());
        api.perform(get("/v3/api-docs")).andExpect(status().isForbidden());
        verifyNoInteractions(service);
    }
}
