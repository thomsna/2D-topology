// master-header.pde

#ifndef _MASTER_HEADER_PDE_
#define _MASTER_HEADER_PDE_


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


const uint8_t MASTER = 1; // the master is at address 1 on the bus
const uint8_t maxdev = 254; // how many devices are expected at max
const uint8_t ndev = 7; // initialize arrays of size ndev
char neighbour_msg[7];
uint32_t scan_time;
uint8_t maxdepth = 0;
uint8_t matrix_size;
uint8_t UID[4];
uint32_t big_UID;



#endif  //_MASTER_HEADER_PDE_
