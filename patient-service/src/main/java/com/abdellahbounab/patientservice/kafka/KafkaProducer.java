package com.abdellahbounab.patientservice.kafka;

import com.abdellahbounab.patientservice.model.Patient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import patient.events.PatientEvent;

@Service
public class KafkaProducer {
    private static final Logger log = LoggerFactory.getLogger(KafkaProducer.class);
    //define message type & use kafka template to send the messages
    //message : {"key" : "value"}
    private final KafkaTemplate<String, byte[]> kafkaTemplate;

    public KafkaProducer(KafkaTemplate<String, byte[]> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendEvent(Patient patient) {
        PatientEvent event = PatientEvent.newBuilder()
                .setPatientId(patient.getId().toString())
                .setName(patient.getName())
                .setEmail(patient.getEmail())
                .setEventType("PATIENT_CREATED") //setting the type inside the topic
                .build();

        try {
            //sending the message into #patient# topic
            kafkaTemplate.send("patient", event.toByteArray());
        }catch (Exception e) {
            log.error("Error sending PatientCreated event : {}", event);
        }
    }
}
