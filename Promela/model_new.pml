
typedef Msg {
    mtype msg;
    byte task_id, capability_id, capability_name, task_settings, input_parameters;
  }

mtype = {READY, RUNNING, COMPLETE, ERROR, PAUSED, CANCELED};



mtype = {
    Message_REJECT_TASK,
    Message_LOAD_TASK,
    Message_CANCEL_TASK,
    Message_CAPABILITY_COMPLETE,
    Message_CAPABILITY_INPUT,
    Message_CAPABILITY_OUTPUT,
    Message_CLIENT_REPLAN,
    Message_HELO_CLIENT,
    Message_PAUSE_TASK_COMPLETE,
    Message_PAUSE_LIST,
    Message_PAUSE_TASK,
    Message_RESUME_TASK_COMPLETE,
    Message_RESUME_TASK,
    Message_START_CAPABILITY,
    Message_SYSTEM_REPLAN,
    Message_TASK_COMPLETE,
    Message_TASK_READY,
    Message_CAPABILITY_STATUS,
    Message_TERMINATE_CAPABILITY
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
    :: M.msg == Message_TASK_READY -> printf("Task Ready Message\n");
    :: M.msg == Message_HELO_CLIENT -> {
        printf("Helo Client Message\n");

        //Send Message_START_CAPABILITY to Capability
        Msg M1; M1.msg = Message_START_CAPABILITY; M1.task_id = M.task_id
        run SendMessage(CAPABILITY, M1);

        //Send Message_CAPABILITY_INPUT to Capability
        Msg M2; M2.msg = Message_CAPABILITY_INPUT; M2.task_id = M.task_id
        run SendMessage(CAPABILITY, M2);
      }
    :: M.msg == Message_CAPABILITY_OUTPUT -> printf("Capability Output Message\n");
    :: M.msg == Message_CAPABILITY_COMPLETE -> printf("Capability Complete Message\n");
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
      :: M.msg == Message_LOAD_TASK -> printf("Load Task Message\n");
      fi
       // Send Ready to Task Client
      Msg M1; M1.msg = Message_TASK_READY; M1.task_id = M.task_id
      run SendMessage(TASK_CLIENT, M1);

       // Send Helo Client to Task Client
      Msg M2; M2.msg = Message_HELO_CLIENT; M2.task_id = M.task_id
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
      :: M.msg == Message_START_CAPABILITY -> printf("Start Capability Message\n");
      :: M.msg == Message_CAPABILITY_INPUT -> {
        printf("Capability Input Message\n");

        // Send Message_CAPABILITY_OUTPUT to Task Client
        Msg M1; M1.msg = Message_CAPABILITY_OUTPUT; M1.task_id = M.task_id
        run SendMessage(TASK_CLIENT, M1);

        // Send Message_CAPABILITY_COMPLETE to Task Client
        Msg M2; M2.msg = Message_CAPABILITY_COMPLETE; M2.task_id = M.task_id
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
  M.msg = Message_LOAD_TASK;
  M.task_id = 1
  run SendMessage(TASK_MANAGER, M);
}