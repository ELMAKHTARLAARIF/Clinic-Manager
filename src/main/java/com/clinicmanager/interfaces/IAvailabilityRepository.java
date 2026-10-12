package com.clinicmanager.interfaces;

import com.clinicmanager.enums.AvailabilityStatus;
import com.clinicmanager.model.Availability;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface IAvailabilityRepository {

    /** Toutes les disponibilités d'un médecin (liste vide si aucune). */
    List<Availability> findByDoctor(Long doctorId);

    /**
     * true si une plage du MÊME type (même jour, même statut) chevauche la nouvelle :
     * les heures se recouvrent ET les périodes de validité se recouvrent.
     */
    boolean existsOverlap(Long doctorId, DayOfWeek day, AvailabilityStatus status,
                          LocalTime start, LocalTime end,
                          LocalDate validFrom, LocalDate validTo);

    /** Persiste la disponibilité en l'associant au médecin donné. */
    Availability save(Availability availability, Long doctorId);

    /** Supprime SEULEMENT si la disponibilité appartient à ce médecin. Renvoie false sinon. */
    boolean deleteByIdAndDoctor(Long id, Long doctorId);
}