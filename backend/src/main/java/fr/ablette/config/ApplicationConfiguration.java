package fr.ablette.config;

import java.time.Clock;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
public class ApplicationConfiguration {
    @Bean
    Clock clock() {
        return Clock.systemUTC();
    }

    @Bean
    OpenAPI openAPI() {
        return new OpenAPI().info(new Info().title("Ablette API").version("v1")
                .description("Lot 1 : garage persistant. Le profil local est réservé au développement sur cette machine."));
    }
}
