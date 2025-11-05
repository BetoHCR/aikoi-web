package com.aikoi.model;

import java.util.ArrayList;
import java.util.List;

public class Quiz {
    private Integer id;
    private String title;
    private String description;
    private String createdBy;
    private String createdAt; // ISO o texto simple
    private List<QuizOption> options = new ArrayList<>();

    public Quiz() {}

    public Quiz(Integer id, String title, String description, String createdBy, String createdAt) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    // Getters/setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public List<QuizOption> getOptions() { return options; }
    public void setOptions(List<QuizOption> options) { this.options = options; }
}
