package com.clinicmanager.repository;

import com.clinicmanager.model.Patient;
import com.clinicmanager.model.User;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.util.List;
import java.util.Optional;

public class PatientRepository {


    public boolean existsByCin(String cin) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Long count = em.createQuery("SELECT COUNT(p) FROM Patient p WHERE UPPER(p.cin) = :cin", Long.class).setParameter("cin", cin.toUpperCase()).getSingleResult();
            return count > 0;
        }
    }

    public Optional<Patient> findById(Long id) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            return em.createQuery("SELECT p FROM Patient p JOIN FETCH p.user WHERE p.id = :id", Patient.class).setParameter("id", id).getResultStream().findFirst();
        }
    }

    public List<Patient> findAll() {
        try (EntityManager em = JPAUtil.getEntityManager()) {

            return em.createQuery(" SELECT p FROM Patient p " + " JOIN FETCH p.user u ", Patient.class).getResultList();
        }
    }

    public void deletePatient(Patient patient){
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            Patient managedPatient = em.contains(patient) ? patient : em.merge(patient);
            User managedUser = managedPatient.getUser();
            em.remove(managedPatient);
            em.remove(managedUser);
            em.getTransaction().commit();
        }catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            throw new RuntimeException("Failed to delete patient", e);
        } finally {
            em.close();
        }
    }
    public Patient update(Patient patient) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(patient.getUser());      // les deux dans UNE transaction
            Patient saved = em.merge(patient);
            tx.commit();
            return saved;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
