package com.clinicmanager.interfaces;

import com.clinicmanager.model.Doctor;

import java.util.List;
import java.util.Optional;

public interface IDoctorRepository {

    /** Tous les médecins, avec user, spécialité et département chargés (évite LazyInitializationException). */
    List<Doctor> findAll();

    /** Tous les médecins dont le compte utilisateur est actif (liste vide si aucun). */
    List<Doctor> findAllActive();

    /** true si un médecin avec ce matricule existe déjà (comparaison insensible à la casse). */
    boolean existsByMatricule(String matricule);

    /** Médecin actif correspondant à cet id, ou Optional vide. */
    Optional<Doctor> findById(Long id);

    /** true si la spécialité existe ET appartient bien à ce département. */
    boolean specialtyBelongsToDepartment(Long specialtyId, Long departmentId);
}