NAME	:= program_name
B_NAME	:= program_name_b
CC		:= gcc
INCLUDE	:= -I./includes
CFLAGS	:= -g -Wall -Werror -Wextra $(INCLUDE)
LIBS	:=
VPATH	:= srcs

SRCS	:= main.c
OBJS	:= $(SRCS:%.c=$(SRCDIR)%.o)
B_SRCS	:= main_bonus.c
B_OBJS	:= $(B_SRCS:%.c=$(SRCDIR)%.o)
B_FLG	:= .bonus_flg
DSTRCTR	:= ./tests/destructor.c

all: $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME) $(LIBS)

bonus: $(B_FLG)

$(B_FLG): $(B_OBJS)
	$(CC) $(CFLAGS) $(B_OBJS) -o $(NAME) $(LIBS)
	touch $(B_FLG)

clean: FORCE
	rm -f $(OBJS) $(B_OBJS)

fclean: clean
	rm -f $(NAME) $(B_NAME)
	rm -rf $(NAME).dSYM $(B_NAME).dSYM

re: fclean all

norm: FORCE
	@printf "\e[31m"; norminette | grep -v ": OK!" \
	&& exit 1 \
	|| printf "\e[32m%s\n\e[m" "Norm OK!"; printf "\e[m"

$(DSTRCTR):
	curl https://gist.githubusercontent.com/ywake/793a72da8cdae02f093c02fc4d5dc874/raw/destructor.c > $(DSTRCTR)

Darwin_leak: $(DSTRCTR) $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(DSTRCTR) -o $(NAME) $(LIBS)

Linux_leak: $(OBJS)
	$(CC) $(CFLAGS) -fsanitize=address $(OBJS) -o $(NAME) $(LIBS)

leak: FORCE $(shell uname)_leak

Darwin_leak_bonus: $(DSTRCTR) $(B_OBJS)
	$(CC) $(CFLAGS) $(B_OBJS) $(DSTRCTR) -o $(B_NAME) $(LIBS)

Linux_leak_bonus: $(B_OBJS)
	$(CC) $(CFLAGS) -fsanitize=address $(B_OBJS) -o $(B_NAME) $(LIBS)

leak_bonus: FORCE $(shell uname)_leak_bonus

FORCE:

CXX			:= clang++
CXXFLAG		:= -std=c++11 -DDEBUG -g -fsanitize=integer -fsanitize=address -Wno-writable-strings
gTestDir	:= ./.google_test
gVersion	:= release-1.11.0
gTestVer	:= googletest-$(gVersion)
gTest		:= $(gTestDir)/gtest $(gTestDir)/$(gTestVer)

TESTDIR		:= ./tests/
TESTSRCS_C	:= $(filter-out main.c,$(SRCS))
TESTSRCS_CPP:= $(wildcard $(TESTDIR)*.cpp)
TESTOBJS	:= $(TESTSRCS_C:%.c=$(SRCDIR)%.o) \
				$(TESTSRCS_CPP:%.cpp=%.o)

%.o: %.cpp
	$(CXX) $(CXXFLAG) -I$(gTestDir) $(INCLUDE) -c $< -o $@

$(gTest):
	mkdir -p $(gTestDir)
	curl -OL https://github.com/google/googletest/archive/refs/tags/$(gVersion).tar.gz
	tar -xvzf $(gVersion).tar.gz $(gTestVer)
	$(RM) $(gVersion).tar.gz
	python $(gTestVer)/googletest/scripts/fuse_gtest_files.py $(gTestDir)
	mv $(gTestVer) $(gTestDir)

test: $(gTest) $(TESTOBJS)
	@$(CXX) $(CXXFLAG) \
		$(TESTOBJS) \
		$(gTestDir)/$(gTestVer)/googletest/src/gtest_main.cc \
		$(gTestDir)/gtest/gtest-all.cc \
		-I$(gTestDir) $(INCLUDE) $(LIBS) -lpthread -o test && ./test

test_clean: FORCE
	$(RM) $(TESTOBJS)

test_fclean: test_clean
	$(RM) -r tester tester.dSYM

test_re: test_fclean test
