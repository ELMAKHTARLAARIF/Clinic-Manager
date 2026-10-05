package com.clinicmanager.service.AdminService;

import com.clinicmanager.enums.BloodGroup;
import com.clinicmanager.enums.Gender;
import com.clinicmanager.enums.Role;                       // adapte si ton enum est ailleurs
import com.clinicmanager.exception.DuplicateEmailException;
import com.clinicmanager.exception.DuplicateMatriculeException;
import com.clinicmanager.model.*;
import com.clinicmanager.repository.DoctorRepository;
import com.clinicmanager.repository.PatientRepository;
import com.clinicmanager.repository.UserRepository;
import com.clinicmanager.util.PasswordUtil;
import jakarta.persistence.PersistenceException;

import java.time.LocalDate;
import java.util.List;

public class DoctorService {

    private final DoctorRepository doctorRepository = new DoctorRepository();
    private final UserRepository userRepository = new UserRepository();
    private final PatientRepository patientRepository = new PatientRepository();

    public List<Doctor> findAll() {
        return doctorRepository.findAll();      // liste vide si aucun médecin : pas d'erreur
    }
    public void createDoctor(String lastName, String firstName, String email, String phone, String password, String matricule, String title, Long departmentId, Long specialtyId) {

        String normalizedEmail = email.trim().toLowerCase();
        String normalizedMatricule = matricule.trim().toUpperCase();

        if (userRepository.existsByEmail(normalizedEmail))
            throw new DuplicateEmailException("Cet email est déjà utilisé.");
        if (doctorRepository.existsByMatricule(normalizedMatricule))
            throw new DuplicateMatriculeException("Ce matricule est déjà utilisé.");
        if (!doctorRepository.specialtyBelongsToDepartment(specialtyId, departmentId))
            throw new IllegalArgumentException("Cette spécialité n'appartient pas au département choisi.");

        User user = new User();
        user.setLastName(lastName.trim());
        user.setFirstName(firstName.trim());
        user.setEmail(normalizedEmail);
        user.setPhone(isBlank(phone) ? null : phone.trim());
        user.setPassword(PasswordUtil.hash(password));
        user.setRole(Role.DOCTOR);
        user.setActive(true);

        Doctor doctor = new Doctor();
        doctor.setMatricule(normalizedMatricule);
        doctor.setTitle(isBlank(title) ? null : title.trim());

        try {
            userRepository.saveWithUser(user, doctor, (em, d) -> {
                d.setUser(user);
                d.setDepartment(em.getReference(Department.class, departmentId));
                d.setSpecialty(em.getReference(Specialty.class, specialtyId));
            });
        } catch (PersistenceException e) {
            if (userRepository.existsByEmail(normalizedEmail))
                throw new DuplicateEmailException("Cet email est déjà utilisé.");
            if (doctorRepository.existsByMatricule(normalizedMatricule))
                throw new DuplicateMatriculeException("Ce matricule est déjà utilisé.");
            throw e;
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}