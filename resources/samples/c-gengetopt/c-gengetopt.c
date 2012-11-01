#include "cmdline.c"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	struct gengetopt_args_info args_info;
	cmdline_parser_init(&args_info);
	if (cmdline_parser(argc, argv, &args_info) != 0)
		exit(1);

	if (args_info.arg_given)
	{
		printf("arg given: %s\n", args_info.arg_arg);
	}

	if (args_info.grp1c_given)
	{
		printf("Value of group switch: %d\n", args_info.grp1c_arg);
	}
	else
	{
		printf("Value of group switch (not set): %d\n", args_info.grp1c_arg);
	}

	return 0;
}
