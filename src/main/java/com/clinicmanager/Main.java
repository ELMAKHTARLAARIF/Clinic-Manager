package com.clinicmanager;

import com.clinicmanager.util.JPAUtil;
import jakarta.persistence.EntityManager;

public class Main {
    public static void main(String[] args) {
        EntityManager em = JPAUtil.getEntityManager();
        System.out.println("Connexion OK, tables créées !");
        em.close();
        JPAUtil.close();
    }
}