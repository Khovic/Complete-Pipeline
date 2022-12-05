package com.example;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import javax.annotation.PostConstruct;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

@SpringBootApplication
public class Application {

    private final Connection dbConnection;

    public Application(Connection dbConnection) {
        this.dbConnection = dbConnection;
    }

    public static void main(String[] args)
    {
        SpringApplication.run(Application.class, args);
    }

    @PostConstruct
    public void init()
    {
        Logger log = LoggerFactory.getLogger(Application.class);
        log.info("Java app started");

        try {
            Statement stmt = dbConnection.createStatement();
            createTable(stmt);
            generateData(stmt);
            stmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    private void createTable(Statement stmt) throws SQLException {
        String sqlStatement = "CREATE TABLE IF NOT EXISTS team_members(" +
                "member_id INT AUTO_INCREMENT PRIMARY KEY,\n" +
                "member_name VARCHAR(255),\n" +
                "member_role VARCHAR(255),\n" +
                "member_projects VARCHAR(255)" +
                ")";
        stmt.executeUpdate(sqlStatement);
    }

    private void generateData(Statement stmt) throws SQLException {
        String sqlQuery = "SELECT member_name, member_role FROM team_members";
        ResultSet resultSet = stmt.executeQuery(sqlQuery);
        if (!resultSet.next()) {
            String sqlStatement = "INSERT INTO team_members(member_name, member_role)\n" +
                    "VALUES ('Sarah', 'Full stack developer'),\n" +
                    "('Bobby', 'React developer'),\n" +
                    "('Ari', 'Java developer'),\n" +
                    "('Andrea', 'DevOps engineer'),\n" +
                    "('Bruno', 'IT operations')";
            stmt.executeUpdate(sqlStatement);
        }
    }

    public String getStatus() {
        return "OK";
    }
}
