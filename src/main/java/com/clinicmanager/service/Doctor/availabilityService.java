package com.clinicmanager.service.DoctorSpaceService;

import com.clinicmanager.enums.AvailabilityStatus;
import com.clinicmanager.model.Availability;
import com.clinicmanager.model.Doctor;
import com.clinicmanager.repository.AvailabilityRepository;
import com.clinicmanager.repository.DoctorRepository;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Comparator;
import java.util.List;

public class availabilityService {

    private static final int SLOT_MINUTES = 30;       // durée d'un rendez-vous (cahier)

    private final AvailabilityRepository availabilityRepository = new AvailabilityRepository();
    private final DoctorRepository doctorRepository = new DoctorRepository();

    /** Les disponibilités du médecin connecté, triées lundi → samedi puis par heure. */
    public List<Availability> findForUser(Long userId) {
        Doctor doctor = currentDoctor(userId);
        List<Availability> list = availabilityRepository.findByDoctor(doctor.getId());
        list.sort(Comparator.comparing(Availability::getDayOfWeek)
                .thenComparing(Availability::getStartTime));
        return list;
    }

    public Availability create(Long userId, DayOfWeek day, AvailabilityStatus status,
                               LocalTime start, LocalTime end, LocalDate validFrom, LocalDate validTo) {

        // 1. règles de cohérence (le service ne fait pas confiance au contrôleur)
        if (day == null || status == null || start == null || end == null || validFrom == null)
            throw new IllegalArgumentException("Tous les champs obligatoires doivent être remplis.");
        if (day == DayOfWeek.SUNDAY)
            throw new IllegalArgumentException("Le dimanche est fermé.");
        if (!end.isAfter(start))
            throw new IllegalArgumentException("L'heure de fin doit être après l'heure de début.");
        if (Duration.between(start, end).toMinutes() < SLOT_MINUTES)
            throw new IllegalArgumentException("La plage doit durer au moins " + SLOT_MINUTES + " minutes.");
        if (validTo != null && validTo.isBefore(validFrom))
            throw new IllegalArgumentException("La date de fin ne peut pas précéder la date de début.");

        // 2. règle métier : pas de chevauchement avec une plage du même type
        Doctor doctor = currentDoctor(userId);
        if (availabilityRepository.existsOverlap(doctor.getId(), day, status, start, end, validFrom, validTo))
            throw new IllegalArgumentException("Cette plage chevauche une disponibilité existante du même type.");

        Availability availability = new Availability();
        availability.setDayOfWeek(day);
        availability.setStatus(status);
        availability.setStartTime(start);
        availability.setEndTime(end);
        availability.setValidFrom(validFrom);
        availability.setValidTo(validTo);               // null = sans fin
        return availabilityRepository.save(availability, doctor.getId());
    }

    public void delete(Long userId, Long availabilityId) {
        Doctor doctor = currentDoctor(userId);
        if (availabilityId == null || !availabilityRepository.deleteByIdAndDoctor(availabilityId, doctor.getId()))
            throw new IllegalArgumentException("Disponibilité introuvable.");
    }

    /** Le médecin vient TOUJOURS de la session, jamais d'un paramètre du formulaire. */
    private Doctor currentDoctor(Long userId) {
        return doctorRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Aucun profil médecin pour ce compte."));
    }


}