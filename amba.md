<!-- ###################################################################### -->
## AMBA APB, AHB and AXI
<!-- .slide: data-background="#145A32" -->
<!-- ###################################################################### -->

[rodrigomelo9.github.io/amba](https://rodrigomelo9.github.io/amba)

Rodrigo Alejandro Melo

[Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/)

---
<!-- ###################################################################### -->
### AMBA
#### Advanced Microcontroller Bus Architecture
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Description

AMBA is a freely available, globally adopted, open standard for the connection and management of functional blocks in a System-on-Chip (SoC).
It facilitates right-first-time development of multiprocessor designs, with large numbers of controllers and peripherals.

----

### AMBA specifications

|                                     | AMBA          | AMBA2          | AMBA3              | AMBA4                       | AMBA5
| :---:                               | :---:         | :---:          | :---:              | :---:                       | :---:
|                                     |               |                |                    | AXI4-Stream<br>(2010)       | AXI5-Stream<br>(2021)
| Advanced<br>eXtensible<br>Interface |               |                | AXI3<br>(2003/4)   | AXI4<br>AXI4-Lite<br>(2010) | AXI5<br>AXI5-Lite<br>(2017/21)
| Advanced<br>High-performance<br>Bus |               | AHB<br>(1999)  | AHB-Lite<br>(2006) |                             | AHB5<br>AHB5-Lite<br>(2015/21)
| Advanced<br>System<br>Bus           | ASB<br>(1996) | ASB<br>(1996)  |                    |                             |
| Advanced<br>Peripherals<br>Bus      | APB<br>(1996) | APB2<br>(1999) | APB3<br>(2003/4)   | APB4<br>(2010)              | APB5<br>(2021)
<!-- .element: style="font-size: 0.5em !important;" -->

> **WARNING:** ASB and the first APB are deprecated (shouldn't be used in new designs)
<!-- .element: style="font-size: 0.4em !important;" -->

----

### Terminology

Term        | Description
---         |---
Interface   | APB, AHB, AXI (a core could have multiple)
Channel     | Independent collection of AXI signals associated to a VALID
Bus         | Multi-bit signal (not an interface, not a channel)
Transfer    | (aka beat) single clock cycle, qualified by a VALID/READY handshake
Transaction | Complete communication, with one or more transfers
Burst       | Transaction with more than one transfer
Manager     | Agent that initiates transactions
Subordinate | Agent that receives and responds to requests
<!-- .element: style="font-size: 0.5em !important;" -->

----

### General considerations

* All signals are sampled at the rising edge of xCLK.
* xRESETn is the only active low signal.
* xADDR indicates a byte address.

---

<!-- ###################################################################### -->
### APB
#### Advanced Peripherals Bus
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Description

A low-cost interface, optimized for minimal power consumption and reduced complexity.
It is not  pipelined and is a simple, synchronous protocol.
Every transfer takes at least two cycles to complete.

Main uses:
* Low bandwidth peripherals
* Control/Status registers

> Transfers are typically initiated by a bridge (Requester), and a peripheral interface (Completer) responds.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### APB signals

|                | APB2  | APB3  | APB4  | APB5  | Default | Description
| ---            | :---: | :---: | :---: | :---: | :---:   | ---
| PCLK           | Y     | Y     | Y     | Y     |         | Clock
| PRESETn        | Y     | Y     | Y     | Y     |         | Reset
| PADDR[A-1:0]   | Y     | Y     | Y     | Y     |         | Address (up to 32 bits)
| PSELx          | Y     | Y     | Y     | Y     |         | Completer x selected
| PENABLE        | Y     | Y     | Y     | Y     |         | Enable
| PWRITE         | Y     | Y     | Y     | Y     |         | Write operation
| PWDATA[D-1]    | Y     | Y     | Y     | Y     |         | Write Data. (8, 16 or 32 bits)
| PRDATA[D-1]    | Y     | Y     | Y     | Y     |         | Read Data (8, 16 or 32 bits)
| PREADY         |       | O     | O     | O     | 1'b1    | Indicates the completion of a transfer
| PSLVERR        |       | O     | O     | O     | 1'b0    | Indicates an error condition
| PPROT[2:0]     |       |       | O     | O     | '0      | Normal, privileged, or secure protection level
| PSTRB[D/8-1:0] |       |       | O     | O     | '1      | Write Strobe (bytes to update during a write)
| PWAKEUP        |       |       |       | O     |         | Wake-up
| PxUSER[]       |       |       |       | O     |         | User defined attribute
| PxCHK          |       |       |       | O     |         | Parity protection (for safety-critical applications)
<!-- .element: style="font-size: 0.4em !important;" -->

----

### APB4-S interface

![APB-S interface](images/apb-s.svg)

----

### APB4 Signaling

![APB Signaling](images/apb-waves.png)

----

### APB3 - PREADY

* Completer can use PREADY to extend (introduce wait states) transfers.
* Peripherals with fixed two-cycle access can set PREADY always HIGH.

----

### APB3 - PSLVERR

* Can be used to indicate an ERROR condition (error, unsupported, timeout, etc).
* A WRITE transaction with ERROR, might or might not have updated the state of the peripheral.
* A READ transaction with ERROR, might or might not provide valid data.

----

### APB4 - PSTRB

* Enables sparse data transfer on the write data bus
* There is one bit per each byte of PWDATA
  * PSTRB[n] -> PWDATA[(8n + 7):(8n)]
* When asserted HIGH, the corresponding byte of PWDATA contains valid information

> During read transfers, all the bits of PSTRB **must** be driven LOW
<!-- .element: style="font-size: 0.4em !important;" -->

----

### APB4 - PPROT

* PPROT[0]: Normal or Privileged
* PPROT[1]: Secure or Non-secure
* PPROT[2]: Data or Instruction

> **ATTENTION:** the primary use of PPROT is as an identifier for Secure or Non-secure transactions (it is acceptable to use different interpretations for PPROT[0] and PPROT[2])
<!-- .element: style="font-size: 0.4em !important;" -->

> **WARNING:** PPROT[2] is provided as a hint, but might not be accurate in all cases
<!-- .element: style="font-size: 0.4em !important;" -->

----

### APB design considerations - Unaligned transfers
<!-- .slide: data-background="yellow" -->

PADDR can be unaligned, but the result is UNPREDICTABLE (Completer may utilize the unaligned address, aligned address, or indicate an error response).

----

### APB design considerations - Operating States
<!-- .slide: data-background="yellow" -->

![APB states](images/apb-states.svg)

> When a transfer is required, the interface moves into the SETUP state, where the appropriate PSELx is asserted.
> The interface remains in this state for one clock cycle and always moves to the ACCESS state, where PENABLE is asserted.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### APB design considerations - Validity rules
<!-- .slide: data-background="yellow" -->

* PSEL must be always valid
* PADDR, PPROT, PENABLE, PWRITE, PSTRB and PWDATA must be valid when PSEL is asserted
* PREADY must be valid when PSEL, and PENABLE are asserted
* PRDATA, and PSLVERR must be valid when PSEL, PENABLE and PREADY are asserted

> **RECOMMENDATION:** signals which are not required to be valid should be driven to zero
<!-- .element: style="font-size: 0.4em !important;" -->

---

<!-- ###################################################################### -->
### AHB
#### Advanced High-performance Bus
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Description

Main uses:
* High Performance system bus
* Lite: single masters

----

### AHB signals

|               | AHB2     | AHB-Lite  | AHB5    | Default | Description
| ---           | :---:    | :---:     | :---:   | :---:   | ---
| HCLK          | Y        | Y         | Y       |         | Clock
| HRESETn       | Y        | Y         | Y       |         | Reset
| HADDR[]       | Y        | Y         | Y       |         | Address (32-bits, between 10 and 64 in AHB5)
| HSELx         | Y        | Y         | Y       |         | Selected (combinatorial decode of the address bus)
| HTRANS[1:0]   | Y        | Y         | Y       |         | Transfer type (IDLE, BUSY, NONSEQ, SEQ)
| HWRITE        | Y        | Y         | Y       |         | Write operation
| HSIZE[2:0]    | Y        | Y         | Y       |         | Size of the transfer (2^SIZE bytes)
| HBURST[2:0]   | O        | O         | O       | 3'b001  | Burst length and address increments
| HPROT[3:0]    | O        | O         | O       | 4'b0011 | Protection level
| HWDATA[]      | Y        | Y         | Y       |         | WR (8, 16, 32, 64, 128, 256, 512, 1024 bits)
| HRDATA[]      | Y        | Y         | Y       |         | RD (8, 16, 32, 64, 128, 256, 512, 1024 bits)
| HWSTRB[D/8-1] |          | O (AMBA5) | O       | '1      | Write Strobe (bytes to update during a write)
| HREADY        | Y        | Y         | Y       |         | (IN) other transfers completed
| HRESP         | Y [1:0]  | Y         | Y       |         | Transfer response
| HBUSREQx      | Y        |           |         |         | Bus required
| HLOCKx        | Y        |           |         |         | Locked access required
| HGRANTx       | Y        |           |         |         | Locked access has the highest priority
| HMASTER[]     | O [3:0]  |           | O [7:0] | '0      | Manager identifier
| HMASTLOCK     | O        | O         | O       | 1'b0    | Current transfer is part of a locked sequence
| HSPLITx[15:0] | Y        |           |         |         | M to re-attempt a split transaction
| HREADYOUT     |          | Y         | Y       |         | (OUT) transfer has finished
| HNONSEC       |          |           | O       | 1'b0    | Indicates Non-secure transaction
| HEXCL         |          |           | O       | 1'b0    | Exclusive Access
| HEXOKAY       |          |           | O       | 1'b0    | Exclusive Okay
| HxUSER[]      |          |           | O       |         | User defined attribute
| HxCHKx        |          |           | O       |         | Parity protection (for safety-critical applications)
<!-- .element: style="font-size: 0.3em !important;" -->

----

### AHB-Lite interfaces

![AHB interface](images/ahb.svg)

----

### AHB-Lite Signaling (basic transfers)

![AHB basic transfers signaling](images/ahb-waves-basic.png)

----

### AHB-Lite Signaling (multiple transfers)

![AHB multiple transfers signaling](images/ahb-waves-multi.png)

> Extending the data phase of transfer B has the effect of extending the address phase of transfer C.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB - HREADY & HREADYOUT (waited transfers)

> SUBORDINATES require HREADY as both an input and an output (HREADYOUT) signal.
<!-- .element: style="font-size: 0.4em !important;" -->

* HREADYOUT is driven during the data phase:
  * LOW: extend the transfer
  * HIGH: transfer has finished
* The INTERCONNECT is responsible for combining all the HREADYOUT to generate a single HREADY.
* HSELx, HADDR and control **must** be sampled when HREADY is HIGH (current transfer is completing).

> A SUBORDINATE cannot request that the address phase be extended, so it **must** always be capable of sampling the address.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB - HRESP (transfer response)

> HRESP is 2 bits wide in AHB2, to support SPLIT and RETRY (removed on AMBA3).
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB5 - HWSTRB

* Enables sparse data transfer on the write data bus
* There is one bit per each byte of HWDATA
  * HWSTRB[n] -> HWDATA[(8n + 7):(8n)]
* When asserted HIGH, the corresponding byte of HWDATA contains valid information

> * During read transfers, it is recommended that write strobes are deasserted.
> * Write transfers with all HWSTRB deasserted are permitted (no bytes are written).
> * HWSTRB can change between beats of a burst.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB - HPROT

* HPROT[0]: Data/Opcode
* HPROT[1]: Privileged
* HPROT[2]: Buffereable
* HPROT[3]: Cacheable

> * HPROT **must** remain constant during a burst transfer.
> * If unused, a manager should set 3'b0011
> * A subordinate shouldn't use HPROT unless absolutely necessary.
<!-- .element: style="font-size: 0.4em !important;" -->


----

### AHB - HTRANS (transfer types)

| HTRANS[1:0] | Type   | Description                                                                                                           |
| :---:       | :---:  | ---                                                                                                                   |
| 2'b00       | IDLE   | No data transfer is required                                                                                          |
| 2'b01       | BUSY   | Insert idle cycles in the middle of a burst (address and control signals must reflect the next transfer in the burst) |
| 2'b10       | NONSEQ | Single transfer or first transfer of a burst (address and control signals are unrelated to the previous transfer)     |
| 2'b11       | SEQ    | Remaining transfers in a burst (control information is identical to the previous transfer, address is adjusted)       |
<!-- .element: style="font-size: 0.5em !important;" -->

> In case of IDLE and BUSY, a subordinate **must** always provide a zero wait state OKAY response, and the transfer **must** be ignored.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB - HSIZE (transfer size)

Indicates the size (bytes) of a data transfer (**must** be less than or equal to the width of the data bus).

| HSIZE[2:0] | Bytes |
| :---:      | :---: |
| 3'b000     | 1     |
| 3'b001     | 2     |
| 3'b010     | 4     |
| 3'b011     | 8     |
| 3'b100     | 16    |
| 3'b101     | 32    |
| 3'b110     | 64    |
| 3'b111     | 128   |
<!-- .element: style="font-size: 0.5em !important;" -->

> * HSIZE **must** remain constant during a burst transfer.
> * SIZE = `2**HSIZE` (or `1<<HSIZE`).
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB - HBURST (burst types)

| HBURST[2:0] | Type        | Description
| :---:       | :---:       | ---
| 3'b000      | SINGLE      | Single burst
| 3'b001      | INCR        | Incrementing burst of undefined length
| 3'b010      | WRAP4       | Wrapping burst (4 beats)
| 3'b011      | INCR4       | Incremental burst (4 beats)
| 3'b100      | WRAP8       | Wrapping burst (8 beats)
| 3'b101      | INCR8       | Incremental burst (8 beats)
| 3'b110      | WRAP16      | Wrapping burst (16 beats)
| 3'b111      | INCR16      | Incremental burst (16 beats)
<!-- .element: style="font-size: 0.5em !important;" -->

> * Managers **must** not attempt to start an incrementing burst that crosses a 1KB address boundary.
> * The total amount of data transferred in a burst is calculated multiplying the number of beats by the amount of data (as indicated by HSIZE[2:0]).
> * Transfers in a burst **must** be aligned to the address boundary (as indicated by HSIZE[2:0]).
> * Wrapping bursts wrap when they cross an address boundary (BEATS x SIZE).
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB - WRAP4/INCR4 example

![AHB WRAP4/INCR4 example](images/ahb-wrap4-incr4.png)
<!-- .element: style="background-color: white;" -->

----

### AHB - Undefined INCR example

![AHB undefined INCR example](images/ahb-undef-incr.png)
<!-- .element: style="background-color: white;" -->

----

### AHB - Early burst termination

----

### AHB - HMASTLOCK (locked transfers)

Indicates that the current transfer sequence is indivisible (typically used to maintain the integrity of a semaphore).
<!-- .element: style="font-size: 0.8em !important;" -->

![AHB locked transfers](images/ahb-lock.png)
<!-- .element: style="background-color: white;" -->

> After a locked transfer, it is recommended to insert an IDLE transfer.
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AHB design considerations - TBD
<!-- .slide: data-background="yellow" -->

---
<!-- ###################################################################### -->
### AXI
#### Advanced eXtensible Interface
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Description

Main uses:
* Full: Higher performance system bus
* Lite: Control/Status registers
* Stream: High speeds unidirectional transfers

----

### AXI signals

Write Address Channel    | Write Data Channel         | Read Address Channel     | Read Data Channel
---                      |---                         |---                       |---
AWID[]                   | ~~WID[]~~                  | ARID[]                   | RID[]
AWADDR[]                 | WDATA[]                    | ARADDR[]                 | RDATA[]
AWLEN[7:0] -- __MOD__    | WSTRB[]                    | ARLEN[7:0] -- __MOD__    | RRESP[1:0]
AWSIZE[2:0]              | WLAST                      | ARSIZE[2:0]              | RLAST
AWBURST[1:0]             | WUSER[] -- __NEW__         | ARBURST[1:0]             | RUSER[] -- __NEW__
AWLOCK -- __MOD__        | WVALID                     | ARLOCK -- __MOD__        | RVALID
AWCACHE[3:0]             | WREADY                     | ARCACHE[3:0]             | RREADY
AWPROT[2:0]              | __Write Response Channel__ | ARPROT[2:0]              |
AWQOS[3:0] -- __NEW__    | BID[]                      | ARQOS[3:0] -- __NEW__    |
AWREGION[3:0] -- __NEW__ | BRESP[1:0]                 | ARREGION[3:0] -- __NEW__ |
AWUSER[] -- __NEW__      | BUSER[] -- __NEW__         | ARUSER[] -- __NEW__      | __Global signals__
AWVALID                  | BVALID                     | AWVALID                  | ACLK
AWREADY                  | BREADY                     | AWREADY                  | ARESETn
<!-- .element: style="font-size: 0.5em !important;" -->

> * AXI3: AxLEN[3:0] and AxLOCK[1:0].
> * AXI4: removed WID, added AxQOS, AxREGION and xUSER.
> * AXI5: several signals added (not only parity)
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AXI signals description

Signal   | Description
---      |---
AxPROT   | Protection type (un/privileged, non/secure, data/instruction access)
WSTRB    | Write strobe, indicates valid bytes
xRESP    | OKAY, EXOKAY (exclusive), SLVERR (Slave ERROR), DECERR (Decode ERROR)
AxLEN    | Burst length (AxLEN + 1)
AxSIZE   | 1, 2, 4, 8, 16, 32, 64, 128 bytes of the beat (2^AxSIZE)
AxBURST  | FIXED, INCR, WRAP, reserved
xLAST    | Indicates last beat in the burst
AxLOCK   | Normal, exclusive or locked (only AXI3) access
AxCACHE  | Indicates Bufferable, Cacheable, and Allocate attributes
AxQOS    | Quality of Service
AxREGION | Up to 16 regions for the address decode
xID      | Transaction identifiers (ordering)
xUSER    | User-defined (not recommended)
<!-- .element: style="font-size: 0.5em !important;" -->

----

### AXI4 interface

![AXI4 interface](images/axi.svg)

---

<!-- ###################################################################### -->
### AXI-Lite
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Description

----

### AXI-Lite signals

|Write Address Channel | Write Data Channel         | Read Address Channel     | Read Data Channel
|---                   |---                         |---                       |---
|AWADDR[]              | WDATA[]                    | ARADDR[]                 | RDATA[]
|AWPROT[2:0]           | WSTRB[]                    | ARPROT[2:0]              | RRESP[1:0]
|AWVALID               | WVALID                     | AWVALID                  | RVALID
|AWREADY               | WREADY                     | AWREADY                  | RREADY
|                      | __Write Response Channel__ |                          |
|                      | BRESP[1:0]                 |                          | __Global signals__
|                      | BVALID                     |                          | ACLK
|                      | BREADY                     |                          | ARESETn
<!-- .element: style="font-size: 0.5em !important;" -->

> AXI5-lite: several signals added, for parity and more flexibility on bus width and ordering
<!-- .element: style="font-size: 0.4em !important;" -->

----

### AXI4-Lite interface

![AXI4-Lite interface](images/axi-lite.svg)

---
<!-- ###################################################################### -->
### AXI-Stream
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Description

----

### AXI-Stream signals

| AXI4-Stream  | AXI5-Stream  | Description
|---           |--            |---
| ACLK         | ACLK         | Clock
| ARESETn      | ARESETn      | Reset
| TVALID       | TVALID       | Valid
| TREADY       | TREADY       | Ready
| TDATA[D-1:0] | TDATA[D-1:0] | D: 8, 16, 32, 64, 128, 256, 512, 1024 (bits)
| TSTRB[]      | TSTRB[]      | Indicates is the associated byte is a data byte or a position byte
| TKEEP[]      | TKEEP[]      | Indicates which bytes must be transported to the destination
| TLAST        | TLAST        | Indicates the boundary of a packet
| TID[]        | TID[]        | Data stream identifier
| TDEST[]      | TDEST[]      | Provides routing information
| TUSER[]      | TUSER[]      | User-defined sideband information
|              | TWAKEUP      | Wake-up
|              | T*CHK        | Parity (for safety)
<!-- .element: style="font-size: 0.5em !important;" -->

---
<!-- ###################################################################### -->
### Interconnect
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Buses

----

### Crossbar switches

----

### Network-on-Chip (NoC)

---

<!-- ###################################################################### -->
### Practical considerations
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

----

### Performance comparison

----

### It is common to have multiple interfaces per IP

![DMA example](images/dma-example.svg)

----

### Address boundaries

WIP (1KB AHB, 4KB AXI)

<!--AHB-->
<!--The minimum address space that can be allocated to a single slave is 1kB. All bus-->
<!--masters are designed such that they will not perform incrementing transfers over a 1kB-->
<!--boundary, thus ensuring that a burst never crosses an address decode boundary.-->

---
<!-- ###################################################################### -->
### AMBA5 parity signals
<!-- .slide: data-background="#581845" -->
<!-- ###################################################################### -->

<!-- diagram about interconnect protection -->

----

### APB5 parity signals

----

### AHB5 parity signals

----

### AXI5 parity signals

---
<!-- ###################################################################### -->
# Questions?
<!-- .slide: data-background="#1F618D" -->
<!-- ###################################################################### -->

|   |   |
|---|---|
| ![GitHub icon](icons/github.png)     | [rodrigomelo9](https://github.com/rodrigomelo9)                          |
| ![Twitter icon](icons/twitter.png)   | [rodrigomelo9ok](https://twitter.com/rodrigomelo9ok)                     |
| ![LinkedIn icon](icons/linkedin.png) | [rodrigoalejandromelo](https://www.linkedin.com/in/rodrigoalejandromelo) |
|   |   |