// master-main.pde

#include "master-PJON.pde"
#include "master-header.pde"
#include "master-data-structures.pde"
#include "master-helper-func.pde"
#include "master-boot-sequence.pde"


void setup() {

	Serial.begin(115200);

	// Initialize PJON bus
	bus.begin();

	// generate random 32-bit UID
	randomSeed(getSeed());
	big_UID = random();

	// function that define actions to be taken
	// when a command is received from slaves
	bus.set_receiver(bus_receiver);
	bus.set_error(error_handler);

	// set address on the bus
	bus.set_id(MASTER); // set master address

	// start the boot sequence
	bootSequence();

}


void loop() {

	bus.receive();
	bus.update();

}
