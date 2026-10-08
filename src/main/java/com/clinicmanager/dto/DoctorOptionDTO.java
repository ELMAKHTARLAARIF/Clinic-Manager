package com.clinicmanager.dto;

public class DoctorOptionDTO {
    private final Long id;
    private final String name;
    private final Long specialtyId;
    private final String department;

    public DoctorOptionDTO(Long id, String name, Long specialtyId, String department) {
        this.id = id;
        this.name = name;
        this.specialtyId = specialtyId;
        this.department = department;
    }
    public Long getId() { return id; }
    public String getName() { return name; }
    public Long getSpecialtyId() { return specialtyId; }
    public String getDepartment() { return department; }
}
