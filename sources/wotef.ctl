> $4000 @org=$4000
b $4000 Loading screen
D $4000 #UDGTABLE { #SCR(loading) | The Way Of The Exploding Fist Loading Screen. } TABLE#
@ $4000 label=LOADING
B $4000,6144,32 Pixels
@ $4000 label=SCREEN_BUFFER
B $5800,768,32 Attributes
@ $5800 label=ATTRIBUTE_BUFFER

s $5B00

b $5F00
B $5F00,$01
@ $5F00 label=BACKGROUND_REFERENCE
B $5F02,$02
@ $5F02 label=BBB
W $5F08
@ $5F08 label=BBBB
W $5F0A,$02 Location of code to copy background 1 reference data.
@ $5F0A label=COPY_BACKGROUND_1
W $5F0C,$02 Location of code to copy background 2 reference data.
@ $5F0C label=COPY_BACKGROUND_2
W $5F0E,$02 Location of code to copy background 3 reference data.
@ $5F0E label=COPY_BACKGROUND_3
B $5F10,$12 Buffer which holds the currently processed background data.
@ $5F10 label=BACKGROUND_DATA_BUFFER

c $5F22 Change Background.
N $5F22 Blanks the screen.
  $5F22,$0D Writes $3F to all $300 locations of the attributes buffer.
  $5F2F,$0D Writes $00 to all $1800 locations of the screen buffer.
N $5F3C Fetch the background reference from #R$5F00.
  $5F3C,$04 Loads #REGa with the contents of #R$5F00.
  $5F40,$02 Decrease it by one, then double it.
  $5F42,$03 Store it as the low-order byte of #REGbc (high-order is $00).
  $5F45,$01 Write $00 to #R$5F00.
  $5F46,$03 #REGhl=#R$5F0A
  $5F49,$01 Add #REGbc to #REGhl.
  $5F4A,$03 Loads #REGde with the contents of #REGhl.
  $5F4D,$01 Swap #REGde and #REGhl.
  $5F4E,$03 Call #R$5F52.
  $5F51,$01 Return.
  $5F52,$01 Indirect jump to address held by #REGhl.
