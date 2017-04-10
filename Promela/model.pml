/**
 *
 * This is model of Gizmo
 * Created by Team E
 *
**/

typedef MESSAGE {
    mtype msg;
    mtype type;
    byte task_id,
    capability_id
}

mtype = {SEQUENCE, PARALLEL};

int last_task_id = 1;
int last_capability_id = 1;


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

#define LENGTH  20  /* length of message queue chanel */

mtype = {TASK_CLIENT, TASK_MANAGER, CAPABILITY};

mtype = {
    CAPABILITY_INIT_STATUS,
    CAPABILITY_LOADED_STATUS,
    CAPABILITY_COMPLETE_STATUS,
    CAPABILITY_RUNNING_STATUS,
    CAPABILITY_PAUSED_STATUS,
    CAPABILITY_CANCELED_STATUS,
    CAPABILITY_ERROR_STATUS
};

chan MessageBroker = [LENGTH] of {mtype, MESSAGE};

init {
  printf ("Application is started.\n");
  run TaskManager();
  run Capability();
  run TaskClient();

  //run SendInitMessage(SEQUENCE);
  run SendInitMessage(PARALLEL);
}

proctype SendInitMessage(mtype type) {
    atomic {
        MESSAGE message;
        message.msg = Message_LOAD_TASK;
        message.type = type;
        run SendMessage(TASK_MANAGER, message);
    }
}

proctype TaskExecutor(MESSAGE message) {
    run ScriptTaskStrategy(message)
}


proctype ScriptTaskStrategy(MESSAGE message) {
    run SetStatusCapability(message,CAPABILITY_LOADED_STATUS);
}

proctype SetStatusCapability(MESSAGE message; mtype status) {
    printf("Set status of capability: %e",status)
    if
    :: status == CAPABILITY_LOADED_STATUS -> {
        // Send Helo Client to Task Client
        MESSAGE helo_client_message;
        helo_client_message.msg = Message_HELO_CLIENT;
        helo_client_message.task_id = message.task_id;
        helo_client_message.type = message.type;
        run SendMessage(TASK_CLIENT, helo_client_message);
    }
    :: status == CAPABILITY_COMPLETE_STATUS -> {
        // Send CapabilityCompleteMessage to Task Client
        MESSAGE capability_complete_message;
        capability_complete_message.msg = Message_CAPABILITY_COMPLETE;
        capability_complete_message.task_id = message.task_id
        capability_complete_message.capability_id = message.capability_id
        run SendMessage(TASK_CLIENT, capability_complete_message);
    }
    fi

}


proctype TaskClient()
{
  printf("Task client is started.\n");
  MESSAGE message;
  do
  :: MessageBroker ? TASK_CLIENT, message -> {

    printf("TASK_CLIENT received \"%e\" with task_id = %d, capability_id = %d \n", message.msg, message.task_id, message.capability_id);
    if
    :: message.msg == Message_TASK_READY -> {
            int f = 0; // NEED CHANGE
        };
    :: message.msg == Message_HELO_CLIENT -> {
        if
        :: message.type == PARALLEL -> {

              last_capability_id++;
              //Send Message_START_CAPABILITY to Capability

              MESSAGE capability_message1;
              capability_message1.msg = Message_START_CAPABILITY;
              capability_message1.task_id = message.task_id;

              capability_message1.capability_id = last_capability_id;
              run SendMessage(CAPABILITY, capability_message1);

              //Send CapabilityInputMessage to Capability
              MESSAGE capability_message2;
              capability_message2.msg = Message_CAPABILITY_INPUT;
              capability_message2.task_id = message.task_id
              capability_message2.capability_id=last_capability_id;
              run SendMessage(CAPABILITY, capability_message2);

              last_capability_id++;

              capability_message1.capability_id = last_capability_id;
              run SendMessage(CAPABILITY, capability_message1);

              capability_message2.capability_id=last_capability_id;
              run SendMessage(CAPABILITY, capability_message2);

            }
        :: message.type == SEQUENCE -> {
              last_capability_id++;
              //Send Message_START_CAPABILITY to Capability

              MESSAGE capability_message1;
              capability_message1.msg = Message_START_CAPABILITY;
              capability_message1.task_id = message.task_id

              capability_message1.capability_id = last_capability_id;
              run SendMessage(CAPABILITY, capability_message1);


              //Send CapabilityInputMessage to Capability
              MESSAGE capability_message2;
              capability_message2.msg = Message_CAPABILITY_INPUT;
              capability_message2.task_id = message.task_id
              capability_message2.capability_id=last_capability_id;
              run SendMessage(CAPABILITY, capability_message2);

              MESSAGE message_from_capability;

              MessageBroker ? TASK_CLIENT,message_from_capability-> {
                printf("%e WORK1",message_from_capability.msg);
                MessageBroker ? TASK_CLIENT,message_from_capability -> {
                    printf("%e WORK2",message_from_capability.msg);
                }
              }

        }
        fi
      }
    :: message.msg == Message_CAPABILITY_OUTPUT -> {
        int a = 10;
    }
    :: message.msg == Message_CAPABILITY_COMPLETE -> {
        int a = 10;
    }
    fi
  }
  od
}

proctype TaskManager()
{
    printf("Task manager is started.\n");
    MESSAGE message;
    do
    :: MessageBroker ? TASK_MANAGER, message -> {
        printf("Task Manager received %e \n\n", message.msg);

        // Send Ready to Task Client
        MESSAGE task_ready_message;
        task_ready_message.msg = Message_TASK_READY;
        task_ready_message.task_id = last_task_id;
        task_ready_message.type = message.type;
        run SendMessage(TASK_CLIENT, task_ready_message);

        //Transferring of managing to TaskExecutor
        run TaskExecutor(message);
        last_task_id = last_task_id + 1;
    }
    od
}

proctype Capability()
{
  MESSAGE message;
  do
  :: MessageBroker ? CAPABILITY, message -> {
      printf("Capability received \"%e\" with task_id = %d, capability_id = %d \n", message.msg, message.task_id, message.capability_id);
      if
      :: message.msg == Message_START_CAPABILITY -> {
        {
            int a = 10;


        };
      }
      :: message.msg == Message_CAPABILITY_INPUT -> {

        // Send CapabilityOutputMessage to Task Client
        MESSAGE capability_output_message;
        capability_output_message.msg = Message_CAPABILITY_OUTPUT;
        capability_output_message.task_id = message.task_id
        capability_output_message.capability_id = message.capability_id
        run SendMessage(TASK_CLIENT, capability_output_message);


        run SetStatusCapability(message,CAPABILITY_COMPLETE_STATUS);
      }
      fi
    }
  od
}


proctype SendMessage(mtype recipient; MESSAGE message) {
  atomic {
    printf("\nSending message \"%e\" taskid = %d, capability_id = %d to \"%e\"\n\n", message.msg, message.task_id, message.capability_id, recipient)
    MessageBroker ! recipient, message
  }
}