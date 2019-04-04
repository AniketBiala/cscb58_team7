module DotKong
    (
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                        //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                             //    VGA Green[9:0]
        VGA_B,                           //    VGA Blue[9:0]
        HEX0,
        HEX1
    );
    input            CLOCK_50;                //    50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;
    output   [6:0] HEX0;
    output   [6:0] HEX1;
    // Declare your inputs and outputs here
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC26'b10000000000000000000000000
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [9:0]    VGA_R;                   //    VGA Red[9:0]
    output    [9:0]    VGA_G;                     //    VGA Green[9:0]
    output    [9:0]    VGA_B;                   //    VGA Blue[9:0]
   
    wire resetn;
    assign resetn = 1'b1 ;
   
    // Create the colour, x, y and writeEn wires that are inputs to the controller.
   reg [2:0] colour;// notice they were originally wire ,  I made them reg     edit:Mar20, 2:30am
    reg [6:0] x;
    reg [6:0] y;
    reg  writeEn;
   

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";
   
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
	 reg speed1 = 2'b00;
	 reg speed2 = 2'b01;
	 reg speed3 = 2'b10;
   
    wire ld_x, ld_y;
    wire [3:0] stateNum;
    reg  [7:0] init_player_coord = 8'b00000101; // this is x coord
    wire [2:0] colour_player;
    wire [6:0] x_player;
    wire [6:0] y_player;
    wire writeEn_player;
    reg [25:0] counter_for_player = 26'b00000000000000000000000000;
    reg [6:0] init_y_p = 7'b1110101;
    reg [2:0] acolour_p = 3'b010;
    // Instansiate datapath                             
    datapath d0(.clk(CLOCK_50), .ld_x(ld_x), .ld_y(ld_y), .in(init_player_coord), .reset_n(resetn), .x(x_player), .y(y_player), .colour(colour_player), .write(writeEn_player), .stateNum(stateNum), .init_y(init_y_p), .acolour(acolour_p), .restrict_ladder_movement(1'b1));
   
    // Instansiate FSM control
    control c0(.clk(CLOCK_50), .move_r(~KEY[0]), .move_l(~KEY[3]), .move_d(~KEY[1]), .move_u(~KEY[2]), .reset_n(resetn), .ld_x(ld_x), .ld_y(ld_y), .stateNum(stateNum), .reset_game(reset_game), .press_counter(counter_for_player), .how_fast(speed1));
   
     
    // --------------------------------------minion movements----------------------------------------------------------
   
    wire minion0_load_x, minion0_load_y;
    wire [3:0] minion0_stateNum;
    wire [2:0] minion0_colour;
    wire [6:0] minion0_xCoord;
    wire [6:0] minion0_yCoord;
    wire minion0_write;
    reg [25:0] minion0_counter = 26'b00000000000000000000000001;
	 reg [6:0] minion0_xStart = 7'b0101111;
    reg [6:0] minion0_yStart = 7'b0101010;
    reg [2:0] minion0_colourChoice = 3'b100;
	 
    datapath minion0_datapath(.clk(CLOCK_50), .ld_x(minion0_load_x), .ld_y(minion0_load_y), .in(  minion0_xStart), .reset_n(resetn), .x(minion0_xCoord), .y(minion0_yCoord), .colour(minion0_colour), .write(minion0_write), .stateNum(minion0_stateNum),  .init_y(minion0_yStart), .acolour(minion0_colourChoice), .restrict_ladder_movement(1'b0));
    control minion0_control(.clk(CLOCK_50), .move_r(1'b1), .move_l(~KEY[2]), .move_d(1'b0),  .move_u(1'b0), .reset_n(resetn), .ld_x(minion0_load_x), .ld_y(minion0_load_y), .stateNum(minion0_stateNum), .reset_game(1'b0), .press_counter(minion0_counter), .how_fast(speed1));

	 wire minion1_load_x, minion1_load_y;
    wire [3:0] minion1_stateNum;
    wire [2:0] minion1_colour;
    wire [6:0] minion1_xCoord;
    wire [6:0] minion1_yCoord;
    wire minion1_write;
    reg [25:0] minion1_counter = 26'b00000000000000000000000011;
	 reg  [6:0] minion1_xStart = 7'b0110000;
    reg [6:0] minion1_yStart = 7'b0100100;
    reg [2:0] minion1_colourChoice = 3'b100;
	 
    datapath minion1_datapath(.clk(CLOCK_50), .ld_x(minion1_load_x), .ld_y(minion1_load_y), .in(minion1_xStart), .reset_n(resetn), .x(minion1_xCoord), .y(minion1_yCoord), .colour(minion1_colour), .write(minion1_write), .stateNum(minion1_stateNum),  .init_y(minion1_yStart), .acolour(minion1_colourChoice), .restrict_ladder_movement(1'b0));
    control minion1_control(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b1), .move_d(1'b0),  .move_u(1'b0), .reset_n(resetn), .ld_x(minion1_load_x), .ld_y(minion1_load_y), .stateNum(minion1_stateNum), .reset_game(1'b0), .press_counter(minion1_counter), .how_fast(speed1));
	
	 wire minion2_load_x, minion2_load_y;
    wire [3:0] minion2_stateNum;
    wire [2:0] minion2_colour;
    wire [6:0] minion2_xCoord;
    wire [6:0] minion2_yCoord;
    wire minion2_write;
    reg [25:0] minion2_counter = 26'b00000000000000000000000100;
	 reg  [6:0] minion2_xStart = 7'b0100100;
    reg [6:0] minion2_yStart = 7'b1000110;
    reg [2:0] minion2_colourChoice = 3'b100;
                            
    datapath minion2_datapath(.clk(CLOCK_50), .ld_x(minion2_load_x), .ld_y(minion2_load_y), .in(minion2_xStart), .reset_n(resetn), .x(minion2_xCoord), .y(minion2_yCoord), .colour(minion2_colour), .write(minion2_write), .stateNum(minion2_stateNum),  .init_y(minion2_yStart), .acolour(minion2_colourChoice), .restrict_ladder_movement(1'b0));
    control minion2_control(.clk(CLOCK_50), .move_r(1'b1), .move_l(1'b0), .move_d(1'b0),  .move_u(1'b0), .reset_n(resetn), .ld_x(minion2_load_x), .ld_y(minion2_load_y), .stateNum(minion2_stateNum), .reset_game(1'b0), .press_counter(minion2_counter), .how_fast(speed1));
    
    wire minion3_load_x, minion3_load_y;
    wire [3:0] minion3_stateNum;
    wire [2:0] minion3_colour;
    wire [6:0] minion3_xCoord;
    wire [6:0] minion3_yCoord;
    wire minion3_write;
    reg [25:0] minion3_counter = 26'b00000000000000000000000101;
	 reg  [6:0] minion3_xStart = 7'b1010011;
    reg [6:0] minion3_yStart = 7'b1010010;
    reg [2:0] minion3_colourChoice = 3'b100;
                              
    datapath minion3_datapath(.clk(CLOCK_50), .ld_x(minion3_load_x), .ld_y(minion3_load_y), .in(minion3_xStart), .reset_n(resetn), .x(minion3_xCoord), .y(minion3_yCoord), .colour(minion3_colour), .write(minion3_write), .stateNum(minion3_stateNum),  .init_y(minion3_yStart), .acolour(minion3_colourChoice), .restrict_ladder_movement(1'b0));
    control minion3_control(.clk(CLOCK_50), .move_r(1'b1), .move_l(1'b0), .move_d(1'b0),  .move_u(1'b0), .reset_n(resetn), .ld_x(minion3_load_x), .ld_y(minion3_load_y), .stateNum(minion3_stateNum), .reset_game(1'b0), .press_counter(minion3_counter), .how_fast(speed1));

    wire minion4_load_x, minion4_load_y;
    wire [3:0] minion4_stateNum;
    wire [2:0] minion4_colour;
    wire [6:0] minion4_xCoord;
    wire [6:0] minion4_yCoord;
    wire minion4_write;
    reg [25:0] minion4_counter = 26'b00000000000000000000000110;
	 reg  [6:0] minion4_xStart = 7'b1010001;
    reg [6:0] minion4_yStart = 7'b1100001;
    reg [2:0] minion4_colourChoice = 3'b100;
                              
    datapath minion4_datapath(.clk(CLOCK_50), .ld_x(minion4_load_x), .ld_y(minion4_load_y), .in(minion4_xStart), .reset_n(resetn), .x(minion4_xCoord), .y(minion4_yCoord), .colour(minion4_colour), .write(minion4_write), .stateNum(minion4_stateNum),  .init_y(minion4_yStart), .acolour(minion4_colourChoice), .restrict_ladder_movement(1'b0));
    control minion4_control(.clk(CLOCK_50), .move_r(1'b0), .move_l(1'b1), .move_d(1'b0),  .move_u(1'b0), .reset_n(resetn), .ld_x(minion4_load_x), .ld_y(minion4_load_y), .stateNum(minion4_stateNum), .reset_game(1'b0), .press_counter(minion4_counter), .how_fast(speed1));

    wire minion5_load_x, minion5_load_y;
    wire [3:0] minion5_stateNum;
    wire [2:0] minion5_colour;
    wire [6:0] minion5_xCoord;
    wire [6:0] minion5_yCoord;
    wire minion5_write;
    reg [25:0] minion5_counter = 26'b00000000000000000000000111;
	 reg  [6:0] minion5_xStart = 7'b0111000;
    reg [6:0] minion5_yStart = 7'b1101011;
    reg [2:0] minion5_colourChoice = 3'b100;
                            
    datapath minion5_datapath(.clk(CLOCK_50), .ld_x(minion5_load_x), .ld_y(minion5_load_y), .in(minion5_xStart), .reset_n(resetn), .x(minion5_xCoord), .y(minion5_yCoord), .colour(minion5_colour), .write(minion5_write), .stateNum(minion5_stateNum),  .init_y(minion5_yStart), .acolour(minion5_colourChoice), .restrict_ladder_movement(1'b0));
    control minion5_control(.clk(CLOCK_50), .move_r(1'b1), .move_l(1'b0), .move_d(1'b0),  .move_u(1'b0), .reset_n(resetn), .ld_x(minion5_load_x), .ld_y(minion5_load_y), .stateNum(minion5_stateNum), .reset_game(1'b0), .press_counter(minion5_counter), .how_fast(speed1));
    
	 // -----------------------------------minion movements-----------------------------------------------------------

    wire [4:0] score;
    wire reset_game;
    collisionLogic player_and_minion(x_player, y_player, minion0_xCoord, minion0_yCoord, minion1_xCoord, minion1_yCoord, minion2_xCoord, minion2_yCoord, minion3_xCoord, minion3_yCoord, minion4_xCoord, minion4_yCoord, minion5_xCoord, minion5_yCoord, score, reset_game);
    hex_display first_digit(score, HEX1[6:0], HEX0[6:0]); //notice score is displayed in hexadecimal
   
	 // Processes player/minion movement and determines whether or not player is moving
    always @(posedge CLOCK_50)
    begin
        if(writeEn_player) 
            begin
                writeEn <= writeEn_player;
                x <= x_player;       
                y <= y_player;
                colour = colour_player;
            end
        else if (minion0_write) // check for minion movements - going to be basically always
            begin
                writeEn <= minion0_write;    
                x <= minion0_xCoord;                       
                y <= minion0_yCoord;
                colour <= minion0_colour;
            end
			else if (minion1_write)   
            begin
                writeEn <= minion1_write;    
                x <= minion1_xCoord;                       
                y <= minion1_yCoord;
                colour <= minion1_colour;
            end
			else if (minion2_write)   
            begin
                writeEn <= minion2_write;    
                x <= minion2_xCoord;                       
                y <= minion2_yCoord;
                colour <= minion2_colour;
            end   
        else if (minion3_write)  
            begin
                writeEn <= minion3_write;    
                x <= minion3_xCoord;                       
                y <= minion3_yCoord;
                colour <= minion3_colour;
            end   
        else if (minion4_write)   
            begin
                writeEn <= minion4_write;    
                x <= minion4_xCoord;                       
                y <= minion4_yCoord;
                colour <= minion4_colour;
            end   
        else if (minion5_write)   
            begin
                writeEn <= minion5_write;    
                x <= minion5_xCoord;                       
                y <= minion5_yCoord;
                colour <= minion5_colour;
            end  
    end
endmodule


// If reset is given value 1, player hit a minion and resets game setup
module collisionLogic(x_player, y_player, minion0_xCoord, minion0_yCoord, minion1_xCoord, minion1_yCoord, minion2_xCoord, minion2_yCoord, minion3_xCoord, minion3_yCoord, minion4_xCoord, minion4_yCoord, minion5_xCoord, minion5_yCoord, score, reset_game);
    input [6:0] x_player;
    input [6:0] y_player;
    input [6:0] minion0_xCoord;
    input [6:0] minion0_yCoord;
    input [6:0] minion1_xCoord;
    input [6:0] minion1_yCoord;
    input [6:0] minion2_xCoord;
    input [6:0] minion2_yCoord;
    input [6:0] minion3_xCoord;
    input [6:0] minion3_yCoord;
    input [6:0] minion4_xCoord;
    input [6:0] minion4_yCoord;
    input [6:0] minion5_xCoord;
    input [6:0] minion5_yCoord;
    output reg [4:0] score;
    output reg reset_game;
    
	
    always @(*)
    begin
		  // when player collides with monster, increment score
        if (y_player == 7'b0011010 && (x_player >= 7'b0000000 && x_player <= 7'b00010100)) // When player reaches the top of the screen and passes the boss
            begin
                score = score + 5'b00001;
                reset_game = 1'b1;
            end
			// when player collides with any of the minions, reset score and game
        else if ((x_player == minion0_xCoord && y_player == minion0_yCoord) || (x_player == minion1_xCoord && y_player == minion1_yCoord) ||
		           (x_player == minion2_xCoord && y_player == minion2_yCoord) || (x_player == minion3_xCoord && y_player == minion3_yCoord) ||
					  (x_player == minion4_xCoord && y_player == minion4_yCoord) || (x_player == minion5_xCoord && y_player == minion5_yCoord))  // player collide with any minion
            begin
                     reset_game = 1'b1;
                     score = 5'b00000;
            end
        else
		  begin
            reset_game = 1'b0;
				score = score;
		  end
    end
endmodule				  


module control(clk, move_r, move_l, move_d, move_u, reset_n, ld_x, ld_y, stateNum, reset_game, press_counter, how_fast);
    input [25:0] press_counter;
    input reset_game;
    input clk, move_r, move_l, move_d, move_u, reset_n;
	 input [1:0] how_fast;
    output reg ld_y, ld_x;
    reg [3:0] curr, next;
    output reg [3:0] stateNum;
    localparam    S_CLEAR    = 4'b0000;
    localparam S_LOAD_X    = 4'b0001;
    localparam S_WAIT_Y    = 4'b0010;
    localparam S_LOAD_Y    = 4'b0011;
   
    localparam    wait_input    = 4'b0100;
    localparam    clear_all    = 4'b0101;
    localparam    print_right    = 4'b0110;
    localparam    print_left    = 4'b0111;
    localparam    print_down    = 4'b1000;
    localparam    print_up    = 4'b1001;
    localparam  temp_selecting_state = 4'b1010;
    localparam after_drawing = 4'b1011;
    localparam cleanUp = 4'b1100;
    wire [26:0] press_now;   
    wire [26:0] press_now_for_car;   
    wire result_press_now;
	 reg [25:0] speed;
    //wire result_for_car;
    
	 always @(*)
	 begin
		if (how_fast == 2'b00)
		   speed <= 26'b0101111101011110000100;

		else if (how_fast == 2'b01)
		   speed <= 26'b010111110101111000010;
	   else if (how_fast == 2'b10)
		   speed <= 26'b010111110101111000010;
		else
		   speed <= 26'b01011111010111100001;
	 end
	 RateDivider player_counter1(clk, press_now, reset_n, speed);
	 
    assign result_press_now = (press_now == press_counter) ? 1 : 0;
   
    always @(*)
    begin: state_table
        case (curr)
            S_CLEAR: next = S_LOAD_X ;
            S_LOAD_X: next = S_WAIT_Y;
            S_WAIT_Y: next = S_LOAD_Y;

            S_LOAD_Y: next = temp_selecting_state; // the next line is edited on Mar 27
            temp_selecting_state: next = reset_game ? cleanUp : ( ((move_r || move_l || move_d || move_u) && result_press_now) ? clear_all : S_LOAD_Y );
           
            clear_all:
                begin
                    if(move_r)  
                        next <= print_right;
                    else if (move_l)    // if player isnt moving, then let the car move
                        next <= print_left;
                    else if (move_d)   // if player isnt moving, then let the car move
                        next <= print_down;
                    else if (move_u)   // if player isnt moving, then let the car move
                        next <= print_up;
                end
            cleanUp: next = S_CLEAR;
            //
            print_right: next = reset_game ? S_LOAD_Y : after_drawing;
            print_left: next =  reset_game ? S_LOAD_Y : after_drawing;
            print_down: next = reset_game ? S_LOAD_Y : after_drawing;
            print_up: next = reset_game ? S_LOAD_Y : after_drawing;
            after_drawing: next= temp_selecting_state;
           
        default: next = S_CLEAR;
        endcase
    end

    always@(*)
    begin: enable_signals
        ld_x = 1'b0;
        ld_y = 1'b0;
        stateNum = 4'b0000;
        case (curr)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
					 
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
					 
            cleanUp: begin
                stateNum = 4'b0001;
                ld_y = 1'b0;
                end
					 
            clear_all: begin
                stateNum = 4'b0001;
                ld_y = 1'b0;
                end
           
            print_right: begin
                stateNum = 4'b0100;
                ld_y = 1'b0;
                end
           
            print_down: begin
                stateNum = 4'b0011;
                ld_y = 1'b0;
                end				  
               
            print_left: begin
                stateNum = 4'b0010;
                ld_y = 1'b0;
                end
               
            print_up: begin
                stateNum = 4'b1001;
                ld_y = 1'b0;
                end
               
            after_drawing: begin
                stateNum = 4'b1000;
                end  
        endcase
    end

    always @(posedge clk)
    begin: states
        if(!reset_n)
            curr <= S_LOAD_X;
        else
            curr <= next;
    end
endmodule

// this module monitors horizontal/vertical movements of the player - restricting at certain spots
module datapath(clk, ld_x, ld_y, in, reset_n, x, y, colour, stateNum, write, init_y, acolour, restrict_ladder_movement);
    input clk;
	 input restrict_ladder_movement;
    input [7:0] in;
    input [6:0] init_y;
    input [2:0] acolour;
    input ld_x, ld_y;
    input reset_n;
	 input [3:0] stateNum;
	 
    output reg [2:0] colour;
    output reg write;
    output reg [6:0] y;
    output reg [7:0] x;

    always @(posedge clk)
    begin
        if(!reset_n)
        begin
            x <= 7'b0000000;
            y <= 6'b000000;
            colour <= 3'b000;
        end
        else
        begin       
            if(ld_x)
                begin
                    x[7:0] <= in;
                    y <= init_y;
                    write <= 1'b0;
                end
            else if(ld_y)  
                begin
                    write <= 1'b0;
                end
               
            // The following is for clearing
            else if(stateNum == 4'b0001)
                begin
                    colour <= 3'b000;
                    write <= 1'b1;
                end
               
            // Moving Right Logic
            else if(stateNum == 4'b0100)   
                begin
						if (restrict_ladder_movement && ((x == 8'b01111110 && (y <= 7'b1110100 && y >= 7'b1010110)) || (x == 8'b00010000 && (y <= 7'b1010100 && y >= 7'b0111001)) || (x == 8'b01111110 && (y <= 7'b0110111 && y >= 7'b0011011))))
							begin
							  x[7:0] <= x;
							  colour <= acolour;
							  write <= 1'b1;
							end
						  else if (x == 8'b01111110)
					       begin
								x <= 8'b00000000;
								colour <= acolour;
							  write <= 1'b1;
							 end
						  else
						  begin
							  x[7:0] <= x + 8'b00000001;
							  colour <= acolour;
							  write <= 1'b1;
						  end
						 end
               
            // Moving Left Logic
            else if(stateNum == 4'b0010)   
                begin
					   if (restrict_ladder_movement && ((x == 8'b01111110 && (y <= 7'b1110100 && y >= 7'b1010110)) || (x == 8'b00010000 && (y <= 7'b1010100 && y >= 7'b0111001)) || (x == 8'b01111110 && (y <= 7'b0110111 && y >= 7'b0011011))))
						begin
                    x[7:0] <= x;
                    colour <= acolour;
                    write <= 1'b1;
						end
						else if (x == 8'b0000000)
					       begin
								x <= 8'b01111110;
								colour <= acolour;
							  write <= 1'b1;// can't exactly fix horizontal movements whilst on ladders w/o creating an entirely new datapath modu
							 end
						else
						  begin
                    x[7:0] <= x - 8'b00000001;
                    colour <= acolour;
                    write <= 1'b1;
						  end
                end
               
            // Moving Down Logic
            else if(stateNum == 4'b0011)
					 begin
							begin
							if (x == 8'b01111110 && (y <= 7'b1110100 && y >= 7'b1010101)) // only allow down at ladder - bottom row 
								begin
						  
								  y[6:0] <= y + 7'b0000001;
								  colour <= acolour;
								  write <= 1'b1;
								end
							else if (x == 8'b00010000 && (y <= 7'b1010100 && y >= 7'b0111000)) // only allow up at ladder - middle row
								begin
									y[6:0] <= y + 7'b0000001;
									colour <= acolour;
									write <= 1'b1;
								end
							else if (x == 8'b01111110 && (y <= 7'b0110111 && y >= 7'b0011010)) // only allow up at ladder - top row 
								begin
								  y[6:0] <= y + 7'b0000001;
								  colour <= acolour;
								  write <= 1'b1;
								end	
							else
							      y[6:0] <= y; 
							      colour <= acolour;		
									write <= 1'b1;
							
							end
                end
					 
            // Moving Up Logic
            else if(stateNum == 4'b1001)
                begin
							begin
							if (x == 8'b01111110 && (y <= 7'b1110101 && y >= 7'b1010110)) // only allow up at ladder - bottom row 
								begin
						  
								  y[6:0] <= y - 7'b0000001;
								  colour <= acolour;
								  write <= 1'b1;
								end
							else if (x == 8'b00010000 && (y <= 7'b1010110 && y >= 7'b0111001)) // only allow up at ladder - middle row
								begin
									y[6:0] <= y - 7'b0000001;
									colour <= acolour;
									write <= 1'b1;
								end
							else if (x == 8'b01111110 && (y <= 7'b0111101 && y >= 7'b0011011)) // only allow up at ladder - top row 
								begin
								  y[6:0] <= y - 7'b0000001;
								  colour <= acolour;
								  write <= 1'b1;
								end
							else
							      y[6:0] <= y; 
							      colour <= acolour;		
									write <= 1'b1;
							end
                end
               
            else if(stateNum == 4'b1000)//after drawing
                begin
                    write <= 1'b0;
                end
        end
    end
endmodule
   
   
module RateDivider (clock, q, Clear_b, Max_num); 
    input [0:0] clock;
    input [0:0] Clear_b;
	 input [25:0] Max_num;
    output reg [26:0] q; // declare q
    always@(posedge clock)   // triggered every time clock rises
    begin
        if (q == Max_num) // when q is the maximum value for the counter
            q <= 0; // q reset to 0
        else if (clock == 1'b1) // increment q only when Enable is 1
            q <= q + 1'b1;  // increment q
    end
endmodule


// The hex display for showing the level of the player
module hex_display(score_in, score_out1, score_out2);
   input [4:0] score_in;
   output reg [6:0] score_out1, score_out2;
     always @(*)
     begin
        case(score_in[4:0])
            5'b00000:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b1000000;
                end
            5'b00001:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b1111001;
                end
            5'b00010:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0100100;
                end
            5'b00011:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0110000;
                end
            5'b00100:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0011001;
                end
            5'b00101:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0010010;
                end
            5'b00110:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0000010;
                end
            5'b00111:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b1111000;
                end
            5'b01000:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0000000;
                end
            5'b01001:
                begin
                    score_out1 = 7'b1000000;
                    score_out2 = 7'b0011000;
                end
            5'b01010:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b1000000;
                end
            5'b01011:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b1111001;
                end
            5'b01100:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0100100;
                end
            5'b01101:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0110000;
                end
            5'b01110:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0011001;
                end
            5'b01111:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0010010;
                end
            5'b10000:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0000010;
                end
            5'b10001:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b1111000;
                end
            5'b10010:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0000000;
                end
            5'b10011:
                begin
                    score_out1 = 7'b1111001;
                    score_out2 = 7'b0011000;
                end
            5'b10100:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b1000000;
                end
            5'b10101:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b1111001;
                end
            5'b10110:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0100100;
                end
            5'b10111:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0110000;
                end
            5'b11000:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0011001;
                end
            5'b11001:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0010010;
                end
            5'b11010:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0000010;
                end
            5'b11011:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b1111000;
                end
            5'b11100:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0000000;
                end
            5'b11101:
                begin
                    score_out1 = 7'b0100100;
                    score_out2 = 7'b0011000;
                end
            5'b11110:
                begin
                    score_out1 = 7'b0110000;
                    score_out2 = 7'b1000000;
                end
            5'b11111:
                begin
                    score_out1 = 7'b0110000;
                    score_out2 = 7'b0100100;
                end
           
            default:
                begin
                    score_out1 = 7'b0110000;
                    score_out2 = 7'b1111111;
                end
        endcase
    end
endmodule
