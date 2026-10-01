package com.clinicmanager.model;

import com.clinicmanager.enums.NoteStatus;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "medical_notes")
public class MedicalNote {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    @OneToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "appointment_id", unique = true)
    private Appointment appointment;

    @Column(nullable = false, length = 255)
    private String diagnosis;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(nullable = false)
    private LocalDateTime noteDate = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    private NoteStatus status = NoteStatus.DRAFT;   // VALIDATED = lecture seule
}
