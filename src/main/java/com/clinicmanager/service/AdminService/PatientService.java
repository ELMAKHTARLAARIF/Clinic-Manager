package com.clinicmanager.service.AdminService;

import com.clinicmanager.enums.BloodGroup;
import com.clinicmanager.enums.Gender;
import com.clinicmanager.enums.Role;
import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.exception.PatientNotFoundException;
import com.clinicmanager.model.Patient;
import com.clinicmanager.model.User;
import com.clinicmanager.repository.PatientRepository;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.util.PasswordUtil;
import jakarta.persistence.PersistenceException;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static com.clinicmanager.util.ValidationUtil.isBlank;

public class PatientService {
    private final UserRepository userRepository = new UserRepository();
    private final PatientRepository patientRepository = new PatientRepository();

    public List<Patient> findAll(){
        return patientRepository.findAll();
    }
    public Optional<Patient> findById(Long id) {
        return patientRepository.findById(id);
    }
    public void createPatient(String lastName, String firstName, String email, String phone, String password, String cin, LocalDate birthDate, Gender gender, BloodGroup bloodGroup, String address) {

        String normalizedEmail = email.trim().toLowerCase();
        String normalizedCin = cin.trim().toUpperCase();

        if (userRepository.existsByEmail(normalizedEmail))
            throw new DuplicateEmailException("Cet email est déjà utilisé.");
        if (patientRepository.existsByCin(normalizedCin))
            throw new IllegalArgumentException("Ce CIN est déjà utilisé.");

        User user = new User();
        user.setLastName(lastName.trim());
        user.setFirstName(firstName.trim());
        user.setEmail(normalizedEmail);                       // et non l'email brut
        user.setPhone(isBlank(phone) ? null : phone.trim());
        user.setPassword(PasswordUtil.hash(password));
        user.setRole(Role.PATIENT);
        user.setActive(true);

        Patient patient = new Patient();
        patient.setCin(normalizedCin);
        patient.setBirthDate(birthDate);
        patient.setGender(gender);                            // manquait dans ta version
        patient.setBloodGroup(bloodGroup);
        patient.setAddress(isBlank(address) ? null : address.trim());
        patient.setPhone(user.getPhone());

        try {
            userRepository.saveWithUser(user, patient, (em, p) -> p.setUser(user));   // ← l'enregistrement qui manquait
        } catch (PersistenceException e) {
            if (userRepository.existsByEmail(normalizedEmail))
                throw new DuplicateEmailException("Cet email est déjà utilisé.");
            if (patientRepository.existsByCin(normalizedCin))
                throw new IllegalArgumentException("Ce CIN est déjà utilisé.");
            throw e;
        }
    }
    public void deletePatient(Long patientId){
        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new IllegalArgumentException("Patient not found with ID: " + patientId));
        patientRepository.deletePatient(patient);
    }

    public void updatePatient(Long id, String lastName, String firstName, String email, String phone,
                              String password, String cin, LocalDate birthDate,
                              Gender gender, BloodGroup bloodGroup, String address) {

        Patient patient = patientRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Patient introuvable."));
        User user = patient.getUser();

        String normalizedEmail = email.trim().toLowerCase();
        String normalizedCin = cin.trim().toUpperCase();

        // unicité : on ne vérifie que si la valeur a CHANGÉ
        if (!normalizedEmail.equals(user.getEmail()) && userRepository.existsByEmail(normalizedEmail))
            throw new DuplicateEmailException("Cet email est déjà utilisé.");
        if (!normalizedCin.equals(patient.getCin()) && patientRepository.existsByCin(normalizedCin))
            throw new IllegalArgumentException("Ce CIN est déjà utilisé.");

        user.setLastName(lastName.trim());
        user.setFirstName(firstName.trim());
        user.setEmail(normalizedEmail);
        user.setPhone(isBlank(phone) ? null : phone.trim());
        if (!isBlank(password)) user.setPassword(PasswordUtil.hash(password));   // vide = inchangé

        patient.setCin(normalizedCin);
        patient.setBirthDate(birthDate);
        patient.setGender(gender);
        patient.setBloodGroup(bloodGroup);
        patient.setAddress(isBlank(address) ? null : address.trim());

        patientRepository.update(patient);
    }


}
