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

	// function that define actions to be taken
	// when a command is received from slaves
	bus.set_receiver(bus_receiver);
	bus.set_error(error_handler);

	// // generate a UID address using the Entropy.h library
	// Entropy.initialize();
	// big_UID = Entropy.random(0,UINT32_MAX);
	// uint32_t delay_time = millis();
	// delay(750-delay_time);

	// pack big_UID into 8-bit UID[]
	UID[0] = big_UID >> 24;
	UID[1] = big_UID >> 16;
	UID[2] = big_UID >> 8;
	UID[3] = big_UID;

	// set address on the bus
	bus.set_id(MASTER); // set master address

	// start the boot sequence
	bootSequence();

}


void loop() {

	bus.receive();
	bus.update();

}
