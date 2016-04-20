// slave-main.pde

#include "slave-header.pde"
#include "slave-helper-func.pde"
#include "slave-PJON.pde"


void setup() {

	Serial.begin(115200);

	// generate random 32-bit UID
	randomSeed(getSeed());
	big_UID = random();

	// functions that define actions to be taken
	// when a command is received from neighbours
	com_0.set_receiver(receiver_0);
	com_90.set_receiver(receiver_90);
	com_180.set_receiver(receiver_180);
	com_270.set_receiver(receiver_270);

	// when a command is received from master
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

	// random address between 2 and maxdev
	rand_address = random(2,maxdev);
	// rand_address = 5;
	bus.set_id(rand_address); // set address on the bus

	// start the boot sequence
	bootSequence();

}

// when boot sequence is finished, default behaviour 
// is set to listening for commands from master
void loop() {

	bus.receive();

}
