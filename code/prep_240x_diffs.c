/* GLP2.0	Christian Horn <chorn@fluxcoil.net>
 * 
 * media prepare: 
 * Takes 2 pictures, compares them, writes diffs into an
 * output file.  One output-file per diff.  If the 2 frames
 * are identical, the output file is 0.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct rec {
	unsigned char x,y,c;
};

int main(int argc, char *argv[]) {

	int i, width, height, counter = 0;
	int picnumber,pixarray;
	char basepath[512]="../bamedia/tiny_240x180/image-";
	char diffbasepath[512]="../bamedia/tiny_240x180_differ/image-";
	char pic1path[512],pic2path[512],differpath[512];
	FILE *f1, *f2, *fdiffer;
	struct rec mydiffs[50000];
	int mydiffcnt=0;

	if ( argc != 2 ) {
		printf("I got called with %d argument(s).\n", argc);
		printf("Please provide exactly one number.\n");
		printf("I will compare image-00000<number>.bmp and image-00000<number+1>.bmp .\n");
		return 1;
	}
	picnumber = atoi( argv[1] );
	sprintf(pic1path,"%s%07d.bmp", basepath, picnumber);
	sprintf(pic2path,"%s%07d.bmp", basepath, picnumber + 1);
	// printf("comparing %s and %s. ", pic1path, pic2path );	
	printf("%d\n",picnumber);	
	sprintf(differpath,"%s%07d", diffbasepath, picnumber);
	// printf("differpath: %s\n", differpath );	

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

	fdiffer = fopen( differpath, "wb");
	if (fdiffer == NULL) {
		printf("Could not open %s for writing.\n", differpath);
		return 1;
	}

	// printf("pixarray: %d \n", pixarray);
	// printf("fsize: %d \n", fsize1);
	// printf("pic1 : %d x %d \n", width, height);
	int cntx=1,cnty=1;

	for ( i=pixarray; i < fsize1; i+=3 ) {
		if ( contents1[i] != contents2[i] ) {
			// printf("difference spotted: byte %d, pixel %dx%d \n", i, cntx, cnty);
			// printf("trying to store: %x %x %x\n", cntx, cnty, contents2[i]);
			mydiffs[mydiffcnt].x=cntx;
			mydiffs[mydiffcnt].y=cnty;
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

	// fprintf(fdiffer,"%x%x%x", cntx, cnty, contents2[i]);
	fwrite( mydiffs, mydiffcnt*3, 1, fdiffer);
	fclose(fdiffer);

	return 0;
}
