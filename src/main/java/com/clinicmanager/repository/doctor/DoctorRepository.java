package com.clinicmanager.repository.doctor;

import com.clinicmanager.model.Doctor;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.Optional;

public class DoctorRepository {

    /**
     * Tous les médecins, avec user, spécialité et département chargés (évite LazyInitializationException).
     */


    public List<Doctor> findAll() {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT d FROM Doctor d " + "JOIN FETCH d.user u " + "JOIN FETCH d.specialty s " + "JOIN FETCH d.department dep " + "ORDER BY u.lastName, u.firstName", Doctor.class).getResultList();
        }
    }

    public List<Doctor> findAllActive() {
        try (EntityManager em = JPAUtil.getEntityManager()) {

            return em.createQuery(
                            "SELECT d FROM Doctor d " +
                                    "JOIN FETCH d.user u " +
                                    "JOIN FETCH d.specialty s " +
                                    "JOIN FETCH d.department dep " +
                                    "WHERE u.active = true " +
                                    "ORDER BY u.lastName, u.firstName", Doctor.class)
                    .getResultList();                      // liste vide si aucun médecin : pas d'erreur
        }
    }
    public boolean existsByMatricule(String matricule) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Long count = em.createQuery("SELECT COUNT(d) FROM Doctor d WHERE UPPER(d.matricule) = :m", Long.class).setParameter("m", matricule.toUpperCase()).getSingleResult();
            return count > 0;
        }
    }
    public Optional<Doctor> findById(Long id) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery(
                            "SELECT d FROM Doctor d JOIN FETCH d.user u WHERE d.id = :id AND u.active = true", Doctor.class)
                    .setParameter("id", id)
                    .getResultStream()
                    .findFirst();
        }
    }

    /**
     * true si la spécialité existe ET appartient bien à ce département.
     */
    public boolean specialtyBelongsToDepartment(Long specialtyId, Long departmentId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Long count = em.createQuery("SELECT COUNT(s) FROM Specialty s WHERE s.id = :sid AND s.department.id = :did", Long.class).setParameter("sid", specialtyId).setParameter("did", departmentId).getSingleResult();
            return count > 0;
        }
    }

    /**
     * Enregistre le User et le Doctor dans UNE SEULE transaction : tout ou rien.
     */
}