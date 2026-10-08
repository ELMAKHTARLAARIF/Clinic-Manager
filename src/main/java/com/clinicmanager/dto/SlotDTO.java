package com.clinicmanager.dto;

public class SlotDTO {
    final long doctorId; final String date; final String time; final String status;
    public SlotDTO(long doctorId, String date, String time, String status) {
        this.doctorId = doctorId; this.date = date; this.time = time; this.status = status;
    }
}