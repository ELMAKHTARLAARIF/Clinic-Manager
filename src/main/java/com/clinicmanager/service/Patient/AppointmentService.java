package com.clinicmanager.service.Patient;

import com.clinicmanager.enums.AppointmentStatus;
import com.clinicmanager.enums.AppointmentType;
import com.clinicmanager.exception.AppointmentConflictException;
import com.clinicmanager.exception.UnauthorizedActionException;
import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.Doctor;
import com.clinicmanager.model.Patient;
import com.clinicmanager.repository.AppointmentRepository;
import com.clinicmanager.repository.PatientRepository;
import com.clinicmanager.repository.doctor.DoctorRepository;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class AppointmentService {
    private static final int CANCEL_MIN_HOURS = 12;          // règle du cahier des charges
    private final PatientRepository patientRepository = new PatientRepository();
    private final DoctorRepository doctorRepository = new DoctorRepository();
    private final AppointmentRepository appointmentRepository = new AppointmentRepository();

    public void create(Long patientId, Long doctorId, LocalDateTime startDateTime, LocalDateTime endDateTime, String type, String reason) {

        Patient patient = patientRepository.findByUserId(patientId).orElseThrow(() -> new IllegalArgumentException("Patient introuvable"));

        Doctor doctor = doctorRepository.findById(doctorId).orElseThrow(() -> new IllegalArgumentException("Médecin introuvable"));

        Appointment appointment = new Appointment();

        appointment.setPatient(patient);
        appointment.setDoctor(doctor);
        appointment.setStartDateTime(startDateTime);
        appointment.setEndDateTime(endDateTime);
        appointment.setType(AppointmentType.valueOf(type));
        appointment.setReason(reason);
        appointment.setStatus(AppointmentStatus.PLANNED);
        try {
            appointmentRepository.save(appointment);
        } catch (AppointmentConflictException e) {
            throw new AppointmentConflictException(e.getMessage());
        }

    }

    public List<Appointment> findForUser(Long userId) {
        LocalDateTime now = LocalDateTime.now();
        List<Appointment> all = appointmentRepository.findByPatientUser(userId);    // déjà triés du plus récent au plus ancien

        List<Appointment> result = new ArrayList<>(all.stream().filter(a -> a.getStartDateTime().isAfter(now)).sorted(Comparator.comparing(Appointment::getStartDateTime)).toList());
        result.addAll(all.stream().filter(a -> !a.getStartDateTime().isAfter(now)).toList());
        return result;
    }

    public boolean canCancel(Appointment a) {
        return a.getStatus() == AppointmentStatus.PLANNED && !LocalDateTime.now().plusHours(CANCEL_MIN_HOURS).isAfter(a.getStartDateTime());
    }

    public void cancel(Long userId, Long appointmentId) {
        Appointment appointment = appointmentRepository.findOwned(appointmentId, userId)       // le rendez-vous d'un AUTRE patient = "introuvable"
                .orElseThrow(() -> new IllegalArgumentException("Rendez-vous introuvable."));

        if (appointment.getStatus() != AppointmentStatus.PLANNED)
            throw new IllegalArgumentException("Seul un rendez-vous planifié peut être annulé.");

        if (!canCancel(appointment))
            throw new UnauthorizedActionException("Annulation impossible : le rendez-vous commence dans moins de " + CANCEL_MIN_HOURS + " heures.");

        if (appointmentRepository.cancel(appointmentId, LocalDateTime.now()) == 0)
            throw new IllegalArgumentException("Ce rendez-vous ne peut plus être annulé.");
    }

}
