; Copyright Melbourne House 1985, 2023 ArcadeGeek LTD.
; NOTE: Disassembly is Work-In-Progress.
; Label naming is loosely based on Action_ActionName_SubAction e.g. Print_HighScore_Loop.

> $4000 @org=$4000
> $4000 @expand=#DEFINE0(BUG,#LINK:Bugs)
> $4000 @expand=#DEFINE0(FACT,#LINK:Facts)
> $4000 @expand=#DEFINE0(POKE,#LINK:Pokes)
b $4000 Loading screen
D $4000 #UDGTABLE { #SCR2(loading) | The Way Of The Exploding Fist Loading Screen. } UDGTABLE#
@ $4000 label=Loading
  $4000,$1800,$20 Pixels
  $5800,$0300,$20 Attributes

s $5B00

g $5F00 Background Reference
@ $5F00 label=Background_Reference
D $5F00 Used by the routine at #R$5F3C. Can be either; #LIST { #N$01 } { #N$02 } { #N$03 } LIST#
. This represents which background is shown.

g $5F01 Unused.
S $5F01

g $5F02 Background screen buffer
W $5F02 Holds current screen location
@ $5F02 label=Background_Screen_Address
W $5F04 Background UDG reference buffer.
@ $5F04 label=Background_Current_UDG
W $5F08 Holds currently processed UDG data block.
@ $5F08 label=Background_UDG_Data
N $5F0A Used with the indirect jump at #R$5F46/ #R$5F52.
W $5F0A,$02 Location of code to copy background 1 reference data.
@ $5F0A label=Copy_Background_1
W $5F0C,$02 Location of code to copy background 2 reference data.
@ $5F0C label=Copy_Background_2
W $5F0E,$02 Location of code to copy background 3 reference data.
@ $5F0E label=Copy_Background_3

