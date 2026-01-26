CFILES = $(wildcard *.c)
OFILES = $(CFILES:.c=.o)
SFILES = boot.s
SOFILES = $(SFILES:.s=.o)
GCCFLAGS = -Wall -O0 -ffreestanding -nostdinc -nostdlib -nostartfiles -mstrict-align

CC = aarch64-none-elf-gcc
LD = aarch64-none-elf-ld
OBJCOPY = aarch64-none-elf-objcopy

all: clean kernel8.img

%.o: %.s
	$(CC) $(GCCFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(GCCFLAGS) -c $< -o $@

kernel8.img: $(SOFILES) $(OFILES)
	$(LD) -nostdlib $(SOFILES) $(OFILES) -T link.ld -o kernel8.elf
	$(OBJCOPY) -O binary kernel8.elf kernel8.img

clean:
	/bin/rm kernel8.elf *.o *.img > /dev/null 2> /dev/null || true
