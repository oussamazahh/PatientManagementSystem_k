package com.abdellahbounab.patientservice.service;

import com.abdellahbounab.patientservice.dto.PatientRequestDTO;
import com.abdellahbounab.patientservice.dto.PatientResponseDTO;
import com.abdellahbounab.patientservice.exception.EmailAlreadyExistsException;
import com.abdellahbounab.patientservice.exception.PatientNotExistsException;
import com.abdellahbounab.patientservice.grpc.BillingServiceGrpcClient;
import com.abdellahbounab.patientservice.kafka.KafkaProducer;
import com.abdellahbounab.patientservice.mapper.PatientMapper;
import com.abdellahbounab.patientservice.model.Patient;
import com.abdellahbounab.patientservice.repository.PatientRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PatientService {
    private final PatientRepository patientRepository;
    private final BillingServiceGrpcClient billingServiceGrpcClient;
    private final KafkaProducer kafkaProducer;

    public PatientService(PatientRepository patientRepository,
                          BillingServiceGrpcClient billingServiceGrpcClient,
                          KafkaProducer kafkaProducer) {
        this.patientRepository = patientRepository;
        this.billingServiceGrpcClient = billingServiceGrpcClient;
        this.kafkaProducer = kafkaProducer;
    }

    public List<PatientResponseDTO> getPatients() {
        List<Patient> patients = patientRepository.findAll();
        return patients.stream().map(PatientMapper::toPatientDTO).collect(Collectors.toList());
    }

    public PatientResponseDTO createPatient(PatientRequestDTO patientRequestDTO) {
        if (patientRepository.existsByEmail(patientRequestDTO.getEmail())) {
            throw new EmailAlreadyExistsException("this email already exists: " + patientRequestDTO.getEmail());
        }
        // Convert DTO to model
        // Save patient
        Patient savedPatient = patientRepository.save(PatientMapper.toPatientModel(patientRequestDTO));

        //sending to the billing service
        billingServiceGrpcClient.createBillingAccount(savedPatient.getId().toString(), savedPatient.getName(), savedPatient.getEmail());
        //sending the event to kafka
        kafkaProducer.sendEvent(savedPatient);
        // Convert model to ResponseDTO , return it to controller
        return PatientMapper.toPatientDTO(savedPatient);
    }

    public PatientResponseDTO updatePatient(UUID id, PatientRequestDTO patientRequestDTO) {
        Patient patient = patientRepository.findById(id).orElseThrow(() -> new PatientNotExistsException("Patient doesnt exists"));


        patient.setName(patientRequestDTO.getName());
        if (patientRepository.existsByEmailAndIdNot(patientRequestDTO.getEmail(), id))
            throw new EmailAlreadyExistsException("this email already exists: " + patientRequestDTO.getEmail());
        patient.setEmail(patientRequestDTO.getEmail());
        patient.setAddress(patientRequestDTO.getAddress());
        patient.setDataOfBirth(LocalDate.parse(patientRequestDTO.getDateOfBirth()));

        Patient updatedPatient = patientRepository.save(patient);
        return PatientMapper.toPatientDTO(updatedPatient);
    }

    public void deletePatient(UUID id) {
        patientRepository.deleteById(id);
    }
}
