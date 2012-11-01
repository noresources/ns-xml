<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->
<!-- C Source code in customizable XSLT form -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform"
	xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.generic-names.xsl" />
	<output method="text" encoding="utf-8" />
	<param name="prg.c.parser.header.filePath" select="'cmdline.h'" />
	
	<variable name="prg.c.parser.genericHeader"><![CDATA[
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

#if defined(NSXML_DEBUG)
#	undef NSXML_DEBUG
#	define NSXML_DEBUG 1
#else
#	define NSXML_DEBUG 0
#endif

/** An option name (without '-' or '--' prefix) */
#define NSXML_MAX_OPTION_NAME_LENGTH 61
/** An option name (with '-' or '--' prefix) */
#define NSXML_MAX_OPTION_CLI_NAME_LENGTH (NSXML_MAX_OPTION_NAME_LENGTH + 2)
/** A buffer that can hold a cli option name */
#define NSXML_OPTION_NAME_BUFFER_LENGTH (NSXML_MAX_OPTION_CLI_NAME_LENGTH + 1)

/* Utility functions ******************************/

/** Copy a string */
/*
 * @param output Output buffer
 * @param output_length Output buffer size
 * @param input Input string to copy
 * @param input_length Maximum length to copy
 * The @param output parameter will always ends with a null-character. If @param input_length is greater than @c[ output_length + 1},
 * the result will be truncated
 * @return  Difference between @p input_length and the real number of character copied
 */
NSXMLAPI int ]]><value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(char *output, size_t output_length, const char *input, size_t input_length);

/** Copy a string */
/**
 *
 * @param output Output buffer
 * @param output_length Output buffer size
 * @param input Input string to copy
 * @param input_length Maximum length to copy
 *
 * Same as nsxml_util_strncpy with an input string length set to @c strlen(input)
 *
 * @return  Copied characters
 */
NSXMLAPI int ]]><value-of select="$prg.c.parser.functionName.nsxml_util_strcpy"/><![CDATA[(char *output, size_t output_length, const char *input);

/** snprintf with automatic reallocation */
/**
 * @param output Output string buffer
 * @param output_length Output string buffer current size
 * @param format String format
 * @return Printed characters
 *
 * Parameters @param output and @param output_length will be modified if the printed strings
 * is taller than @param output_length
 */
NSXMLAPI int ]]><value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(char **output, size_t *output_length, const char *format, ...);

/** Indicates if a string begins with a given character sequence */
/**
 * @param haystack
 * @param needle
 * @return A non-zero valueif @param haystack starts with the string @param needle
 */
NSXMLAPI int ]]><value-of select="$prg.c.parser.functionName.nsxml_util_string_starts_with"/><![CDATA[(const char *haystack, const char *needle);

/** Test a file system path permission */
/**
 * @path Path
 * @flag access function flags
 */
NSXMLAPI int ]]><value-of select="$prg.c.parser.functionName.nsxml_util_path_access_check"/><![CDATA[(const char *path, int flag);

/**
 * Options for text wrapping
 */
NSXMLAPI struct _nsxml_util_text_wrap_options
{
	/**
	 * Size of one indentation
	 */
	size_t tab_size;
	/**
	 * Maximum line length
	 */
	size_t line_length;
	/**
	 * Indentation mode
	 */
	int indent_mode;
	/**
	 * End-of line character(s)
	 */
	char eol[3];
};

typedef struct _nsxml_util_text_wrap_options ]]><value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[;

/**
 * Text wrapping indentation modes
 */
NSXMLAPI enum nsxml_util_text_indent_mode
{
	]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_indent_none"/><![CDATA[ = 0,/**!< Do not indent */
	]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_indent_first"/><![CDATA[,   /**!< Indent first line */
	]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_indent_others"/><![CDATA[   /**!< Indent all line except the first */
};

/**
 * End of line character(s) to use while wrapping text
 */
NSXMLAPI enum nsxml_util_text_wrap_eol
{
	]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_cr"/><![CDATA[ = 1, /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_cr"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_lf"/><![CDATA[ = 2, /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_lf"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_crlf"/><![CDATA[ = 3/**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_crlf"/><![CDATA[ */
};

/** Initialize text wrapping option structure */
/**
 * @param options Option structure to initialize
 * @param tab Tab size
 * @param line Line length
 * @param indent_mode Indentation mode
 * @param eol End of line mode
 */
NSXMLAPI void ]]><value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_options_init"/><![CDATA[(]]><value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *options, size_t tab, size_t line, int indent_mode, int eol);

/** Print a text using text wrapping options */
/**
 * @param stream Output stream
 * @param text Text to print
 * @param options Text wrapping option
 * @param level Initial indentation level
 */
NSXMLAPI void ]]><value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprintf"/><![CDATA[(FILE *stream, const char *text, const ]]><value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *options, size_t level);