g $5F10 Background address buffer
@ $5F10 label=Background_Data_Buffer
D $5F10 Buffer that holds the currently processed background data depending on the background reference value.
. #TABLE(default,centre,centre)
. { =h #R$5F00 | =h Background Data }
. { #N$01 | #R$602B }
. { #N$02 | #R$603D }
. { #N$03 | #R$604F }
. TABLE#
. Populated from one of #R$5F53, #R$5F62 or #R$5F71.
W $5F10,$04 Block 1.
W $5F14,$04 Block 2.
W $5F18,$04 Block 3.
W $5F1C,$04 Block 4.
W $5F20 Attribute data.

c $5F22 Change Background.
@ $5F22 label=Change_Background
D $5F22 #HTML(Takes the background reference from #R$5F00 and executes the appropriate routine to copy the background data
.       addresses to the buffer at #R$5F10.
.       <div>Used by the routine at #R$9200.</div>)
N $5F22 Blanks the screen.
  $5F22,$0D Writes #N$3F to all #N$300 locations of the attributes buffer.
. #TABLE(default,centre,centre,centre,centre)
. { =h Value | =h Ink | =h Paper | =h Bright }
. { #N$3F | #N$07 | #N$07 | #N$00 }
. TABLE#
. This is white ink on white paper.
  $5F2F,$0D Writes #N$00 to all #N$1800 locations of the screen buffer.
N $5F3C Fetch the background reference from #R$5F00 and use it to calculate the address for the copy-to-buffer routine.
  $5F3C,$04 Loads #REGa with the contents of #R$5F00.
  $5F40,$02 Decrease it by one, then double it.
  $5F42,$03 Store it as the LSB of #REGbc (MSB is #N$00).
  $5F45,$01 Write #N$00 to #R$5F00.
  $5F46,$03 #REGhl=The beginning of three address references for the copy routines which populate #R$5F10 at
.           #R$5F0A($5F0A).
  $5F49,$01 Add #REGbc to #REGhl.
  $5F4A,$03 #REGde=One of the three background address references;
. #TABLE(default,centre,centre)
. { =h #R$5F00 | =h Address Reference }
. { #N$01 | #R$5F0A($5F0A) }
. { #N$02 | #R$5F0C($5F0C) }
. { #N$03 | #R$5F0E($5F0E) }
. TABLE#
  $5F4D,$01 Swap #REGde and #REGhl.
  $5F4E,$03 Call #R$5F52.
  $5F51,$01 Return.
N $5F52 Indirect jump to copy-to-buffer routine.
@ $5F52 label=Indirect_Jump
  $5F52,$01 Indirect jump to address held by #REGhl.
. #TABLE(default,centre,centre)
. { =h #R$5F00 | =h Jumps To... }
. { #N$01 | #R$5F53 }
. { #N$02 | #R$5F62 }
. { #N$03 | #R$5F71 }
. TABLE#

N $5F53 Set up background 1.
  $5F53,$0B Copies #N$12 bytes of data from #R$602B to #R$5F10.
  $5F5E,$03 Call #R$5F80.
  $5F61,$01 Return.

N $5F62 Set up background 2.
  $5F62,$0B Copies #N$12 bytes of data from #R$603D to #R$5F10.
  $5F6D,$03 Call #R$5F80.
  $5F70,$01 Return.

N $5F71 Set up background 3.
  $5F71,$0B Copies #N$12 bytes of data from #R$604F to #R$5F10.
  $5F7C,$03 Call #R$5F80.
  $5F7F,$01 Return.

c $5F80 Creates the background image.
N $5F80 Each background uses 4 sets of data "pairs" and a single reference for attribute data (handled separately at
. #R$6010). For example, #R$602B(background 1) uses;
. #TABLE(default,centre,centre,centre)
. { =h Block | =h UDGs | =h Data }
. { #N$01 | #R$626A | #R$6102 }
. { #N$02 | #R$648A | #R$6157 }
. { #N$03 | #R$685A | #R$61D9 }
. { #N$04 | #R$6AE2 | #R$624D }
. { =h,c2 Attribute Data | #R$6061 }
. TABLE#
@ $5F80 label=Create_Background
  $5F80,$06 The first screen address is #N$4080 which allows space for the "header". This is the top of character block 4.
.           This is then stored in the buffer at #R$5F02.
  $5F86,$03 #REGhl=#R$5F10(Background address data buffer).
N $5F89 Each background has 4 "sets" of data, so set a counter of 4.
  $5F89,$02 #REGb=Initialise block counter.
N $5F8B The block processing loop.
  $5F8B,$01 Push the counter onto the stack.
@ $5F8B label=Create_Background_Loop
N $5F8C Each block contains two address references, one is for UDG data, and one is for positioning data.
  $5F8C,$08 Pick up the next background UDG data block and store it at #R$5F08.
  $5F94,$04 Fetch the address of the next positioning data block and store it in #REGde.
  $5F98,$01 Push the position of the address data buffer (pointing to the start of the next block) onto the stack.
N $5F99 Set up the current screen position, the positioning data and the UDG data block.
  $5F99,$03 #REGhl=The current screen address from #R$5F02.
  $5F9C,$01 Switch #REGde and #REGhl so #REGde now holds the screen address and #REGhl holds the start of the
.           positioning data block.
  $5F9D,$03 Call #R$5FBE.
  $5FB2,$02 Restores #REGhl and the counter from the stack.
  $5FB4,$02 Decrease counter by one and loop back to #R$5F8B until counter is zero.
N $5FB6 Finally, now write the attributes and return.
  $5FB6,$07 Fetch the last address from the #R$5F10(Background address data buffer) which is the attributes data and
.           call #R$6010 to process and display in the attributes buffer.
  $5FBD,$01 Return.
N $5FA0 fgg
  $5FA0,$03 #REGhl=The current screen address from #R$5F02.
  $5FA3,$04 Add #N$0080 to #REGhl.
  $5FA7,$04 Set the zero flag if we're at a screen section boundary. Skip forward to #R$5FAF if not.
  $5FAB,$04 Add #N$07 to the MSB of #REGhl to handle moving between screen sections.
@ $5FAF label=Background_No_Boundary
  $5FAF,$03 Stash #REGhl at #R$5F02.
N $5FBE Fetch the next positioning data and check for the terminator.
@ $5FBE label=Background_Fetch_Next
  $5FBE,$01 Fetch the next positioning data byte.
  $5FBF,$01 Increase #REGhl by one to point to the next byte.
  $5FC0,$01 Check if this byte is the same as the previous positioning data byte value.
  $5FC1,$02 Jump to #R$5FC6 if the values are different.
  $5FC3,$03 Double zero is the terminator, so jump to #R$5FF3 to return if this is detected.
N $5FC6 Process the UDG data.
@ $5FC6 label=Background_Process
  $5FC6,$04 Check if d7 is set, reset it regardless.
  $5FCA,$01 Push the new positioning data value onto the stack.
  $5FCB,$01 Exchange the registers.
N $5FCC Point #REGhl to the base address of the currently referenced UDG.
  $5FCC,$03 Set the LSB of #REGbc to #REGa, and the MSB to #N$00.
  $5FCF,$02 Copy the same value into #REGhl.
  $5FD1,$03 * 8.
  $5FD4,$04 #REGbc=Fetch the address of the start of the UDG data block from #R$5F08.
  $5FD8,$04 Choose the referenced UDG and store this at #R$5F04.
  $5FDC,$01 Restore the registers.
  $5FDD,$03 Call #R$5FF4.
  $5FE0,$03 Call #R$6007.
N $5FE3 Check if the flag for repetition is set, if so - action it. If not, jump and work on the next position.
  $5FE3,$01 Fetch the position data off the stack, as this is #REGaf this also restores the d7 check flag.
  $5FE4,$02 Jump back to #R$5FBE unless the bit was set.
N $5FE6 Using the following position data byte as a counter, copy the current byte this number of times.
  $5FE6,$01 Pick up the position data from #REGhl and store it in #REGb to use as a counter.
  $5FE7,$01 Increment #REGhl to point to the next item of position data.
  $5FE8,$01 Decrease the counter by one.
@ $5FE9 label=Background_Repeat_Copy
  $5FE9,$03 Call #R$5FF4.
  $5FEC,$03 Call #R$6007.
  $5FEF,$02 Decrease counter by one and loop back to #R$5FE9 until the counter is zero.
  $5FF1,$02 Jump back round to #R$5FBE.
N $5FF3 Used to "just return" after flag checking operations.
@ $5FF3 label=Background_Return
  $5FF3,$01 Return.
@ $5FF4 label=Copy_UDG
N $5FF4 Copy a single UDG 8x8 block to the screen.
  $5FF4,$02 Push #REGde (current screen location) and #REGhl (next position data location) onto the stack.
  $5FF6,$02 Set a counter of #N$08 for the number of lines in a character block.
  $5FF8,$03 #REGhl=#R$5F04(the currently targeted UDG address).
@ $5FFB label=Copy_UDG_Loop
  $5FFB,$01 Stash the counter for later.
  $5FFC,$02 Copy the UDG data held by #REGhl into the screen buffer currently pointed to by #REGde.
  $5FFE,$01 Increment #REGhl by one to point to the next line of the UDG data.
  $5FFF,$01 Increment the MSB of #REGde by one to point to the line directly below in the screen buffer.
  $6000,$01 Restore the counter.
  $6001,$01 Decrease the counter by one.
  $6002,$02 Loop back to #R$5FFB until the counter is zero.
  $6004,$02 Restore the original #REGhl and #REGde values for screen location and position data from the stack.
  $6006,$01 Return.
N $6007 Handles moving from one screen location block to the next.
@ $6007 label=Background_Next_Screen_Block
  $6007,$01 Increase #REGde by 1.
  $6008,$03 Return if d0 is not set on the MSB of #REGde. This checks to see if we're at a screen boundary.
  $600B,$04 Add #N$07 to #REGd, so that #REGde points to the next block down.
  $600F,$01 Return.

c $6010 Unpack background attribute data.
@ $6010 label=Background_Attributes
N $6010 Unpacks the attribute data into the buffer. On entry #REGhl will contain one of the following background
. reference memory locations;
. #TABLE(default,centre,centre)
. { =h Background reference | =h Background data }
. { #N$01 | #R$6061 }
. { #N$02 | #R$6B83 }
. { #N$03 | #R$7766 }
. TABLE#
. The idea here is to use bit 7 (flash) as a flag to signify to copy the attrbute byte a specified number of times. For
. example;
. #TABLE(default,centre,centre,centre,centre)
. { =h Address | =h Value | =h Binary | =h Value After Reset }
. { #N$6061 | #N(#PEEK($6061)) | #EVAL(#PEEK($6061),$02,$08) | #N(#EVAL(#PEEK$6061-128)) }
. { #N$6062 | #N(#PEEK($6062)) |  |  }
. TABLE#
. So, in #N$6061 bit 7 is set - after a reset we take #N$6062 as a counter and hence copy #N(#EVAL(#PEEK$6061-128)) into
. the following #PEEK($6062) memory locations.
  $6010,$03 Begin at the start of the #R$5800.
  $6013,$01 Pick up the attribute data from #REGhl.
@ $6013 label=Background_Attributes_Loop
  $6014,$01 Increase #REGhl by one.
  $6015,$03 If the following byte is different to the current attribute byte jump to #R$601A.
  $6018,$02 The data terminates with double zeroes, so if this occurs then return.
  $601A,$04 Test if d7 is set in current attribute data. Reset bit to zero.
N $601A Copy and loop back round to #R$6013 until bit 7 in the current attribute data is set.
@ $601A label=Background_Attributes_Repeat_Copy
  $601E,$01 Write the attribute data to #REGde.
  $601F,$01 Increment #REGde by one.
  $6020,$02 Jump back to #R$6013 unless the bit was set.
N $6022 Using the following attribute data byte as a counter, copy the current byte this number of times.
  $6022,$01 Pick up the attribute data from HL into #REGb to use as a counter.
  $6023,$01 Increase #REGhl by one.
  $6024,$01 Decrease the counter by one.
@ $6025 label=Background_Copy_Attribute_Repeat
  $6025,$01 Write the same attribute data to #REGde.
  $6026,$01 Increment #REGde by one.
  $6027,$02 Decrease counter by one and loop back to #R$6025 until counter is zero.
  $6029,$02 Jump back to #R$6013.

b $602B Background 1 Address references.
D $602B The data blocks containing UDG, positioning and attribute data.
N $602B #BACKGROUND1,$01(background_1)
@ $602B label=Background_1_Addresses
W $602B,$04 Block #N$01.
W $602F,$04 Block #N$02.
W $6033,$04 Block #N$03.
W $6037,$04 Block #N$04.
W $603B Attribute data.
@ $603B label=Background_1_Attribute_Data

b $603D Background 2 Address references.
D $603D The data blocks containing UDG, positioning and attribute data.
N $603D #BACKGROUND2,$01(background_2)
@ $603D label=Background_2_Addresses
W $603D,$04 Block #N$01.
W $6041,$04 Block #N$02.
W $6045,$04 Block #N$03.
W $6049,$04 Block #N$04.
W $604D Attribute data.
@ $604D label=Background_2_Attribute_Data

b $604F Background 3 Address references.
D $604F The data blocks containing UDG, positioning and attribute data.
N $604F #BACKGROUND3,$01(background_3)
@ $604F label=Background_3_Addresses
W $604F,$04 Block #N$01.
W $6053,$04 Block #N$02.
W $6057,$04 Block #N$03.
W $605B,$04 Block #N$04.
W $605F Attribute data.
@ $605F label=Background_3_Attribute_Data

b $6061 Background 1 attribute data.
D $6061 See #R$6010 for usage.
B $6100,$02 Terminator.
b $6102 Background 1 positioning data.
D $6102 See #R$5F80 for usage.
B $6102 #CALL:position_data(#PC, $626A, position_1_1, 1)
B $6155,$02 Terminator.
b $6157 Background 1 positioning data.
D $6157 See #R$5F80 for usage.
B $6157 #CALL:position_data(#PC, $648A, position_1_2, 1)
B $61D7,$02 Terminator.
b $61D9 Background 1 positioning data.
D $61D9 See #R$5F80 for usage.
B $61D9 #CALL:position_data(#PC, $685A, position_1_3, 1)
B $624B,$02 Terminator.
b $624D Background 1 positioning data.
D $624D See #R$5F80 for usage.
B $624D #CALL:position_data(#PC, $6AE2, position_1_4, 1)
B $6268,$02 Terminator.
b $626A Background 1 tile data.
B $626A,$08 #UDG(#PC,attr=56)
L $626A,$08,$44
b $648A Background 1 tile data.
B $648A,$08 #UDG(#PC,attr=56)
L $648A,$08,$7A
b $685A Background 1 tile data.
B $685A,$08 #UDG(#PC,attr=56)
L $685A,$08,$51
b $6AE2 Background 1 tile data.
B $6AE2,$08 #UDG(#PC,attr=56)
L $6AE2,$08,$14
u $6B82
b $6B83 Background 2 attribute data.
D $6B83 See #R$6010 for usage.
B $6C49,$02 Terminator.
b $6C4B Background 2 positioning data.
D $6C4B See #R$5F80 for usage.
B $6C4B #CALL:position_data(#PC, $6DAE, position_2_1, 1)
B $6C77,$02 Terminator.
b $6C79 Background 2 positioning data.
D $6C79 See #R$5F80 for usage.
B $6C79 #CALL:position_data(#PC, $6E96, position_2_2, 1)
B $6CF5,$02 Terminator.
b $6CF7 Background 2 positioning data.
D $6CF7 See #R$5F80 for usage.
B $6CF7 #CALL:position_data(#PC, $720E, position_2_3, 1)
B $6D77,$02 Terminator.
b $6D79 Background 2 positioning data.
D $6D79 See #R$5F80 for usage.
B $6D79 #CALL:position_data(#PC, $7606, position_2_4, 1)
B $6DAC,$02 Terminator.
b $6DAE Background 2 tile data.
B $6DAE,$08 #UDG(#PC,attr=56)
L $6DAE,$08,$1D
b $6E96 Background 2 tile data.
B $6E96,$08 #UDG(#PC,attr=56)
L $6E96,$08,$6F
b $720E Background 2 tile data.
B $720E,$08 #UDG(#PC,attr=56)
L $720E,$08,$7F
b $7606 Background 2 tile data.
B $7606,$08 #UDG(#PC,attr=56)
L $7606,$08,$2C
b $7766 Background 3 attribute data.
D $7766 See #R$6010 for usage.
B $784D,$02 Terminator.
b $784F Background 3 positioning data.
D $784F See #R$5F80 for usage.
B $784F #CALL:position_data(#PC, $79B1, position_3_1, 1)
B $7891,$02 Terminator.
b $7893 Background 3 positioning data.
D $7893 See #R$5F80 for usage.
B $7893 #CALL:position_data(#PC, $7BB1, position_3_2, 1)
B $790E,$02 Terminator.
b $7910 Background 3 positioning data.
D $7910 See #R$5F80 for usage.
B $7910 #CALL:position_data(#PC, $7D09, position_3_3, 1)
B $798F,$02 Terminator.
b $7991 Background 3 positioning data.
D $7991 See #R$5F80 for usage.
B $7991 #CALL:position_data(#PC, $7F39, position_3_4, 1)
B $79AF,$02 Terminator.
b $79B1 Background 3 tile data.
B $79B1,$08 #UDG(#PC,attr=56)
L $79B1,$08,$40
b $7BB1 Background 3 tile data.
B $7BB1,$08 #UDG(#PC,attr=56)
L $7BB1,$08,$2B
b $7D09 Background 3 tile data.
B $7D09,$08 #UDG(#PC,attr=56)
L $7D09,$08,$46
b $7F39 Background 3 tile data.
B $7F39,$08 #UDG(#PC,attr=56)
L $7F39,$08,$0E

b $8000 Shadow buffer
@ $8000 label=Shadow_Buffer
D $8000 Once a background is unpacked and displayed, #N$4820-#N$5020 are copied to this shadow buffer to
.       allow the background layer to be drawn quickly (without rerunning the unpacking routines at #R$5F80).
D $8000 #UDGTABLE
. { #SHADOWBUFF1,$02{y=$50}(shadow-screen-1) }
. { #SHADOWBUFF2,$02{y=$50}(shadow-screen-2) }
. { #SHADOWBUFF3,$02{y=$50}(shadow-screen-3) }
. UDGTABLE#
D $8000 Used by the routine at #R$9200.
B $8000,$800,$20 Pixels

c $8800
c $8833

c $8898
  $889C

c $8A30
C $8AA2,$03 Jump to #R$8833.

c $8AD1
C $8AE8,$01 Return.

g $8BD2 Player 1 controls.
D $8BD2 Points to the address containing the player 1 control address mappings.
W $8BD2 Player 2 control address mappings.
@ $8BD2 label=Player_1_Controls

g $8BD4 Player 1 redefined keys.
D $8BD4 When player 1 is using the keyboard, these byte pairs will be populated with the corresponding keys.
N $8BD4 #TABLE(default,centre,centre) { =h MSB | =h LSB } { Port | Bits } TABLE#
.       See #R$8E3A.
B $8BD4,$02 Player 1 - "up" key.
@ $8BD4 label=Player_1_Up
B $8BD6,$02 Player 1 - "up/ right" key.
@ $8BD6 label=Player_1_Up_Right
B $8BD8,$02 Player 1 - "right" key.
@ $8BD8 label=Player_1_Right
B $8BDA,$02 Player 1 - "down/ right" key.
@ $8BDA label=Player_1_Down_Right
B $8BDC,$02 Player 1 - "down" key.
@ $8BDC label=Player_1_Down
B $8BDE,$02 Player 1 - "down/ left" key.
@ $8BDE label=Player_1_Down_Left
B $8BE0,$02 Player 1 - "left" key.
@ $8BE0 label=Player_1_Left
B $8BE2,$02 Player 1 - "up/ left" key.
@ $8BE2 label=Player_1_Up_Left
B $8BE4,$02 Player 1 - "fire" key.
@ $8BE4 label=Player_1_Fire

g $8BE6 Player 2 controls.
D $8BE6 Points to the address containing the player 2 control address mappings.
W $8BE6 Player 2 control address mappings.
@ $8BE6 label=Player_2_Controls

g $8BE8 Player 2 redefined keys.
D $8BE8 When player 2 is using the keyboard, these byte pairs will be populated with the corresponding keys.
N $8BE8 #TABLE(default,centre,centre) { =h MSB | =h LSB } { Port | Bits } TABLE#
.       See #R$8E3A.
B $8BE8,$02 Player 2 - "up" key.
@ $8BE8 label=Player_2_Up
B $8BEA,$02 Player 2 - "up/ right" key.
@ $8BEA label=Player_2_Up_Right
B $8BEC,$02 Player 2 - "right" key.
@ $8BEC label=Player_2_Right
B $8BEE,$02 Player 2 - "down/ right" key.
@ $8BEE label=Player_2_Down_Right
B $8BF0,$02 Player 2 - "down" key.
@ $8BF0 label=Player_2_Down
B $8BF2,$02 Player 2 - "down/ left" key.
@ $8BF2 label=Player_2_Down_Left
B $8BF4,$02 Player 2 - "left" key.
@ $8BF4 label=Player_2_Left
B $8BF6,$02 Player 2 - "up/ left" key.
@ $8BF6 label=Player_2_Up_Left
B $8BF8,$02 Player 2 - "fire" key.
@ $8BF8 label=Player_2_Fire

g $8BFA Player 1 default keys.
D $8BFA See #R$8E3A for key mappings.
B $8BFA,$12,$02 #TABLE(default,centre,centre,centre,centre)
. { =h Port Number | =h Bit | =h Action | =h Key }
. { #N(#PEEK($8BFB)) | #EVAL(#PEEK($8BFA),$02,$08) | Up | "#CALL:get_key(#PEEK($8BFB), #PEEK($8BFA))" }
. { #N(#PEEK($8BFD)) | #EVAL(#PEEK($8BFC),$02,$08) | Up-Right | "#CALL:get_key(#PEEK($8BFD), #PEEK($8BFC))" }
. { #N(#PEEK($8BFF)) | #EVAL(#PEEK($8BFE),$02,$08) | Right | "#CALL:get_key(#PEEK($8BFF), #PEEK($8BFE))" }
. { #N(#PEEK($8C01)) | #EVAL(#PEEK($8C00),$02,$08) | Down-Right | "#CALL:get_key(#PEEK($8C01), #PEEK($8C00))" }
. { #N(#PEEK($8C03)) | #EVAL(#PEEK($8C02),$02,$08) | Down | "#CALL:get_key(#PEEK($8C03), #PEEK($8C02))" }
. { #N(#PEEK($8C05)) | #EVAL(#PEEK($8C04),$02,$08) | Down-Left | "#CALL:get_key(#PEEK($8C05), #PEEK($8C04))" }
. { #N(#PEEK($8C07)) | #EVAL(#PEEK($8C06),$02,$08) | Left | "#CALL:get_key(#PEEK($8C07), #PEEK($8C06))" }
. { #N(#PEEK($8C09)) | #EVAL(#PEEK($8C08),$02,$08) | Up-Left | "#CALL:get_key(#PEEK($8C09), #PEEK($8C08))" }
. { #N(#PEEK($8C0B)) | #EVAL(#PEEK($8C0A),$02,$08) | Fire | "#CALL:get_key(#PEEK($8C0B), #PEEK($8C0A))" }
. TABLE#
@ $8BFA label=P1_Default_Keys

g $8C0C Player 2 default keys.
D $8C0C See #R$8E3A for key mappings.
B $8C0C,$12,$02  #TABLE(default,centre,centre,centre,centre)
. { =h Port Number | =h Bit | =h Action | =h Key }
. { #N(#PEEK($8C0D)) | #EVAL(#PEEK($8C0C),$02,$08) | Up | "#CALL:get_key(#PEEK($8C0D), #PEEK($8C0C))" }
. { #N(#PEEK($8C0F)) | #EVAL(#PEEK($8C0E),$02,$08) | Up-Right | "#CALL:get_key(#PEEK($8C0F), #PEEK($8C0E))" }
. { #N(#PEEK($8C11)) | #EVAL(#PEEK($8C10),$02,$08) | Right | "#CALL:get_key(#PEEK($8C11), #PEEK($8C10))" }
. { #N(#PEEK($8C13)) | #EVAL(#PEEK($8C12),$02,$08) | Down-Right | "#CALL:get_key(#PEEK($8C13), #PEEK($8C12))" }
. { #N(#PEEK($8C15)) | #EVAL(#PEEK($8C14),$02,$08) | Down | "#CALL:get_key(#PEEK($8C15), #PEEK($8C14))" }
. { #N(#PEEK($8C17)) | #EVAL(#PEEK($8C16),$02,$08) | Down-Left | "#CALL:get_key(#PEEK($8C17), #PEEK($8C16))" }
. { #N(#PEEK($8C19)) | #EVAL(#PEEK($8C18),$02,$08) | Left | "#CALL:get_key(#PEEK($8C19), #PEEK($8C18))" }
. { #N(#PEEK($8C1B)) | #EVAL(#PEEK($8C1A),$02,$08) | Up-Left | "#CALL:get_key(#PEEK($8C1B), #PEEK($8C1A))" }
. { #N(#PEEK($8C1D)) | #EVAL(#PEEK($8C1C),$02,$08) | Fire | "#CALL:get_key(#PEEK($8C1D), #PEEK($8C1C))" }
. TABLE#
@ $8C0C label=P2_Default_Keys

g $8C1E Sinclair Joystick #2.
D $8C1E See #R$8E3A for key mappings.
N $8C1E Note the Sinclair joystick maps directional movements and fire to keys.
B $8C1E,$12,$02  #TABLE(default,centre,centre,centre,centre)
. { =h Port Number | =h Bit | =h Action | =h Key }
. { #N(#PEEK($8C1F)) | #EVAL(#PEEK($8C1E),$02,$08) | Up | "#CALL:get_key(#PEEK($8C1F), #PEEK($8C1E))" }
. { #N(#PEEK($8C21)) | #EVAL(#PEEK($8C20),$02,$08) | Up-Right | - }
. { #N(#PEEK($8C23)) | #EVAL(#PEEK($8C22),$02,$08) | Right | "#CALL:get_key(#PEEK($8C23), #PEEK($8C22))" }
. { #N(#PEEK($8C25)) | #EVAL(#PEEK($8C24),$02,$08) | Down-Right | - }
. { #N(#PEEK($8C27)) | #EVAL(#PEEK($8C26),$02,$08) | Down | "#CALL:get_key(#PEEK($8C27), #PEEK($8C26))" }
. { #N(#PEEK($8C29)) | #EVAL(#PEEK($8C28),$02,$08) | Down-Left | - }
. { #N(#PEEK($8C2B)) | #EVAL(#PEEK($8C2A),$02,$08) | Left | "#CALL:get_key(#PEEK($8C2B), #PEEK($8C2A))" }
. { #N(#PEEK($8C2D)) | #EVAL(#PEEK($8C2C),$02,$08) | Up-Left | - }
. { #N(#PEEK($8C2F)) | #EVAL(#PEEK($8C2E),$02,$08) | Fire | "#CALL:get_key(#PEEK($8C2F), #PEEK($8C2E))" }
. TABLE#
@ $8C1E label=Sinclair_2

g $8C30 Sinclair Joystick #1.
D $8C30 See #R$8E3A for key mappings.
N $8C30 Note the Sinclair joystick maps directional movements and fire to keys.
B $8C30,$12,$02  #TABLE(default,centre,centre,centre,centre)
. { =h Port Number | =h Bit | =h Action | =h Key }
. { #N(#PEEK($8C31)) | #EVAL(#PEEK($8C30),$02,$08) | Up | "#CALL:get_key(#PEEK($8C31), #PEEK($8C30))" }
. { #N(#PEEK($8C33)) | #EVAL(#PEEK($8C32),$02,$08) | Up-Right | - }
. { #N(#PEEK($8C35)) | #EVAL(#PEEK($8C34),$02,$08) | Right | "#CALL:get_key(#PEEK($8C35), #PEEK($8C34))" }
. { #N(#PEEK($8C37)) | #EVAL(#PEEK($8C36),$02,$08) | Down-Right | - }
. { #N(#PEEK($8C39)) | #EVAL(#PEEK($8C38),$02,$08) | Down | "#CALL:get_key(#PEEK($8C39), #PEEK($8C38))" }
. { #N(#PEEK($8C3B)) | #EVAL(#PEEK($8C3A),$02,$08) | Down-Left | - }
. { #N(#PEEK($8C3D)) | #EVAL(#PEEK($8C3C),$02,$08) | Left | "#CALL:get_key(#PEEK($8C3D), #PEEK($8C3C))" }
. { #N(#PEEK($8C3F)) | #EVAL(#PEEK($8C3E),$02,$08) | Up-Left | - }
. { #N(#PEEK($8C41)) | #EVAL(#PEEK($8C40),$02,$08) | Fire | "#CALL:get_key(#PEEK($8C41), #PEEK($8C40))" }
. TABLE#
@ $8C30 label=Sinclair_1

g $8C42 Kempston Joystick.
B $8C42,$12,$02  #TABLE(default,centre,centre,centre,centre)
. { =h Port Number | =h Bit | =h Action | =h Joystick }
. { #N(#PEEK($8C43)) | #EVAL(#PEEK($8C42),$02,$08) | Up | "#CALL:get_kempston(#PEEK($8C43), #PEEK($8C42))" }
. { #N(#PEEK($8C45)) | #EVAL(#PEEK($8C44),$02,$08) | Up-Right | - }
. { #N(#PEEK($8C47)) | #EVAL(#PEEK($8C46),$02,$08) | Right | "#CALL:get_kempston(#PEEK($8C47), #PEEK($8C46))" }
. { #N(#PEEK($8C49)) | #EVAL(#PEEK($8C48),$02,$08) | Down-Right | - }
. { #N(#PEEK($8C4B)) | #EVAL(#PEEK($8C4A),$02,$08) | Down | "#CALL:get_kempston(#PEEK($8C4B), #PEEK($8C4A))" }
. { #N(#PEEK($8C4D)) | #EVAL(#PEEK($8C4C),$02,$08) | Down-Left | - }
. { #N(#PEEK($8C4F)) | #EVAL(#PEEK($8C4E),$02,$08) | Left | "#CALL:get_kempston(#PEEK($8C4F), #PEEK($8C4E))" }
. { #N(#PEEK($8C51)) | #EVAL(#PEEK($8C50),$02,$08) | Up-Left | - }
. { #N(#PEEK($8C53)) | #EVAL(#PEEK($8C52),$02,$08) | Fire | "#CALL:get_kempston(#PEEK($8C53), #PEEK($8C52))" }
. TABLE#
@ $8C42 label=Kempston

c $8C54 Game Settings.
N $8C54 The main settings page, used for directing to the controls for P1/ P2 and turning the sound on or off.
@ $8C54 label=Game_Configs_Main
  $8C54,$03 Call #R$8E4C.
  $8C57,$09 Point to #R$8E6B and call #R$92E4.
  $8C60,$09 Point to #R$8E8C and call #R$92E4.
  $8C69,$09 Point to #R$8E99 and call #R$92E4.
  $8C72,$09 Point to #R$8EA6 and call #R$92E4.
  $8C7B,$09 Point to #R$8EB3 and call #R$92E4.
  $8C84,$09 Point to #R$8EC6 and call #R$92E4.
N $8C8D Does the user want to change Player 1 input method?
  $8C8D,$05 Check if "1" key is pressed.
@ $8C8D label=Game_Configs_P1
  $8C92,$03 No keys were pressed, continue on to #R$8C9E.
  $8C95,$06 Write #R$8BD2 to #R$8E69.
  $8C9B,$03 Jump to #R$8CDB.
N $8C9E Does the user want to change Player 2 input method?
  $8C9E,$05 Check if "2" key is pressed.
@ $8C9E label=Game_Configs_P2
  $8CA3,$03 No keys were pressed, continue on to #R$8CAF.
  $8CA6,$06 Write #R$8BE6 to #R$8E69.
  $8CAC,$03 Jump to #R$8CDB.
N $8CAF Does the user want to exit this config screen and go back to the demo mode?
  $8CAF,$05 Check if "E" key is pressed.
@ $8CAF label=Game_Configs_Exit
  $8CB4,$03 Jump to #R$8CDA (just returns).
N $8CB7 Does the user want to toggle the sound flag to be "ON".
  $8CB7,$05 Check if "3" key is pressed.
@ $8CB7 label=Game_Configs_Sound_On
  $8CBC,$03 No keys were pressed, continue on to #R$8CC7.
  $8CBF,$05 Write #N$01 to #R$B2FA.
  $8CC4,$03 Jump to #R$8CDA (just returns).
N $8CC7 Does the user want to toggle the sound flag to be "OFF".
  $8CC7,$05 Check if "4" key is pressed.
@ $8CC7 label=Game_Configs_Sound_Off
  $8CCC,$03 No keys were pressed, continue on to #R$8CD7.
  $8CCF,$05 Write #N$00 to #R$B2FA.
  $8CD7,$03 Loop back round to #R$8C8D.
@ $8CD7 label=Game_Configs_End
  $8CD4,$03 Jump to #R$8CDA (just returns).
  $8CDA,$01 Return.
@ $8CDA label=Game_Configs_Return

c $8CDB Game Control Settings.
N $8CDB The player controls menu.  Used for either player, references the currently targetted player at #R$8E69.
@ $8CDB label=Game_Configs_Controls
  $8CDB,$03 Call #R$8E4C.
  $8CDE,$09 Point to #R$8ED6 and call #R$92E4.
  $8CE7,$09 Point to #R$8EF4 and call #R$92E4.
  $8CF0,$09 Point to #R$8F0F and call #R$92E4.
  $8CF9,$09 Point to #R$8F2A and call #R$92E4.
  $8D02,$09 Point to #R$8F41 and call #R$92E4.
  $8D0B,$09 Point to #R$8F59 and call #R$92E4.
  $8D14,$06 Adds a delay for keyboard debounce.
N $8D1A Does the user want to revert to the default control method?
  $8D1A,$05 Check if "1" key is pressed.
@ $8D1A label=Game_Controls_Defaults
  $8D1F,$03 No keys were pressed, continue on to #R$8D25.
  $8D22,$03 Jump to #R$8D57.
N $8D25 Change player to use "Sinclair Joystick #1"?
  $8D25,$05 Check if "2" key is pressed.
@ $8D25 label=Game_Controls_Sinclair_1
  $8D2A,$03 No keys were pressed, continue on to #R$8D30.
  $8D2D,$03 Jump to #R$8D75.
N $8D30 Change player to use "Sinclair Joystick #2"?
  $8D30,$05 Check if "3" key is pressed.
@ $8D30 label=Game_Controls_Sinclair_2
  $8D35,$03 No keys were pressed, continue on to #R$8D3B.
  $8D38,$03 Jump to #R$8D81.
N $8D3B Change player to use "Kempston" joystick?
  $8D3B,$05 Check if "5" key is pressed.
@ $8D3B label=Game_Controls_Kempston
  $8D40,$03 No keys were pressed, continue on to #R$8D46.
  $8D43,$03 Jump to #R$8D8D.
N $8D46 Redefine keys for player.
  $8D46,$05 Check if "4" key is pressed.
@ $8D46 label=Game_Controls_Keyboard
  $8D4B,$03 No keys were pressed, loop back round to #R$8D1A.
  $8D4E,$06 Adds a delay for keyboard debounce.
  $8D54,$03 Jump to #R$8D99.
N $8D57 Actions setting keyboard controls for player back to defaults.
  $8D57,$09 Check if #R$8E69 is equal to #R$8BD2.
@ $8D57 label=Game_Controls_Set_Default
  $8D60,$03 Jump to #R$8D6C if we are working with player 2.
  $8D63,$06 Store #R$8BFA at #R$8BD2.
  $8D69,$03 Jump to #R$8CDA (just returns).
  $8D6C,$06 Store #R$8C0C at #R$8BE6.
@ $8D6C label=Game_Controls_Set_Default_P2
  $8D72,$03 Jump to #R$8CDA (just returns).

N $8D75 Actions setting player to use Sinclair Joystick #1.
  $8D75,$03 Fetch the current player from #R$8E69.
@ $8D75 label=Game_Controls_Set_Sinclair_1
  $8D78,$06 Pushes #R$8C30 for the current player.
  $8D7E,$03 Jump to #R$8CDA (just returns).

N $8D81 Actions setting player to use Sinclair Joystick #2.
  $8D81,$03 Fetch the current player from #R$8E69.
@ $8D81 label=Game_Controls_Set_Sinclair_2
  $8D84,$06 Pushes #R$8C1E for the current player.
  $8D8A,$03 Jump to #R$8CDA (just returns).

N $8D8D Actions setting player to use Kempston Joystick.
  $8D8D,$03 Fetch the current player from #R$8E69.
@ $8D8D label=Game_Controls_Set_Kempston
  $8D90,$06 Pushes #R$8C42 for the current player.
  $8D96,$03 Jump to #R$8CDA (just returns).

c $8D99 Game Settings - Redefine Keys.
@ $8D99 label=Game_Configs_Keys
  $8D99,$03 Call #R$8E4C.
N $8D9C Displays the "for each direction ... press key" banner.
  $8D9C,$09 Point to #R$8F6B and call #R$92E4.
  $8DA5,$09 Point to #R$8F89 and call #R$92E4.
  $8DAE,$09 Point to #R$8FA7 and call #R$92E4.
N $8DB7 Set that this player should use the "redefined keys" for their input.
  $8DB7,$07 Fetch the current player from #R$8E69, and set it in both #REGde and #REGhl.
  $8DBE,$02 Increase #REGde by two to point to the beginning of that players redefined keys map.
  $8DC0,$03 Stores either #R$8BD4 or #R$8BE8 at the address for the player control method.
N $8DC3 Go through each key and process.
  $8DC3,$06 Point to #R$8FBB and call #R$8DFC.
  $8DC9,$06 Point to #R$8FBE and call #R$8DFC.
  $8DCF,$06 Point to #R$8FC7 and call #R$8DFC.
  $8DD5,$06 Point to #R$8FCD and call #R$8DFC.
  $8DDB,$06 Point to #R$8FD8 and call #R$8DFC.
  $8DE1,$06 Point to #R$8FDD and call #R$8DFC.
  $8DE7,$06 Point to #R$8FE7 and call #R$8DFC.
  $8DED,$06 Point to #R$8FEC and call #R$8DFC.
  $8DF3,$06 Point to #R$8FF4 and call #R$8DFC.
  $8DF9,$03 Jump to #R$8CDA.
N $8DFC Print the message, get the key and write it to the mapping buffer for this player.
  $8DFC,$01 Stash the current key mapping address on the stack.
C $8DFD,$07 Use #R$92E4 to show the message for which key to press.
  $8E04,$01 Fetch the current key mapping address from the stack.
  $8E05,$01 Stash it again for later.
  $8E06,$03 Call #R$8E22.
  $8E09,$01 Fetch the current key mapping address from the stack.
  $8E0A,$06 Writes the port number and key byte to the current key mapping address.
  $8E10,$01 Stash the next key mapping address on the stack.
@ $8DFC label=Print_Key_Loop
  $8E11,$09 Blank out the "press key" message with whitespace.
  $8E1A,$06 Delay (for debounce) twice #R$8E42.
  $8E20,$01 Restores the current key location off the stack.
  $8E21,$01 Return.
N $8E22 Detect the key press.
@ $8E22 label=Get_Key
  $8E22,$03 #REGde=#R$8E3A.
  $8E25,$02 Set a counter #REGb=#N$08.
  $8E27,$03 Using the current port, read the keyboard.
@ $8E27 label=Get_Key_Loop
  $8E2A,$03 Is a key being pressed?
  $8E2D,$03 Yes - jump to #R$8E36.
  $8E30,$01 Increase #REGde by one.
  $8E31,$02 Decrease counter by one and loop back to #R$8E27 until counter is zero.
  $8E33,$03 Jump to #R$8E22.
N $8E36 Stores the port number as the MSB of #REGhl, and the key byte as the LSB.
@ $8E36 label=Store_Key
  $8E36,$01 Store the key byte as the LSB of #REGhl.
  $8E37,$02 Store the port number from #REGde as the MSB of #REGhl.
  $8E39,$01 Return.

N $8E3A The keyboard is split into 8 sections - 4 'half rows' on each side, and each with a unique port number.
. #TABLE(default,centre,centre,centre,centre,centre,centre)
. { =h,r2 Port Number | =h,c5 Bit }
. { =h 0 | =h 1 | =h 2 | =h 3 | =h 4 }
. { v$FE | SHIFT | Z | X | C | V }
. { #N$FD | A | S | D | F | G }
. { #N$FB | Q | W | E | R | T }
. { #N$F7 | 1 | 2 | 3 | 4 | 5 }
. { #N$EF | 0 | 9 | 8 | 7 | 6 }
. { #N$DF | P | O | I | U | Y }
. { #N$BF | ENTER | L | K | J | H }
. { #N$7F | SPACE | FULL-STOP | M | N | B }
. TABLE#
B $8E3A,$08 Key Data
@ $8E3A label=Key_Data

c $8E42 Short delay.
@ $8E42 label=Configs_Delay
  $8E42,$03 Set #REGbc=#N$EA60
@ $8E45 label=Configs_Delay_Loop
  $8E45,$06 Countdown #REGbc until #0000.
  $8E4B,$01 Return.

c $8E4C Blank the screen buffer.
@ $8E4C label=Clear_Screen
  $8E4C,$0E Clears the screen buffer by writing #N$00 to 6143 memory locations.
  $8E5A,$0E Clears the attribute buffer by writing #N$0D to 767 memory locations.
  $8E68,$01 Return.

w $8E69 Holds which player is currently being altered.
D $8E69 Will hold either;
. #TABLE(default,centre,centre)
. { =h #R$8BD2 | #N$8BD2 }
. { =h #R$8BE6 | #N$8BE6 }
. TABLE#
@ $8E69 label=Temp_Player

t $8E6B
T $8E6B,$21,$20:1 P1 controls text.
@ $8E6B label=Text_P1_Controls
T $8E8C,$0D,$0C:1 P2 text.
@ $8E8C label=Text_P2_Controls
T $8E99,$0D,$0C:1 Sound on text.
@ $8E99 label=Text_Sound_On
T $8EA6,$0D,$0C:1 Sound off text.
@ $8EA6 label=Text_Sound_Off
T $8EB3,$13,$12:1 "Type" message.
@ $8EB3 label=Text_Type_1
T $8EC6,$10,$0F:1 "Exit" message.
@ $8EC6 label=Text_Exit
T $8ED6,$1E,$1D:1 "Default" layout text.
@ $8ED6 label=Text_Default_Layout
T $8EF4,$1B,$1A:1 P1 "Sinclair" text.
@ $8EF4 label=Text_Sinclair_P1
T $8F0F,$1B,$1A:1 P2 "Sinclair" text.
@ $8F0F label=Text_Sinclair_P2
T $8F2A,$17,$16:1 Reconfigure keyboard text.
@ $8F2A label=Text_Keyboard_Reconfig
T $8F41,$18,$17:1 "Kempston" text.
@ $8F41 label=Text_Kempston
T $8F59,$12,$11:1 "Type" message.
@ $8F59 label=Text_Type_2
T $8F6B,$1E,$1D:1 "Change keys line 1" message.
@ $8F6B label=Text_Change_1
T $8F89,$1E,$1D:1 "Change keys line 2" message.
@ $8F89 label=Text_Change_2
T $8FA7,$14,$13:1 "Change keys line 3" message.
@ $8FA7 label=Text_Change_3
T $8FBB,$03,$02:1 "Up" text.
@ $8FBB label=Text_Up
T $8FBE,$09,$08:1 "Up-Right" text.
@ $8FBE label=Text_Up_Right
T $8FC7,$06,$05:1 "Right" text.
@ $8FC7 label=Text_Right
T $8FCD,$0B,$0A:1 "Down-Right" text.
@ $8FCD label=Text_Down_Right
T $8FD8,$05,$04:1 "Down" text.
@ $8FD8 label=Text_Down
T $8FDD,$0A,$09:1 "Down-Left" text.
@ $8FDD label=Text_Down_Left
T $8FE7,$05,$04:1 "Left" text.
@ $8FE7 label=Text_Left
T $8FEC,$08,$07:1 "Up-Left" text.
@ $8FEC label=Text_Up_Left
T $8FF4,$0C,$0B:1 "Fire" text.
@ $8FF4 label=Text_Fire
T $9000,$0D,$0C:1 Blank text.
@ $9000 label=Text_Whitespace_12

i $900D

c $900E Yin-yang controller.
N $900E Player 1 yin-yang functionality.
@ $900E label=Yin_Yang_1UP
  $900E,$07 If #R$AA08 is #N$00 then no point was awarded for 1UP. Jump forward to #R$9057.
N $9015 Update 1UP yin-yang total.
  $9015,$05 Add #R$AA08 to #R$AA01 and update the new total at #R$AA01.
N $901A Check if 1UP yin-yang total is now #N$01.
  $901A,$04 #HTML(If the total is not <strong>#N$01</strong> then skip forward to #R$9028.)
  $901E,$09 Call #R$9255 using #R$92AA.
  $9027,$01 Return.
N $9028 Check if 1UP yin-yang total is now #N$02.
@ $9028 label=Yin_Yang_1UP_2
  $9028,$04 #HTML(If the total is not <strong>#N$02</strong> then skip forward to #R$9036.)
  $902C,$09 Call #R$9255 using #R$928A.
  $9035,$01 Return.
N $9036 Check if 1UP yin-yang total is now #N$03.
@ $9036 label=Yin_Yang_1UP_3
  $9036,$04 #HTML(If the total is not <strong>#N$03</strong> then skip forward to #R$904D.)
  $903A,$09 Call #R$9255 using #R$928A.
  $9043,$09 Call #R$9255 using #R$92AA.
  $904C,$01 Return.
N $904D 1UP yin-yang total is #N$04.
@ $904D label=Yin_Yang_1UP_4
  $904D,$09 Call #R$9255 using #R$928A.
  $9056,$01 Return.
N $9057 Player 2 yin-yang functionality.
@ $9057 label=Yin_Yang_2UP
  $9057,$05 #HTML(If #R$AA48 is <strong>#N$00</strong> then no point was awarded for 2UP, if so then return.)
N $905C Update 2UP yin-yang total.
  $905C,$05 Add #R$AA48 to #R$AA41 and update the new total at #R$AA41.
N $9061 Check if 2UP yin-yang total is now #N$01.
  $9061,$04 #HTML(If the total is not <strong>#N$01</strong> then skip forward to #R$906F.)
  $9065,$09 Call #R$9255 using #R$92AA.
  $906E,$01 Return.
N $906F Check if 2UP yin-yang total is now #N$02.
@ $906F label=Yin_Yang_2UP_2
  $906F,$04 #HTML(If the total is not <strong>#N$02</strong> then skip forward to #R$907D.)
  $9073,$09 Call #R$9255 using #R$928A.
  $907C,$01 Return.
N $907D Check if 2UP yin-yang total is now #N$03.
@ $907D label=Yin_Yang_2UP_3
  $907D,$04 #HTML(If the total is not <strong>#N$03</strong> then skip forward to #R$9094.)
  $9081,$09 Call #R$9255 using #R$928A.
  $908A,$09 Call #R$9255 using #R$92AA.
  $9093,$01 Return.
N $9094 2UP yin-yang total is #N$04.
@ $9094 label=Yin_Yang_2UP_4
  $9094,$09 Call #R$9255 using #R$928A.
  $909D,$01 Return.

c $909E New round.
@ $909E label=New_Round
  $909E,$0D Write #N$00 to; #LIST { #R$AA01 } { #R$AA41 } { #R$AA02 } { #R$AA42 } LIST#
  $90AB,$09 Point to #R$B060($B064) and call #R$92E4.
  $90B4,$09 Point to #R$B060($B064) and call #R$92E4.
  $90BD,$09 Point to #R$B060($B064) and call #R$92E4.
  $90C6,$09 Point to #R$B060($B064) and call #R$92E4.
  $90CF,$01 Return.

c $90D0 Intro music.
B $90D0,$01
@ $90D1 label=Intro_Music
  $90D1,$01 Disable interrupts.
  $90D2,$05 If #R$B2FA is zero then return.
  $90D7,$03 #R$90D0.
  $90DA,$02 Check bits 0-4.
  $90E0,$04 #REGix=#R$9128
@ $90E4 label=Intro_Music_Loop
  $90E4,$03 #REGc=the next note byte from #REGix+#N$00.
  $90E7,$03 If the current note is #N$00 then return.
  $90EA,$02 Move the index onto the next note.
  $90EC,$03 #REGb=the next note byte from #REGix+#N$00.
  $90EF,$02 Move the index onto the next note.
  $90F1,$03 #REGe=the next note byte from #REGix+#N$00.
  $90F4,$02 Move the index onto the next note.
  $90F6,$03 #REGd=the next note byte from #REGix+#N$00.
  $90F9,$02 Move the index onto the next note.
  $90FB
@ $9106 label=Intro_Music_Delay_1
  $910B,$02 Loop back to #R$90E4.
N $910D Process the note data and create the sounds.
@ $910D label=Intro_Music_Play
@ $9111 label=Intro_Music_Delay_2
@ $911B label=Intro_Music_Delay_3

B $9128,$D8,$04
@ $9128 label=Intro_Music_Data

c $9200
  $9200,$03 Write #REGa to #R$5F00.
  $9203,$03 Call #R$5F22.
  $9206,$05 Call #R$C203 using #N$48. On return #REGhl=#N$4820.
  $920B,$02 Set a counter of #N$40.
  $920D,$03 #REGde=#R$8000.
  $9210,$01 Push #REGhl onto the stack.
  $9211,$01 Push #REGde onto the stack.
  $9212,$01 Push #REGbc onto the stack.
  $9213,$05 Copy #REGhl to #REGde #N$20 times.
  $921E,$01 Stash the counter on the stack.
  $9225,$01 Restore the counter from the stack.
  $9226,$02 Decrease counter by one and loop back to #R$9210 until counter is zero.
  $9228,$01 Return.

c $9229
  $9239,$01 Return.

c $923A
  $9254,$01 Return.

c $9255 Copy yin-yang to screen.
N $9255 On entry #REGde points to a yin-yang UDG and #REGhl to screen coordinates;
. #TABLE(default,centre,centre,centre)
. { =h #REGde | =h,c2 Yin-yang UDG }
. { #R$92AA($92AA) | =c2 Half }
. { #R$928A($928A) | =c2 Full }
. { =h #REGhl | =h,c2 Screen Position }
. { #N$0108 | 1 | 8 }
. { #N$0408 | 4 | 8 }
. { #N$1A08 | 26 | 8 }
. { #N$1D08 | 29 | 8 }
. TABLE#
@ $9255 label=Yin_Yang_Copy
  $9255,$02 Stash yin-yang UDG and screen coordinates on the stack.
  $9257,$03 Call #R$92CA.
  $925A,$02 Restore yin-yang UDG and screen coordinates from the stack.
  $925C,$01 Keep a reference to #REGhl on the stack as we'll need to refer to it again later.
  $925D,$01 Increase the LSB of #REGhl by one.
  $925E,$07 Add #N($0008,$04,$04) to #REGde and stash it on the stack.
  $9265,$03 Call #R$92CA.
  $926F,$07 Add #N($0008,$04,$04) to #REGde and stash it on the stack.
  $9276,$03 Call #R$92CA.
  $9280,$06 Add #N($0008,$04,$04) to #REGde.
  $9286,$03 Call #R$92CA.
  $9289,$01 Return.
N $928A Full yin-yang UDG.
@ $928A label=Yin_Yang_UDG_Full
B $928A,$20,$08 #UDGARRAY2,scale=4;(#PC)-(#PC+28)-8(full-yin-yang)
N $92AA Half yin-yang UDG.
@ $92AA label=Yin_Yang_UDG_Half
B $92AA,$20,$08 #UDGARRAY2,scale=4;(#PC)-(#PC+28)-8(half-yin-yang)
N $92CA fff
@ $92CA label=Yin_Yang_Copy_Line
  $92CA,$02 Stash #REGde and #REGhl on the stack.
  $92CD,$03 Call #R$C203.
  $92D0,$01 Restore #REGde from the stack.
  $92D7,$02 Set a counter of #N$08.
@ $92D9 label=Yin_Yang_Copy_Loop
  $92D9,$02 Copy a byte from #REGhl to #REGde.
  $92DB,$01 Increase #REGhl by one.
  $92DC,$05 Call #R$9229.
  $92E1,$02 Decrease counter by one and loop back to #R$92D9 until counter is zero.
  $92E3,$01 Return.

c $92E4 Print String.
@ $92E4 label=Print_String
N $92E4 #TABLE(default,centre,centre)
.       { =h REGde | =h REGhl }
.       { Memory location of string | X/Y position on screen }
.       TABLE#
@ $92F0 label=Print_String_Loop

c $92FF Expand time byte to ASCII.
@ $92FF label=Time_Counter
B $92FF,$08,$02 Guessing at the length.
B $9307,$02 Terminator.
N $9309 On entry #REGhl contains the time as the LSB, e.g. for 30s #REGhl will be #N($001E,$04,$04).
@ $9309 label=Process_Time
  $9309,$03 Pushes #REGhl, #REGde and #REGbc onto the stack.
  $930C,$03 Point to #R$92FF.
@ $930F label=Process_Time_Loop
  $930F,$05 Load the next byte pair from the address pointer into #REGbc.
  $9314,$02 Increase the address pointer by one and stash it on the stack for later.
  $9316,$02 Store #N$2F in #REGa.
N $9318 Count "up" from ASCII "0" until the correct representation is reached.
@ $9318 label=Process_Time_Char
  $9318,$01 Increment #REGa by one (so on the first pass #REGa will now contain ASCII "0").
  $9319,$02 Copy the remaining time into #REGde.
  $931B,$01 Adds the remaining time to the 16-bit number held in #REGbc.
  $931C,$02 If the carry flag is set loop back to #R$9318.
  $931E,$01 Swap #REGde and #REGhl.
  $931F,$03 Write the processed ASCII number character to the time print buffer.
  $9322,$02 Increment #REGix by one to process the next character in the time buffer once looped around.
  $9324,$01 Restore the byte pair address pointer from the stack.
  $9325,$03 Loop back to #R$930F until the terminator is reached (#N$FF+#N$01 will set the zero flag).
  $9328,$03 Restores #REGbc, #REGde and #REGhl from the stack.
  $932B,$01 Return.

c $932C Processes the remaining time string.
N $932C Buffer for processing text output.
@ $932C label=Time_Buffer
T $932C,$06,$05:1 Guessing at the length.
S $9332,$04 Maybe unused?
  $9336,$01 Push #REGde containing the screen position for printing onto the stack for later.
@ $9336 label=Process_Print_Time
  $9337,$04 Point #REGix at the first character of the time display buffer at #R$932C.
  $933B,$03 Call #R$9309.
  $933E,$06 #REGix points to one byte off the end of the time buffer, write #N$00 as a terminator for the print routine.
  $9344,$01 Fetch the screen position off the stack and store it in #REGhl.
N $9345 The time isn't printed as "00005" so this routine replaces the zeroes with spaces in the time print buffer.
  $9345,$03 Store #R$932C in #REGde.
@ $9348 label=Time_Zero_To_Spaces
  $9348,$01 Grab the next character from the time buffer.
  $9349,$05 If it is not ASCII "0" then jump to #R$9355.
  $934E,$03 Write ASCII "space" ($20) to the time buffer location.
  $9351,$01 Move onto the next character.
  $9352,$03 Jump back to #R$9348.
N $9355 If time has run out, show at least an ASCII "0".
@ $9355 label=Time_Check_Last
  $9355,$03 Point to the last digit of the time buffer #R$932C($9330).
  $9358,$06 If it is not an ASCII "space" ($20) then jump to #R$9361.
  $935E,$03 Time has run out, so write ASCII "0" to this last character.
N $9361 Send the time buffer to #R$92E4.
@ $9361 label=Print_Time_Screen
  $9361,$06 Point to #R$932C and call #R$92E4.
  $9367,$01 Return.

b $9368
B $9413

c $95D4
  $95D4,$06 Call #R$95E1 using #R$AA16.
  $95DA,$06 Call #R$95E1 using #R$AA56.
  $95E0,$01 Return.
N $95E1 fffff
  $95E1,$01
B $9743,$01
B $9744,$01

c $9745
@ $9745 label=Game_Over

  $975C,$05 Write #N$40 to #R$9C29.

  $9768,$04 Write #N$00 to #R$9C29.

  $977C,$0A Clear the yin-yang images by writing #N$00 to #R$AA08 and #R$AA48 and calling #R$900E.
  $9786,$0A Clear the yin-yang images by writing #N$00 to #R$AA01 and #R$AA41 and calling #R$95D4, #R$BF13.

  $9795,$05 Write #N$40 to #R$9C29.

  $97BA,$01 Return.

  $97CA,$01 Return.
  $97CB,$07 If #R$9C2C is not #N$00 then jump to #R$9827.
  $97D4,$08 Write #N$01 to; #LIST { #R$AA46 } { #R$AA06 } LIST#

N $97DC Should we start a 1 player game?
  $97DC,$05 Check if "1" key is pressed.
  $97E1,$02 If it is, jump to #R$97EF.
  $97E3,$02 Take a reading from the kempston joystick port.
  $97E5,$05 If the fire button is not being pressed, jump to #R$9801.
  $97EA,$05 Keep only bit 4 (fire), if it's not being pressed, jump to #R$9801.
N $97EF Starts a 1 player game.
@ $97EF label=Start_1UP
  $97EF,$08 Write #N$01 to; #LIST { #R$9C2C } { #R$AA46 } LIST#
  $97F7,$04 Write #N$00 to; #LIST { #R$AA06 } LIST#
  $97FB,$03 Call #R$909E.
  $97FE,$02 #REGa=#N$80.
  $9800,$01 Return.

N $9801 Should we start a 2 player game?
  $9801,$05 Check if "2" key is pressed.
  $9806,$02 No keys were pressed, continue on to #R$981A.
N $9808 Starts a 2 player game.
@ $9808 label=Start_2UP
  $9808,$05 Write #N$02 to; #LIST { #R$9C2C } LIST#
  $980D,$07 Write #N$00 to; #LIST { #R$AA06 } { #R$AA46 } LIST#
  $9814,$03 Call #R$909E.
  $9817,$02 #REGa=#N$80.
  $9819,$01 Return.

N $981A Should we go to the config page?
@ $981A label=Demo_Configs_Main
  $981A,$05 Check if "0" key is pressed.
  $981F,$02 No keys were pressed, continue on to #R$983D.
  $9821,$03 Call #R$8C54.
  $9824,$02 #REGa=#N$80.
  $9826,$01 Return.

N $9827 Checks if "G" and "H" are being held to quit a game.
@ $9827 label=Check_Quit_Game
  $9827,$05 Check if "H" key is pressed.
  $982C,$02 No keys were pressed, continue on to #R$983D.
  $982E,$05 Check if "G" key is pressed.
  $9833,$02 No keys were pressed, continue on to #R$983D.
  $9835,$04 Write #N$00 to; #LIST { #R$9C2C } LIST#
  $9839,$02 #REGa=#N$80.
  $983C,$01 Return.

  $98BF,$03 #REGhl=#R$9C2C.
  $98C2,$02 Set a counter of 1.
  $98C4,$03 Call #R$AFDA.
  $98C7,$03 Call #R$AFF3.
  $98CA,$09 Point to #R$B024 and call #R$92E4.
  $98D3,$09 Point to #R$B03E and call #R$92E4.
  $98DC,$01 Return.

g $9C28
g $9C29
g $9C2A
g $9C2B
g $9C2C Number of players.
@ $9C2C label=Num_Players

g $9C2D

c $9C2E Game Entry Point.
@ $9C2E label=Game_Start
  $9C2E,$01 Disable interrupts.
  $9C2F,$04 Set border colour to cyan.
. #TABLE(default,centre,centre,centre,centre)
. { =h Value | =h Ink | =h Paper | =h Bright }
. { #N$05 | #N$05 | #N$00 | #N$00 }
. TABLE#
  $9C33,$04 Set the stack pointer to #N$5BFF.
  $9C37,$03 Call #R$B138.

  $9C3A,$0B Copies a large chunk of code from #N$6000 to #N$5F00. See the .t2s file.
  $9C45,$0B Write #N($0000,$04,$04) to; #LIST { #R$C423 } { #R$C425 } LIST#
  $9C50,$03 Jump to #R$AC05.

c $9C53 Read Key Input.
N $9C53 Annotated by Stephen Jones; Spectrum Discovery Club.
@ $9C53 label=Keyboard_Test
  $9C53,$01 Key to test in #REGc.
  $9C54,$02 Mask bits d0-d2 for row.
  $9C56,$01 In range 1-8.
  $9C57,$01 Place in #REGb.
  $9C58,$06 Divide #REGc by 8 to find position within row.
  $9C5E,$02 Only 5 keys per row.
  $9C60,$01 Subtract position.
  $9C61,$01 Put into #REGc.
  $9C62,$02 High byte of port to read.
  $9C64,$01 Rotate into position.
@ $9C64 label=Keyboard_Find_Row
  $9C65,$02 Repeat until we've found the relevant row.
  $9C67,$02 Read port (#REGa=high, 254=low).
  $9C69,$01 Rotate bit out of result.
@ $9C69 label=Keyboard_Rotate_Loop
  $9C6A,$01 Loop counter.
  $9C6B,$02 Repeat until bit for position in carry flag.
  $9C6D,$01 Return.

u $9C6E

c $9C6F
  $9C6F,$05 Return if #R$9C2B is not zero.
  $9C74,$08 Return if #R$AA03 or #R$AA43 is not zero.
  $9C7C,$06 Return if #R$AA04 is #N$17.
  $9C82,$05 Decrease #R$9CA6 by one, return if it is not zero.
  $9C87,$02 Write #N$0D to; #LIST { #R$9CA6 } LIST#
  $9C89,$05 Call #R$9CA0 and jump to #R$9C93 if it is not zero.
  $9C8E,$05 Write #N$01 to; #LIST { #R$9C2B } LIST#

c $9C93 Print remaining time to the screen.
@ $9C93 label=Print_Time
  $9C93,$06 Stores #R$9CA5 as the LSB in #REGhl.
  $9C99,$03 Store #N$0B00 in #REGde for the screen position.
  $9C9C,$03 Call #R$9336.
  $9C9F,$01 Return.

c $9CA0 Countdown time by one unit.
@ $9CA0 label=Time_Tick
C $9CA0,$05 Decrease #R$9CA5 by 1 and return.

g $9CA5 Time.
@ $9CA5 label=Time

c $9CA6
  $9CAD,$2B Write #N$00 to; #LIST
. { #R$9C2B }
. { #R$9CA7 }
. { #R$AA4D }
. { #R$AA0D }
. { #R$AA03 }
. { #R$AA43 }
. { #R$AA16 }
. { #R$AA56 }
. { #R$AA17 }
. { #R$AA0B }
. { #R$AA4B }
. { #R$AA09 }
. { #R$AA49 }
. { #R$9C28 }
. LIST#
  $9CD8,$05 Write #N$20 to; #LIST { #R$AA19 } LIST#
  $9CDD,$05 Write #N$3C to; #LIST { #R$AA59 } LIST#
  $9CE2,$08 Write #N$7A to; #LIST { #R$AA18 } { #R$AA58 } LIST#
  $9CEA,$14 Write #N$17 to; #LIST
. { #R$AA0C }
. { #R$AA4C }
. { #R$AA05 }
. { #R$AA45 }
. { #R$AA04 }
. { #R$AA44 }
. LIST#
  $9CFE,$08 Write #N$01 to; #LIST { #R$AA0A } { #R$AA4A } LIST#
  $9D06,$05 Write #N$01 to; #LIST { #R$AA57 } LIST#

c $9ED2

c $A3FF Random number.
D $A3FF Semi-random number generator using the refresh register.
@ $A3FF label=Random_Number
  $A3FF #REGa=0-127 (the contents of the refresh register).
  $A401,$01 Return.

c $A402

c $A647 New high score?
N $A647 Check if either player has broken the high score.
@ $A647 label=Check_HighScore
  $A647,$03 #REGhl=#R$B035(high score).
  $A64A,$03 #REGde=#R$B02F(1UP score)
N $A64D If this is not a two player game then we skip forward to #R$A679 to only test for the 1UP score.
  $A64D,$05 Check #R$9C2C; is this a 2 player game?
  $A652,$02 If not, jump to #R$A679.
N $A654 #R$A6B6 mirrors #R$9C2C here. todo: why?
  $A654,$03 Store #N$02 at #R$A6B6.
N $A657 Check 2UP score.
  $A657,$06 #REGhl=#R$B032 and call #R$A697.
  $A65D,$02 Jump to #R$A669 if this is not a new high score.
N $A65F Overwrite the high score with the 2UP score.
  $A65F,$05 Copy the 2UP score over the current #R$B035.
  $A664,$03 #REGde=#R$B02F(2UP score)
  $A667,$02 Jump to #R$A676.
N $A669 Checks if all three digits changed. todo: why?
@ $A669 label=Check_HighScore_Changes
  $A669,$05 Check #R$A6B7; are there three digit changes?
  $A66E,$02 Store #N$01 at #R$A6B6 (skips forward to #R$A673).
N $A672 Else reset #R$A6B6.
  $A672,$04 Write #N$00 to #R$A6B6.
@ $A673 label=HighScore_Write_A6B6
N $A676 Resets #REGhl with #R$B038 so the 1UP score can also be tested.
@ $A676 label=Check_HighScore_Restore
  $A676,$03 #REGhl=#R$B038.
@ $A679 label=Check_HighScore_1UP
  $A679,$03 Call #R$A697.
  $A67C,$01 Return if this is not a new high score.
N $A67D Overwrite the high score with the 1UP score.
  $A67D,$01 Stash the high score memory address temporarily.
  $A67E,$06 Overwrite the high score.
  $A684,$01 Restore the high score memory address to #REGhl.

c $A685 Print Hi-Score.
@ $A685 label=Print_HighScore
  $A685,$02 Set a counter = #N$03 digits.
  $A687,$03 Call #R$AFDA.
  $A68A,$03 Call #R$AFED.
  $A68D,$09 Point to #R$B024 and call #R$92E4.
  $A696,$01 Return.

c $A697 Check player score against high score.
@ $A697 label=Is_HighScore
  $A697,$05 Write #N$00 to #R$A6B7.
  $A69C,$02 Stash the high score and player score positions on the stack.
  $A69E,$02 Set the counter to #N$03 for the three score digits.
@ $A6A0 label=Is_HighScore_Loop
  $A6A0,$01 Fetch the score digit.
  $A6A1,$01 Compare the score digit against the high score.
  $A6A2,$02 If the the high score is higher, jump to #R$A6B3.
  $A6A4,$02 If the high score is lower skip ahead to #R$A6AD.
  $A6A6,$07 Increase #R$A6B7 by one.
@ $A6AD label=Is_HighScore_Skip
  $A6AD,$02 Move onto the next digits for both the player score and high score.
  $A6AF,$02 Decrease counter by one and loop back to #R$A6A0 until counter is zero.
  $A6B1,$02 Sets then clears the carry flag.
@ $A6B3 label=Is_HighScore_Return
  $A6B3,$02 Restore high score and player score positions from the stack.
  $A6B5,$01 Return.

g $A6B6
g $A6B7
g $AA00
g $AA01 1UP Yin-yang count.
@ $AA01 label=P1_Yin_Yang
B $AA01,$01
B $AA02,$01

B $AA04,$01

g $AA06 Is this demo mode?
B $AA06,$01
@ $AA06 label=Is_Demo_Mode

B $AA08,$01
@ $AA08 label=P1_Points_Awarded
B $AA0A,$01
B $AA0B,$01
B $AA0D,$01
B $AA16,$01
B $AA18,$01
B $AA3C,$01

g $AA40
g $AA41
@ $AA41 label=P2_Yin_Yang
B $AA41,$01

B $AA42,$01
B $AA44,$01
B $AA45,$01
B $AA46,$01
B $AA48,$01
@ $AA48 label=P2_Points_Awarded
B $AA4A,$01
B $AA4B,$01
B $AA4D,$01
B $AA56,$01
B $AA58,$01
B $AA77,$01
B $AA80,$01
@ $AA80 label=Also_Rank
B $AA8B,$01

t $AA9C
T $AA9D,$04 "DEMO" text.
T $AAA1,$06 "PLAYER" text.
T $AAA7,$06 "NOVICE" text.
T $AAAE,$08,$02 numeric suffixes.
T $AAB7,$03 "DAN" text.
T $AABA,$08 "JOYSTICK" text.
T $AAC2,$08 "KEYBOARD" text.
T $AACC,$0C Whitespace?

c $AADC
  $AADC,$0B Copies #N$1A bytes of data from #R$AA00 to #R$A5F1.
  $AAE7,$0B Copies #N$1A bytes of data from #R$AA40 to #R$A62B.
  $AAF2,$01 Return.

  $AAF3,$0B Copies #N$1A bytes of data from #R$A5F1 to #R$AA00.
  $AAFE,$0B Copies #N$1A bytes of data from #R$A62B to #R$AA40.
  $AB09,$01 Return.

  $AB0A,$0B Copies #N$12 bytes of data from #R$AA8B to #R$A60B.
  $AB15,$01 Return.

  $AB16,$0B Copies #N$12 bytes of data from #R$A60B to #R$AA8B.
  $AB21,$01 Return.

  $AB22,$0B Copies #N$1A bytes of data from #R$AA40 to #R$A5F1.
  $AB2D,$0B Copies #N$1A bytes of data from #R$AA00 to #R$A62B.
  $AB38,$01 Return.

  $AB39,$0B Copies #N$1A bytes of data from #R$A5F1 to #R$AA40.
  $AB44,$0B Copies #N$1A bytes of data from #R$A62B to #R$AA00.
  $AB4F,$01 Return.

  $AB50,$0B Copies #N$12 bytes of data from #R$AA77 to #R$A60B.
  $AB5B,$01 Return.

  $AB5C,$0B Copies #N$12 bytes of data from #R$A60B to #R$AA77.
  $AB67,$01 Return.

c $AB70 Demo mode.
@ $AB70 label=Demo_Mode
  $AB70,$01 #REGa=#N$00
  $AB71,$06 Write #N$00 to; #LIST { #R$B05F } { #R$9C2C } LIST#
  $AB77,$03 Call #R$A3FF.

  $AB8B,$08 Write #N$01 to; #LIST { #R$AA46 } { #R$AA06 } LIST#
  $AB93,$04 Write #N$02 to; #LIST { #R$AF34 } LIST#
  $AB97,$03 #R$AF34.

  $AB9D,$09 Point to #R$B039 and call #R$92E4.
  $ABA6,$06 Point to #R$B035 and call #R$A685.
  $ABAC,$03 Call #R$909E.
  $ABAF,$03 Call #R$AEF8.

  $ABB2,$04 Write #N$00 to; #LIST { #N$9C2B } LIST#
  $ABB6,$03 Call #R$ABC8.

  $ABBE,$04 Point to #R$B05F and increment it by 1.
  $ABC2,$05 If this value is not #N$04 then jump to #R$AB97.
  $ABC7,$01 Else, return.

c $AC05 Main game loop.
@ $AC05 label=Main_Game
  $AC05,$04 Writes #N$00 to #R$9C2C - this signifies we're in "demo mode".
@ $AC09 label=Main_Game_Loop
  $AC09,$09 Point to #R$B060 and call #R$92E4.
  $AC12,$09 Point to #R$B060 and call #R$92E4.
  $AC1B,$09 Point to #R$B039 and call #R$92E4.
  $AC24,$03 Call #R$AB70.
  $AC27,$06 If #R$9C2C is still zero, loop back round to #R$AC09.
  $AC2D,$04 If #R$9C2C is #N$01, then jump to #R$AC3E.
  $AC31,$03 Else, call #R$AD9C.
  $AC34,$02 Loop back round to #R$AC09.
@ $AC36 label=Main_Game_Start_1UP
  $AC36,$03 Call #R$AC3E.
  $AC39,$03 Call #R$A647.
  $AC3C,$02 Loop back round to #R$AC09.

c $AC3E
N $AC3E fff
@ $AC3E label=Start_1UP_Game
  $AC3E,$10 Write #N$00 to; #LIST { #R$AA80 } { #R$B05F } { #R$AA06 } { #R$AA08 } { #R$AA48 } LIST#
  $AC4E,$07 Write #N$01 to; #LIST { #R$AF35 } { #R$AA46 } LIST#
  $AC55,$07 Write #N$02 to; #LIST { #R$AA3C } { #R$AF34 } LIST#
  $AC5C,$03 Call #R$AF0B.

  $AC7A,$06 Point to #R$B035 and call #R$A685.

  $AC91,$09 Point to #R$B024 and call #R$92E4.
  $AC9A,$03 Call #R$AEBF.

  $ACE8,$08 Write #N$19 to; #LIST { #R$AA0C } { #R$AA4C } LIST#
  $ACF0,$13 Write #N$00 to; #LIST { #R$AA0D } { #R$AA0B } { #R$AA4B } { #R$AA16 } { #R$AA56 } { #R$AA0D } LIST#
  $AD03,$08 Write #N$7A to; #LIST { #R$AA18 } { #R$AA58 } LIST#

  $AD0B,$03 Call #R$95D4.
  $AD0E,$03 Call #R$BF13.

  $AD2B,$02 Check if player 1 has 4 points.

  $AD32,$02 Check if player 2 has 4 points.

@ $AD9C label=Start_2UP_Game
  $AD9C,$10 Write #N$00 to; #LIST { #R$B05F } { #R$AA06 } { #R$AA46 } { #R$AA08 } { #R$AA48 } LIST#
  $ADAC,$05 Write #N$02 to; #LIST { #R$AF34 } LIST#

  $AE51,$04 Write #N$00 to; #LIST { #R$C427 } LIST#
  $AE55,$02 Jump to #R$AE5C.
  $AE57,$05 Write #N$01 to; #LIST { #R$C427 } LIST#
  $AE5C,$05 Return if #R$9C28 is not zero.
  $AE61,$06 Jump to #R$AE29 if #R$9C2B is not zero.
  $AE67,$08 Write #N$1C to; #LIST { #R$AA0C } { #R$AA4C } LIST#
  $AE6F,$03 Call #R$ACF0.
  $AE72,$03 Call #R$AF1A.
  $AE75,$03 Call #R$AF1A.
  $AE78,$01 Return.

c $AEBF Print the current Dan (or "NOVICE") message.
@ $AEBF label=Show_Rank
N $AEBF Should this be a Dan, or just "novice"?
  $AEBF,$06 Grab #R$B05F.
  $AEC5,$02 Mask bits d0-d4.
  $AEC7,$02 If the rank is higher than zero jump to #R$AED0.
  $AEC9,$06 Point to #R$B045 and call #R$92E4.
  $AECF,$01 Return.
@ $AED0 label=Rank_Is_Dan
N $AED0 Handle "ST" suffix.
  $AED0,$07 Use #R$B04D if this is the "1st" Dan.
N $AED7 Handle "ND" suffix.
  $AED7,$07 Use #R$B050 if this is the "2nd" Dan.
N $AEDE Handle "RD" suffix.
  $AEDE,$07 Use #R$B053 if this is the "3rd" Dan.
N $AEE5 Handle "TH" suffix.
  $AEE5,$03 Else use #R$B056 for every"th"ing else.
@ $AEE8 label=Print_Rank
N $AEE8 Print the result to screen.
  $AEE8,$06 Call #R$92E4.
  $AEEE,$09 Point to #R$B059 and call #R$92E4.
  $AEF7,$01 Return.

c $AEF8 Initialise time counter.
@ $AEF8 label=Init_Time
  $AEF8,$05 Write #N$1E (30 seconds) to #R$9CA5.
  $AEFD,$03 Call #R$9C93.
  $AF00,$01 Return.

c $AF01
  $AF0A,$01 Return.

c $AF0B Resets score.
@ $AF0B label=Reset_Score
  $AF0B,$0E Writes #N$00 to the memory locations between #N$B02D-#N$B032 (blanks current #N$B02D).
  $AF19,$01 Return.

c $AF1A

c $AF27
B $AF33
B $AF34
B $AF35

c $AF36
  $AF36,$08 Jump to #R$AF7D if #R$AA08 is zero.
  $AF3E,$03 #REGhl=#R$B00B
  $AF41,$06 #REGbc=#N$AA3F.

  $AF52,$01 fff
  $AF53,$03 #REGhl=#R$AA02
  $AF56,$01
  $AF58,$03 #R$B02C($B02D).
  $AF5B,$03 Call #R$AFC2.
  $AF5E,$04 Write #N$00 to; #LIST { #R$AA08 } LIST#
  $AF62,$06 Return if #R$9C2C is zero.

N $AF68 Player 1 display score.
  $AF68,$03 Point to #R$B02F.
  $AF6B,$02 Set a counter of #N$03.
  $AF6D,$03 Call #R$AFDA.
  $AF70,$03 Call #R$AFED.
  $AF73,$09 Point to #R$B024 and call #R$92E4.
  $AF7C,$01 Return.

N $AFAD Player 2 display score.
  $AFAD,$03 Point to #R$B032.
  $AFB0,$02 Set a counter of #N$03.
  $AFB2,$03 Call #R$AFDA.
  $AFB5,$03 Call #R$AFED.
  $AFB8,$09 Point to #R$B024 and call #R$92E4.
  $AFC1,$01 Return.

N $AFC2 Calculate score.
  $AFD9,$01 Return.

c $AFDA
@ $AFDA label=Populate_Score_Buffer
  $AFDA,$03 Point to #R$B024.
  $AFDD,$01 Stores the contents of #REGhl in the accumulator.
@ $AFDD label=Score_Buffer_Loop
  $AFDE,$04 Move bits 4 and 5 into bits 0 and 1.
  $AFE2,$03 Call #R$B004.
  $AFE5,$01 Stores the contents of #REGhl in the accumulator.
  $AFE6,$03 Call #R$B004.
  $AFE9,$01 Decrease #REGhl by one.
  $AFEA,$02 Decrease counter by one and loop back to #R$AFDD until counter is zero.
  $AFEC,$01 Return.

N $AFED Writes "00" to the end of the score.
@ $AFED label=Write_00
  $AFED,$02 #REGa="0" (ASCII zero for display).
  $AFEF,$04 Write "0" to #REGde, increment #REGde by 1, write "0" to #REGde, increment #REGde by 1.
  $AFF3,$02 Writes #N$00 to #REGde (used as a terminator).
@ $AFF3 label=Zero_To_Space
  $AFF5,$03 Point to #R$B024.
  $AFF8,$02 Set a counter of #N$07.
@ $AFFA label=Zero
  $AFFA,$01 Fetch the score character.
  $AFFB,$03 If it is not ASCII "0" then return.
  $AFFE,$02 Overwrite the character with #N$20 (ASCII space for display).
  $B000,$01 Move onto next character.
  $B001,$02 Decrease counter by one and loop back to #R$AFFA until counter is zero.
@ $B001 label=Zero_Loop
  $B003,$01 Return.
N $B004 Convert a single number into ASCII ready for printing to the screen.
@ $B004 label=Convert_ASCII
  $B004,$05 Store the ASCII representation of the number at #REGde
.           (it adds ASCII "0") so for example 1 ends up being
.           1 + #N$30 = #N$31 (e.g. "1" in ASCII).
  $B009,$01 Then increase #REGde by one for the next digit.
  $B00A,$01 Return.

b $B00B

t $B024
T $B024,$08 Score text buffer.
@ $B024 label=Score_Buffer
B $B02C,$03 XXXXX
@ $B02C label=XXXXX
B $B02F,$03 Score Player 1
@ $B02F label=Score_P1
B $B032,$03 Score Player 2
@ $B032 label=Score_P2
B $B035,$03 Hi-Score (defaults to 1000).
@ $B035 label=Hi_Score
T $B039,$05,$04:1 "DEMO" text.
@ $B039 label=Text_Demo
T $B03E,$07,$06:1 "PLAYER" text.
@ $B03E label=Text_Player
T $B045,$08,$07:1 "NOVICE" text.
@ $B045 label=Text_Novice
T $B04D,$03,$02:1 "ST" numeric suffix.
@ $B04D label=Text_ST_Suffix
T $B050,$03,$02:1 "ND" numeric suffix.
@ $B050 label=Text_ND_Suffix
T $B053,$03,$02:1 "RD" numeric suffix.
@ $B053 label=Text_RD_Suffix
T $B056,$03,$02:1 "TH" numeric suffix.
@ $B056 label=Text_TH_Suffix
T $B059,$05,$04:1 "DAN" text.
@ $B059 label=Text_Dan
B $B05F,$01 Current rank (0=novice, 1 or more=Dan rank).
@ $B05F label=Current_Rank
T $B060,$0A,$09:1 Whitespace?
@ $B060 label=Text_Whitespace_9

b $B06A

c $B138
@ $B138 label=Game_Init
  $B138,$05 Write #N$01 to; #LIST { #R$B153 } LIST#
  $B13D,$06 Write #N$FFFF to; #LIST { #R$B151 } LIST#
  $B143,$01 Return.
N $B144 TODO.
B $B144
W $B151
B $B153,$01
B $B154

c $B15A

g $B2FA Sound flag.
@ $B2FA label=Flag_Sound

c $B2FB

b $B800 UDGs
B $B800,$08 #UDG(#PC,attr=56)
L $B800,$08,$E0

c $BF13
  $C100,$01 Return.

c $C101

c $C1A2

c $C1CC

c $C1F6

c $C203 Screen Calculation.
N $C203 This routine works out which area of the screen we are in.
.       Here are a few examples of usage;
.       #REGa=#N$22
.       #REGhl=#N$4000
.       #REGa=#N$22 (restored from #REGe)
.       AND #N$07 == #REGa=#N$02
.       #REGbc=#N$0200
.       #REGhl=#N$4200
.       #REGa=#N$22 (restored from #REGe)
.       AND #N$38 == #REGa=#N$20
.       #REGbc=#N$0020
.       #REGbc=#N$0080
.       #REGhl=#N$4280
@ $C203 label=Screen_Calc
  $C203 Stash the accumulator in #REGe for later.
  $C204,$02 Mask off low bits d6-d7.
  $C206,$03 If the result is now zero, jump to #R$C21A.
  $C209,$05 If #REGa is #N$40 then jump to #R$C214.
  $C20E,$03 Sets #REGhl to #N$5000 (the bottom of the screen buffer).
  $C211,$03 Jump to #R$C21D.
@ $C20E label=Screen_Bottom
  $C214,$03 Sets #REGhl to #N$4800 (the middle of the screen buffer).
@ $C214 label=Screen_Middle
  $C217,$03 Jump to #R$C21D.
  $C21A,$03 Sets #REGhl to #N$4000 (the top of the screen buffer) and continue on...
@ $C21A label=Screen_Top
N $C21D Now we have the base screen address; work out the exact address to return.
  $C21D,$01 Restore the accumulator from #REGe.
@ $C21D label=Screen_Calc_Minor
  $C21E,$02 Mask bits d0-d2.
  $C220,$03 Push the accumulator into #REGbc as the high-order byte (low is #N$00).
  $C223,$01 Adds #REGbc to #REGhl.
  $C224,$01 Again, restore the accumulator from #REGe.
  $C225,$02 Mask bits d3-d5.
  $C227,$03 Push the accumulator into #REGbc as the low-order byte (high is #N$00).
  $C22A,$08 * 2 * 2.
  $C232,$01 Adds #REGbc to #REGhl.
  $C233,$01 Return.

c $C234
  $C2AF,$01 Return.
B $C2B0

c $C2B5
  $C304,$01 Return.

c $C305
  $C318,$01 Return.

c $C319
  $C34E,$01 Return.

c $C34F
  $C36D,$01 Return.

c $C36E
  $C3E3,$01 Return.

c $C3E4
  $C406,$01 Return.

b $C407

g $C409 Player 1 screen position.
@ $C409 label=Position_P1
W $C409 The position in the screen buffer for Player 1.
g $C40B
g $C410
g $C411
g $C412
W $C412
g $C414
g $C41B
g $C41F
g $C421
g $C423
W $C423
g $C425
W $C425
b $C427

B $D296,$40,$08 #UDGARRAY3,scale=4,step=3;(#PC)-(#PC+$F2)-$08(test-2)
B $D2F1,$4B,$05 #UDGARRAY5,scale=4,step=5;(#PC)-(#PC+$F2)-$08(test-3)

B $EB6C,$40,$08 #UDGARRAY2,scale=4,step=2;(#PC)-(#PC+$10)-$10(test-4)
