#include <iostream>
#include <wiringPi.h>

using namespace std;

int main(int argc, char **argv)
{
	wiringPiSetup () ;
	cout << "Ready to start development";
}
