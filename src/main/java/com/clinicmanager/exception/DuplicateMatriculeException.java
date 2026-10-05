package com.clinicmanager.exception;

public class DuplicateMatriculeException extends RuntimeException {
    public DuplicateMatriculeException(String message) {
        super(message);
    }
}
