package fr.ablette.vehicle;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.ArgumentCaptor;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VehicleServiceTest {
    private static final Instant NOW = Instant.parse("2026-10-21T12:00:00Z");

    @Mock VehicleRepository repository;
    private VehicleService service;

    @BeforeEach
    void setUp() {
        service = new VehicleService(repository, Clock.fixed(NOW, ZoneOffset.UTC));
    }

    @Test
    void createsVehicleWithServerTimestampAndNormalizedFields() {
        when(repository.saveAndFlush(any(Vehicle.class))).thenAnswer(invocation -> invocation.getArgument(0));

        VehicleResponse result = service.create(new CreateVehicleRequest("  Ablette  ", " Renault ", " Clio ",
                2018, " 1.5 dCi ", Fuel.DIESEL, 85000));

        assertThat(result.nickname()).isEqualTo("Ablette");
        assertThat(result.brand()).isEqualTo("Renault");
        assertThat(result.model()).isEqualTo("Clio");
        assertThat(result.engine()).isEqualTo("1.5 dCi");
        assertThat(result.currentMileage()).isEqualTo(85000);
        assertThat(result.createdAt()).isEqualTo(NOW);
        verify(repository).saveAndFlush(any(Vehicle.class));
    }

    @Test
    void acceptsNextModelYearAndZeroMileage() {
        when(repository.saveAndFlush(any(Vehicle.class))).thenAnswer(invocation -> invocation.getArgument(0));

        VehicleResponse result = service.create(request(2027, 0));

        assertThat(result.year()).isEqualTo(2027);
        assertThat(result.currentMileage()).isZero();
    }

    @Test
    void normalizesTimestampToPostgresqlMicrosecondPrecisionBeforePersisting() {
        service = new VehicleService(repository,
                Clock.fixed(Instant.parse("2026-10-21T18:59:03.825061500Z"), ZoneOffset.UTC));
        when(repository.saveAndFlush(any(Vehicle.class))).thenAnswer(invocation -> invocation.getArgument(0));

        VehicleResponse result = service.create(request(2018, 85000));

        ArgumentCaptor<Vehicle> savedVehicle = ArgumentCaptor.forClass(Vehicle.class);
        verify(repository).saveAndFlush(savedVehicle.capture());
        Instant expected = Instant.parse("2026-10-21T18:59:03.825061Z");
        assertThat(savedVehicle.getValue().getCreatedAt()).isEqualTo(expected);
        assertThat(result.createdAt()).isEqualTo(expected);
    }

    @Test
    void rejectsYearBeyondNextYearBeforeSaving() {
        assertThatThrownBy(() -> service.create(request(2028, 0)))
                .isInstanceOf(InvalidVehicleException.class)
                .satisfies(exception -> assertThat(((InvalidVehicleException) exception).getErrors())
                        .containsEntry("year", "L'année ne doit pas dépasser 2027."));
        verifyNoInteractions(repository);
    }

    @Test
    void usesInjectedClockWhenYearChanges() {
        service = new VehicleService(repository, Clock.fixed(Instant.parse("2027-01-01T00:00:00Z"), ZoneOffset.UTC));
        when(repository.saveAndFlush(any(Vehicle.class))).thenAnswer(invocation -> invocation.getArgument(0));

        assertThat(service.create(request(2028, 0)).year()).isEqualTo(2028);
    }

    @Test
    void blankOptionalNicknameIsAbsent() {
        when(repository.saveAndFlush(any(Vehicle.class))).thenAnswer(invocation -> invocation.getArgument(0));
        assertThat(service.create(request(2018, 100)).nickname()).isNull();
    }

    @Test
    void returnsEmptyGarage() {
        when(repository.findAllByOrderByCreatedAtDescIdAsc()).thenReturn(List.of());
        assertThat(service.list()).isEmpty();
    }

    @Test
    void convertsStoredVehiclesToResponseDtosInRepositoryOrder() {
        Vehicle vehicle = new Vehicle(null, "Renault", "Clio", 2018, "1.5 dCi", Fuel.DIESEL, 85000, NOW);
        when(repository.findAllByOrderByCreatedAtDescIdAsc()).thenReturn(List.of(vehicle));

        assertThat(service.list()).singleElement().satisfies(dto -> {
            assertThat(dto.brand()).isEqualTo("Renault");
            assertThat(dto.createdAt()).isEqualTo(NOW);
        });
    }

    @Test
    void returnsNotFoundForMissingVehicle() {
        UUID id = UUID.randomUUID();
        when(repository.findById(id)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.get(id)).isInstanceOf(VehicleNotFoundException.class)
                .hasMessageContaining(id.toString());
    }

    private CreateVehicleRequest request(int year, int mileage) {
        return new CreateVehicleRequest("  ", "Renault", "Clio", year, "1.5 dCi", Fuel.DIESEL, mileage);
    }
}
