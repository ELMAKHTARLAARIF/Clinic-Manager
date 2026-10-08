package com.clinicmanager.service.Patient;

import com.clinicmanager.dto.SlotDTO;
import com.clinicmanager.model.Appointment;
import com.clinicmanager.model.Availability;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AgendaService {

    private static final int SLOT_MINUTES = 30;

    // Main method: 3 simple steps
    public List<SlotDTO> buildSlots(List<Long> doctorIds, LocalDate from, LocalDate to) {
        if (doctorIds.isEmpty()) return List.of();

        try (EntityManager em = JPAUtil.getEntityManager()) {
            List<Availability> availabilities = loadAvailabilities(em, doctorIds);       // when doctors work
            Set<String> bookedKeys = loadBookedKeys(em, doctorIds, from, to);            // what is already taken
            return createSlots(availabilities, bookedKeys, from, to);                    // combine both
        }
    }

    // STEP 1: read the weekly working hours of the doctors
    private List<Availability> loadAvailabilities(EntityManager em, List<Long> doctorIds) {
        return em.createQuery(
                        "SELECT a FROM Availability a WHERE a.doctor.id IN :ids", Availability.class)
                .setParameter("ids", doctorIds)
                .getResultList();
    }

    // STEP 2: read the appointments and turn each one into a text key like "1|2026-10-08|09:30"
    private Set<String> loadBookedKeys(EntityManager em, List<Long> doctorIds, LocalDate from, LocalDate to) {
        List<Appointment> appointments = em.createQuery(
                        "SELECT a FROM Appointment a " +
                                "WHERE a.doctor.id IN :ids " +
                                "AND a.startDateTime >= :from AND a.startDateTime < :to", Appointment.class)
                .setParameter("ids", doctorIds)
                .setParameter("from", from.atStartOfDay())               // first day, 00:00
                .setParameter("to", to.plusDays(1).atStartOfDay())       // day after the last day, 00:00
                .getResultList();

        Set<String> keys = new HashSet<>();
        for (Appointment appointment : appointments) {
            LocalDateTime start = appointment.getStartDateTime();
            keys.add(makeKey(appointment.getDoctor().getId(), start.toLocalDate(), start.toLocalTime()));
        }
        return keys;
    }

    // STEP 3: for each day and each working period, cut it into 30 minute slots
    private List<SlotDTO> createSlots(List<Availability> availabilities, Set<String> bookedKeys,
                                      LocalDate from, LocalDate to) {
        List<SlotDTO> slots = new ArrayList<>();

        for (LocalDate day = from; !day.isAfter(to); day = day.plusDays(1)) {          // each day
            for (Availability availability : availabilities) {                          // each working period

                if (availability.getDayOfWeek() != day.getDayOfWeek()) continue;        // not this weekday: skip

                long doctorId = availability.getDoctor().getId();
                LocalTime time = availability.getStartTime();
                LocalTime end = availability.getEndTime();

                while (!time.plusMinutes(SLOT_MINUTES).isAfter(end)) {                  // while the slot fits
                    boolean isBooked = bookedKeys.contains(makeKey(doctorId, day, time));
                    slots.add(new SlotDTO(doctorId, day.toString(), formatTime(time), isBooked ? "BOOKED" : "FREE"));
                    time = time.plusMinutes(SLOT_MINUTES);                              // next slot
                }
            }
        }
        return slots;
    }

    // Same key format everywhere: "doctorId|date|HH:mm"
    private String makeKey(long doctorId, LocalDate date, LocalTime time) {
        return doctorId + "|" + date + "|" + formatTime(time);
    }

    private String formatTime(LocalTime time) {
        return time.toString().substring(0, 5);       // "09:30:00" becomes "09:30"
    }
}