all:
	bison -d -o final.tab.cc final.yy
	g++ -c -g -I.. final.tab.cc
	flex -o lex.yy.cc final.l
	g++ -c -g -I.. lex.yy.cc
	g++ -o csmli final.tab.o lex.yy.o -ll
	cp csmli ../
test:
	./csmli < input.txt
clear:
	rm csmli final.tab.o lex.yy.o lex.yy.cc final.tab.cc final.tab.hh
