// slave-main.pde

#include "slave-header.pde"
#include "slave-helper-func.pde"
#include "slave-PJON.pde"


void setup() {

	Serial.begin(115200);

	// generate random 32-bit UID
	randomSeed(getSeed());
	big_UID = random();

	// initialize PJON bus
	bus.set_pin(2);
	bus.begin();

	com_0.set_pin(A0);
	com_90.set_pin(A1);
	com_180.set_pin(7);
	com_270.set_pin(8);

	// functions that define actions to be taken
	// when a command is received from neighbours
	com_0.set_receiver(receiver_0);
	com_90.set_receiver(receiver_90);
	com_180.set_receiver(receiver_180);
	com_270.set_receiver(receiver_270);

	// when a command is received from master
	bus.set_receiver(bus_receiver);
	bus.set_error(error_handler);

	// random address between 6 and maxdev
	// rand_address = random(6,maxdev);
	rand_address = 45;
	bus.set_id(rand_address); // set address on the bus

	// start the boot sequence
	bootSequence();

}

// when boot sequence is finished, default behaviour 
// is set to listening for commands from master
void loop() {

	bus.receive();

}
