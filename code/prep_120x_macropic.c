/* GLP2.0	Christian Horn <chorn@fluxcoil.net>
 * 
 * media prepare: 
 * This reads the next 8 frames as bmp-file, and writes
 * them into a single file.  The output format are simply
 * all 120x90 pixels after each other, no header.  As in
 * the input, all 3 bytes for RGB are always same, that's
 * just a single byte here.
 * Why not just one single output file?
 * Because the Lua script is reading
 * the complete file, so we are memory bound on the mp3player.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct rec {
	unsigned char c;
};

int main() {

	int i, width, height, counter = 0;
	int picnumber,pixarray;
	char basepath[512]="../bamedia/tiny_120x90/image-";
	char pic1path[512];
	char differpath[512];
	FILE *f1, *f2;
	struct rec mydiffs[50000];
	int mydiffcnt,myoffset=0;
	int *mysize;

	char outputbase[512]="../bamedia/tiny_120x90-macropic/pic-";
	char outputpath[512];
	int  outputcnt=0, framesperfile=8, framecnt=0;
	FILE *foutput;

	mysize=malloc(4);

	// for ( picnumber=1; picnumber < 500; picnumber++ ) {
	for ( picnumber=1; picnumber < 6571; picnumber+=framesperfile ) {
		mydiffcnt = 0;

		sprintf(pic1path,"%s%07d.bmp", basepath, picnumber);
		// printf("working on %s \n", pic1path );	
	
		f1 = fopen( pic1path, "rb");
                if (NULL == f1) {
                        printf("\nfopen() error, could not open %s for reading.\n", pic1path);
                        return 1;
                };
		fseek(f1, 0, SEEK_END);
		long fsize1 = ftell(f1);
		fseek(f1, 0, SEEK_SET);
		unsigned char *contents1 = malloc(fsize1 + 1);
		fread(contents1, 1, fsize1, f1);
		fclose(f1);
		contents1[fsize1] = 0;
	
		pixarray = contents1[10];
		width = contents1[18];
		height = contents1[22];
	
		// printf("pixarray: %d \n", pixarray);
		// printf("fsize: %d \n", fsize1);
		// printf("pic1 : %d x %d \n", width, height);
		
		int cntx=1,cnty=1;
		for ( i=pixarray; i < fsize1; i+=3 ) {
			// printf("trying to store: %x %x %x\n", cntx, cnty, contents2[i]);
			mydiffs[mydiffcnt].c=contents1[i];
			mydiffcnt++;

			if ( cntx < width ) {
				cntx++;
			}
			else {
				cntx=1;
				cnty++;
			};
		}
		free(contents1);

		if (framecnt > (framesperfile -1) )  {
			outputcnt+=1;
			framecnt=0;
		}
	
		printf("working on pic %s, output file %s \n", pic1path, outputpath );	
		// output section
		sprintf(outputpath,"%s%07d", outputbase, outputcnt);
		foutput = fopen( outputpath, "ab");
		if (foutput == NULL) {
			printf("Could not open %s for writing.\n", outputpath);
			return 1;
		}

		fwrite( mydiffs, mydiffcnt, 1, foutput);

		fclose(foutput);

		framecnt++;
	}

	return 0;
}
