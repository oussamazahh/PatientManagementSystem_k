package com.abdellahbounab.patientservice.controller;

import com.abdellahbounab.patientservice.dto.PatientRequestDTO;
import com.abdellahbounab.patientservice.dto.PatientResponseDTO;
import com.abdellahbounab.patientservice.dto.validators.CreatePatientValidationGroup;
import com.abdellahbounab.patientservice.service.PatientService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.groups.Default;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/patients")
@Tag(name = "Patient", description = "REST API to manage patients")
public class PatientController {
    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    @GetMapping
    @Operation(summary = "get patients")
    public ResponseEntity<List<PatientResponseDTO>> getPatients() {
        List<PatientResponseDTO> patients = patientService.getPatients();
        return ResponseEntity.ok().body(patients);
    }

    @PostMapping
    @Operation(summary = "create a new patient")
    public ResponseEntity<PatientResponseDTO> createPatient(@Validated({Default.class, CreatePatientValidationGroup.class}) @RequestBody PatientRequestDTO patientDTO) {
        PatientResponseDTO patient = patientService.createPatient(patientDTO);
        return ResponseEntity.created(null).body(patient);
    }

    @PutMapping("/{id}")
    @Operation(summary = "update existing patient")
    public ResponseEntity<PatientResponseDTO> updatePatient(@PathVariable UUID id,
                                                            @Validated({Default.class}) @RequestBody PatientRequestDTO patientDTO) {
        PatientResponseDTO patient = patientService.updatePatient(id, patientDTO);
        return ResponseEntity.created(null).body(patient);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "delete a patient")
    public ResponseEntity<Void> deletePatient(@PathVariable UUID id) {
        patientService.deletePatient(id);
        return ResponseEntity.noContent().build();
    }
}

