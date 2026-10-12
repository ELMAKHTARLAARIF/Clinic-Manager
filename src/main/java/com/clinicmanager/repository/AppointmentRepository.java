package com.clinicmanager.repository;

import com.clinicmanager.enums.AppointmentStatus;
import com.clinicmanager.interfaces.IAppointmentRepository;
import com.clinicmanager.model.Appointment;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public class AppointmentRepository implements IAppointmentRepository {


    public void save(Appointment appointment) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(appointment);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw e;
        } finally {
            em.close();
        }

    }

    public List<Appointment> findByPatientUser(Long userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT a FROM Appointment a " + "JOIN FETCH a.doctor d " + "JOIN FETCH d.user " + "JOIN FETCH d.specialty " + "WHERE a.patient.user.id = :uid " + "ORDER BY a.startDateTime DESC", Appointment.class).setParameter("uid", userId).getResultList();                       // liste vide si aucun rendez-vous
        }
    }


    /**
     * Un rendez-vous, SEULEMENT s'il appartient à ce patient (sinon : vide).
     */
    public Optional<Appointment> findOwned(Long appointmentId, Long userId) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT a FROM Appointment a WHERE a.id = :id AND a.patient.user.id = :uid", Appointment.class).setParameter("id", appointmentId).setParameter("uid", userId).getResultStream().findFirst();
        }
    }

    /**
     * Passe un rendez-vous PLANIFIÉ à ANNULÉ. Renvoie 0 s'il n'était plus planifié (double clic...).
     */
    public int cancel(Long appointmentId, LocalDateTime when) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            int updated = em.createQuery("UPDATE Appointment a SET a.status = :canceled, a.canceledAt = :when " + "WHERE a.id = :id AND a.status = :planned").setParameter("canceled", AppointmentStatus.CANCELED).setParameter("planned", AppointmentStatus.PLANNED).setParameter("when", when).setParameter("id", appointmentId).executeUpdate();
            tx.commit();
            return updated;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }


}
