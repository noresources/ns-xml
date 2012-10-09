/**************************************************************************************$
 *
 ***************************************************************************************
 * Copyright © 2012 by Renaud Guillard (dev@niao.fr)
 * Distributed under the terms of the BSD License, see LICENSE
 ***************************************************************************************
 */

#if defined(__cplusplus)
#	include <cstdlib>
#	include <cstdio>
#	include <cstdarg>
extern "C"
{
#else
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#endif

#if !defined(__NSXML_PROGRAM_PARSER_H__)
#define __NSXML_PROGRAM_PARSER_H__

/* Macros ****************************************/

#if !defined (NSXMLAPI)
#	define NSXMLAPI
#endif

/** An option name (without '-' or '--' prefix) */
#define NSXML_MAX_OPTION_NAME_LENGTH 61
/** An option name (with '-' or '--' prefix) */
#define NSXML_MAX_OPTION_CLI_NAME_LENGTH (NSXML_MAX_OPTION_NAME_LENGTH + 2)
/** A buffer that can hold a cli option name */
#define NSXML_OPTION_NAME_BUFFER_LENGTH (NSXML_MAX_OPTION_CLI_NAME_LENGTH + 1)

/* Utility functions ******************************/

/**
 * Copy a string
 * @param output Output buffer
 * @param output_length Output buffer length
 * @param input Input string to copy
 * @param input_length Maximum length to copy
 * The output will always end with a zero
 * @return  Difference between @p input_length and the real number of character copied
 */
NSXMLAPI int nsxml_util_strncpy(char *output, size_t output_length, const char *input, size_t input_length);

/** Copy a string */
/**
 * @param output Output buffer
 * @param output_length Output buffer length
 * @param input Input string to copy
 * @param input_length Maximum length to copy
 * The output will always end with a zero
 * @return  Copied characters
 */
NSXMLAPI int nsxml_util_strcpy(char *output, size_t output_length, const char *input);

/** snprintf with automatic reallocation */
/**
 * @param output Output string buffer
 * @param output_length Output string buffer length
 * @param format String format
 * @return Printed characters
 *
 * Parameters @param output and @param output_length will be modified if the printed strings
 * is taller than @param output_length
 */
NSXMLAPI int nsxml_util_asnprintf(char **output, size_t *output_length, const char *format, ...);

/**
 * @param haystack
 * @param needle
 * @return
 */
NSXMLAPI int nsxml_util_string_starts_with(const char *haystack, const char *needle);

/**
 * @path Path
 * @flag access() function flags
 */
NSXMLAPI int nsxml_util_path_access_check(const char *path, int flag);

/**
 * Options for text wrapping
 */
NSXMLAPI struct nsxml_util_text_wrap_options
{
	/**
	 * Size of one indentation
	 */
	int tab_size;
	/**
	 * Maximum line length
	 */
	int line_length;
	/**
	 * Indentation mode
	 */
	int indent_mode;
	/**
	 * End-of line character(s)
	 */
	char eol[3];
};

/**
 * Text wrapping indentation modes
 */
NSXMLAPI enum nsxml_util_text_indent_mode
{
	nsxml_util_text_wrap_indent_none = 0,/**!< Do not indent */
	nsxml_util_text_wrap_indent_first,   /**!< Indent first line */
	nsxml_util_text_wrap_indent_others   /**!< Indent all line except the first */
};

/**
 * End of line character(s) to use while wrapping text
 */
NSXMLAPI enum nsxml_util_text_wrap_eol
{
	nsxml_util_text_wrap_eol_cr = 1, /**!< nsxml_util_text_wrap_eol_cr */
	nsxml_util_text_wrap_eol_lf = 2, /**!< nsxml_util_text_wrap_eol_lf */
	nsxml_util_text_wrap_eol_crlf = 3/**!< nsxml_util_text_wrap_eol_crlf */
};

/** Initialize text wrapping option structure */
/**
 * @param options Option structure to initialize
 * @param tab Tab size
 * @param line Line length
 * @param indent_mode Indentation mode
 * @param eol End of line mode
 */
NSXMLAPI void nsxml_util_text_wrap_options_init(struct nsxml_util_text_wrap_options* options, int tab, int line, int indent_mode, int eol);

/** Print a text using text wrapping options */
/**
 * @param stream Output stream
 * @param text Text to print
 * @param options Text wrapping option
 * @param level Initial indentation level
 */
NSXMLAPI void nsxml_util_text_wrap_fprintf(FILE *stream, const char *text, const struct nsxml_util_text_wrap_options* options, int level);

/* Messages **************************************/

/**
 * Message severity
 */
NSXMLAPI enum nsxml_message_type
{
	nsxml_message_type_debug = 0,  /**!< nsxml_message_type_debug */
	nsxml_message_type_warning,    /**!< nsxml_message_type_warning */
	nsxml_message_type_error,      /**!< nsxml_message_type_error */
	nsxml_message_type_fatal_error,/**!< nsxml_message_type_fatal_error */

	nsxml_message_type_count       /**!< nsxml_message_type_count */
};

/**
 * A message from the parser
 */
NSXMLAPI struct _nsxml_message
{
	int type;
	char *message;
	struct _nsxml_message* next_message;
};

typedef struct _nsxml_message nsxml_message;

NSXMLAPI int nsxml_message_count(const nsxml_message *list);

nsxml_message *nsxml_message_new_ref(nsxml_message *ref);

/* Item names *************************************/

/**
 * Name of a parser item
 * - Program name
 * - Sub command name and aliases. The real name of the sub command is the first element of the list
 * - Option names (short and long). The first name of the list is used for messages
 */
struct nsxml_item_name
{
	char *name;
	struct nsxml_item_name* next_name;
};

struct nsxml_item_name *nsxml_item_names_new (const char *, ...);
void nsxml_item_name_free (struct nsxml_item_name *);
int nsxml_item_name_snprintf (const struct nsxml_item_name *, char **output, size_t *output_length, const char *prefix_text);

/* Validator *************************************/

struct nsxml_value_validator;
struct nsxml_parser_state;
struct nsxml_program_result;
struct nsxml_option_name_binding;
struct nsxml_option_info;
typedef int nsxml_value_validator_validation_callback(struct nsxml_value_validator *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
typedef void nsxml_value_validator_cleanup_callback(struct nsxml_value_validator *self);
typedef int nsxml_value_validator_usage_callback(struct nsxml_value_validator *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

/**
 * Validator flags
 */
enum nsxml_value_validator_flags
{
	nsxml_value_validator_checkmin = (1 << 0),         /**!< nsxml_value_validator_checkmin */
	nsxml_value_validator_checkmax = (1 << 1),         /**!< nsxml_value_validator_checkmax */
	nsxml_value_validator_path_exists = (1 << 2),      /**!< nsxml_value_validator_path_exists */
	nsxml_value_validator_path_readable = (1 << 3),    /**!< nsxml_value_validator_path_readable */
	nsxml_value_validator_path_writable = (1 << 4),    /**!< nsxml_value_validator_path_writable */
	nsxml_value_validator_path_executable = (1 << 5),  /**!< nsxml_value_validator_path_executable */
	nsxml_value_validator_path_type_file = (1 << 6),   /**!< nsxml_value_validator_path_type_file */
	nsxml_value_validator_path_type_folder = (1 << 7), /**!< nsxml_value_validator_path_type_folder */
	nsxml_value_validator_path_type_symlink = (1 << 8),/**!< nsxml_value_validator_path_type_symlink */
	nsxml_value_validator_path_type_all =              /**!< nsxml_value_validator_path_type_all */
					(nsxml_value_validator_path_type_file
					| nsxml_value_validator_path_type_folder
					| nsxml_value_validator_path_type_symlink),
	nsxml_value_validator_enum_strict = (1 << 9)       /**!< nsxml_value_validator_enum_strict */
};

struct nsxml_value_validator
{
	nsxml_value_validator_validation_callback *validation_callback;
	nsxml_value_validator_cleanup_callback *cleanup_callback;
	nsxml_value_validator_usage_callback *usage_callback;
	struct nsxml_value_validator *next_validator;
	int flags;
};

void nsxml_value_validator_init(struct nsxml_value_validator *validator, nsxml_value_validator_validation_callback *callback, nsxml_value_validator_cleanup_callback *cleanup, nsxml_value_validator_usage_callback *usage_cb, int flags);
void nsxml_value_validator_add(struct nsxml_value_validator **list, struct nsxml_value_validator *validator);
void nsxml_value_validator_free(struct nsxml_value_validator *validator);

int nsxml_value_validator_validate_path(struct nsxml_value_validator *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
int nsxml_value_validator_usage_path(struct nsxml_value_validator *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

struct nsxml_value_validator_number
{
	struct nsxml_value_validator validator;
	float min_value;
	float max_value;
};
int nsxml_value_validator_validate_number(struct nsxml_value_validator *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
int nsxml_value_validator_usage_number(struct nsxml_value_validator *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

struct nsxml_value_validator_enum
{
	struct nsxml_value_validator validator;
	struct nsxml_item_name *values;
};
int nsxml_value_validator_validate_enum(struct nsxml_value_validator *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
void nsxml_value_validator_cleanup_enum(struct nsxml_value_validator *self);
int nsxml_value_validator_usage_enum(struct nsxml_value_validator *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

/* Item info *************************************/

/**
 *
 */
enum nsxml_item_type
{
	nsxml_item_type_program = 1,			/**!< nsxml_item_type_program */
	nsxml_item_type_subcommand, 			/**!< nsxml_item_type_subcommand */
	nsxml_item_type_option,     		 	/**!< nsxml_item_type_option */
	nsxml_item_type_positional_argument, 	/** Positional argument */

	nsxml_item_type_count
};

/**
 * Shared info for program, subcommand and options
 */
struct nsxml_item_info
{
	/** Short informations */
	char *abstract;

	/** Long informations (not wrapped) */
	char *details;

	/** Item type */
	int item_type;
};

void nsxml_item_info_init(struct nsxml_item_info *info, int type, const char *abstract, const char *details);

/** Option types */
enum nsxml_option_type
{
	nsxml_option_type_switch = 0,   /**!< nsxml_option_type_switch */
	nsxml_option_type_argument,     /**!< nsxml_option_type_argument */
	nsxml_option_type_multiargument,/**!< nsxml_option_type_multiargument */
	nsxml_option_type_group,        /**!< nsxml_option_type_group */

	nsxml_option_type_count         /**!< nsxml_option_type_count */
};

/**
 *
 */
NSXMLAPI enum nsxml_value_type
{
	nsxml_value_type_unset = -1,/**!< nsxml_value_type_unset */
	nsxml_value_type_null,      /**!< nsxml_value_type_null */
	nsxml_value_type_int,       /**!< nsxml_value_type_int */
	nsxml_value_type_float,     /**!< nsxml_value_type_float */
	nsxml_value_type_string    /**!< nsxml_value_type_string */
};

struct nsxml_group_option_info;

enum nsxml_option_flags
{
	nsxml_option_flag_required = (1 << 0)
};

struct nsxml_option_info
{
	struct nsxml_item_info item_info;

	/** Option type */
	int option_type;

	/** Several modifiers */
	int option_flags;

	/** Option variable name as described in the databinding/variable node */
	char *var_name;

	/** List of option names (short and longs) */
	struct nsxml_item_name *names;

	/** Parent group (if any) */
	struct nsxml_group_option_info *parent;

	/** Argument value validator(s) */
	struct nsxml_value_validator *validators;
};

void nsxml_option_info_init(struct nsxml_option_info *info, int type, int flags, const char *var_name, struct nsxml_item_name *names, struct nsxml_group_option_info *parent);

struct nsxml_switch_option_info
{
	struct nsxml_option_info option_info;
};

enum nsxml_argument_type
{
	nsxml_argument_type_string,
	nsxml_argument_type_mixed,
	nsxml_argument_type_existingcommand,
	nsxml_argument_type_hostname,
	nsxml_argument_type_path,
	nsxml_argument_type_number
};

struct nsxml_argument_option_info
{
	struct nsxml_option_info option_info;
	int argument_type;
	char *default_value;
};

void nsxml_argument_option_info_free(struct nsxml_argument_option_info* argumentoption_info);

struct nsxml_multiargument_option_info
{
	struct nsxml_option_info option_info;
	int argument_type;
	int min_argument;
	int max_argument;
};

enum nsxml_group_optiontype
{
	nsxml_group_option_standard,
	nsxml_group_option_exclusive
};

struct nsxml_group_option_info
{
	struct nsxml_option_info option_info;
	int group_type;
	int option_info_count;
	struct nsxml_option_info **option_info_refs;
};

NSXMLAPI enum nsxml_positional_argument_flags
{
	nsxml_positional_argument_required = (1 << 0)
};

struct nsxml_positional_argument_info
{
	struct nsxml_item_info item_info;

	int positional_argument_flags;

	int argument_type;

	int max_argument;

	struct nsxml_value_validator *validators;
};

void nsxml_positional_argument_info_init(struct nsxml_positional_argument_info *info, int flags, int arg_type, int max_arg);
void nsxml_positional_argument_info_cleanup(struct nsxml_positional_argument_info *info);

struct nsxml_rootitem_info
{
	struct nsxml_item_info item_info;
	int option_info_count;
	struct nsxml_option_info **option_infos;

	int positional_argument_info_count;
	struct nsxml_positional_argument_info *positional_argument_infos;
};

struct nsxml_subcommand_info
{
	struct nsxml_rootitem_info rootitem_info;
	struct nsxml_item_name *names;
};

NSXMLAPI struct nsxml_program_info
{
	struct nsxml_rootitem_info rootitem_info;
	const char *name;
	int subcommand_info_count;
	struct nsxml_subcommand_info *subcommand_infos;
};

void nsxml_item_info_cleanup(struct nsxml_item_info* item_info);
void nsxml_option_info_name_display(FILE *, const char *);
void nsxml_option_info_names_display(FILE *, const struct nsxml_option_info* option_info, const char *, const char *);
void nsxml_option_info_cleanup(struct nsxml_option_info *option_info);
void nsxml_switch_option_info_free(struct nsxml_switch_option_info *switch_option_info);
void nsxml_multiargument_option_info_free(struct nsxml_multiargument_option_info* multiargumentoption_info);
void nsxml_group_option_info_free(struct nsxml_group_option_info* group_option_info);
void nsxml_rootitem_info_cleanup(struct nsxml_rootitem_info *rootitem_info);
void nsxml_subcommand_info_cleanup(struct nsxml_subcommand_info* subcommand_info);
NSXMLAPI void nsxml_program_info_cleanup(struct nsxml_program_info *info);
NSXMLAPI void nsxml_program_info_free(struct nsxml_program_info *info);

/* Program option argument or positional argument value */

NSXMLAPI struct _nsxml_value
{
	int type;
	const char *string_value;
	int int_value;
	float float_value;
	struct _nsxml_value *next_value;
};

typedef struct _nsxml_value nsxml_value;

nsxml_value *nsxml_value_new(int, const char *);
void nsxml_value_init(nsxml_value *);
void nsxml_value_set(nsxml_value *item, int value_type, const char *value);
void nsxml_value_append(nsxml_value **list, int type, const char *value);
void nsxml_value_cleanup(nsxml_value *single_value);
void nsxml_value_free(nsxml_value *list);
int nsxml_argument_type_to_value_type(int argument_type);

/* Parser internal state *************************/

struct nsxml_option_name_binding
{
	const char *name_ref;
	struct nsxml_option_result *result_ref;
	const struct nsxml_option_info *info_ref;
	int level;
	struct nsxml_group_option_result **parent_tree_refs;
};

struct nsxml_subcommand_name_binding
{
	const char *name_ref;
	const struct nsxml_subcommand_info *info_ref;
	int subcommand_index;
};

/**
 * Parser state flags
 */
enum nsxml_parser_state_flags
{
	/** 
	 * All remaining command line arguments are positional arguments. 
	 * Occurs if a '--' marker is found 
	 */
	nsxml_parser_state_endofoptions = (1 << 0),
	/** The option is recognized but is not expected in the current context */
	nsxml_parser_state_option_unexpected = (1 << 1),
	/** Do not move to the next command line argument on next iteration */
	nsxml_parser_state_stayoncurrentitem = (1 << 2),
	/** Processing was aborted by a fatal error */
	nsxml_parser_state_abort = (1 << 3)
};

/**
 * Parser state
 */
struct nsxml_parser_state
{
	/** Program info */
	const struct nsxml_program_info *program_info_ref;

	/** Number of option name binding arrays */
	int option_name_binding_group_count;

	/** Per-group option name binding counts */
	int *option_name_binding_counts;

	/**
	 * Array of name binding groups
	 * First index: array of bindings for program options
	 * Other: array of bindings for each subcommand options
	 */
	struct nsxml_option_name_binding **option_name_bindings;

	int subcommand_name_binding_count;

	struct nsxml_subcommand_name_binding *subcommand_name_bindings;

	/** User input */

	/** Number of arguments */
	int argc;

	/** Arguments values */
	const char **argv;

	/** Parser state */

	/** Current argument index */
	int arg_index;

	/** State flags */
	int state_flags;

	/** active subcommand 
	 * 0: none
	 * 1-n:  
	 */
	int subcommand_index;

	/** Active option info */

	/** Option currently processed */
	struct nsxml_option_name_binding *active_option;

	/** 
	 * Number of argument processed for the current option
	 * @note Does not include previously processed arguments if the option appears more than once 
	 */
	size_t active_option_argc;


	/**
	 * List of argument associated to the active option
	 * Redirect to one of state->argv;
	 */
	const char **active_option_argv;

	char active_option_cli_name[NSXML_OPTION_NAME_BUFFER_LENGTH];
	const char *active_option_name;

	/** Results */
	int anonymous_option_result_count;
	struct nsxml_option_result **anonymous_option_results;

	int value_count;
	nsxml_value *values;
};

/**
 * Create a new parser state
 * @param argc Number of argument on the command line
 * @param argv List of arguments
 * @param start_index First argument to consider
 * @return A new @c nsxml_parser_state
 */
struct nsxml_parser_state *nsxml_parser_state_new(const struct nsxml_program_info *info, int argc, const char **argv, int start_index);

void nsxml_parser_state_allocate_name_bindings(struct nsxml_parser_state *state, int option_name_binding_group_count, int *option_name_binding_counts);

/**
 * Destroy the given parser state and set the pointer to NULL
 * @param state
 */
void nsxml_parser_state_free(struct nsxml_parser_state *state);

/* Parser results ********************************/

enum nsxml_result_type
{
	nsxml_result_type_program,
	nsxml_result_type_subcommand,
	nsxml_result_type_switch,
	nsxml_result_type_argument,
	nsxml_result_type_multiargument,
	nsxml_result_type_group
};

/**
 * Pseudo base class for all option types. 
 * All option result have at least these members (at the same place)
 * 
 * @note For internal use
 */
struct nsxml_option_result
{
	int result_type;
	int is_set;
};

struct nsxml_switch_option_result
{
	int result_type;
	int is_set;
};

struct nsxml_argument_option_result
{
	int result_type;
	int is_set;
	nsxml_value argument;
};

struct nsxml_multiargument_option_result
{
	int result_type;
	int is_set;
	int argument_count;
	nsxml_value *arguments;
};

struct nsxml_group_option_result
{
	int result_type;
	int is_set;

	struct nsxml_option_result *selected_option;
	const char *selected_option_name;
};

void nsxml_switch_option_result_init(struct nsxml_switch_option_result *option);
void nsxml_argument_option_result_init(struct nsxml_argument_option_result *option);
void nsxml_multiargument_option_result_init(struct nsxml_multiargument_option_result *option);
void nsxml_group_option_result_init(struct nsxml_group_option_result *option);
void nsxml_option_result_cleanup(struct nsxml_option_result *option);

struct nsxml_program_result
{
	nsxml_message *messages[nsxml_message_type_count];
	nsxml_message *first_message;
	const char *subcommand_name;
	int value_count;
	nsxml_value *values;
};

void nsxml_program_result_init(struct nsxml_program_result *result);
void nsxml_program_result_cleanup(struct nsxml_program_result *result);
void nsxml_program_result_free(struct nsxml_program_result *result);

void nsxml_program_result_add_message(struct nsxml_program_result *result, int type, const char *text);
void nsxml_program_result_add_messagef(struct nsxml_program_result *result, int type, const char *format, ...);

NSXMLAPI int nsxml_program_result_message_count(const struct nsxml_program_result *, int messagetype_min, int messagetype_max);

/* Usage Functions *******************************/

/**
 * Usage display format
 */
NSXMLAPI enum nsxml_usage_format
{
	nsxml_usage_format_short = 1,   /**!< nsxml_usage_format_short */
	nsxml_usage_format_abstract = 2,/**!< nsxml_usage_format_abstract */
	nsxml_usage_format_details = 7  /**!< nsxml_usage_format_details */
};

NSXMLAPI void nsxml_usage(FILE *stream, struct nsxml_program_info *info, struct nsxml_program_result *result, int format, const struct nsxml_util_text_wrap_options *wrap);
const char *nsxml_usage_get_first_short_name(struct nsxml_option_info *option_info);
const char *nsxml_usage_get_first_long_name(struct nsxml_option_info *option_info);
const char *nsxml_usage_option_argument_type_string(int argument_type);
const char *nsxml_usage_path_type_string(int fs_type);
int nsxml_usage_path_type_count(int fs_type);
const char *nsxml_usage_path_access_string(int fs_access);
int nsxml_usage_path_access_count(int fs_);
void nsxml_usage_option_argument_type(FILE *stream, int argumenttype, int short_name);
void nsxml_usage_option_inline_details(FILE *stream, struct nsxml_option_info *info, int short_name);
void nsxml_usage_option_root_short(FILE *stream, struct nsxml_rootitem_info *info, int index, int *visited, const struct nsxml_util_text_wrap_options *wrap);
void nsxml_usage_option_root_detailed(FILE *stream, struct nsxml_rootitem_info *info, int format, const struct nsxml_util_text_wrap_options *wrap);

/* Parser Functions ******************************/

void nsxml_parse_core(struct nsxml_parser_state *state, struct nsxml_program_result *result);
struct nsxml_option_name_binding *nsxml_parse_find_option_at(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *name, int group_index);
struct nsxml_option_name_binding *nsxml_parse_find_option(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *name);
int nsxml_parse_argument_validates(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value);
int nsxml_parse_positional_argument_validates(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_positional_argument_info *info, const char *value);
int nsxml_parse_option_expected(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_option_name_binding *option);
void nsxml_parse_mark_option(struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding* option, int is_set);
void nsxml_parse_unset_active_option(struct nsxml_parser_state *state, struct nsxml_program_result *result);
int nsxml_parse_active_option_accepts_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result);
void nsxml_parse_append_option_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value);
void nsxml_parse_process_positional_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value);
int nsxml_parse_option_postprocess(struct nsxml_parser_state *state, struct nsxml_program_result *result);
int nsxml_parse_positional_argument_process(struct nsxml_parser_state *state, struct nsxml_program_result *result);

#if defined(__cplusplus)
} /* extern "C" */
#endif

#endif /* __NSXML_PROGRAM_PARSER_H__ */
