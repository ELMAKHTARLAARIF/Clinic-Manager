package com.clinicmanager.interfaces;

import com.clinicmanager.model.User;
import jakarta.persistence.EntityManager;

import java.util.Optional;
import java.util.function.BiConsumer;

public interface IUserRepository {

    /** true si un utilisateur avec cet email existe déjà (comparaison insensible à la casse). */
    boolean existsByEmail(String email);

    /** Utilisateur correspondant à cet email, ou Optional vide. */
    Optional<User> findByEmail(String email);

    /**
     * Persiste le User et son profil (Patient, Doctor...) dans UNE SEULE transaction : tout ou rien.
     * Le callback {@code link} relie le profil au user (et aux autres entités) avant la persistance.
     */
    <T> T saveWithUser(User user, T profile, BiConsumer<EntityManager, T> link);
}