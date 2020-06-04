#include "basic_io.h"
#include "LCD.h"
#include "SD_Card.h"
#include "fat.h"
#include <altera_avalon_pio_regs.h>
#include "wm8731.h"
#include <stdlib.h>
#include <math.h>

#define NORMAL_SPEED 2
#define HALF_SPEED 0
#define DOUBLE_SPEED 4

volatile int PLAY = 0;
volatile int next_track = 1;
volatile int prev_track = 0;
volatile int pressed = 0;
volatile int data_rate = NORMAL_SPEED;
volatile int data_rate_incr = NORMAL_SPEED;
volatile int sect_num = 0;
volatile int reverse = 0;
volatile int dly_channel = 0;

static void button_ISR(void* context, alt_u32 id)
{
	int buttons = 0;
	buttons = IORD_ALTERA_AVALON_PIO_EDGE_CAP(BUTTON_PIO_BASE) & 0xf;

	if (buttons & 0x01) {
		if (!pressed) {
			PLAY = 0;
			pressed = 1;
		} else {
			pressed = 0;
		}
	}
	if (PLAY == 0) {
		if (buttons & 0x02){
			if (!pressed) {
				PLAY = 1;
				pressed = 1;
			} else {
				pressed = 0;
			}
		} else if (buttons & 0x04) {
			if (!pressed) {
				next_track = 1;
				pressed = 1;
			} else {
				pressed = 0;
			}
		} else if (buttons & 0x08) {
			if (!pressed) {
				prev_track = 1;
				pressed = 1;
			} else {
				pressed = 0;
			}
		}
	}
	IOWR(BUTTON_PIO_BASE, 3, 0x0);
}

int get_play_mode(data_file df) {
	int switches = IORD(SWITCH_PIO_BASE, 0);

	if (switches == 1) {
		data_rate = DOUBLE_SPEED;
		data_rate_incr = DOUBLE_SPEED;
		LCD_Display(df.Name, 1);
		return 1;
	} else if (switches == 2) {
		data_rate = HALF_SPEED;
		// set data rate increment to normal speed, the half speed is accounted for elsewhere
		data_rate_incr = NORMAL_SPEED;
		LCD_Display(df.Name, 2);
		return 2;
	} else if (switches == 4) {
		dly_channel = 1;
		data_rate = NORMAL_SPEED;
		data_rate_incr = NORMAL_SPEED;
		LCD_Display(df.Name, 3);
		return 3;
	} else if (switches == 8) {
		reverse = 1;
		sect_num = df.FileSize/BPB_BytsPerSec - 1;
		data_rate = NORMAL_SPEED;
		data_rate_incr = NORMAL_SPEED;
		LCD_Display(df.Name, 4);
		return 4;
	} else {
		data_rate = NORMAL_SPEED;
		data_rate_incr = NORMAL_SPEED;
		LCD_Display(df.Name, 5);
		return 5;
	}

}

void init(void) {
	if(SD_card_init() == 1) {
		perror("SD Card initialisation failed.");
		exit(1);
	}
	if (init_mbr() == 1) {
		perror("Master boot record initialisation failed.");
		exit(2);
	}
	if (init_bs() == 1) {
		perror("Boot sector initialisation failed.");
		exit(3);
	}
	init_audio_codec();
	LCD_Init();

	// Set up button interrupts
	IOWR(BUTTON_PIO_BASE, 3, 0x0);
	alt_irq_register( BUTTON_PIO_IRQ, (void*)0, button_ISR );
	IOWR(BUTTON_PIO_BASE, 2, 0xf);
}

int main(void) {
	BYTE buffer[512] = {0}; // Stores the block of data read from the SD card. 
	data_file df;
	int length; // Length of the cc[] array.
	int i = 0;
	int rel_sect = 0;
	int play_mode = 0;
	char * filename = "";
	BYTE dly_buff[172][512] = {0};
	int dly_cnt = 0;
	int index = 0;
	int index2 = 0;

	init();

	while (1){
		rel_sect = 0;
		sect_num = 0;
		dly_channel = 0;
		dly_cnt = 0;
		reverse = 0;

		if (next_track) {
			search_for_filetype("WAV", &df, 0, 1);
			next_track = 0;
			play_mode = get_play_mode(df);
		} else if (prev_track) {
			data_file curr_df;
			data_file prev_df;
			search_for_filetype("WAV", &curr_df, 0, 1);

			while(curr_df.Sector != df.Sector) {
				prev_df = curr_df;
				search_for_filetype("WAV", &curr_df, 0, 1);
			}
			df = prev_df;
			prev_track = 0;
			play_mode = get_play_mode(df);
		}

		length = 1+(int)(ceil(df.FileSize/(BPB_BytsPerSec*BPB_SecPerClus)));
		int cc[length];

		if (PLAY) {
			play_mode = get_play_mode(df);
			LCD_File_Buffering(filename);

			build_cluster_chain(cc, length, &df);

			LCD_Display(df.Name, play_mode);
			while(rel_sect == 0 && PLAY){
				rel_sect = get_rel_sector(&df, buffer, cc, sect_num);
				UINT16 tmp; //Create a 16-bit variable to pass to the FIFO
				if (reverse) {
					if (rel_sect > 0)
						rel_sect = 0;
					for (i = 511; i >= 0; i = i-data_rate_incr) {
						while( IORD( AUD_FULL_BASE, 0 ) ); //Check if the FIFO is not full
						tmp = ( buffer[ i ] << 8 ) | ( buffer[ i - 1 ] );
						IOWR( AUDIO_0_BASE, 0, tmp ); //Write the 16-bit variable tmp to the FIFO where it
						//will be processed by the audio CODEC
					}
					sect_num--;
				} else if (dly_channel) {
					index = sect_num % 172;
					index2 = (index + 1) % 172;
					for (i = 0; i < 512; i++) {
						dly_buff[index][i] = buffer[i];
					}
					for (i = 0; i < 512; i = i+2*data_rate_incr) {
						while( IORD( AUD_FULL_BASE, 0 ) ); //Check if the FIFO is not full
						tmp = ( buffer[ i + 1 ] << 8 ) | ( buffer[ i ] );
						IOWR( AUDIO_0_BASE, 0, tmp ); //Write the 16-bit variable tmp to the FIFO where it
						//will be processed by the audio CODEC
						while( IORD( AUD_FULL_BASE, 0 ) );
						tmp = ( dly_buff[ index2 ][ i + 3 ] << 8 ) | ( dly_buff[ index2 ][ i + 2 ] );
						IOWR( AUDIO_0_BASE, 0, tmp );
					}
					sect_num++;
				} else {
					for (i = 0; i < 512; i = i+data_rate_incr) {
						while( IORD( AUD_FULL_BASE, 0 ) ); //Check if the FIFO is not full
						tmp = ( buffer[ i + 1 ] << 8 ) | ( buffer[ i ] );
						IOWR( AUDIO_0_BASE, 0, tmp ); //Write the 16-bit variable tmp to the FIFO where it
						//will be processed by the audio CODEC
						while( IORD( AUD_FULL_BASE, 0 ) );
						if (data_rate == HALF_SPEED) {
							IOWR( AUDIO_0_BASE, 0, tmp );
						}
					}
					sect_num++;
				}
			}
			PLAY = 0;
		}
	}
	return 0;
}
