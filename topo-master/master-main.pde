// master-main.pde

#include "master-PJON.pde"
#include "master-header.pde"
#include "master-data-structures.pde"
#include "master-helper-func.pde"
#include "master-boot-sequence.pde"


void setup() {

	Serial.begin(115200);

	// generate random 32-bit UID
	randomSeed(getSeed());
	big_UID = random();

	// Initialize PJON bus
	bus.set_pin(12);
	bus.begin();

	com_0.set_pin(7);
	com_90.set_pin(9);
	com_180.set_pin(8);
	com_270.set_pin(10);

	// function that define actions to be taken
	// when a command is received from slaves
	bus.set_receiver(bus_receiver);
	bus.set_error(error_handler);

	// start the boot sequence
	bootSequence();

}


void loop() {

	bus.receive();
	bus.update();

}
