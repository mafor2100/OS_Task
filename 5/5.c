#include <ucontext.h>
#include <sys/types.h>
#include <sys/time.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <poll.h>

const int NUMCONTEXTS = 8
const int STACKSIZE = 4096              
const int INTERVAL = 100

typedef struct{
	ucontext_t context;
	int isTerminated;
	int priority;
	time_t Time_to_wake_up;
	int sleeping_time;
} structure_context;

int isDebug = 0;
int index_context = -1;
int threads_live;
sigset_t set;                       
ucontext_t scheduler_context;
void *signal_stack;
structure_context contexts[NUMCONTEXTS];
ucontext_t * current_context;
struct itimerval it;

void sleeping_sheduler(int);

void scheduler(){
	sleeping_sheduler(0);
	while(threads_live != 0){
		time_t my_time = time(NULL);
		for (int k = 0 ; k < NUMCONTEXTS; ++k){
			if (contexts[k].isTerminated == 1)
				continue;
			if (my_time > contexts[k].Time_to_wake_up){
				index_context = k;
				current_context = &contexts[k].context;
				printf("thread is alive %d",k);
				sleeping_sheduler(1);
				setcontext(current_context);
			}
		}
		poll(NULL,0,50);
	}
}

void sleeping_sheduler(int sec){
	it.it_interval.tv_sec = sec;
	it.it_value.tv_sec = sec;
	if (setitimer(ITIMER_REAL , &it , NULL) < 0){printf("Timer has not been set"); exit(1);}
}

void timer_interrupt(int j, siginfo_t *si, void *old_context){
	printf("\npause thread %d for %d seconds \n",index_context,contexts[index_context].sleeping_time);
	contexts[index_context].context = *( ucontext_t *) old_context;
	sleeping_thread(contexts[index_context].sleeping_time,index_context); 
	swapcontext(current_context , &scheduler_context);
}

void init_scheduler_context(ucontext_t * signal_cont){
	getcontext(signal_cont);
	signal_cont->uc_stack.ss_sp = signal_stack;
	signal_cont->uc_stack.ss_size = STACKSIZE;
	signal_cont->uc_stack.ss_flags = 0;
	sigemptyset(&signal_cont->uc_sigmask);
	makecontext(signal_cont , scheduler , 0);
}

void setup_signals(void){
    struct sigaction action;
    action.sa_sigaction = timer_interrupt;
    int res = sigemptyset(&action.sa_mask);
    if (res < 0){printf("Error setup signals\n"); exit(1);}
	action.sa_flags = SA_RESTART | SA_SIGINFO;
	sigemptyset(&set);
	sigaddset(&set, SIGALRM);
	if(sigaction(SIGALRM, &action, NULL) != 0){printf("Error setup signals\n"); exit(1);}
}

void create_thread(ucontext_t *uc,  void *function){
    void * stack;
    getcontext(uc);
    stack = malloc(STACKSIZE);
    if (stack == NULL) {printf("Can't allocate memory\n"); exit(1);}
    uc->uc_stack.ss_sp = stack;
    uc->uc_stack.ss_size = STACKSIZE;
    uc->uc_stack.ss_flags = 0;
    uc->uc_link = &scheduler_context;
    if (sigemptyset(&uc->uc_sigmask) < 0){printf("Can't initialize the signal set\n"); exit(1);}
    makecontext(uc, function, 0 );
}

void sleeping_thread(int ms, int index){
	time_t wut = time(NULL);
	contexts[index].Time_to_wake_up = wut + ms;
}

void low_thread(){
	for(int j = 0; j < 15 ; ++j){
		printf(" %d ",j);
		poll(NULL,0,100);
    }
    contexts[index_context].isTerminated = 1;
	--threads_live;
	printf("\nThread %d is stopped\n",index_context);
}

void high_thread(){
	for(int j = 97; j < 122; ++j){
		printf(" %c ",j);
		poll(NULL,0,100);
	}
	contexts[index_context].isTerminated = 1;
	--threads_live;
	printf("\nThread %d is stopped\n",index_context);
}

int main(int argc , char* argv[]){
	threads_live = NUMCONTEXTS;
	for(int i =  0; i < NUMCONTEXTS/2; ++i){
		create_thread(&contexts[i].context,high_thread);
		contexts[i].isTerminated = 0;
		contexts[i].priority = 2;
		contexts[i].Time_to_wake_up = time(NULL);
		contexts[i].sleeping_time = 5;
	}
    for (int i = NUMCONTEXTS/2 ; i< NUMCONTEXTS ; ++i){
       	create_thread(&contexts[i].context, low_thread);
		contexts[i].isTerminated = 0;
		contexts[i].priority = 1;
		contexts[i].Time_to_wake_up = time(NULL);
		contexts[i].sleeping_time = 4; 
	}
	setup_signals();
	init_scheduler_context(&scheduler_context);
	current_context = &scheduler_context;
	setcontext(current_context);
	return 0;
}