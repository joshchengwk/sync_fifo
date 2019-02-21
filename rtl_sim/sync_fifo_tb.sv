`timescale 1ns/10ps

module sync_fifo_tb();

//==========================================================================================
// Testbench parameter
//******************************************************************************************
parameter real clk_period = 20;
//==========================================================================================

//==========================================================================================
// DUT parameter
//******************************************************************************************
parameter		DATA_WIDTH = 32,
			ADDR_WIDTH = 8,
			AFULL_LEVEL = 248,
			AEMPTY_LEVEL = 8,
			LOOKAHEAD = 0;
//==========================================================================================

//==========================================================================================
// DUT Signal
//******************************************************************************************
logic				clk		;	// Clock input
logic				rst_n		;	// Active low asynchronous reset
logic	[DATA_WIDTH-1:0]	data_in		;	// Data input
logic				rd_en		;	// Read enable
logic				wr_en		;	// Write Enable
logic	[DATA_WIDTH-1:0]	data_out	;	// Data Output
logic				empty		;	// FIFO empty
logic				full		;	// FIFO full
logic				afull		;	// FIFO almost full
logic				aempty		;	// FIFO almost empty
logic	[ADDR_WIDTH :0]		uw		;	// FIFO used word
logic				sclr		;	// FIFO synchronous clear
//===========================================================================================

//===========================================================================================
// Testbench Signal
//*******************************************************************************************
integer				i,j;
//============================================================================================




always
begin
	clk = 1;
	#(clk_period/2);
	clk= 0;
	#(clk_period/2);
end

initial
begin
	//initialize input
	data_in = 0;
	wr_en = 0;
	sclr = 0;
	
	rst_n = 0;
	#(2)
	rst_n = 1;
end


//FIFO write control
initial
begin
	//Wait a few clock cycles
	#(clk_period *10);
	
	for (i=0; i<16; i=i+1)
	begin
		@(posedge clk)
		wr_en <= 1'b1;
		data_in <= $random;
	end
	@(posedge clk)
		wr_en <= 1'b0;
		
	#(clk_period *10);
	for (i=0; i<16; i=i+1)
	begin
		@(posedge clk)
		wr_en <= 1'b1;
		data_in <= $random;
	end
	@(posedge clk)
		wr_en <= 1'b0;
	#(clk_period *10);
	
end

//FIFO read control
//assign rd_en = ~empty;
// always_ff@(posedge clk or negedge rst_n)
// begin
	// if (~rst_n)
		// rd_en <= 0;
	// else
		// rd_en <= ~empty;
// end

initial
begin
	rd_en = 0;
	//Wait a few clock cycles
	#(clk_period *100);
	
	for (j=0; j<16; j=j+1)
	begin
		@(posedge clk)
		rd_en <= 1'b1;
	end
	@(posedge clk)
		rd_en <= 1'b0;
		
	#(clk_period *10);
	for (j=0; j<16; j=j+1)
	begin
		@(posedge clk)
		rd_en <= 1'b1;
	end
	@(posedge clk)
		rd_en <= 1'b0;
	#(clk_period *10);
	$stop;
end


//Instantiate DUT
sync_fifo	 #(	.DATA_WIDTH		(DATA_WIDTH	),
			.ADDR_WIDTH		(ADDR_WIDTH	),
			.AFULL_LEVEL		(AFULL_LEVEL	),
			.AEMPTY_LEVEL		(AEMPTY_LEVEL	),
			.LOOKAHEAD		(LOOKAHEAD	))

DUT(
		.clk		(clk		),	// Clock input
		.rst_n		(rst_n		),	// Active low reset
		.data_in	(data_in	),	// Data input
		.rd_en		(rd_en		),	// Read enable
		.wr_en		(wr_en		),	// Write Enable
		.data_out	(data_out	),	// Data Output
		.empty		(empty		),	// FIFO empty
		.full		(full		),	// FIFO full
		.afull		(afull		),	// FIFO almost full
		.aempty		(aempty		),	// FIFO almost empty
		.uw		(uw		),	// FIFO used word
		.sclr		(sclr		));	// FIFO synchronous clear
	
endmodule