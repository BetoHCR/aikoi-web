package com.aikoi.dao;

import com.aikoi.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MeetingDAO {

    public static class Meeting {
        private int id;
        private String meetingCode;
        private String meetingName;
        private String hostEmail;
        private Timestamp createdAt;

        // getters y setters
        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public String getMeetingCode() { return meetingCode; }
        public void setMeetingCode(String meetingCode) { this.meetingCode = meetingCode; }

        public String getMeetingName() { return meetingName; }
        public void setMeetingName(String meetingName) { this.meetingName = meetingName; }

        public String getHostEmail() { return hostEmail; }
        public void setHostEmail(String hostEmail) { this.hostEmail = hostEmail; }

        public Timestamp getCreatedAt() { return createdAt; }
        public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    }

    // insertar reunión
    public static boolean createMeeting(String meetingCode, String meetingName, String hostEmail) throws Exception {
        String sql = "INSERT INTO meetings (meeting_code, meeting_name, host_email) VALUES (?,?,?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, meetingCode);
            ps.setString(2, meetingName);
            ps.setString(3, hostEmail);

            return ps.executeUpdate() > 0;
        }
    }

    // listar reuniones por email
    public static List<Meeting> listMeetingsByHost(String hostEmail) throws Exception {
        List<Meeting> list = new ArrayList<>();

        String sql = "SELECT id, meeting_code, meeting_name, host_email, created_at " +
                     "FROM meetings WHERE host_email = ? ORDER BY created_at DESC LIMIT 20";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, hostEmail);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Meeting m = new Meeting();
                m.setId(rs.getInt("id"));
                m.setMeetingCode(rs.getString("meeting_code"));
                m.setMeetingName(rs.getString("meeting_name"));
                m.setHostEmail(rs.getString("host_email"));
                m.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(m);
            }
        }
        return list;
    }
}
