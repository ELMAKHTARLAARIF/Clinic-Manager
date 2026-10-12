package com.clinicmanager.interfaces;

import com.clinicmanager.model.Appointment;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface IAppointmentRepository {

    /** Persiste un nouveau rendez-vous. */
    void save(Appointment appointment);

    /** Tous les rendez-vous d'un patient (via son user), du plus récent au plus ancien. Liste vide si aucun. */
    List<Appointment> findByPatientUser(Long userId);

    /** Un rendez-vous, SEULEMENT s'il appartient à ce patient (sinon : vide). */
    Optional<Appointment> findOwned(Long appointmentId, Long userId);

    /** Passe un rendez-vous PLANIFIÉ à ANNULÉ. Renvoie 0 s'il n'était plus planifié (double clic...). */
    int cancel(Long appointmentId, LocalDateTime when);
}