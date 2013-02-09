#include <iostream>
#include <pthread.h>
using namespace std;

int sum = 0;
int mutex = 0;
const int threads_count = 1000;

int cas (int *mutex){
	int param;
	asm volatile("pusha");
	asm volatile(
			"lock cmpxchg %1,%2"
			: "=a" (param)
			: "r" (1),  "m" (*mutex), "0" (0)
			: "memory", "cc"
		);		
	asm volatile("popa");
	return param;
}

void unlock(int *m){
	*m = 0;
}
/*

*/
void *Func_thread_lock(void *arg){ 
	int i = 0;
	while(i < 999){
		//int flag = cas(&mutex); 	//@
		//if(!flag){				//@
			++i;
			++sum;
		//	unlock(&mutex);			//@
		//}							//@
	}
}

void *Func_thread_unlock(void *arg){ 
	int i = 0;
	while(i < 999){
		//int flag = cas(&mutex); 	//@
		//if(!flag){				//@
			++i;
			--sum;
		//	unlock(&mutex);			//@
		//}							//@
	}
}

int main(){
	pthread_t threads_mas[threads_count];	
	for(int i=0; i < threads_count; ++i){
			int threads_err = pthread_create(&threads_mas[i], NULL, Func_thread_lock, NULL);
			if (threads_err){
				cout << "Can't create a thread number"<<i<<endl<<"Error"<<threads_err<<endl;
				return 0;
			}
		}
	for (int i = 0; i < threads_count; ++i){
		int threads_err = pthread_join(threads_mas[i], NULL);
		if (threads_err){
			cout << "Can't join thread number"<<i<<endl<<"Error"<<threads_err<<endl;
			return 0;
		}
	}
	
	for(int i=0; i < threads_count; ++i){
			int threads_err = pthread_create(&threads_mas[i], NULL, Func_thread_unlock, NULL);
			if (threads_err){
				cout << "Can't create a thread number"<<i<<endl<<"Error"<<threads_err<<endl;
				return 0;
			}
		}
	for (int i = 0; i < threads_count; ++i){
		int threads_err = pthread_join(threads_mas[i], NULL);
		if (threads_err){
			cout << "Can't join thread number"<<i<<endl<<"Error"<<threads_err<<endl;
			return 0;
		}
	}
	
	cout<<"Result: "<<sum<<endl;
	return 0;
}