package;

import openfl.display.Sprite;
import openfl.Lib;
import src.database.DatabaseManager;

/**
 * ...
 * @author zelek
 */

class Main extends Sprite 
{

	public function new() {
		super();
		
		DatabaseManager.getInstance().init();
		
		feedTestData();
	}
	
	private function feedTestData():Void {
		addTestUser('Przemysław', 'Banasiak', 'przemekb93@o2.pl', 'Zapaven', 'password', 'avatar.png');
		addTestUser("Mateusz", "Debski", "asd@dmail.com", "asd", "lasjfkas", "asfasf.png");
		
		
		addProject("OgromnyProjekt", Date.now(), Date.fromTime(Date.now().getTime() + 3600 * 100));
		addProject("MalyProjekt", Date.fromTime(Date.now().getTime() + 3600 * 20), Date.fromTime(Date.now().getTime() + 3600 * 50));
		addProject("SredniProjekt", Date.now(), Date.fromTime(Date.now().getTime() + 3600 * 10));
		addProject("DziwnyProjekt", Date.fromTime(Date.now().getTime() + 3600 * 100), Date.fromTime(Date.now().getTime() + 3600 * 200));
		
		
		// add main task to first project
		DatabaseManager.getInstance().addTask(1, "Trudne Zadanie", "Utworzyc wstepny projekt GUI w Boostrapie, dolaczyc Javascriptowe skrypty niezbedne do generowanie wykresow, agile board i komentarzy", getUserIdByNickname("Zapaven"), 2222, getUserIdByNickname("Zapaven"));
		
		// add sub task
		DatabaseManager.getInstance().addSubTask(1, "Mniejsze Zadanie", 'Zrobic abc i def', getUserIdByNickname("Zapaven"), 11, 1, getUserIdByNickname("Zapaven"));
		
		// add time spent
		DatabaseManager.getInstance().addTimeSpent(getUserIdByNickname("Zapaven"), 1, 10, Date.now(), "Naprawiłem to i tamto");
		
		// add comment
		DatabaseManager.getInstance().addComment(1, getUserIdByNickname("asd"), "Nie zapomnij dodać tamtego");
		
		// add player log
		DatabaseManager.getInstance().addLoginTime(getUserIdByNickname("asd"), "1111.11.1.1.1.1");
	}
	
	private function getUserIdByNickname(nickname:String):Int {
		return DatabaseManager.getInstance().executeQuery("SELECT * FROM Users WHERE Nickname ='" + nickname + "'").getIntResult(0);
	}
	
	private function addProject(name:String, startTime:Date, endTime:Date):Void {
		if (!DatabaseManager.getInstance().checkIfKeyExists("Projects", "Name", name)) {
			DatabaseManager.getInstance().addProject(name, startTime, endTime);
		}
	}
	
	private function addTestUser(firstName:String, secondName:String, email:String, nick:String, password:String, avatar:String):Void {
		if (!DatabaseManager.getInstance().checkIfKeyExists("Users", "Nickname", nick)) {
			DatabaseManager.getInstance().addUser(firstName, secondName, email, nick, password, avatar);
		}
		else {
			trace("Nick already taken");
		}
	}
	
}
