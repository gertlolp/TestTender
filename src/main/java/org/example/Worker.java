package org.example;

import java.math.BigDecimal;
import java.util.List;

public class Worker  {

    private List <ProfessionalSkill> skills;
    private BigDecimal financialOffer;

    public Worker(List<ProfessionalSkill> skills, BigDecimal financialOffer) {
        this.skills = skills;
        this.financialOffer = financialOffer;
    }

    public List<ProfessionalSkill> getSkills() {
        return skills;
    }

    public BigDecimal getFinancialOffer() {
        return financialOffer;
    }

    public void setSkills(List<ProfessionalSkill> skills) {
        this.skills = skills;
    }

    public void setFinancialOffer(BigDecimal financialOffer) {
        this.financialOffer = financialOffer;
    }

    @Override
    public String toString() {
        return "Worker{" +
                "skills=" + skills +
                ", financialOffer=" + financialOffer +
                '}';
    }
}
