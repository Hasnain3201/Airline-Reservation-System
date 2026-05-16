package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ApplicationDB {
	
	public ApplicationDB(){
		
	}

	public Connection getConnection(){
		
		String connectionUrl = getEnvOrDefault("DB_URL", "jdbc:mysql://localhost:3306/cs336project?useSSL=false");
		String databaseUser = getEnvOrDefault("DB_USER", "root");
		String databasePassword = getEnvOrDefault("DB_PASSWORD", "");
		
		try {
			loadJdbcDriver();
			return DriverManager.getConnection(connectionUrl, databaseUser, databasePassword);
		} catch (ClassNotFoundException e) {
			throw new IllegalStateException("MySQL JDBC driver was not found. Add the connector JAR to WEB-INF/lib.", e);
		} catch (SQLException e) {
			throw new IllegalStateException("Could not connect to the airline reservation database.", e);
		}
		
	}

	private void loadJdbcDriver() throws ClassNotFoundException {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			Class.forName("com.mysql.jdbc.Driver");
		}
	}

	private String getEnvOrDefault(String key, String defaultValue) {
		String value = System.getenv(key);
		return value == null || value.trim().isEmpty() ? defaultValue : value;
	}
	
	public void closeConnection(Connection connection){
		if (connection == null) {
			return;
		}
		try {
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	
	
	
	
	public static void main(String[] args) {
		ApplicationDB dao = new ApplicationDB();
		Connection connection = dao.getConnection();
		
		System.out.println(connection);		
		dao.closeConnection(connection);
	}
	
	

}
