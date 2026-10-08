package com.clinicmanager.dto;

public class AvailabilityDTO {
    private final Long id;
    private final String dayLabel;
    private final String startTime;
    private final String endTime;
    private final String validFrom;
    private final String validTo;     // null = sans fin
    private final String status;

    public AvailabilityDTO(Long id, String dayLabel, String startTime, String endTime,
                           String validFrom, String validTo, String status) {
        this.id = id;
        this.dayLabel = dayLabel;
        this.startTime = startTime;
        this.endTime = endTime;
        this.validFrom = validFrom;
        this.validTo = validTo;
        this.status = status;
    }

    public Long getId() { return id; }
    public String getDayLabel() { return dayLabel; }
    public String getStartTime() { return startTime; }
    public String getEndTime() { return endTime; }
    public String getValidFrom() { return validFrom; }
    public String getValidTo() { return validTo; }
    public String getStatus() { return status; }
}