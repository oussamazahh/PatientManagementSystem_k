package com.abdellahbounab.patientservice.exception;

public class PatientNotExistsException extends RuntimeException {
    public PatientNotExistsException(String msg) {
        super(msg);
    }
}
