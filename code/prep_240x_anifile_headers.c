/* GLP2.0	Christian Horn <chorn@fluxcoil.net>
 * 
 * media prepare: 
 * Takes 2 pictures, compares them, writes diffs into an
 * output file.  
 * Each diffset has a 4 byte header, the size of all of the
 * diffs for that frame, including that 4 byte header.
 * Each output file gets 8 diffs.  Why not
 * just one single file?  Because the Lua script is reading
 * the complete file, so we are memory bound on the mp3player.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct rec {
	unsigned char x,y,c;
};

int main() {

	int i, width, height, counter = 0;
	int picnumber,pixarray;
	char basepath[512]="../bamedia/tiny_240x180/image-";
	char pic1path[512],pic2path[512],differpath[512];
	FILE *f1, *f2;
	struct rec mydiffs[50000];
	int mydiffcnt,myoffset=0;
	int *mysize;

	char outputbase[512]="../bamedia/tiny_240x180-ani/part-";
	char outputpath[512];
	int  outputcnt=0, framesperfile=3, framecnt=0;
	FILE *foutput;

	mysize=malloc(4);

	// for ( picnumber=1; picnumber < 500; picnumber++ ) {
	for ( picnumber=1; picnumber < 6571; picnumber++ ) {
		mydiffcnt = 0;

		sprintf(pic1path,"%s%07d.bmp", basepath, picnumber);
		sprintf(pic2path,"%s%07d.bmp", basepath, picnumber + 1);
		printf("comparing %s and %s. ", pic1path, pic2path );	
	
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
	
		f2 = fopen( pic2path, "rb");
                if (NULL == f2) {
                        printf("\nfopen() error, could not open %s for reading.\n", pic2path);
                        return 1;
                };
		fseek(f2, 0, SEEK_END);
		long fsize2 = ftell(f2);
		fseek(f2, 0, SEEK_SET);
		unsigned char *contents2 = malloc(fsize2 + 1);
		fread(contents2, 1, fsize2, f2);
		fclose(f2);
		contents2[fsize2] = 0;
	
		pixarray = contents1[10];
		width = contents1[18];
		height = contents1[22];
	
		// printf("pixarray: %d \n", pixarray);
		// printf("fsize: %d \n", fsize1);
		// printf("pic1 : %d x %d \n", width, height);
		int cntx=1,cnty=1;
	
		for ( i=pixarray; i < fsize1; i+=3 ) {
			if ( contents1[i] != contents2[i] ) {
				// printf("difference spotted: byte %d, pixel %dx%d \n", i, cntx, cnty);
				// printf("trying to store: %x %x %x\n", cntx, cnty, contents2[i]);
				mydiffs[mydiffcnt].x=cntx;

				// we mirror the y-value
                        	if (cnty < 90)
                               		mydiffs[mydiffcnt].y = 90 + ( 90 - cnty );
                        	else
                                	mydiffs[mydiffcnt].y = 90 - ( cnty - 90 );

				// mydiffs[mydiffcnt].y=cnty;
				mydiffs[mydiffcnt].c=contents2[i];
				mydiffcnt++;
			}
			if ( cntx < width ) {
				cntx++;
			}
			else {
				cntx=1;
				cnty++;
			};
		}
		free(contents1);
		free(contents2);

		// output section

		if ( framecnt == framesperfile ) {
			outputcnt+=1;
			framecnt=0;
		}

		sprintf(outputpath,"%s%07d", outputbase, outputcnt);
		foutput = fopen( outputpath, "ab");
		if (foutput == NULL) {
			printf("Could not open %s for writing.\n", outputpath);
			return 1;
		}

		*mysize = mydiffcnt*3 + 4;
		printf("mysize: %d\n",*mysize);
		fwrite( mysize, 4, 1, foutput);
		fwrite( mydiffs, mydiffcnt*3, 1, foutput);

		framecnt++;

		fclose(foutput);
	}

	return 0;
}
