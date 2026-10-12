package com.clinicmanager.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class PasswordUtilTest {

    @Test
    void hash_is_never_the_plain_password() {
        String hash = PasswordUtil.hash("secret123");
        assertNotEquals("secret123", hash);
    }

    @Test
    void correct_password_is_verified() {
        String hash = PasswordUtil.hash("secret123");
        assertTrue(PasswordUtil.verify("secret123", hash));
    }

    @Test
    void wrong_password_is_rejected() {
        String hash = PasswordUtil.hash("secret123");
        assertFalse(PasswordUtil.verify("secret124", hash));
    }

    @Test
    void same_password_gives_two_different_hashes() {      // le sel est aléatoire
        assertNotEquals(PasswordUtil.hash("secret123"), PasswordUtil.hash("secret123"));
    }

    @Test
    void invalid_stored_hash_or_null_never_throws() {
        assertFalse(PasswordUtil.verify("secret123", "pas-un-hash"));
        assertFalse(PasswordUtil.verify(null, PasswordUtil.hash("x")));
        assertFalse(PasswordUtil.verify("secret123", null));
    }
}