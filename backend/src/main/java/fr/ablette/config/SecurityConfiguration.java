package fr.ablette.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.SecurityFilterChain;

/** Until account isolation is implemented, the garage can only be opened explicitly in local development. */
@Configuration(proxyBeanMethods = false)
public class SecurityConfiguration {
    @Bean
    @Profile("local")
    SecurityFilterChain localSecurity(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(requests -> requests
                        .requestMatchers(HttpMethod.GET, "/api/v1/vehicles", "/api/v1/vehicles/*",
                                "/v3/api-docs", "/v3/api-docs/**", "/swagger-ui.html", "/swagger-ui/**",
                                "/actuator/health").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/v1/vehicles").permitAll()
                        .anyRequest().denyAll())
                .build();
    }

    @Bean
    @Profile("!local")
    SecurityFilterChain closedSecurity(HttpSecurity http) throws Exception {
        return http.authorizeHttpRequests(requests -> requests.anyRequest().denyAll()).build();
    }

    @Bean
    UserDetailsService noAccountsYet() {
        return username -> { throw new UsernameNotFoundException("Les comptes seront disponibles au lot 4."); };
    }
}
