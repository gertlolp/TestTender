package org.example;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Tender  {
    private List<Brigade> brigades;
    private HashMap<ProfessionalSkill, Integer> requiredSkills;

    public Tender(List<Brigade> brigades, HashMap<ProfessionalSkill, Integer> requiredSkills) {
        this.brigades = brigades;
        this.requiredSkills = requiredSkills;
    }

    private boolean hasRequiredSkills(Brigade brigade){
        HashMap<ProfessionalSkill, Integer> skillsCount = (HashMap<ProfessionalSkill, Integer>) brigade.getWorkers().stream()
                .flatMap(worker -> worker.getSkills().stream())
                .collect(Collectors.groupingBy(Function.identity(), Collectors.summingInt(e -> 1)));
        return requiredSkills.entrySet().stream()
                .allMatch(entry -> skillsCount.getOrDefault(entry.getKey(), 0) >= entry.getValue());
    }

    /* private boolean hasRequiredSkills(Brigade brigada, HashMap<ProfessionalSkill, BigDecimal> requiredSkills){
        HashMap<ProfessionalSkill, BigDecimal> skillsCount = brigada.getWorkers().stream()
                .flatMap(worker -> worker.getSkills().stream())

        return requiredSkills.entrySet().stream()
                .allMatch(entry -> skillsCount.getOrDefault(entry.getKey(), BigDecimal.ZERO).compareTo(entry.getValue()) >= 0);
                   .collect(Collectors.groupingBy(Function.identity(), Collectors.summingInt(e -> 1)));

    }*///    private boolean hasRequiredSkills(Brigade brigade){
//        HashMap<ProfessionalSkill, Integer> skillsCount = brigade.getWorkers().stream()
//                .flatMap(worker -> worker.getSkills().stream())
//                .collect(Collectors.groupingBy(Function.identity(), Collectors.summingInt(e -> 1)));
//        return requiredSkills.entrySet().stream()
//                .allMatch(entry -> skillsCount.getOrDefault(entry.getKey(), 0) >= entry.getValue());
//
//    }
    public Brigade suitableBrigade(){
        return brigades.stream()
                .filter(this::hasRequiredSkills)
                .min(Comparator.comparing(Brigade::getTotalFinancialOffer))
                .orElse(null);
    }
}
