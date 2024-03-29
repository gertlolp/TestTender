package org.example;

import java.math.BigDecimal;
import java.util.*;

// Press Shift twice to open the Search Everywhere dialog and type `show whitespaces`,
// then press Enter. You can now see whitespace characters in your code.
public class TestTender {
    public static void main(String[] args) {
        List<Brigade> brigades = new ArrayList<>();

        Worker worker1 = new Worker(Arrays.asList(ProfessionalSkill.BULDER, ProfessionalSkill.CRANEOPERATOR), BigDecimal.valueOf(1000));
        Worker worker2 = new Worker(Arrays.asList(ProfessionalSkill.INSTALLER), BigDecimal.valueOf(1200));
        brigades.add(new Brigade(Arrays.asList(worker1, worker2)));
        HashMap<ProfessionalSkill, Integer> requiredSkills = new HashMap<>();
        requiredSkills.put(ProfessionalSkill.BULDER, 2);
        requiredSkills.put(ProfessionalSkill.CRANEOPERATOR, 2);
        Tender tender = new Tender(brigades, requiredSkills);
        Worker worker3 = new Worker(Arrays.asList(ProfessionalSkill.BULDER, ProfessionalSkill.CRANEOPERATOR), BigDecimal.valueOf(900));
        Worker worker4 = new Worker(Arrays.asList(ProfessionalSkill.BULDER, ProfessionalSkill.CRANEOPERATOR), BigDecimal.valueOf(700));
        brigades.add(new Brigade(Arrays.asList(worker3, worker4)));
        Worker worker5 = new Worker(Arrays.asList(ProfessionalSkill.BULDER, ProfessionalSkill.CRANEOPERATOR), BigDecimal.valueOf(1000));
        Worker worker6 = new Worker(Arrays.asList(ProfessionalSkill.BULDER, ProfessionalSkill.CRANEOPERATOR), BigDecimal.valueOf(1000));
        brigades.add(new Brigade(Arrays.asList(worker5, worker6)));


        Brigade suitableBrigade = tender.suitableBrigade();
        if (suitableBrigade != null) {
            System.out.println("Подходящая бригада найдена: " +  suitableBrigade);
        } else {
            System.out.println("Подходящая бригада не найдена");
            System.out.println("ggg");
        }
    }
}