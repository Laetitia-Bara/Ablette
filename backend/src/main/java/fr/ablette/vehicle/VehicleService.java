package fr.ablette.vehicle;

import java.time.Clock;
import java.time.Year;
import java.util.List;
import java.util.UUID;

import jakarta.validation.Valid;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;

@Service
@Validated
@Transactional(readOnly = true)
public class VehicleService {
    private final VehicleRepository repository;
    private final Clock clock;

    public VehicleService(VehicleRepository repository, Clock clock) {
        this.repository = repository;
        this.clock = clock;
    }

    public List<VehicleResponse> list() {
        return repository.findAllByOrderByCreatedAtDescIdAsc().stream().map(VehicleResponse::from).toList();
    }

    public VehicleResponse get(UUID id) {
        return VehicleResponse.from(repository.findById(id).orElseThrow(() -> new VehicleNotFoundException(id)));
    }

    /** The injected clock makes the rolling model-year boundary deterministic in tests. */
    @Transactional
    public VehicleResponse create(@Valid CreateVehicleRequest request) {
        int lastAllowedYear = Year.now(clock).getValue() + 1;
        if (request.year() > lastAllowedYear) {
            throw new InvalidVehicleException("year", "L'année ne doit pas dépasser " + lastAllowedYear + ".");
        }
        Vehicle vehicle = new Vehicle(request.nickname(), request.brand(), request.model(), request.year(),
                request.engine(), request.fuel(), request.currentMileage(), clock.instant());
        return VehicleResponse.from(repository.saveAndFlush(vehicle));
    }
}
