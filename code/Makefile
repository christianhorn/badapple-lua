all: 
	gcc -o prep_120x_anifile_headers prep_120x_anifile_headers.c
	gcc -o prep_120x_macropic prep_120x_macropic.c
	gcc -o prep_240x_anifile_headers prep_240x_anifile_headers.c
	gcc -o prep_240x_diffs prep_240x_diffs.c
	gcc -o prep_240x_diffs_half prep_240x_diffs_half.c
	gcc -o prep_240x_macropic prep_240x_macropic.c

clean:
	rm -f prep_120x_anifile_headers prep_120x_macropic2 prep_240x_anifile_headers
	rm -f prep_240x_diffs prep_240x_diffs_half prep_240x_macropic2
	rm -f prep_240x_macropic
	rm -rf ../bamedia/tiny_120x90-ani ../bamedia/tiny_120x90-macropic
	rm -rf ../bamedia/tiny_240x180-ani ../bamedia/tiny_240x180_differ
	rm -rf ../bamedia/tiny_240x180_differ_half ../bamedia/tiny_240x180-macropic

media:
	mkdir ../bamedia/tiny_120x90-ani
	./prep_120x_anifile_headers 
	mkdir ../bamedia/tiny_120x90-macropic
	./prep_120x_macropic
	mkdir ../bamedia/tiny_240x180-ani
	./prep_240x_anifile_headers 
	mkdir ../bamedia/tiny_240x180_differ
	./prep_240x_diffs 1
	mkdir ../bamedia/tiny_240x180_differ_half
	./prep_240x_diffs_half 2
	mkdir ../bamedia/tiny_240x180-macropic
	./prep_240x_macropic 
