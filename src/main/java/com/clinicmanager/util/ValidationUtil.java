package com.clinicmanager.util;

import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

public final class ValidationUtil {

    private static final Pattern EMAIL = Pattern.compile("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$");
    private static final Pattern PHONE = Pattern.compile("^[0-9+\\s]{8,20}$");
    private static final Pattern NAME  = Pattern.compile("^[\\p{L}][\\p{L} '\\-]{0,99}$");

    private ValidationUtil() {}

    /** Retire les espaces autour ; renvoie "" si null. */
    public static String clean(String s) {
        return s == null ? "" : s.trim();
    }

    public static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    public static boolean isValidName(String s) {
        return s != null && NAME.matcher(s).matches();
    }

    public static boolean isValidEmail(String s) {
        return s != null && s.length() <= 150 && EMAIL.matcher(s).matches();
    }

    public static boolean isValidPhone(String s) {
        return s != null && PHONE.matcher(s).matches();
    }

    public static boolean hasMinLength(String s, int min) {
        return s != null && s.length() >= min;
    }

    public static LocalTime parseTime(String value) {
        try { return LocalTime.parse(value); }                    // "08:30"
        catch (DateTimeParseException | NullPointerException e) { return null; }
    }


}