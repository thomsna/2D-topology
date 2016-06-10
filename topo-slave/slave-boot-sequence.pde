// slave-boot-sequence.pde

#ifndef _SLAVE_BOOT_SEQUENCE_PDE_
#define _SLAVE_BOOT_SEQUENCE_PDE_

#include "slave-header.pde"


void bootSequence() {

	// pack big_UID into 8-bit UID[]
  UID[0] = big_UID >> 24;
  UID[1] = big_UID >> 16;
  UID[2] = big_UID >> 8;
  UID[3] = big_UID;

	// prepare packet to be sent to neighbour
	// first byte is the command ID
	// second byte is this device's address
	neighbour_msg[0] = 'W';
	neighbour_msg[1] = rand_address;
	neighbour_msg[2] = UID[0];
	neighbour_msg[3] = UID[1]; 
	neighbour_msg[4] = UID[2]; 
	neighbour_msg[5] = UID[3];

	delay(1500-millis());
	blink(1, 10);

	// waiting for neighbour to send its address
	// keep on listening if nothing has been received yet
	while (!neighbour_addr) {
		com_0.receive(1000);
		com_90.receive(1000);
		com_180.receive(1000);
		com_270.receive(1000);
	}

	uint32_t scan_time;

	for (uint8_t i = 0; i < 5; i++) {
		// send this address to neighbour
		scan_time = millis();
		while (millis() - scan_time < 100)
			com_0.update();

		scan_time = millis();
		while (millis() - scan_time < 100)
			com_90.update();

		scan_time = millis();
		while (millis() - scan_time < 100)
			com_180.update();

		scan_time = millis();
		while (millis() - scan_time < 100)
			com_270.update();
	}

	// prepare packet to master:
	// this address, the received neighbour's address, 
	// this UID, the neighbour's UID, the port the 
	// neighbour is seen on
	char edge[12];
	edge[0] = 'A';
	edge[1] = rand_address;
	edge[2] = neighbour_addr;
	edge[3] = UID[0];
	edge[4] = UID[1];
	edge[5] = UID[2];
	edge[6] = UID[3];
	edge[7] = neighbour_UID[0];
	edge[8] = neighbour_UID[1];
	edge[9] = neighbour_UID[2];
	edge[10] = neighbour_UID[3];
	edge[11] = this_port;

	// avoid collisions on the bus by setting random delay
	// further reduced by polynomial backoff
	randomSeed(getSeed());
	uint16_t send_delay = random();
	delayMicroseconds(send_delay);

	// Entropy.initialize();
	// delayMicroseconds(Entropy.random(0, 20000));

	// send edge info to master
	int send_master = bus.send(MASTER, edge, 12);

	scan_time = millis();
	while (millis() - scan_time < 1500)
		bus.update();		

	// int send_master;
	// while (send_master != ACK)
	// 	send_master = bus.send_string(MASTER, edge, 12);

}


#endif  //_SLAVE_BOOT_SEQUENCE_PDE_