/* Messages **************************************/

/**
 * Message severity
 */
NSXMLAPI enum nsxml_message_type
{
	]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[ = 0,  /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_warning"/><![CDATA[,    /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_warning"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[,      /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/><![CDATA[,/**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/><![CDATA[ */
	
	]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/><![CDATA[       /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/><![CDATA[ */
};

/**
 * A message from the parser
 */
NSXMLAPI struct _nsxml_message
{
	int type;
	char *message;
	struct _nsxml_message *next_message;
};

typedef struct _nsxml_message ]]><value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[;

NSXMLAPI size_t nsxml_message_count(const ]]><value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *list);

]]><value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *nsxml_message_new_ref(]]><value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *ref);

/* Item names *************************************/

struct nsxml_item_name;

struct nsxml_item_name *nsxml_item_names_new(const char *, ...);

/** Get the nth item name in a item_name list */
/**
 * @param list
 * @param item_index
 * @return Item name
 */
const char *nsxml_item_name_get(const struct nsxml_item_name *list, int item_index);

/* Validator *************************************/

struct nsxml_value_validator;
struct nsxml_parser_state;
struct nsxml_program_result;
struct nsxml_option_name_binding;
struct nsxml_option_info;
typedef int nsxml_value_validator_validation_callback(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
typedef void nsxml_value_validator_cleanup_callback(void *self);
typedef int nsxml_value_validator_usage_callback(const void *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

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

int nsxml_value_validator_validate_path(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
int nsxml_value_validator_usage_path(const void *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

struct nsxml_value_validator_number
{
	struct nsxml_value_validator validator;
	float min_value;
	float max_value;
};
int nsxml_value_validator_validate_number(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
int nsxml_value_validator_usage_number(const void *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

struct nsxml_value_validator_enum
{
	struct nsxml_value_validator validator;
	struct nsxml_item_name *values;
};
int nsxml_value_validator_validate_enum(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_name_binding *option, const char *value);
void nsxml_value_validator_cleanup_enum(void *self);
int nsxml_value_validator_usage_enum(const void *self, const struct nsxml_option_info *info, char **output, size_t *output_length);

/* Item info *************************************/

/** Types of element informations */
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

/** Type of option or positional argument value */
NSXMLAPI enum nsxml_value_type
{
	]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_unset"/><![CDATA[ = -1,/**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_unset"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_null"/><![CDATA[,      /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_null"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_int"/><![CDATA[,       /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_int"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_float"/><![CDATA[,     /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_float"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_string"/><![CDATA[    /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_value_type_string"/><![CDATA[ */
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
	const struct nsxml_group_option_info *parent;
	
	/** Argument value validator(s) */
	struct nsxml_value_validator *validators;
};

void nsxml_option_info_init(struct nsxml_option_info *info, int type, int flags, const char *var_name, struct nsxml_item_name *names, const void *parent);

struct nsxml_switch_option_info
{
	struct nsxml_option_info option_info;
};

/** Option argument type */
enum nsxml_argument_type
{
	nsxml_argument_type_string,         /**< A string */
	nsxml_argument_type_mixed,          /**< Mixed content (alias of string) */
	nsxml_argument_type_existingcommand,/**< An existing command */
	nsxml_argument_type_hostname,       /**< A host name */
	nsxml_argument_type_path,           /**< A file system path */
	nsxml_argument_type_number          /**< A number */
};

struct nsxml_argument_option_info
{
	struct nsxml_option_info option_info;
	int argument_type;
	char *default_value;
};

struct nsxml_multiargument_option_info
{
	struct nsxml_option_info option_info;
	int argument_type;
	size_t min_argument;
	/**
	 * Should be > 0 to be considered
	 */
	size_t max_argument;
};

/** Group type */
enum nsxml_group_optiontype
{
	nsxml_group_option_standard, /**< A group with no particular effect */
	nsxml_group_option_exclusive /**< Only one option of the group can appear on the same command line */
};

struct nsxml_group_option_info
{
	struct nsxml_option_info option_info;
	int group_type;
	size_t option_info_count;
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
	
	size_t max_argument;
	
	struct nsxml_value_validator *validators;
};

void nsxml_positional_argument_info_init(struct nsxml_positional_argument_info *info, int flags, int arg_type, size_t max_arg);

struct nsxml_rootitem_info
{
	struct nsxml_item_info item_info;
	size_t option_info_count;
	struct nsxml_option_info **option_infos;
	
	size_t positional_argument_info_count;
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
	size_t subcommand_info_count;
	struct nsxml_subcommand_info *subcommand_infos;
};

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

typedef struct _nsxml_value ]]><value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[;

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
 * Parser state
 */
struct nsxml_parser_state
{
	/** Program info */
	const struct nsxml_program_info *program_info_ref;
	
	/** Number of option name binding arrays */
	size_t option_name_binding_group_count;
	
	/** Per-group option name binding counts */
	size_t *option_name_binding_counts;
	
	/**
	 * Array of name binding groups
	 * First index: array of bindings for program options
	 * Other: array of bindings for each subcommand options
	 */
	struct nsxml_option_name_binding **option_name_bindings;
	
	size_t subcommand_name_binding_count;
	
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
	size_t anonymous_option_result_count;
	struct nsxml_option_result **anonymous_option_results;
	
	size_t value_count;
	]]><value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *values;
};

/**
 * Create a new parser state
 * @param argc Number of argument on the command line
 * @param argv List of arguments
 * @param start_index First argument to consider
 * @return A new @c nsxml_parser_state
 */
struct nsxml_parser_state *nsxml_parser_state_new(const struct nsxml_program_info *info, int argc, const char **argv, int start_index);

void nsxml_parser_state_allocate_name_bindings(struct nsxml_parser_state *state, size_t option_name_binding_group_count, size_t *option_name_binding_counts);

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

/**
 * Switch option result
 */
struct nsxml_switch_option_result
{
	int result_type;

	/**
	 * Set to 1 if the option is present at least once on the command line
	 */
	int is_set;
};

/**
 * Single argument option result
 */
struct nsxml_argument_option_result
{
	int result_type;

	/**
	 * Set to 1 if the option is present at least once on the command line
	 */
	int is_set;

	/**
	 * Option argument value
	 */
	]]><value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ argument;
};

/**
 * Multiple argument option result
 */
struct nsxml_multiargument_option_result
{
	int result_type;

	/**
	 * Set to 1 if the option is present at least once on the command line
	 */
	int is_set;

	/**
	 * Number of arguments
	 */
	size_t argument_count;

	/**
	 * Option arguments value
	 */
	]]><value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *arguments;
};

