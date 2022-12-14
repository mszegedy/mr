SRAM Plus
=========

This patch basically rewrites all of the SRAM saving, loading, and erasing save file routines that SMW uses. It uses DMA to copy the addresses to and from SRAM, meaning that it is probably as efficient as possible. The complicated checksum check and direct file copy was replaced with simple validation bytes, meaning that you have more SRAM at your disposal. The patch also frees up 141 bytes at $1F49 by moving the SRAM buffer to $1EA2.

You should probably apply this patch after you use LM to modify any of the level flags on the overworld -- it doesn't take into account the fact that $1F49 is never being used anymore.

Read sram_table.asm for more information on adding RAM addresses.