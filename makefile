OBJS = main.o steam_library.o log.o
CXX = g++
DEBUG = -g3 -pthread -gdwarf-4 -DLinux -fPIC -Wno-deprecated -pipe -fno-elide-type -fdiagnostics-show-template-tree -Wall -Werror -Wextra -Wpedantic -Wvla -Wextra-semi -Wnull-dereference -Wswitch-enum -fvar-tracking-assignments -Wduplicated-cond -Wduplicated-branches -rdynamic -Wsuggest-override -O0 -MMD -MP -Wno-gnu-include-next -Wno-unused-variable -Wno-unused-parameter
CPPFLAGS = -c -std=c++20 $(DEBUG)
LDFLAGS = -std=c++20 $(DEBUG)
EXE = main

$(EXE): $(OBJS)
	$(CXX) $(LDFLAGS) $(OBJS) -o $(EXE)

log.o: log.h log.cpp
	$(CXX) $(CPPFLAGS) log.cpp

steam_library.o: steam_library.h steam_library.cpp library.h log.h
	$(CXX) $(CPPFLAGS) steam_library.cpp

main.o: main.cpp steam_library.h log.h
	$(CXX) $(CPPFLAGS) main.cpp

clean:
	rm *.o $(EXE) -v
