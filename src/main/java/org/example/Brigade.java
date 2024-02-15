package org.example;

import java.math.BigDecimal;
import java.util.List;

public class Brigade {
    private List<Worker> workers;

    public Brigade(List<Worker> workers) {
        this.workers = workers;
    }
    public List<Worker> getWorkers() {
        return workers;
    }
    public BigDecimal getTotalFinancialOffer() {
        return workers.stream()
                .map(Worker::getFinancialOffer)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    @Override
    public String toString() {
        return "Brigade{" +
                "workers=" + workers +
                '}';
    }
}