/**
 *
 * This is model of Gizmo
 * Created by Team E
 *
**/


mtype = {
    Message_TASK_READY,
    Message_HELO_CLIENT,
    Message_CAPABILITY_COMPLETE,
    Message_PAUSE_TASK_COMPLETE,
    Message_PAUSE_LIST,
    Message_PAUSE_TASK,
    Message_RESUME_TASK_COMPLETE,
    Message_TASK_COMPLETE,
    Message_CAPABILITY_OUTPUT,
    Message_CANCEL_TASK,
    Message_SYSTEM_REPLAN,
    Message_REJECT_TASK
}

chan qname = [16] of { short };

init {
    printf("Program is started... PID = %d\n",_pid)
    run taskManager();

    run taskClient();
}

proctype taskManager() {
    printf("Starting TaskManager. PID = %d \n",_pid);

    qname ! 16;
}


proctype taskClient() {
    printf("Starting TaskClient. PID = %d \n",_pid);

    short msg;

    qname ? msg;

    printf("start b\n %d\n", msg)

}