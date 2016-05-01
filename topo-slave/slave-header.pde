// slave-header.pde

#ifndef _SLAVE_HEADER_PDE_
#define _SLAVE_HEADER_PDE_


#include <PJON.h>
#include <Entropy.h>
#include <MemoryFree.h>


// PJON bus set on pin 12
PJON bus(12); 

// define addresses for PJON interconnects
const uint8_t addr_0 = 2;
const uint8_t addr_90 = 3;
const uint8_t addr_180 = 4;
const uint8_t addr_270 = 5;

// const uint8_t inter = 255;

// set PJON pins and addresses for interconnections
PJON com_0 (6, addr_0);
PJON com_90 (9, addr_90); 
PJON com_180 (10, addr_180); 
PJON com_270 (11, addr_270); 

// defined for identification of ports.
// if devices receives from specific port,
// send to resulting addresses
const uint8_t port_0 = 1;
const uint8_t port_90 = 2;
const uint8_t port_180 = 3;
const uint8_t port_270 = 4;


const uint8_t MASTER = 1; // PJON master address
const uint8_t maxdev = 254; // maximum number of devices
char neighbour_msg[7];
uint32_t scan_time;
uint8_t ringbuf[4] = {port_0, port_90, port_180, port_270};
uint8_t rand_address;
uint8_t UID[4];
uint32_t big_UID;
uint8_t neighbour_UID[4]; // neighbour's UID
uint8_t this_port;
uint8_t neighbour_addr = NULL;


#endif  //_SLAVE_HEADER_PDE_