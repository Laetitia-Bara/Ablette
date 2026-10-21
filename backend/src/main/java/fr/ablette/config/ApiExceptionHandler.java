package fr.ablette.config;

import java.util.LinkedHashMap;
import java.util.Map;

import fr.ablette.vehicle.InvalidVehicleException;
import fr.ablette.vehicle.VehicleNotFoundException;
import jakarta.validation.ConstraintViolationException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/** Stable REST errors: technical exception messages and SQL are never sent to the client. */
@RestControllerAdvice
public class ApiExceptionHandler extends ResponseEntityExceptionHandler {
    @ExceptionHandler(VehicleNotFoundException.class)
    ProblemDetail notFound(VehicleNotFoundException exception) {
        return problem(HttpStatus.NOT_FOUND, "Véhicule introuvable", exception.getMessage(), Map.of());
    }

    @ExceptionHandler(InvalidVehicleException.class)
    ProblemDetail invalidVehicle(InvalidVehicleException exception) {
        return validation(exception.getErrors());
    }

    @ExceptionHandler(ConstraintViolationException.class)
    ProblemDetail constraintViolation(ConstraintViolationException exception) {
        Map<String, String> errors = new LinkedHashMap<>();
        exception.getConstraintViolations().forEach(violation -> {
            String path = violation.getPropertyPath().toString();
            errors.putIfAbsent(path.substring(path.lastIndexOf('.') + 1), violation.getMessage());
        });
        return validation(errors);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    ProblemDetail dataConflict(DataIntegrityViolationException exception) {
        return problem(HttpStatus.CONFLICT, "Enregistrement impossible",
                "Les données ne respectent pas les contraintes du garage.", Map.of());
    }

    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException exception,
            HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        Map<String, String> errors = new LinkedHashMap<>();
        exception.getBindingResult().getFieldErrors().forEach(error ->
                errors.putIfAbsent(error.getField(), error.getDefaultMessage()));
        return handleExceptionInternal(exception, validation(errors), headers, HttpStatus.BAD_REQUEST, request);
    }

    @Override
    protected ResponseEntity<Object> handleHttpMessageNotReadable(HttpMessageNotReadableException exception,
            HttpHeaders headers, HttpStatusCode status, WebRequest request) {
        return handleExceptionInternal(exception, validation(Map.of("_request",
                        "Le contenu JSON est invalide : vérifiez les champs et le carburant choisis.")),
                headers, HttpStatus.BAD_REQUEST, request);
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    ProblemDetail invalidIdentifier(MethodArgumentTypeMismatchException exception) {
        return validation(Map.of(exception.getName(), "L'identifiant du véhicule doit être un UUID valide."));
    }

    private ProblemDetail validation(Map<String, String> errors) {
        return problem(HttpStatus.BAD_REQUEST, "Données invalides", "Veuillez corriger les champs indiqués.", errors);
    }

    private ProblemDetail problem(HttpStatus status, String title, String detail, Map<String, String> errors) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        problem.setTitle(title);
        problem.setProperty("errors", errors);
        return problem;
    }
}