. #TABLE(default,centre,centre,centre,centre)
. { =h #R$5F00 | =h Jump }
. { $01 | #R$5F53 }
. { $02 | #R$5F62 }
. { $03 | #R$5F71 }
. TABLE#

N $5F53 Set up background 1.
  $5F53,$0B Copies $12 bytes of data from #R$602B to #R$5F10.
  $5F5E,$03 Call #R$5F80.
  $5F61,$01 Return.

N $5F62 Set up background 2.
  $5F62,$0B Copies $12 bytes of data from #R$603D to #R$5F10.
  $5F6D,$03 Call #R$5F80.
  $5F70,$01 Return.

N $5F71 Set up background 3.
  $5F71,$0B Copies $12 bytes of data from #R$604F to #R$5F10.
  $5F7C,$03 Call #R$5F80.
  $5F7F,$01 Return.

N $5F80 Copy.
  $5F80,$06 Stash $4080 at #R$5F02.
  $5F86,$03 #REGhl=#R$5F10.
  $5F89,$02 #REGb=$04.
  $5F8C,$04 Loads #REGde with the contents of #REGhl. #REGhl is now +2.
  $5F90,$04 Stash #REGde at #R$5F08.
  $5F94,$04 Loads #REGde with the contents of #REGhl. #REGhl is now +2.
  $5F99,$03
  $5F9D,$03 Call #R$5FBE.
  $5FBA,$03 Call #R$6010.
  $5FBD,$01 Return.

c $5FBE
  $5FBE,$01 Grab the contents of #REGhl and store it in #REGa.
  $5FBF,$01 Increase #REGhl by 1.
  $5FC0,$01 Compares the contents of #REGhl with #REGa.
N $5FF4
  $5FF4,$01 Push #REGde onto the stack.
  $5FF5,$01 Push #REGhl onto the stack.
  $5FF6,$02 #REGa=$08.
  $5FF8,$03 Store the contents of #R$5F04 in #REGhl.
  $5FFB,$01
  $5FFC,$02 Copy the contents of #REGhl into the contents of #REGde.
  $5FFE,$01 Increase #REGhl by one.
  $5FFF,$01 Increase #REGd by one.
  $6000,$01
  $6001,$01 Decrease #REGa by one.
  $6002,$02 Jump to #R$5FFB if #REGa is not zero.

c $6010 Unpack background attribute data.
@ $6010 label=BACKGROUND_ATTRIBUTES
N $6010 Moves the attribute data into the buffer. On entry #REGhl will contain one of the following background reference
.       memory locations;
. #TABLE(default,centre,centre)
. { =h Background reference | =h Background data }
. { $01 | #R$6061 }
. { $02 | #R$6B83 }
. { $03 | #R$7766 }
. TABLE#
  $6010,$03 Begin at the start of the #R$5800.
  $6013,$01 Pick up the attribute data from #REGhl.
@ $6013 label=BACKGROUND_ATTR_LOOP
  $6014,$01 Increase #REGhl by one.
  $6015,$03 If the following data is different jump to #R$601A.
  $6018,$02 The data terminates with double zeroes, so if this occurs then return.
  $601A,$04 Test if d07 is set in current attribute data. Reset bit to zero.
N $601A Copy and loop back round to #R$6013 until bit 7 in the current attribute data is zero.
@ $601A label=BACKGROUND_REPEAT_COPY
  $601E,$01 Write the attribute data to #REGde.
  $601F,$01 Increment #REGde by one.
  $6020,$02 Jump back to #R$6013 unless the bit operation was zero.
N $6022 Using the following attribute data byte as a counter, copy the current byte this number of times.
  $6022,$01 Pick up the attribute data from HL into #REGb to use as a counter.
  $6023,$01 Increase #REGhl by one.
  $6024,$01 Decrease the counter by one.
@ $6025 label=BACKGROUND_COPY_ATTR_REPEAT
  $6025,$01 Write the same attribute data to #REGde.
  $6026,$01 Increment #REGde by one.
  $6027,$02 Decrease counter by one and loop back to #R$6025 until counter is zero.
  $6029,$02 Jump back to #R$6013.

b $602B Background 1 Data.
@ $602B label=BACKGROUND_1_DATA
W $602B,$10
W $603B Attribute data.
@ $603B label=BACKGROUND_1_ATTRIBUTE_DATA

b $603D Background 2 Data.
@ $603D label=BACKGROUND_2_DATA
W $603D,$10
W $604D Attribute data.
@ $604D label=BACKGROUND_2_ATTRIBUTE_DATA

b $604F Background 3 Data.
@ $604F label=BACKGROUND_3_DATA
W $604F,$10
W $605F Attribute data.
@ $605F label=BACKGROUND_3_ATTRIBUTE_DATA

b $6061 Background 1 attribute data.
B $6100,$02 Terminator.
b $6102 Background 1 data.
b $6157 Background 1 data.
b $61D9 Background 1 data.
b $624D Background 1 data.
b $626A Background 1 data.
b $648A Background 1 data.
b $685A Background 1 data.
b $6AE2 Background 1 data.
b $6B83 Background 2 attribute data.
B $6C49,$02 Terminator.
b $6C4B Background 2 data.
b $6C79 Background 2 data.
b $6CF7 Background 2 data.
b $6D79 Background 2 data.
b $6DAE Background 2 data.
b $6E96 Background 2 data.
b $720E Background 2 data.
b $7606 Background 2 data.
b $7766 Background 3 attribute data.
B $784D,$02 Terminator.
b $784F Background 3 data.
b $7893 Background 3 data.
b $7910 Background 3 data.
b $7991 Background 3 data.
b $79B1 Background 3 data.
b $7BB1 Background 3 data.
b $7D09 Background 3 data.
b $7F39 Background 3 data.

b $8000 Background
@ $8000 label=BACKGROUND_1
D $8000 #SCR2,0,0,32,8,$8000,$8800 (background-1)
B $8000,$800,$20 Pixels
B $8800,$100,$20 Attributes

c $8833

c $8898
  $889C

c $8A30
C $8AA2,$03 Jump to #R$8833.

c $8AD1
C $8AE8,$01 Return.

w $8BD2 Player 1 configs.
@ $8BD2 label=PLAYER_1

w $8BE6 Player 2 configs.
@ $8BE6 label=PLAYER_2

c $8C54 Game Settings.
N $8C54 The main settings page, used for directing to the controls for P1/ P2 and turning the sound on or off.
@ $8C54 label=GAME_CONFIGS_MAIN
  $8C54,$03 Call #R$8E4C.
  $8C57,$09 Point to #R$8E6B and call #R$92E4.
  $8C60,$09 Point to #R$8E8C and call #R$92E4.
  $8C69,$09 Point to #R$8E99 and call #R$92E4.
  $8C72,$09 Point to #R$8EA6 and call #R$92E4.
  $8C7B,$09 Point to #R$8EB3 and call #R$92E4.
  $8C84,$09 Point to #R$8EC6 and call #R$92E4.
N $8C8D Does the user want to change Player 1 input method?
  $8C8D,$05 Check if "1" key is pressed.
@ $8C8D label=GAME_CONFIGS_P1
  $8C92,$03 No keys were pressed, continue on to #R$8C9E.
  $8C95,$06 Write #R$8BD2 to #R$8E69.
  $8C9B,$03 Jump to #R$8CDB.
N $8C9E Does the user want to change Player 2 input method?
  $8C9E,$05 Check if "2" key is pressed.
@ $8C9E label=GAME_CONFIGS_P2
  $8CA3,$03 No keys were pressed, continue on to #R$8CAF.
  $8CA6,$06 Write #R$8BE6 to #R$8E69.
  $8CAC,$03 Jump to #R$8CDB.
N $8CAF Does the user want to exit this config screen and go back to the demo mode?
  $8CAF,$05 Check if "E" key is pressed.
@ $8CAF label=GAME_CONFIGS_EXIT
  $8CB4,$03 Jump to #R$8CDA (just returns).
N $8CB7 Does the user want to toggle the sound flag to be "ON".
  $8CB7,$05 Check if "3" key is pressed.
@ $8CB7 label=GAME_CONFIGS_SOUND_ON
  $8CBC,$03 No keys were pressed, continue on to #R$8CC7.
  $8CBF,$05 Write $01 to #R$B2FA.
  $8CC4,$03 Jump to #R$8CDA (just returns).
N $8CC7 Does the user want to toggle the sound flag to be "OFF".
  $8CC7,$05 Check if "4" key is pressed.
@ $8CC7 label=GAME_CONFIGS_SOUND_OFF
  $8CCC,$03 No keys were pressed, continue on to #R$8CD7.
  $8CCF,$05 Write $00 to #R$B2FA.
  $8CD7,$03 Loop back round to #R$8C8D.
@ $8CD7 label=GAME_CONFIGS_END
  $8CD4,$03 Jump to #R$8CDA (just returns).
  $8CDA,$01 Return.
@ $8CDA label=GAME_CONFIGS_RETURN

c $8CDB Game Control Settings.
N $8CDB The player controls menu.  Used for either player, references the currently targetted player at #R$8E69.
@ $8CDB label=GAME_CONFIGS_CONTROLS
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
@ $8D1A label=GAME_CONTROLS_DEFAULTS
  $8D1F,$03 No keys were pressed, continue on to #R$8D25.
  $8D22,$03 Jump to #R$8D57.
N $8D25 Change player to use "Sinclair Joystick #1"?
  $8D25,$05 Check if "2" key is pressed.
@ $8D25 label=GAME_CONTROLS_SINCLAIR_1
  $8D2A,$03 No keys were pressed, continue on to #R$8D30.
  $8D2D,$03 Jump to #R$8D75.
N $8D30 Change player to use "Sinclair Joystick #2"?
  $8D30,$05 Check if "3" key is pressed.
@ $8D30 label=GAME_CONTROLS_SINCLAIR_2
  $8D35,$03 No keys were pressed, continue on to #R$8D3B.
  $8D38,$03 Jump to #R$8D81.
N $8D3B Change player to use "Kempston" joystick?
  $8D3B,$05 Check if "5" key is pressed.
@ $8D3B label=GAME_CONTROLS_KEMPSTON
  $8D40,$03 No keys were pressed, continue on to #R$8D46.
  $8D43,$03 Jump to #R$8D8D.
N $8D46 Redefine keys for player.
  $8D46,$05 Check if "4" key is pressed.
@ $8D46 label=GAME_CONTROLS_KEYBOARD
  $8D4B,$03 No keys were pressed, loop back round to #R$8D1A.
  $8D4E,$06 Adds a delay for keyboard debounce.
  $8D54,$03 Jump to #R$8D99.
N $8D57 Actions setting keyboard controls for player back to defaults.
  $8D57,$09 Check if #R$8E69 is equal to #R$8BD2.
@ $8D57 label=GAME_CONTROLS_SET_DEFAULT
  $8D60,$03 Jump to #R$8D6C if we are working with player 2.
  $8D63,$06 Store #R$8BFA at #R$8BD2.
  $8D69,$03 Jump to #R$8CDA (just returns).
  $8D6C,$06 Store #R$8C0C at #R$8BE6.
@ $8D6C label=GAME_CONTROLS_SET_DEFAULT_P2
  $8D72,$03 Jump to #R$8CDA (just returns).

N $8D75 Actions setting player to use Sinclair Joystick #1.
  $8D75,$03 Fetch the current player from #R$8E69.
@ $8D75 label=GAME_CONTROLS_SET_SINCLAIR_1
  $8D78,$06 Pushes #R$8C30 for the current player.
  $8D7E,$03 Jump to #R$8CDA (just returns).

N $8D81 Actions setting player to use Sinclair Joystick #2.
  $8D81,$03 Fetch the current player from #R$8E69.
@ $8D81 label=GAME_CONTROLS_SET_SINCLAIR_2
  $8D84,$06 Pushes #R$8C1E for the current player.
  $8D8A,$03 Jump to #R$8CDA (just returns).

N $8D8D Actions setting player to use Kempston Joystick.
  $8D8D,$03 Fetch the current player from #R$8E69.
@ $8D8D label=GAME_CONTROLS_SET_KEMPSTON
  $8D90,$06 Pushes #R$8C42 for the current player.
  $8D96,$03 Jump to #R$8CDA (just returns).

c $8D99 Game Settings - Redefine Keys.
@ $8D99 label=GAME_CONFIGS_KEYS
  $8D99,$03 Call #R$8E4C.
N $8D9C Displays the "for each direction ... press key" banner.
  $8D9C,$09 Point to #R$8F6B and call #R$92E4.
  $8DA5,$09 Point to #R$8F89 and call #R$92E4.
  $8DAE,$09 Point to #R$8FA7 and call #R$92E4.
N $8DB7 xxxx
  $8DB7,$08 Stores the contents of #R$8E69 in both #REGde and #REGhl.
  $8DBE,$02 Increase #REGde by two.
  $8DC0,$03 Stores #REGde at the address held by #REGhl.
N $8DC3 Go through each key and process.
C $8DC3,$06 Point to #R$8FBB and call #R$8DFC.
C $8DC9,$06 Point to #R$8FBE and call #R$8DFC.
C $8DCF,$06 Point to #R$8FC7 and call #R$8DFC.
C $8DD5,$06 Point to #R$8FCD and call #R$8DFC.
C $8DDB,$06 Point to #R$8FD8 and call #R$8DFC.
C $8DE1,$06 Point to #R$8FDD and call #R$8DFC.
C $8DE7,$06 Point to #R$8FE7 and call #R$8DFC.
C $8DED,$06 Point to #R$8FEC and call #R$8DFC.
C $8DF3,$06 Point to #R$8FF4 and call #R$8DFC.
  $8DF9,$03 Jump to #R$8CDA.
N $8DFC gggg
C $8DFC,$08 Call #R$92E4.
@ $8DFC label=PRINT_KEY_LOOP

C $8E11,$09 Point to #R$9000 and call #R$92E4.

  $8E1A,$06 Delay (for debounce) twice #R$8E42.
  $8E20,$01 Restores the current key location off the stack.
  $8E21,$01 Return.

N $8E22 CCCC
@ $8E22 label=GET_KEY
  $8E22,$03 #REGde=#R$8E3A.
  $8E25,$02 Set a counter #REGb=$08.
  $8E27,$03 Using the current port, read the keyboard.
@ $8E27 label=GET_KEY_LOOP
  $8E2A,$03 Is a key being pressed?
  $8E2D,$03 Yes - jump to #R$8E36.
  $8E30,$01 Increase #REGde by one.
  $8E31,$02 Decrease counter by one and loop back to #R$8E27 until counter is zero.
  $8E33,$03 Jump to #R$8E22.

  $8E36,$01 #REGl=#REGa.
@ $8E36 label=STORE_KEY
  $8E37,$01 Store the contents of #REGde in #REGa.
  $8E38,$01 #REGh=#REGa.
  $8E39,$01 Return.

N $8E3A The keyboard is split into 8 sections - 4 'half rows' on each side, and each with a unique port number.
. #TABLE(default,centre,centre,centre,centre,centre,centre)
. { =h,r2 Port Number | =h,c5 Bit }
. { =h 0 | =h 1 | =h 2 | =h 3 | =h 4 }
. { $FE | SHIFT | Z | X | C | V }
. { $FD | A | S | D | F | G }
. { $FB | Q | W | E | R | T }
. { $F7 | 1 | 2 | 3 | 4 | 5 }
. { $EF | 0 | 9 | 8 | 7 | 6 }
. { $DF | P | O | I | U | Y }
. { $BF | ENTER | L | K | J | H }
. { $7F | SPACE | FULL-STOP | M | N | B }
. TABLE#
B $8E3A,$08 Key Data
@ $8E3A label=KEY_DATA

c $8E42 Short delay.
@ $8E42 label=CONFIGS_DELAY
  $8E42,$03 Set #REGbc=$EA60
@ $8E45 label=CONFIGS_DELAY_LOOP
  $8E45,$06 Countdown #REGbc until #0000.
  $8E4B,$01 Return.

c $8E4C Blank the screen buffer.
@ $8E4C label=CLEAR_SCREEN
  $8E4C,$0E Clears the screen buffer by writing $00 to 6143 memory locations.
  $8E5A,$0F Clears the attribute buffer by writing $0D to 767 memory locations.
  $8E68,$01 Return.

w $8E69 Holds which player is currently being altered.
D $8E69 Will hold either;
. #TABLE(default,centre,centre)
. { =h #R$8BD2 | $8BD2 }
. { =h #R$8BE6 | $8BE6 }
. TABLE#
@ $8E69 label=TEMP_PLAYER

t $8E6B
T $8E6B,$21,$20:1 P1 controls text.
@ $8E6B label=TEXT_P1_CONTROLS
T $8E8C,$0D,$0C:1 P2 text.
@ $8E8C label=TEXT_P2_CONTROLS
T $8E99,$0D,$0C:1 Sound on text.
@ $8E99 label=TEXT_SOUND_ON
T $8EA6,$0D,$0C:1 Sound off text.
@ $8EA6 label=TEXT_SOUND_OFF
T $8EB3,$13,$12:1 "Type" message.
@ $8EB3 label=TEXT_TYPE_1
T $8EC6,$10,$0F:1 "Exit" message.
@ $8EC6 label=TEXT_EXIT
T $8ED6,$1E,$1D:1 "Default" layout text.
@ $8ED6 label=TEXT_DEFAULT_LAYOUT
T $8EF4,$1B,$1A:1 P1 "Sinclair" text.
@ $8EF4 label=TEXT_SINCLAIR_P1
T $8F0F,$1B,$1A:1 P2 "Sinclair" text.
@ $8F0F label=TEXT_SINCLAIR_P2
T $8F2A,$17,$16:1 Reconfigure keyboard text.
@ $8F2A label=TEXT_KEYBOARD_RECONFIG
T $8F41,$18,$17:1 "Kempston" text.
@ $8F41 label=TEXT_KEMPSTON
T $8F59,$12,$11:1 "Type" message.
@ $8F59 label=TEXT_TYPE_2
T $8F6B,$1E,$1D:1 "Change keys line 1" message.
@ $8F6B label=TEXT_CHANGE_1
T $8F89,$1E,$1D:1 "Change keys line 2" message.
@ $8F89 label=TEXT_CHANGE_2
T $8FA7,$14,$13:1 "Change keys line 3" message.
@ $8FA7 label=TEXT_CHANGE_3
T $8FBB,$03,$02:1 "Up" text.
@ $8FBB label=TEXT_UP
T $8FBE,$09,$08:1 "Up-Right" text.
@ $8FBE label=TEXT_UP_RIGHT
T $8FC7,$06,$05:1 "Right" text.
@ $8FC7 label=TEXT_RIGHT
T $8FCD,$0B,$0A:1 "Down-Right" text.
@ $8FCD label=TEXT_DOWN_RIGHT
T $8FD8,$05,$04:1 "Down" text.
@ $8FD8 label=TEXT_DOWN
T $8FDD,$0A,$09:1 "Down-Left" text.
@ $8FDD label=TEXT_DOWN_LEFT
T $8FE7,$05,$04:1 "Left" text.
@ $8FE7 label=TEXT_LEFT
T $8FEC,$08,$07:1 "Up-Left" text.
@ $8FEC label=TEXT_UP_LEFT
T $8FF4,$0C,$0B:1 "Fire" text.
@ $8FF4 label=TEXT_FIRE
T $9000,$0D,$0C:1 Blank text.
@ $9000 label=TEXT_WHITESPACE_12

i $900D

c $900E

B $9128

c $9200
  $9200,$03 Write #REGa to #R$5F00.
  $9203,$03 Call #R$5F22.
  $9206,$05 Call #R$C203 using $48.
  $920B,$05
  $9210,$01 Push #REGhl onto the stack.
  $9211,$01 Push #REGde onto the stack.
  $9212,$01 Push #REGbc onto the stack.
  $9213,$05 Copy #REGhl to #REGde $20 times.

c $9229

c $92E4 Print String.
@ $92E4 label=PRINT_STRING
D $92E4 #TABLE(default,centre,centre)
.       { =h REGhl | =h REGde }
.       { Memory location of string | X/Y position on screen }
.       TABLE#

B $932C,$0A Guessing at the length.

c $95D4
  $95E0,$01 Return.
N $95E1 fffff
  $95E1,$01

c $9745 Demo Mode.
@ $9745 label=DEMO_MODE

  $97DC

N $9801 Should we start a 2 player game?
@ $9801 label=DEMO_START_2UP
  $9801,$05 Check if "2" key is pressed.
  $9806,$02 No keys were pressed, continue on to #R$981A.
  $9808,$05 Writes $02 to #R$9C2C.
  $980D,$07 Writes $00 to #R$AA06 and #R$AA46.
  $9814,$03 Call #R$909E.
  $9817,$02 #REGa=$80.
  $9819,$01 Return.

N $981A Should we go to the config page?
@ $981A label=DEMO_CONFIGS_MAIN
  $981A,$05 Check if "0" key is pressed.
  $981F,$02 No keys were pressed, continue on to #R$983D.
  $9821,$03 Call #R$8C54.
  $9824,$02 #REGa=$80.
  $9826,$01 Return.

N $9827 Checks if "G" and "H" are being held to quit a game.
@ $9827 label=CHECK_QUIT_GAME
  $9827,$05 Check if "H" key is pressed.
  $982C,$02 No keys were pressed, continue on to #R$983D.
  $982E,$05 Check if "G" key is pressed.
  $9833,$02 No keys were pressed, continue on to #R$983D.
  $9835,$04 Writes $00 to #R$9C2C.
  $9839,$02 #REGa=$80.
  $983C,$01 Return.

  $98BF,$03 #REGhl=#R$9C2C.
  $98C2,$02 Set a counter of 1.
  $98C4,$03 Call #R$AFDA.
  $98C7,$03 Call #R$AFF3.
  $98CA,$09 Point to #R$B024 and call #R$92E4.
  $98D3,$09 Point to #R$B03E and call #R$92E4.
  $98DC,$01 Return.

b $9C28

g $9C2C Number of players.
@ $9C2C label=NUM_PLAYERS

c $9C2E Game Entry Point.
@ $9C2E label=GAME_START
  $9C2E,$01 Disable interrupts.
  $9C2F,$04 Set border colour to $05 (cyan).
  $9C33,$04 Set the stack pointer to $5BFF.
  $9C37,$03 Call #R$B138.

  $9C3A,$09 Blah...
  $9C45,$02 #REGa=$00
  $9C47,$09 Writes $00 to #R$C423 and #R$C425.
  $9C50,$03 Jump to #R$AC05.

c $9C53 Read Key Input.
N $9C53 Annotated by Stephen Jones; Spectrum Discovery Club.
@ $9C53 label=KEYBOARD_TEST
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
@ $9C64 label=KEYBOARD_FIND_ROW
  $9C65,$02 Repeat until we've found the relevant row.
  $9C67,$02 Read port (#REGa=high, 254=low).
  $9C69,$01 Rotate bit out of result.
@ $9C69 label=KEYBOARD_ROTATE_LOOP
  $9C6A,$01 Loop counter.
  $9C6B,$02 Repeat until bit for position in carry flag.
  $9C6D,$01 Return.

u $9C6E

c $9C6F

c $9C93
@ $9C93 label=KKKK
  $9C93,$03 Stores #R$9CA5 in the accumulator.
  $9C96,$03 #REGh = $00, #REGl = #REGa.
  $9C99,$03 #REGde=$0B00.
  $9C9C,$03 Call #R$9336.
  $9C9F,$01 Return.

c $9CA0 Countdown time by one unit.
@ $9CA0 label=TIME_TICK
C $9CA0,$05 Decrease #R$9CA5 by 1 and return.

g $9CA5 Time.
@ $9CA5 label=TIME

c $9CA6

c $A685 Print Hi-Score.
@ $A685 label=PRINT_HISCORE
  $A685,$02 Set a counter = $03 digits.
  $A687,$03 Call #R$AFDA.
  $A68A,$03 Call #R$AFED.
  $A68D,$09 Point to #R$B024 and call #R$92E4.
  $A696,$01 Return.

c $A697

t $AA9C
T $AA9D,$04 "DEMO" text.
T $AAA1,$06 "PLAYER" text.
T $AAA7,$06 "NOVICE" text.
T $AAAE,$08,$02 numeric suffixes.
T $AAB7,$03 "DAN" text.
T $AABA,$08 "JOYSTICK" text.
T $AAC2,$08 "KEYBOARD" text.
T $AACC,$0C Whitespace?

c $AB70
  $AB70,$01 #REGa=$00
  $AB71,$06 Writes $00 to #R$B05F and #R$9C2C.
  $AB77,$03 Call #R$A3FF.

  $AB9D,$09 Point to #R$B039 and call #R$92E4.
  $ABA6,$06 Point to #R$B035 and call #R$A685.
  $ABAC,$03 Call #R$909E.
  $ABAF,$03 Call #R$AEF8.

  $ABBE,$04 Point to #R$B05F and increment it by 1.
  $ABC2,$05 If this value is not $04 then jump to #R$AB97.
  $ABC7,$01 Else, return.

c $AC05 Quit game.
@ $AC05 label=QUIT_GAME
  $AC05,$04 Writes $00 to #R$9C2C.
  $AC09,$09 Point to #R$B060 and call #R$92E4.
  $AC12,$09 Point to #R$B060 and call #R$92E4.
  $AC1B,$09 Point to #R$B039 and call #R$92E4.
  $AC24,$03 Call #R$AB70.

  $AC7A,$06 Point to #R$B035 and call #R$A685.

  $AC91,$09 Point to #R$B024 and call #R$92E4.
  $AC9A,$03 Call #R$AEBF.

  $AD2B,$02 Check if player 1 has 4 points.

  $AD32,$02 Check if player 2 has 4 points.

c $AEBF Print the current Dan (or "NOVICE") message.
@ $AEBF label=SHOW_RANK
N $AEBF Should this be a Dan, or just "novice"?
  $AEBF,$06 Grab #R$B05F.
  $AEC5,$02 Mask bits d0-d4.
  $AEC7,$02 If the rank is higher than zero jump to #R$AED0.
  $AEC9,$06 Point to #R$B045 and call #R$92E4.
  $AECF,$01 Return.
@ $AED0 label=RANK_IS_DAN
N $AED0 Handle "ST" suffix.
  $AED0,$07 Use #R$B04D if this is the "1st" Dan.
N $AED7 Handle "ND" suffix.
  $AED7,$07 Use #R$B050 if this is the "2nd" Dan.
N $AEDE Handle "RD" suffix.
  $AEDE,$07 Use #R$B053 if this is the "3rd" Dan.
N $AEE5 Handle "TH" suffix.
  $AEE5,$03 Else use #R$B056 for every"th"ing else.
@ $AEE8 label=PRINT_RANK
N $AEE8 Print the result to screen.
  $AEE8,$06 Call #R$92E4.
  $AEEE,$09 Point to #R$B059 and call #R$92E4.
  $AEF7,$01 Return.

c $AEF8 Initialise time counter.
C $AEF8,$05 Write $1E (30 seconds) to #R$9CA5.
C $AEFD,$03 Call #R$9C93.
C $AF00,$01 Return.

c $AF0B Resets score.
@ $AF0B label=RESET_SCORE
  $AF0B,$0E Writes $00 to the memory locations between $B02D-$B032 (blanks current $B02D).
  $AF19,$01 Return.

c $AF1A

N $AF68 Player 1 display score.
  $AF68,$03 Point to #R$B02F.
  $AF6B,$02 Set a counter of $03.
  $AF6D,$03 Call #R$AFDA.
  $AF70,$03 Call #R$AFED.
  $AF73,$09 Point to #R$B024 and call #R$92E4.
  $AF7C,$01 Return.

N $AFAD Player 2 display score.
  $AFAD,$03 Point to #R$B032.
  $AFB0,$02 Set a counter of $03.
  $AFB2,$03 Call #R$AFDA.
  $AFB5,$03 Call #R$AFED.
  $AFB8,$09 Point to #R$B024 and call #R$92E4.
  $AFC1,$01 Return.

N $AFC2 Calculate score.
  $AFD9,$01 Return.

c $AFDA
@ $AFDA label=POPULATE_SCORE_BUFFER
  $AFDA,$03 Point to #R$B024.
  $AFDD,$01 Stores the contents of #REGhl in the accumulator.
@ $AFDD label=SCORE_BUFFER_LOOP
  $AFDE,$04 Move bits 4 and 5 into bits 0 and 1.
  $AFE2,$03 Call #R$B004.
  $AFE5,$01 Stores the contents of #REGhl in the accumulator.
  $AFE6,$03 Call #R$B004.
  $AFE9,$01 Decrease #REGhl by one.
  $AFEA,$02 Decrease counter by one and loop back to #R$AFDD until counter is zero.
  $AFEC,$01 Return.

N $AFED Writes "00" to the end of the score.
@ $AFED label=WRITE_00
  $AFED,$02 #REGa="0" (ASCII zero for display).
  $AFEF,$04 Write "0" to #REGde, increment #REGde by 1, write "0" to #REGde, increment #REGde by 1.
  $AFF3,$02 Writes $00 to #REGde (used as a terminator).
@ $AFF3 label=ZERO_TO_SPACE
  $AFF5,$03 Point to #R$B024.
  $AFF8,$02 Set a counter of $07.
@ $AFFA label=ZERO
  $AFFA,$01 Fetch the score character.
  $AFFB,$03 If it is not ASCII "0" then return.
  $AFFE,$02 Overwrite the character with $20 (ASCII space for display).
  $B000,$01 Move onto next character.
  $B001,$02 Decrease counter by one and loop back to #R$AFFA until counter is zero.
@ $B001 label=ZERO_LOOP
  $B003,$01 Return.
N $B004 Convert a single number into ASCII ready for printing to the screen.
@ $B004 label=CONVERT_ASCII
  $B004,$05 Store the ASCII representation of the number at #REGde
.           (it adds ASCII "0") so for example 1 ends up being
.           1 + $30 = $31 (e.g. "1" in ASCII).
  $B009,$01 Then increase #REGde by one for the next digit.
  $B00A,$01 Return.

b $B00B

t $B024
T $B024,$08 Score text buffer.
@ $B024 label=SCORE_BUFFER
B $B02C,$03 XXXXX
@ $B02C label=XXXXX
B $B02F,$03 Score Player 1
@ $B02F label=SCORE_P1
B $B032,$03 Score Player 2
@ $B032 label=SCORE_P2
B $B035,$03 Hi-Score (defaults to 1000).
@ $B035 label=HISCORE
T $B039,$05,$04:1 "DEMO" text.
@ $B039 label=TEXT_DEMO
T $B03E,$07,$06:1 "PLAYER" text.
@ $B03E label=TEXT_PLAYER
T $B045,$08,$07:1 "NOVICE" text.
@ $B045 label=TEXT_NOVICE
T $B04D,$03,$02:1 "ST" numeric suffix.
@ $B04D label=TEXT_ST_SUFFIX
T $B050,$03,$02:1 "ND" numeric suffix.
@ $B050 label=TEXT_ND_SUFFIX
T $B053,$03,$02:1 "RD" numeric suffix.
@ $B053 label=TEXT_RD_SUFFIX
T $B056,$03,$02:1 "TH" numeric suffix.
@ $B056 label=TEXT_TH_SUFFIX
T $B059,$05,$04:1 "DAN" text.
@ $B059 label=TEXT_DAN
B $B05F,$01 Current rank (0=novice, 1 or more=Dan rank).
@ $B05F label=CURRENT_RANK
T $B060,$0A,$09:1 Whitespace?
@ $B060 label=TEXT_WHITESPACE_9

b $B06A

c $B138

g $B2FA Sound flag.
@ $B2FA label=FLAG_SOUND

c $B2FB

b $B800 #UDGARRAY2,attr=7,scale=4,step=2,flip=2;(#PC)-(#PC+$11)-$01-$10(test-1)

c $BF13
  $C100,$01 Return.

c $C101

c $C1A2

c $C1CC

c $C1F6

c $C203 Screen Calculation.
N $C203 This routine works out which area of the screen we are in.
.       Here are a few examples of usage;
.       #REGa=$22
.       #REGhl=$4000
.       #REGa=$22 (restored from #REGe)
.       AND $07 == #REGa=$02
.       #REGbc=$0200
.       #REGhl=$4200
.       #REGa=$22 (restored from #REGe)
.       AND $38 == #REGa=$20
.       #REGbc=$0020
.       #REGbc=$0080
.       #REGhl=$4280
@ $C203 label=SCREEN_CALC
  $C203 Stash the accumulator in #REGe for later.
  $C204,$02 Mask off low bits d06-d07.
  $C206,$03 If the result is now zero, jump to #R$C21A.
  $C209,$05 If #REGa is $40 then jump to #R$C214.
  $C20E,$06 Sets #REGhl to $5000 (the bottom of the screen buffer) and jump to #R$C21D.
@ $C20E label=SCREEN_BOTTOM
  $C214,$06 Sets #REGhl to $4800 (the middle of the screen buffer) and jump to #R$C21D.
@ $C214 label=SCREEN_MIDDLE
  $C217,$03 Jump to #R$C21D.
  $C21A,$03 Sets #REGhl to $4000 (the top of the screen buffer) and continue on...
@ $C21A label=SCREEN_TOP
N $C21D Now we have the base screen address; work out the exact address to return.
  $C21D,$01 Restore the accumulator from #REGe.
@ $C21D label=SCREEN_CALC_MINOR
  $C21E,$02 Mask bits d0-d2.
  $C220,$03 Push the accumulator into #REGbc as the high-order byte (low is $00).
  $C223,$01 Adds #REGbc to #REGhl.
  $C224,$01 Again, restore the accumulator from #REGe.
  $C225,$02 Mask bits d03-d05.
  $C227,$03 Push the accumulator into #REGbc as the low-order byte (high is $00).
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

g $C410
g $C411
g $C41B
g $C41F
g $C421
g $C423
g $C425
b $C427

B $D293,$40,$08 #UDGARRAY3,scale=4,step=3;(#PC)-(#PC+$F2)-$08(test-2)

B $EB6C,$40,$08 #UDGARRAY2,scale=4,step=2;(#PC)-(#PC+$10)-$10(test-3)
