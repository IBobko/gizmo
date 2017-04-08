package ru.todo100;

import edu.cmu.gizmo.management.taskclient.TaskClient;
import edu.cmu.gizmo.management.taskmanager.TaskManager;

/**
 * @author Igor Bobko <limit-speed@yandex.ru>.
 */
public class App {

    public static void main(String[] args) throws Exception {
        TaskClient taskClient = new TaskClient();
        TaskManager taskManager = new TaskManager();
        taskClient.loadDashboard();
    }
}
