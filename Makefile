NAME	:= program_name
B_NAME	:= program_name_b
CC		:= gcc
INCLUDE	:= -I./includes -I./Libft
CFLAGS	:= -g -Wall -Werror -Wextra $(INCLUDE)
LIBS	:= -L./Libft -lft
VPATH	:= srcs

LIBFT	:= ./Libft/libft.a
OBJDIR	:= ./objs/
SRCS	:= main.c
OBJS	:= $(SRCS:%.c=$(OBJDIR)%.o)
B_SRCS	:= main_bonus.c
B_OBJS	:= $(B_SRCS:%.c=$(OBJDIR)%.o)
B_FLG	:= .bonus_flg
DSTRCTR	:= ./tests/destructor.c

.PHONY: all clean fclean re bonus norm leak Darwin_leak Linux_leak tests

all: $(NAME)

$(OBJDIR)%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(LIBFT): ./Libft/*.c
	$(MAKE) bonus -C ./Libft

$(NAME):  $(LIBFT) $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME) $(LIBS)

bonus: $(B_FLG)

$(B_FLG): $(LIBFT) $(B_OBJS)
	$(CC) $(CFLAGS) $(B_OBJS) -o $(NAME) $(LIBS)

clean:
	$(MAKE) clean -C ./Libft
	rm -f $(OBJS) $(B_OBJS)

fclean: clean
	$(MAKE) fclean -C ./Libft
	rm -f $(NAME) $(B_NAME)

re: fclean all

norm:
	@printf "\e[31m"; norminette srcs includes Libft tests/**/test.c | grep -v ": OK!" \
	|| printf "\e[32m%s\n\e[m" "Norm OK!"; printf "\e[m"

$(DSTRCTR):
	curl -O https://gist.githubusercontent.com/ywake/793a72da8cdae02f093c02fc4d5dc874/raw/destructor.c
	mv destructor.c $(DSTRCTR)

Darwin_leak: $(LIBFT) $(DSTRCTR) $(OBJS) $(B_OBJS)
	$(CC) $(CFLAGS) $(OBJS) ./tests/destructor.c -o $(NAME) $(LIBS)
	$(CC) $(CFLAGS) $(B_OBJS) ./tests/destructor.c -o $(B_NAME) $(LIBS)

Linux_leak: $(LIBFT) $(OBJS) $(B_OBJS)
	$(CC) $(CFLAGS) -fsanitize=leak $(OBJS) -o $(NAME) $(LIBS)
	$(CC) $(CFLAGS) -fsanitize=leak $(B_OBJS) -o $(B_NAME) $(LIBS)

leak: $(shell uname)_leak

tests: leak
	bash auto_test.sh $(TEST)\
	&& $(MAKE) norm
