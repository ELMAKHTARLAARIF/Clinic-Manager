package com.clinicmanager.service.test;

import com.clinicmanager.enums.AppointmentStatus;
import com.clinicmanager.exception.UnauthorizedActionException;
import com.clinicmanager.model.Appointment;
import com.clinicmanager.repository.AppointmentRepository;
import com.clinicmanager.repository.PatientRepository;
import com.clinicmanager.repository.doctor.DoctorRepository;
import com.clinicmanager.service.Patient.AppointmentService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Test UNITAIRE : les repositories sont remplacés par des "mocks".
 * Aucune base de données n'est utilisée, seule la règle métier est testée.
 */
@ExtendWith(MockitoExtension.class)
class AppointmentServiceTest {

    @Mock private PatientRepository patientRepository;
    @Mock private DoctorRepository doctorRepository;
    @Mock private AppointmentRepository appointmentRepository;

    @InjectMocks private AppointmentService service;     // nécessite le constructeur à 3 paramètres (voir la réponse)

    /** Un rendez-vous PLANIFIÉ qui commence dans `hours` heures. */
    private Appointment planned(long hours) {
        Appointment a = new Appointment();
        a.setStatus(AppointmentStatus.PLANNED);
        a.setStartDateTime(LocalDateTime.now().plusHours(hours));
        a.setEndDateTime(LocalDateTime.now().plusHours(hours).plusMinutes(30));
        return a;
    }

    @Test
    @DisplayName("Annulation autorisée : le rendez-vous est dans plus de 12 h")
    void cancel_ok_when_more_than_12_hours() {
        when(appointmentRepository.findOwned(1L, 10L)).thenReturn(Optional.of(planned(13)));
        when(appointmentRepository.cancel(eq(1L), any(LocalDateTime.class))).thenReturn(1);

        assertDoesNotThrow(() -> service.cancel(10L, 1L));
        
        verify(appointmentRepository).cancel(eq(1L), any(LocalDateTime.class));   // la base a bien été modifiée
    }

    @Test
    @DisplayName("Annulation refusée : le rendez-vous est dans moins de 12 h")
    void cancel_refused_when_less_than_12_hours() {
        when(appointmentRepository.findOwned(1L, 10L)).thenReturn(Optional.of(planned(11)));

        assertThrows(UnauthorizedActionException.class, () -> service.cancel(10L, 1L));

        verify(appointmentRepository, never()).cancel(any(), any());               // rien n'a été annulé
    }

    @Test
    @DisplayName("Annulation refusée : le rendez-vous appartient à un autre patient")
    void cancel_refused_when_not_owner() {
        when(appointmentRepository.findOwned(1L, 99L)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () -> service.cancel(99L, 1L));

        verify(appointmentRepository, never()).cancel(any(), any());
    }

    @Test
    @DisplayName("Annulation refusée : le rendez-vous est déjà annulé")
    void cancel_refused_when_already_canceled() {
        Appointment a = planned(48);
        a.setStatus(AppointmentStatus.CANCELED);
        when(appointmentRepository.findOwned(1L, 10L)).thenReturn(Optional.of(a));

        assertThrows(IllegalArgumentException.class, () -> service.cancel(10L, 1L));
    }
}