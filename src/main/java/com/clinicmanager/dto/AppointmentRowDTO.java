package com.clinicmanager.dto;

public class AppointmentRowDTO {
    private final Long id;
    private final String dayNumber, monthLabel, fullDate, startTime, endTime;
    private final String doctorName, specialty, type, reason;
    private final String status;        // PLANNED | DONE | CANCELED
    private final String group;         // upcoming | past | canceled  (onglets de la page)
    private final boolean canCancel;

    public AppointmentRowDTO(Long id, String dayNumber, String monthLabel, String fullDate,
                             String startTime, String endTime, String doctorName, String specialty,
                             String type, String reason, String status, String group, boolean canCancel) {
        this.id = id; this.dayNumber = dayNumber; this.monthLabel = monthLabel; this.fullDate = fullDate;
        this.startTime = startTime; this.endTime = endTime; this.doctorName = doctorName;
        this.specialty = specialty; this.type = type; this.reason = reason;
        this.status = status; this.group = group; this.canCancel = canCancel;
    }
    public Long getId() { return id; }
    public String getDayNumber() { return dayNumber; }
    public String getMonthLabel() { return monthLabel; }
    public String getFullDate() { return fullDate; }
    public String getStartTime() { return startTime; }
    public String getEndTime() { return endTime; }
    public String getDoctorName() { return doctorName; }
    public String getSpecialty() { return specialty; }
    public String getType() { return type; }
    public String getReason() { return reason; }
    public String getStatus() { return status; }
    public String getGroup() { return group; }
    public boolean isCanCancel() { return canCancel; }       // EL : ${a.canCancel}
}
