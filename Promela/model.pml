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

chan qname = [16] of { mtype, short };

init {
    printf("Program is started... PID = %d\n",_pid)
    run taskManager();

    run taskClient();
}

proctype taskManager() {
    printf("Starting TaskManager. PID = %d \n",_pid);

    mtype v;
    short m;

    qname ? v,m;

    printf("%d\n",m);
}


proctype taskClient() {
    printf("Starting TaskClient. PID = %d \n",_pid);


    short msg = 16;

    qname ! Message_TASK_READY , msg;



}