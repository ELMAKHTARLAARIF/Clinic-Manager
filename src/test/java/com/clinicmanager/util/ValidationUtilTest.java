package com.clinicmanager.util;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;

import static com.clinicmanager.util.ValidationUtil.*;
import static org.junit.jupiter.api.Assertions.*;

class ValidationUtilTest {

    @ParameterizedTest
    @ValueSource(strings = {"sara@mail.com", "a.b+c@clinic.ma", "Y_z@sub.domain.org"})
    void valid_emails_are_accepted(String email) {
        assertTrue(isValidEmail(email));
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "sara", "sara@", "@mail.com", "sara@mail", "sara mail@x.com"})
    void invalid_emails_are_rejected(String email) {
        assertFalse(isValidEmail(email));
    }

    @Test
    void null_email_is_rejected() {
        assertFalse(isValidEmail(null));
    }

    @Test
    void names_accept_accents_apostrophes_and_hyphens() {
        assertTrue(isValidName("Hélène"));
        assertTrue(isValidName("O'Brien"));
        assertTrue(isValidName("Jean-Pierre"));
    }

    @Test
    void names_reject_digits_and_empty_values() {
        assertFalse(isValidName("12345"));
        assertFalse(isValidName(""));
        assertFalse(isValidName(null));
    }

    @Test
    void phone_numbers() {
        assertTrue(isValidPhone("+212 6 12 34 56 78"));
        assertFalse(isValidPhone("abc"));
        assertFalse(isValidPhone("123"));            // trop court
    }

    @Test
    void password_minimum_length_is_6() {
        assertTrue(hasMinLength("secret123", 6));
        assertTrue(hasMinLength("123456", 6));
        assertFalse(hasMinLength("12345", 6));
        assertFalse(hasMinLength(null, 6));
    }

    @Test
    void parsing_helpers_return_null_instead_of_throwing() {
        assertEquals(LocalDate.of(1994, 3, 12), parseDate("1994-03-12"));
        assertNull(parseDate("12/03/1994"));
        assertNull(parseDate(null));

        assertEquals(LocalTime.of(8, 30), parseTime("08:30"));
        assertNull(parseTime("25:99"));

        assertEquals(DayOfWeek.MONDAY, parseEnum(DayOfWeek.class, "monday"));
        assertNull(parseEnum(DayOfWeek.class, "FUNDAY"));
        assertNull(parseEnum(DayOfWeek.class, null));
    }
}