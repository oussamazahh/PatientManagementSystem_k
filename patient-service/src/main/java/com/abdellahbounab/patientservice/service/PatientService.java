package com.abdellahbounab.patientservice.service;

import com.abdellahbounab.patientservice.dto.PatientRequestDTO;
import com.abdellahbounab.patientservice.dto.PatientResponseDTO;
import com.abdellahbounab.patientservice.exception.EmailAlreadyExistsException;
import com.abdellahbounab.patientservice.exception.PatientNotExistsException;
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
    private PatientRepository patientRepository;

    public PatientService(PatientRepository patientRepository) {
        this.patientRepository = patientRepository;
    }

    public List<PatientResponseDTO> getPatients() {
        List<Patient> patients = patientRepository.findAll();
        return patients.stream()
                .map(PatientMapper::toPatientDTO)
                .collect(Collectors.toList());
    }

    public PatientResponseDTO createPatient(PatientRequestDTO patientRequestDTO) {
        if (patientRepository.existsByEmail(patientRequestDTO.getEmail())) {
            throw new EmailAlreadyExistsException("this email already exists: " + patientRequestDTO.getEmail());
        }
        // Convert DTO to model
        Patient patient = PatientMapper.toPatientModel(patientRequestDTO);
        // Save patient
        Patient savedPatient = patientRepository.save(patient);
        // Convert model to ResponseDTO , return it to controller
        return PatientMapper.toPatientDTO(savedPatient);
    }

    public PatientResponseDTO updatePatient(UUID id,
                                            PatientRequestDTO patientRequestDTO) {
        Patient patient = patientRepository.findById(id)
                    .orElseThrow(()-> new PatientNotExistsException("Patient doesnt exists"));


        patient.setName(patientRequestDTO.getName());
        if (patientRepository.existsByEmailAndIdNot(patientRequestDTO.getEmail(), id))
            throw new EmailAlreadyExistsException("this email already exists: " + patientRequestDTO.getEmail());
        patient.setEmail(patientRequestDTO.getEmail());
        patient.setAddress(patientRequestDTO.getAddress());
        patient.setDataOfBirth(LocalDate.parse(patientRequestDTO.getDateOfBirth()));

         Patient updatedPatient = patientRepository.save(patient);
        return PatientMapper.toPatientDTO(updatedPatient);
    }

    public void deletePatient(UUID id){
        patientRepository.deleteById(id);
    }
}
