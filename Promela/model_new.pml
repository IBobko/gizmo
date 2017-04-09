
typedef Msg {
    mtype msg;
    byte task_id, capability_id, capability_name, task_settings, input_parameters;
  }

mtype = {READY, RUNNING, COMPLETE, ERROR, PAUSED, CANCELED};

mtype = {
RejectTaskMessage,
LoadTaskMessage,
CancelTaskMessage,
CapabilityCompleteMessage,
CapabilityInputMessage,
CapabilityOutputMessage,
ClientReplanMessage,
HeloClientMessage,
PauseCompleteMessage,
PausedTasksListMessage,
PauseTaskMessage,
ResumeTaskCompleteMessage,
ResumeTaskMessage,
StartCapabilityMessage,
SystemReplanMessage,
TaskCompleteMessage,
TaskMessageHandler,
TaskMessage,
TaskReadyMessage
};

#define LEN  10               /* length of message queue */

mtype = {TASK_CLIENT, TASK_MANAGER, CAPABILITY};

chan Channel = [LEN] of {mtype, Msg};

int i = 1;

proctype TaskClient()
{
  Msg M;
  do
  :: Channel ? TASK_CLIENT, M -> {
    printf("Task Client received [%d] -", M.msg);
    if
    :: M.msg == TaskReadyMessage -> printf("Task Ready Message\n");
    :: M.msg == HeloClientMessage -> {
        printf("Helo Client Message\n");

        //Send StartCapabilityMessage to Capability
        Msg M1; M1.msg = StartCapabilityMessage; M1.task_id = M.task_id
        run SendMessage(CAPABILITY, M1);

        //Send CapabilityInputMessage to Capability
        Msg M2; M2.msg = CapabilityInputMessage; M2.task_id = M.task_id
        run SendMessage(CAPABILITY, M2);
      }
    :: M.msg == CapabilityOutputMessage -> printf("Capability Output Message\n");
    :: M.msg == CapabilityCompleteMessage -> printf("Capability Complete Message\n");
    fi
  }
  od
}

proctype TaskManager()
{
  Msg M;
  do
  :: Channel ? TASK_MANAGER, M -> {
      printf("Task Manager received [%d] -", M.msg);
      if
      :: M.msg == LoadTaskMessage -> printf("Load Task Message\n");
      fi
       // Send Ready to Task Client
      Msg M1; M1.msg = TaskReadyMessage; M1.task_id = M.task_id
      run SendMessage(TASK_CLIENT, M1);

       // Send Helo Client to Task Client
      Msg M2; M2.msg = HeloClientMessage; M2.task_id = M.task_id
      run SendMessage(TASK_CLIENT, M2);
    }
  od
}

proctype Capability()
{
  Msg M;
  do
  :: Channel ? CAPABILITY, M -> {
      printf("Capability received [%d] -", M.msg);
      if
      :: M.msg == StartCapabilityMessage -> printf("Start Capability Message\n");
      :: M.msg == CapabilityInputMessage -> {
        printf("Capability Input Message\n");

        // Send CapabilityOutputMessage to Task Client
        Msg M1; M1.msg = CapabilityOutputMessage; M1.task_id = M.task_id
        run SendMessage(TASK_CLIENT, M1);

        // Send CapabilityCompleteMessage to Task Client
        Msg M2; M2.msg = CapabilityCompleteMessage; M2.task_id = M.task_id
        run SendMessage(TASK_CLIENT, M2);
      }
      fi
    }
  od
}



proctype SendMessage(mtype rcv; Msg M) {
  printf("Sending message [%d] to [%d]\n\n", M.msg, rcv)
  Channel ! rcv, M
}

init {
  printf ("init\n");

  run TaskClient();
  run TaskManager();
  run Capability();

  // Initial message
  Msg M;
  M.msg = LoadTaskMessage;
  M.task_id = 1
  run SendMessage(TASK_MANAGER, M);
}