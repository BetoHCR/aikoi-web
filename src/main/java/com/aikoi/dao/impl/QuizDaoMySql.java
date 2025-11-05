package com.aikoi.dao.impl;

import com.aikoi.dao.QuizDao;
import com.aikoi.model.Quiz;
import com.aikoi.model.QuizOption;
import com.aikoi.util.DB;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class QuizDaoMySql implements QuizDao {

    @Override
    public int createQuiz(Quiz quiz) {
        final String sql = "INSERT INTO quiz (title, description, created_by) VALUES (?, ?, ?)";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, quiz.getTitle());
            ps.setString(2, quiz.getDescription());
            ps.setString(3, quiz.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
            return 0;
        } catch (Exception e) {
            throw new RuntimeException("createQuiz error: " + e.getMessage(), e);
        }
    }

    @Override
    public void addOption(QuizOption option) {
        final String sql = "INSERT INTO quiz_option (quiz_id, option_text, is_correct) VALUES (?, ?, ?)";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, option.getQuizId());
            ps.setString(2, option.getOptionText());
            ps.setBoolean(3, option.isCorrect());
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException("addOption error: " + e.getMessage(), e);
        }
    }

    @Override
    public Optional<Quiz> findById(int id, boolean withOptions) {
        final String q = "SELECT id, title, description, created_by, created_at FROM quiz WHERE id = ?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(q)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return Optional.empty();
                Quiz quiz = new Quiz(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getString("created_by"),
                    rs.getString("created_at")
                );
                if (withOptions) {
                    quiz.setOptions(loadOptions(cn, id));
                }
                return Optional.of(quiz);
            }
        } catch (Exception e) {
            throw new RuntimeException("findById error: " + e.getMessage(), e);
        }
    }

    private List<QuizOption> loadOptions(Connection cn, int quizId) {
        final String q = "SELECT id, quiz_id, option_text, is_correct FROM quiz_option WHERE quiz_id = ? ORDER BY id ASC";
        List<QuizOption> list = new ArrayList<>();
        try (PreparedStatement ps = cn.prepareStatement(q)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new QuizOption(
                        rs.getInt("id"),
                        rs.getInt("quiz_id"),
                        rs.getString("option_text"),
                        rs.getBoolean("is_correct")
                    ));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("loadOptions error: " + e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Quiz> listAll(int limit, int offset) {
        final String q = """
            SELECT id, title, description, created_by, created_at
            FROM quiz
            ORDER BY created_at DESC, id DESC
            LIMIT ? OFFSET ?
        """;
        List<Quiz> list = new ArrayList<>();
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(q)) {
            ps.setInt(1, Math.max(1, limit));
            ps.setInt(2, Math.max(0, offset));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Quiz(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getString("created_by"),
                        rs.getString("created_at")
                    ));
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("listAll error: " + e.getMessage(), e);
        }
        return list;
    }

    @Override
    public int countAll() {
        final String q = "SELECT COUNT(*) FROM quiz";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(q);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
            return 0;
        } catch (Exception e) {
            throw new RuntimeException("countAll error: " + e.getMessage(), e);
        }
    }

    @Override
    public void deleteQuiz(int id) {
        final String q = "DELETE FROM quiz WHERE id = ?";
        try (Connection cn = DB.getConnection();
             PreparedStatement ps = cn.prepareStatement(q)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            throw new RuntimeException("deleteQuiz error: " + e.getMessage(), e);
        }
    }
}
