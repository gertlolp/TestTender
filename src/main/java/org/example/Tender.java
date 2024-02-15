package org.example;

import java.math.BigDecimal;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Tender  {
    private List<Brigada> brigadas;
    private HashMap<ProfessionalSkill, Integer> requiredSkills;



    public Tender(List<Brigada> brigadas, HashMap<ProfessionalSkill, Integer> requiredSkills) {
        this.brigadas = brigadas;
        this.requiredSkills = requiredSkills;
    }

//    private boolean hasRequiredSkills(Brigada brigada){
//        HashMap<ProfessionalSkill, Integer> skillsCount = brigada.getWorkers().stream()
//                .flatMap(worker -> worker.getSkills().stream())
//                .collect(Collectors.groupingBy(Function.identity(), Collectors.summingInt(e -> 1)));
//        return requiredSkills.entrySet().stream()
//                .allMatch(entry -> skillsCount.getOrDefault(entry.getKey(), 0) >= entry.getValue());
//
//    }
    private boolean hasRequiredSkills(Brigada brigada){
        HashMap<ProfessionalSkill, Integer> skillsCount = (HashMap<ProfessionalSkill, Integer>) brigada.getWorkers().stream()
                .flatMap(worker -> worker.getSkills().stream())
                .collect(Collectors.groupingBy(Function.identity(), Collectors.summingInt(e -> 1)));
        return requiredSkills.entrySet().stream()
                .allMatch(entry -> skillsCount.getOrDefault(entry.getKey(), 0) >= entry.getValue());
    }

    /* private boolean hasRequiredSkills(Brigada brigada, HashMap<ProfessionalSkill, BigDecimal> requiredSkills){
        HashMap<ProfessionalSkill, BigDecimal> skillsCount = brigada.getWorkers().stream()
                .flatMap(worker -> worker.getSkills().stream())

        return requiredSkills.entrySet().stream()
                .allMatch(entry -> skillsCount.getOrDefault(entry.getKey(), BigDecimal.ZERO).compareTo(entry.getValue()) >= 0);
                   .collect(Collectors.groupingBy(Function.identity(), Collectors.summingInt(e -> 1)));

    }*/
    public Brigada podHodBrigada(){
        return brigadas.stream()
                .filter(this::hasRequiredSkills)
                .min(Comparator.comparing(Brigada::getTotalFinancialOffer))
                .orElse(null);
    }
}
