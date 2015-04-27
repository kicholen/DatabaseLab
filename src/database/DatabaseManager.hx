package src.database;

import sys.db.Connection;
import sys.db.Mysql;

/**
 * ...
 * @author zelek
 */
class DatabaseManager
{
	private static var _instance:DatabaseManager;
	private var _connection:Connection;
	
	
	public static inline function getInstance():DatabaseManager {
		if (_instance == null) {
			return _instance = new DatabaseManager();
		}
		else {
			return _instance;
		}
	}
	
	public function new() {
		
	}
	
	public function init():Void {
		_connection = Mysql.connect({ 
            host : DatabaseConfig.host,
            port : DatabaseConfig.port,
            user : DatabaseConfig.user,
            pass : DatabaseConfig.pass,
            socket : DatabaseConfig.socket,
            database : DatabaseConfig.database
        });
		
		createTables();
		setBasics();
	}
	
	public function addUser(firstName:String, secondName:String, email:String, nick:String, password:String, avatar:String):Void {
		executeQuery("INSERT INTO Users (FirstName, LastName, Email, Nickname, Password, AvatarFileName, JoinedTime) VALUES ('" + firstName + "', '" + secondName + "', '" + email + "', '" + nick + "', '" + password + "', '" + avatar + "', '" + Date.now() + "')");
	}
	
	public function addProject(name:String, startTime:Date, endTime:Date):Void {
		executeQuery("INSERT INTO Projects (Name, StartTime, EndTime) VALUES ('" + name + "', '" + startTime + "', '" + endTime + "')");
	}
	
	public function addTask(projectId:Int, name:String, description:String, createdBy:Int, estimateTimeInHours:Int, assignee:Int = -1):Void {
		executeQuery("INSERT INTO Tasks (ProjectId, Name, Description, CreatedBy, Estimate, CurrentAssigneeId) VALUES ('" + projectId + "', '" + name + "', '" + description + "', '" + createdBy + "', '" + estimateTimeInHours + "', '" + assignee + "')");
	}
	
	public function addSubTask(projectId:Int, name:String, description:String, createdBy:Int, estimateTimeInHours:Int, parentId:Int, assignee:Int = -1):Void {
		executeQuery("INSERT INTO Tasks (ProjectId, Name, Description, CreatedBy, Estimate, ParentId, CurrentAssigneeId) VALUES ('" + projectId + "', '" + name + "', '" + description + "', '" + createdBy + "', '" + estimateTimeInHours + "', '" + parentId + "', '" + assignee + "')");
	}
	
	public function addTimeSpent(userId:Int, taskId:Int, hoursSpent:Int, time:Date, comment:String):Void {
		executeQuery("INSERT INTO SpentTimes (UserId, TaskId, HoursSpent, Time, Comment) VALUES ('" + userId + "', '" + taskId + "', '" + hoursSpent + "', '" + time + "', '" + comment + "')");
	}
	
	public function addLoginTime(userId:Int, IP:String, loginTime:Date = null):Void {
		if (loginTime == null) {
			executeQuery("INSERT INTO LoginTimes (UserId, IP) VALUES ('" + userId + "', '" + IP + "')");
		}
		else {
			executeQuery("INSERT INTO LoginTimes (UserId, LoginTime, IP) VALUES ('" + userId + "', '" + IP + "', '" + loginTime + "')");
		}
	}
	
	public function addComment(taskId:Int, userId:Int, text:String, createdTime:Date = null):Void {
		if (createdTime == null) {
			executeQuery("INSERT INTO Comments (TaskId, UserId, Text) VALUES ('" + taskId + "', '" + userId + "', '" + text+ "')");
		}
		else {
			executeQuery("INSERT INTO Comments (TaskId, UserId, Text, CreatedTime) VALUES ('" + taskId + "', '" + userId + "', '" + text + "', '" + createdTime + "')");
		}
	}
	
	public function checkIfKeyExists(tableName:String, keyName:String, keyValue:String):Bool {
		var result = executeQuery("SELECT * FROM " + tableName + " WHERE " + keyName + "='" + keyValue + "'");
		
		return result.length > 0;
	}
	
