package com.clinicmanager.model;

import com.clinicmanager.enums.BloodGroup;
import com.clinicmanager.enums.Gender;
import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "patients")
public class Patient {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", unique = true)
    private User user;                  // nom, prénom, email, mot de passe

    @Column(nullable = false, unique = true, length = 20)
    private String cin;

    @Column(nullable = false)
    private LocalDate birthDate;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Gender gender;

    @Column(length = 255)
    private String address;

    @Column(length = 20)
    private String phone;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private BloodGroup bloodGroup;
}
