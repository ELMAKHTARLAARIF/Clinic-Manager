package com.clinicmanager.interfaces;

import com.clinicmanager.model.Patient;

import java.util.List;
import java.util.Optional;

public interface IPatientRepository {

    /** true si un patient avec ce CIN existe déjà (comparaison insensible à la casse). */
    boolean existsByCin(String cin);

    /** Patient (avec son user chargé) correspondant à cet id, ou Optional vide. */
    Optional<Patient> findById(Long id);

    /** Patient (avec son user chargé) lié à cet utilisateur, ou Optional vide. */
    Optional<Patient> findByUserId(Long userId);

    /** Tous les patients, avec leur user chargé (liste vide si aucun). */
    List<Patient> findAll();

    /** Supprime le patient ET son User associé dans une seule transaction. */
    void deletePatient(Patient patient);

    /** Met à jour le User et le Patient dans une seule transaction. Renvoie l'entité mise à jour. */
    Patient update(Patient patient);
}