	/*
	// modify task by id
	// , ClosedBy
	// , CurrentAssigneeId
	// , ClosedTime
	public function modifyTaskById(closedBy:Int, assignee:Int, closedTimes:Date, id:Int):Void {
		executeQuery("UPDATE Tasks SET field1=new-value1, field2=new-value2 WHERE taskId = " + taskId);
	}
	*/
	
	public function executeQuery(text:String) {
		return _connection.request(text);
	}
	
	private function createTables():Void {
		try {
			_connection.startTransaction();
			executeQuery("CREATE TABLE IF NOT EXISTS Projects (Id integer NOT NULL AUTO_INCREMENT PRIMARY KEY, Name varchar(50) NOT NULL, StartTime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, EndTime datetime NOT NULL)");
			executeQuery("CREATE TABLE IF NOT EXISTS Users (Id integer NOT NULL AUTO_INCREMENT PRIMARY KEY, FirstName varchar(50) NOT NULL, LastName varchar(50) NOT NULL, Email varchar(70) NOT NULL, Nickname varchar(30) NOT NULL, Password varchar(32) NOT NULL, AvatarFileName varchar(30) NOT NULL, JoinedTime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP)");
			executeQuery("CREATE TABLE IF NOT EXISTS UserProjects (UserId integer NOT NULL, ProjectId integer NOT NULL, FOREIGN KEY (ProjectId) REFERENCES Projects (Id), FOREIGN KEY (UserId) REFERENCES Users (Id))");
			executeQuery("CREATE TABLE IF NOT EXISTS TaskState (Id integer NOT NULL PRIMARY KEY, Description text NOT NULL)");
			executeQuery("CREATE TABLE IF NOT EXISTS Tasks (Id integer NOT NULL AUTO_INCREMENT PRIMARY KEY, ProjectId integer NOT NULL, Name varchar(128) NOT NULL, ParentId integer, Description text NOT NULL, CreatedBy integer NOT NULL, ClosedBy integer, CurrentAssigneeId integer, CreatedTime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, ClosedTime datetime, Estimate integer NOT NULL, State integer NOT NULL DEFAULT 1, FOREIGN KEY (ProjectId) REFERENCES Projects (Id), FOREIGN KEY (CurrentAssigneeId) REFERENCES Users (Id), FOREIGN KEY (CreatedBy) REFERENCES Users (Id), FOREIGN KEY (ClosedBy) REFERENCES Users (Id), FOREIGN KEY (ParentId) REFERENCES Tasks (Id), FOREIGN KEY (State) REFERENCES TaskState (Id))");
			executeQuery("CREATE TABLE IF NOT EXISTS SpentTimes (UserId integer NOT NULL, TaskId integer NOT NULL, HoursSpent integer NOT NULL, Time datetime NOT NULL, Comment text NOT NULL, FOREIGN KEY (UserId) REFERENCES Users (Id), FOREIGN KEY (TaskId) REFERENCES Tasks (Id))");
			executeQuery("CREATE TABLE IF NOT EXISTS Comments (Id integer NOT NULL AUTO_INCREMENT PRIMARY KEY, TaskId integer NOT NULL, UserId integer NOT NULL, Text text NOT NULL, CreatedTime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (TaskId) REFERENCES Tasks (Id), FOREIGN KEY (UserId) REFERENCES Users (Id));");
			executeQuery("CREATE TABLE IF NOT EXISTS LoginTimes (UserId integer NOT NULL, LoginTime datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, IP varchar(15) NOT NULL, FOREIGN KEY (UserId) REFERENCES Users (Id))");
			_connection.commit();
		}
		catch (e:Dynamic) {
			_connection.rollback();
		}
	}
	
	private function setBasics():Void {
		executeQuery("INSERT IGNORE INTO TaskState (Id, Description) VALUES ('1', 'Started')");
		executeQuery("INSERT IGNORE INTO TaskState (Id, Description) VALUES ('2', 'In Progress')");
		executeQuery("INSERT IGNORE INTO TaskState (Id, Description) VALUES ('3', 'Finished')");
	}
	
}