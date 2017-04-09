/**
 *
 * This is model of Gizmo
 * Created by Team E
 *
**/

#define LENGTH  10 /* length of message queue */

mtype = {
    TASK_CLIENT,
    TASK_MANAGER,
    CAPABILITY
};


/*In this case we declare type for out message*/
typedef MessageType {
    mtype msg; /* This can be TASK_CLIENT, TASK_MANAGER or CAPABILITY */
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
    Message_HELLO_CLIENT,
    Message_PAUSE_COMPLETE,
    Message_PAUSE_LIST,
    Message_PAUSE_TASK,
    Message_RESUME_TASK_COMPLETE,
    Message_RESUME_TASK,
    Message_START_CAPABILITY,
    Message_SYSTEM_REPLAN,
    Message_TASK_COMPLETE,
    Message_TASK_READY
};


chan MessageBroker = [LENGTH] of {mtype, MessageType};

init {
    printf ("Application is started\n");
    run TaskClient();
    run TaskManager();
    run Capability();

    // Trying to start load task
    MessageType M;
    M.msg = Message_LOAD_TASK;
    M.task_id = 1
    run SendMessage(TASK_MANAGER, M);
}

proctype TaskClient()
{

  MessageType message;

  do
  :: MessageBroker ? TASK_CLIENT, message ->
  {
    printf("Task Client received [%d] -", message.msg);
    if
    :: message.msg == Message_TASK_READY -> printf("Task Ready Message\n");
    :: message.msg == Message_HELLO_CLIENT -> {
        printf("Helo Client Message\n");

        //Send Message_START_CAPABILITY to Capability
        MessageType M1; M1.msg = Message_START_CAPABILITY; M1.task_id = message.task_id
        run SendMessage(CAPABILITY, M1);

        //Send Message_CAPABILITY_INPUT to Capability
        MessageType M2; M2.msg = Message_CAPABILITY_INPUT; M2.task_id = message.task_id
        run SendMessage(CAPABILITY, M2);
      }
    :: message.msg == Message_CAPABILITY_OUTPUT -> printf("Capability Output Message\n");
    :: message.msg == Message_CAPABILITY_COMPLETE -> printf("Capability Complete Message\n");
    fi
  }
  od
}

proctype TaskManager()
{
  MessageType message;
  do
  :: MessageBroker ? TASK_MANAGER, message ->
    {
      printf("Task Manager received [%d] -", message.msg);
      if
      :: message.msg == Message_LOAD_TASK -> printf("Load Task Message\n");
      fi

      // Send Ready to Task Client
      MessageType M1;

      M1.msg = Message_TASK_READY;
      M1.task_id = message.task_id;

      run SendMessage(TASK_CLIENT, M1);

       // Send Helo Client to Task Client
      MessageType M2; M2.msg = Message_HELLO_CLIENT; M2.task_id = message.task_id
      run SendMessage(TASK_CLIENT, M2);
    }
  od
}

proctype Capability()
{
  MessageType M;
  do
  :: MessageBroker ? CAPABILITY, M -> {
      printf("Capability received [%d] -", M.msg);
      if
      :: M.msg == Message_START_CAPABILITY -> printf("Start Capability Message\n");
      :: M.msg == Message_CAPABILITY_INPUT -> {
        printf("Capability Input Message\n");

        // Send Message_CAPABILITY_OUTPUT to Task Client
        MessageType M1; M1.msg = Message_CAPABILITY_OUTPUT; M1.task_id = M.task_id
        run SendMessage(TASK_CLIENT, M1);

        // Send Message_CAPABILITY_COMPLETE to Task Client
        MessageType M2; M2.msg = Message_CAPABILITY_COMPLETE; M2.task_id = M.task_id
        run SendMessage(TASK_CLIENT, M2);
      }
      fi
    }
  od
}

/* This function sends message the concrete recipient.*/
proctype SendMessage(mtype recipient; MessageType message) {
  printf("Sending message [%d] to [%d]\n", message.msg, recipient)
  MessageBroker ! recipient, message
}