/**
 * Option gruup result
 */
struct nsxml_group_option_result
{
	int result_type;
	/**
	 * Set to 1 if at least one option of the group tree is present on the command line
	 */
	int is_set;
	
	/**
	 * @attention Apply only on exclusive group
	 *
	 * Reference to the result struct of the selected option if any
	 */
	struct nsxml_option_result *selected_option;
	/**
	 * @attention Apply only on exclusive group
	 *
	 * Variable name of the selected option if any
	 */
	const char *selected_option_name;
};

void nsxml_switch_option_result_init(struct nsxml_switch_option_result *option);
void nsxml_argument_option_result_init(struct nsxml_argument_option_result *option);
void nsxml_multiargument_option_result_init(struct nsxml_multiargument_option_result *option);
void nsxml_group_option_result_init(struct nsxml_group_option_result *option);
void nsxml_option_result_cleanup(void *option_result_ptr);

struct nsxml_program_result
{
	/**
	 * A list of messages generated during the command line parsing
	 * grouped by severity
	 */
	]]><value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *messages[]]><value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/><![CDATA[];

	/**
	 * A list of messages generated during the command line parsing
	 * sorted by apparition
	 */
	]]><value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *first_message;

	/**
	 * Name of the selected subcommand if any
	 * @note The pointer refers to the subcommand name allocated in the program info structure
	 */
	const char *subcommand_name;

	/**
	 * Number of positional argument
	 */
	size_t value_count;

	/**
	 * List of positional arguments
	 */
	]]><value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *values;
};

void nsxml_program_result_init(void *result_ptr);
void nsxml_program_result_cleanup(void *result_ptr);
void nsxml_program_result_free(struct nsxml_program_result *result);

NSXMLAPI size_t nsxml_program_result_message_count(const struct nsxml_program_result *, int messagetype_min, int messagetype_max);

/* Usage Functions *******************************/

/**
 * Usage display format
 */
NSXMLAPI enum nsxml_usage_format
{
	]]><value-of select="$prg.c.parser.variableName.nsxml_usage_format_short"/><![CDATA[ = 1,   /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_usage_format_short"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_usage_format_abstract"/><![CDATA[ = 2,/**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_usage_format_abstract"/><![CDATA[ */
	]]><value-of select="$prg.c.parser.variableName.nsxml_usage_format_details"/><![CDATA[ = 7  /**!< ]]><value-of select="$prg.c.parser.variableName.nsxml_usage_format_details"/><![CDATA[ */
};

NSXMLAPI void nsxml_usage(FILE *stream, const struct nsxml_program_info *info, struct nsxml_program_result *result, int format, const ]]><value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap);

/* Parser Functions ******************************/

void nsxml_parse_core(struct nsxml_parser_state *state, struct nsxml_program_result *result);

#if defined(__cplusplus)
} /* extern "C" */
#endif

#endif /* __NSXML_PROGRAM_PARSER_H__ */
]]></variable>

	<template match="//prg:program">
		<value-of select="$prg.c.parser.genericHeader"/>
	</template>
</stylesheet>

