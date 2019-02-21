//============================================================
// Synchronous FIFO 
// Features:
//	1. Asynchronous and synchronous reset
//	2. Configurable data width
//	3. Configurable depth in power of 2 (round to address width)
//	4. Configurable almost-full and almost-empty level
//	5. Configurable Look-ahead or read-request architecture
//	6. Concurrent used word indication
//	7. Implementation using D-FF or Memory hard-macro
//
// Designer: Josh Cheng
// GNU General Public License v3.0 
//============================================================
module sync_fifo #(
			parameter		DATA_WIDTH = 32,
						ADDR_WIDTH = 8,
						AFULL_LEVEL = 248,
						AEMPTY_LEVEL = 8,
						LOOKAHEAD = 1)
		(
		input				clk		,	// Clock input
		input				rst		,	// Active low reset
		input				sclr		,	// FIFO synchronous clear
		input	[DATA_WIDTH-1:0]	data_in		,	// Data input
		input				rd_en		,	// Read enable
		input				wr_en		,	// Write Enable
		output	[DATA_WIDTH-1:0]	data_out	,	// Data Output
		output				empty		,	// FIFO empty
		output				full		,	// FIFO full
		output				afull		,	// FIFO almost full
		output				aempty		,	// FIFO almost empty
		output	[ADDR_WIDTH :0]		uw			// FIFO used word
		
);
 

localparam RAM_DEPTH = (1 << ADDR_WIDTH);



logic	[ADDR_WIDTH-1:0] 	wr_pointer;
logic	[ADDR_WIDTH-1:0]	rd_pointer;
logic	[ADDR_WIDTH :0]		word_cnt;
logic	[DATA_WIDTH-1:0]	ram_q;
logic	[DATA_WIDTH-1:0]	data_ram;

logic				ram_wren;
logic				ram_rden;
logic	[ADDR_WIDTH-1:0]	ram_wraddr;
logic	[ADDR_WIDTH-1:0]	ram_rdaddr

assign full = (word_cnt == (ADDR_WIDTH+1)'(RAM_DEPTH));
assign empty = (word_cnt == (ADDR_WIDTH+1)'(0));
assign afull = (word_cnt >= (ADDR_WIDTH+1)'(AFULL_LEVEL));
assign aempty = (word_cnt <= (ADDR_WIDTH+1)'(AEMPTY_LEVEL));



//Write pointer
always_ff@(posedge clk or posedge rst)
begin
	if (rst) 
		wr_pointer <= (ADDR_WIDTH)'(0);
	else if (sclr)
		wr_pointer <= (ADDR_WIDTH)'(0);
	else if (wr_en & (~full | rd_en) ) 	//overflow protect, but allow full write if read at same time
		wr_pointer <= wr_pointer + (ADDR_WIDTH)'(1);
end

//Read pointer
generate 
if (LOOKAHEAD)
begin
	always_ff@(posedge clk or posedge rst)
	begin
		if (rst)
			rd_pointer <= (ADDR_WIDTH)'(1);		//init to 1 for lookahead architecture
		else if (sclr)
			rd_pointer <= (ADDR_WIDTH)'(1);
		else if (rd_en & ~empty) //underflow protect
			rd_pointer <= rd_pointer + (ADDR_WIDTH)'(1);
	end
end
else
begin
	always_ff@(posedge clk or posedge rst)
	begin
		if (rst)
			rd_pointer <= (ADDR_WIDTH)'(0);
		else if (sclr)
			rd_pointer <= (ADDR_WIDTH)'(0);
		else if (rd_en & ~empty) //underflow protect
			rd_pointer <= rd_pointer + (ADDR_WIDTH)'(1);
	end
end
endgenerate

//Word counter
always_ff@ (posedge clk or posedge rst)
begin
	if (rst) 
		word_cnt <= (ADDR_WIDTH+1)'(0);
	else if (sclr)
		word_cnt <= (ADDR_WIDTH+1)'(0);
	else if (rd_en & ~wr_en & ~empty)
		word_cnt <= word_cnt - (ADDR_WIDTH+1)'(1);
	else if (wr_en & ~rd_en & ~full)
		word_cnt <= word_cnt + (ADDR_WIDTH+1)'(1);
	else if (wr_en & rd_en & empty) //if write & read same time during empty, write is still valid
		word_cnt <= word_cnt + (ADDR_WIDTH+1)'(1);		
end 


//RAM control
assign ram_wren = wr_en & (~full | rd_en);
assign ram_rden = rd_en & ~empty;
assign ram_rdaddr = rd_pointer;
assign ram_wraddr = wr_pointer;

//=========================================================================================
// Memory instantiation
// Replace a RAM macro here if available. RTL model is shown below and D-FF will be used
// Example instance:
// RAM_XX	macro0 (
//		.clk		(clk),
//		.rdaddr		(ram_rdaddr),
//		.wraddr		(ram_wraddr),
//		.rddata		(data_in),
//		.wrdata		(ram_q),
//		.rden		(ram_wren),
//		.wren		(ram_rden));
//
//*****************************************************************************************
//Memory by D-FF
logic	[DATA_WIDTH-1:0]	mem[0:RAM_DEPTH-1];

always_ff@(posedge clk)
begin
	if (ram_wren)
		mem[ram_wraddr] <= data_in;
end

//Memory Output MUX & register
always_ff@(posedge clk)
begin
	if (ram_rden)                
                ram_q <= mem[ram_rdaddr];
end

//========================================================================================


//===========================================================================================
// Logic for LOOKAHEAD
//*******************************************************************************************
generate 
if (LOOKAHEAD)
begin
	logic				use_buffer;
	logic	[DATA_WIDTH-1:0]	word_buffer;
	logic				use_buffer_next;
	
	assign use_buffer_next = ((wr_en & empty) |				//Write into empty FIFO
			 (wr_en & rd_en & rd_pointer == wr_pointer));		//Read/write at the same time
	
	
	//First word MUX
	always_ff@(posedge clk or posedge rst)
	begin
		if (rst)
			use_buffer <= 1'b0;
		else if (use_buffer_next)
			use_buffer <= 1'b1;
		else if (rd_en)
			use_buffer <= 1'b0;
	end
         
	//First word buffer
	always_ff@(posedge clk or posedge rst)
	begin
		if (rst)
			word_buffer <= (DATA_WIDTH)'(0);
		else if (use_buffer_next)
			word_buffer <= data_in;
	end
	
	assign data_ram = (use_buffer)? word_buffer: ram_q;

end
else
begin
	assign data_ram = ram_q;

end
endgenerate
//========================================================================================


//===========================================================================================
// Output assignment
//*******************************************************************************************
assign uw = word_cnt;
assign data_out = data_ram;
//===========================================================================================



endmodule
