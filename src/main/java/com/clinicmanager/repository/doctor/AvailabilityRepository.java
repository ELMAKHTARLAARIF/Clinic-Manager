package com.clinicmanager.repository;

import com.clinicmanager.enums.AvailabilityStatus;
import com.clinicmanager.model.Availability;
import com.clinicmanager.model.Doctor;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public class AvailabilityRepository {

    /** Toutes les disponibilités d'un médecin (liste vide si aucune). */
    public List<Availability> findByDoctor(Long doctorId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(
                            "SELECT a FROM Availability a WHERE a.doctor.id = :did", Availability.class)
                    .setParameter("did", doctorId)
                    .getResultList();
        }
    }

    /**
     * true si une plage du MÊME type (même jour, même statut) chevauche la nouvelle :
     * les heures se recouvrent ET les périodes de validité se recouvrent.
     */
    public boolean existsOverlap(Long doctorId, DayOfWeek day, AvailabilityStatus status,
                                 LocalTime start, LocalTime end, LocalDate validFrom, LocalDate validTo) {

        StringBuilder jpql = new StringBuilder(
                "SELECT COUNT(a) FROM Availability a " +
                        "WHERE a.doctor.id = :did AND a.dayOfWeek = :day AND a.status = :status " +
                        "AND a.startTime < :end AND a.endTime > :start " +                 // heures qui se recouvrent
                        "AND (a.validTo IS NULL OR a.validTo >= :from) ");                 // l'ancienne n'est pas finie avant
        if (validTo != null) jpql.append("AND a.validFrom <= :to ");               // l'ancienne ne commence pas après

        try (EntityManager em = JPAUtil.getEntityManager()) {
            TypedQuery<Long> q = em.createQuery(jpql.toString(), Long.class)
                    .setParameter("did", doctorId)
                    .setParameter("day", day)
                    .setParameter("status", status)
                    .setParameter("start", start)
                    .setParameter("end", end)
                    .setParameter("from", validFrom);
            if (validTo != null) q.setParameter("to", validTo);
            return q.getSingleResult() > 0;
        }
    }

    public Availability save(Availability availability, Long doctorId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            availability.setDoctor(em.getReference(Doctor.class, doctorId));
            em.persist(availability);
            tx.commit();
            return availability;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /** Supprime SEULEMENT si la disponibilité appartient à ce médecin. Renvoie false sinon. */
    public boolean deleteByIdAndDoctor(Long id, Long doctorId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            int deleted = em.createQuery(
                            "DELETE FROM Availability a WHERE a.id = :id AND a.doctor.id = :did")
                    .setParameter("id", id)
                    .setParameter("did", doctorId)
                    .executeUpdate();
            tx.commit();
            return deleted > 0;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}