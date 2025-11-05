package com.aikoi.dao;

import com.aikoi.model.Quiz;
import com.aikoi.model.QuizOption;

import java.util.List;
import java.util.Optional;

public interface QuizDao {
    int createQuiz(Quiz quiz);                    // devuelve id generado
    void addOption(QuizOption option);
    Optional<Quiz> findById(int id, boolean withOptions);
    List<Quiz> listAll(int limit, int offset);   // simple paginado
    int countAll();
    void deleteQuiz(int id);
}
