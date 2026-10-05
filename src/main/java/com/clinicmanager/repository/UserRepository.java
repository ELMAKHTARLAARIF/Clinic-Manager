package com.clinicmanager.repository;

import com.clinicmanager.exception.UserNotFoundException;
import com.clinicmanager.model.User;
import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;

import java.util.Optional;
import java.util.function.BiConsumer;

public class UserRepository {

    public boolean existsByEmail(String email) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            Long count = em.createQuery("SELECT COUNT(u) FROM User u WHERE LOWER(u.email) = :email", Long.class).setParameter("email", email.toLowerCase()).getSingleResult();
            return count > 0;
        }
    }



    public Optional<User> findByEmail(String email) {
        try (EntityManager em = JPAUtil.getEntityManager()) {
            User user = em.createQuery(
                            "SELECT u FROM User u WHERE u.email = :email", User.class)
                    .setParameter("email", email)
                    .getSingleResult();
            return Optional.of(user);
        } catch (NoResultException e) {
            return Optional.empty();
        }
    }


    public <T> T saveWithUser(User user, T profile, BiConsumer<EntityManager, T> link) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(user);
            link.accept(em, profile);     // relie le profil au user (et aux autres entités)
            em.persist(profile);
            tx.commit();
            return profile;
        } catch (RuntimeException e) {
            if (tx.isActive()) tx.rollback();   // rien n'est enregistré
            throw e;
        } finally {
            em.close();
        }
    }
}
