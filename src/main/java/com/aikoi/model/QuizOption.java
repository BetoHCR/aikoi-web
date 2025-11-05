package com.aikoi.model;

public class QuizOption {
    private Integer id;
    private Integer quizId;
    private String optionText;
    private boolean correct;

    public QuizOption() {}

    public QuizOption(Integer id, Integer quizId, String optionText, boolean correct) {
        this.id = id;
        this.quizId = quizId;
        this.optionText = optionText;
        this.correct = correct;
    }

    // Getters/setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getQuizId() { return quizId; }
    public void setQuizId(Integer quizId) { this.quizId = quizId; }

    public String getOptionText() { return optionText; }
    public void setOptionText(String optionText) { this.optionText = optionText; }

    public boolean isCorrect() { return correct; }
    public void setCorrect(boolean correct) { this.correct = correct; }
}
