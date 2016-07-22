// master-main.pde

#include "master-header.pde"
#include "master-helper-func.pde"
#include "master-boot-sequence.pde"
#include "master-data-structures.pde"
#include "master-PJON.pde"



void setup() {

	pinMode(activityLED, OUTPUT);

	Serial.begin(115200); 

	// generate random 32-bit UID
	randomSeed(getSeed());
	big_UID = random();

	// initialize PJON bus
	bus.set_pin(A3);
	bus.begin();

	com_0.set_pin(A1);
	com_90.set_pin(A0);
	com_180.set_pin(7);
	com_270.set_pin(8);

	// function that define actions to be taken
	// when a command is received from slaves
	bus.set_receiver(bus_receiver);
	bus.set_error(error_handler);

	bus.set_id(MASTER); // set address on the bus

	// start the boot sequence
	bootSequence();

}


void loop() {

	bus.receive();
	bus.update();

}
