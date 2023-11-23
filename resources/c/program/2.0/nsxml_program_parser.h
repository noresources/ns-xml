/**************************************************************************************$
 * * ns-xml c parser
 ***************************************************************************************
 * Copyright © 2012 - 2021 by Renaud Guillard (dev@nore.fr)
 * Distributed under the terms of the MIT License, see LICENSE
 ***************************************************************************************
 */

#if !defined(NSXML_PROGRAM_PARSER_H__)
#define NSXML_PROGRAM_PARSER_H__

#if defined(__cplusplus)
#	define NSXML_EXTERNC_BEGIN extern "C" {
#	define NSXML_EXTERNC_END }
#else
#define NSXML_EXTERNC_END
#endif

#if defined(__cplusplus)
#	include <cstdlib>
#	include <cstdio>
#	include <cstdarg>
NSXML_EXTERNC_BEGIN
#else
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#endif

/* Macros ****************************************/

#if !defined (NSXMLAPI)
#	if defined (__GNUC__)
/** @brief C API exposition macro */
#		define NSXMLAPI __attribute__((visibility("default")))
#	else
/** @brief C API exposition macro */
#		define NSXMLAPI
#	endif
#endif

#if defined(NSXML_DEBUG)
#	undef NSXML_DEBUG
#	define NSXML_DEBUG 1
#else
#	define NSXML_DEBUG 0
#endif

#if defined(NSXML_ASSERT)
#	undef NSXML_ASSERT
#	define NSXML_ASSERT 1
#else
#	define NSXML_ASSERT 0
#endif

/** An option name (without '-' or '--' prefix) */
#define NSXML_MAX_OPTION_NAME_LENGTH 61
/** An option name (with '-' or '--' prefix) */
#define NSXML_MAX_OPTION_CLI_NAME_LENGTH (NSXML_MAX_OPTION_NAME_LENGTH + 2)
/** A buffer that can hold a cli option name */
#define NSXML_OPTION_NAME_BUFFER_LENGTH (NSXML_MAX_OPTION_CLI_NAME_LENGTH + 1)

/* Messages */
#if (!defined(NSXML_FATALERROR_UNKNOWN_OPTION_MSGF))
#define NSXML_FATALERROR_UNKNOWN_OPTION_MSGF "Unknown option %s"
#endif

#if (!defined(NSXML_FATALERROR_UNKNOWN_OPTION_MSGF))
#define NSXML_FATALERROR_UNKNOWN_OPTION_MSGF "Unknown option %s"
#endif

#if (!defined(NSXML_ERROR_INVALID_OPTION_VALUE_MSGF))
#define NSXML_ERROR_INVALID_OPTION_VALUE_MSGF "Invalid value for option %s. %s"
#endif

#if !defined(NSXML_ERROR_INVALID_POSARG_VALUE_MSGF)
#define NSXML_ERROR_INVALID_POSARG_VALUE_MSGF "Invalid value for positional argument %d. %s"
#endif

/* Utility functions ******************************/

/** Append string to another */
/**
 *
 * @param output Output buffer
 * @param output_length Output buffer length
 * @param offset Where to append @c append
 * @param append String to append to @c output
 * @return Number of character appended to @c output
 *
 * If the
 */
NSXMLAPI size_t nsxml_util_append(
    char **output,
    size_t *output_length,
    size_t offset,
    const char *append);

/** Copy a string */
/*
 * @param output Output buffer
 * @param output_length Output buffer size
 * @param input Input string to copy
 * @param input_length Maximum length to copy
 * The @c output parameter will always ends with a null-character. If @c input_length is greater than @c[ output_length + 1},
 * the result will be truncated
 * @return  Difference between @p input_length and the real number of character copied
 */
NSXMLAPI int nsxml_util_strncpy(
    char *output,
    size_t output_length,
    const char *input,
    size_t input_length);

/** Duplicate a string */
/**
 * @param input String to copy
 * @return A new buffer containing @c input
 */
NSXMLAPI char *nsxml_util_strdup(const char *input);

/** Copy a string */
/**
 *
 * @param output Output buffer
 * @param output_length Output buffer size
 * @param input Input string to copy
 *
 * Same as nsxml_util_strncpy with an input string length set to @c strlen(input)
 *
 * @return  Copied characters
 */
NSXMLAPI int nsxml_util_strcpy(
    char *output,
    size_t output_length,
    const char *input);

/** Append text */
/**
 * @param output Output string buffer
 * @param output_length Output string buffer current size
 * @param offset Append text at the given offset
 * @param append Text to append
 *
 * @return Number of character appended to string
 */
NSXMLAPI size_t nsxml_util_strcat(
    char **output,
    size_t *output_length,
    size_t offset,
    const char *append);

/** snprintf with automatic reallocation */
/**
 * @param output Output string buffer
 * @param output_length Output string buffer current size
 * @param format String format
 * @return Printed characters
 *
 * Parameters @c output and @c output_length will be modified if the printed strings
 * is taller than @c output_length
 */
NSXMLAPI size_t nsxml_util_asnprintf(
    char **output,
    size_t *output_length,
    size_t offset,
    const char *format, ...);

/** Indicates if a string begins with a given character sequence */
/**
 * @param haystack Input string
 * @param needle Text to search in @c haystack
 * @return A non-zero valueif @c haystack starts with the string @c needle
 */
NSXMLAPI int nsxml_util_string_starts_with(
    const char *haystack,
    const char *needle);

/** Test a file system path permission */
/**
 * @param path Path
 * @param flag access function flags
 */
NSXMLAPI int nsxml_util_path_access_check(
    const char *path,
    int flag);

/**
 * Options for text wrapping
 */
struct _nsxml_util_text_wrap_options
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
	char eol[4];
};

typedef struct _nsxml_util_text_wrap_options nsxml_util_text_wrap_options;

/**
 * Text wrapping indentation modes
 */
enum nsxml_util_text_indent_mode
{
	nsxml_util_text_wrap_indent_none = 0,/**!< Do not indent */
	nsxml_util_text_wrap_indent_first, /**!< Indent first line */
	nsxml_util_text_wrap_indent_others /**!< Indent all line except the first */
};

/**
 * End of line character(s) to use while wrapping text
 */
enum nsxml_util_text_wrap_eol
{
	nsxml_util_text_wrap_eol_cr = 1, /**!< MacOS < X end-of-line */
	nsxml_util_text_wrap_eol_lf = 2, /**!< Unix end-of-line */
	nsxml_util_text_wrap_eol_crlf = 3/**!< Windows end-of-line */
};

/** Initialize text wrapping option structure */
/**
 * @param options Option structure to initialize
 * @param tab Tab size
 * @param line Line length
 * @param indent_mode Indentation mode
 * @param eol End of line mode
 */
NSXMLAPI void nsxml_util_text_wrap_options_init(nsxml_util_text_wrap_options *options,
        size_t tab,
        size_t line,
        int indent_mode,
        int eol);

/** Print a text using text wrapping options */
/**
 * @param stream Output stream
 * @param text Text to print
 * @param options Text wrapping option
 * @param level Initial indentation level
 */
NSXMLAPI void nsxml_util_text_wrap_fprint(
    FILE *stream,
    const char *text,
    const nsxml_util_text_wrap_options *options,
    size_t level);

/* Messages **************************************/

/**
 * Message severity
 */
enum nsxml_message_type
{
	nsxml_message_type_debug = 0, /**!< Debug messages */
	nsxml_message_type_warning, /**!< Non-critical problem */
	nsxml_message_type_error, /**!< Error */
	nsxml_message_type_fatal_error,/**!< Fatal error */
	
	nsxml_message_type_count
};

enum nsxml_message_warning
{
	nsxml_message_warning_ignore_endofarguments = 1
};

/**
 * Error list
 */
enum nsxml_message_error
{
	nsxml_message_error_invalid_option_argument = 1,
	nsxml_message_error_invalid_pa_argument = 2,
	nsxml_message_error_missing_option_argument = 3,
	nsxml_message_error_missing_required_option = 4,
	nsxml_message_error_missing_required_group_option = 5,
	nsxml_message_error_missing_required_xgroup_option = 6,
	nsxml_message_error_missing_required_pa = 7,
	nsxml_message_error_program_pa_not_allowed = 8,
	nsxml_message_error_subcommand_pa_not_allowed = 9,
	nsxml_message_error_too_many_pa = 10,
	nsxml_message_error_not_enough_arguments = 11,
	nsxml_message_error_unexpected_option = 12,
	nsxml_message_error_option_argument_not_allowed = 13
};

enum nsxml_message_fatal_error
{
	nsxml_message_fatal_error_unknown_option = 1
};

/**
 * A message from the parser
 */
struct _nsxml_message
{
	int type;
	int code;
	char *message;
	struct _nsxml_message *next_message;
};

typedef struct _nsxml_message nsxml_message;

NSXMLAPI size_t nsxml_message_count(
    const nsxml_message *list);

NSXMLAPI nsxml_message *nsxml_message_new_ref(nsxml_message *ref);

/* Item names *************************************/

struct nsxml_item_name;

NSXMLAPI struct nsxml_item_name *nsxml_item_names_new(const char *, ...);

/** Get the nth item name in a item_name list */
/**
 * @param list Iten name table
 * @param item_index name table index
 * @return Item name
 */
NSXMLAPI const char *nsxml_item_name_get(
    const struct nsxml_item_name *list,
    int item_index);

/* Validator *************************************/

struct nsxml_value_validator;
struct nsxml_parser_state;
struct nsxml_program_result;
struct nsxml_option_binding;
struct nsxml_option_info;
struct nsxml_validated_item;

typedef int nsxml_value_validator_validation_callback(
    const void *self,
    struct nsxml_parser_state *state,
    struct nsxml_program_result *result,
    struct nsxml_validated_item *item,
    const char *value);
typedef void nsxml_value_validator_cleanup_callback(void *self);
typedef size_t nsxml_value_validator_usage_callback(
    const void *self,
    struct nsxml_validated_item *item,
    char **output, size_t *output_length);

/**
 * Validator flags
 */
enum nsxml_value_validator_flags
{
	nsxml_value_validator_checkmin = (1 << 0),
	nsxml_value_validator_checkmax = (1 << 1),
	nsxml_value_validator_path_exists = (1 << 2),
	nsxml_value_validator_path_readable = (1 << 3),
	nsxml_value_validator_path_writable = (1 << 4),
	nsxml_value_validator_path_executable = (1 << 5),
	nsxml_value_validator_path_type_file = (1 << 6),
	nsxml_value_validator_path_type_folder = (1 << 7),
	nsxml_value_validator_path_type_symlink = (1 << 8),
	nsxml_value_validator_path_type_all =
	    (nsxml_value_validator_path_type_file
	     | nsxml_value_validator_path_type_folder
	     | nsxml_value_validator_path_type_symlink),
	nsxml_value_validator_enum_strict = (1 << 9)
};

struct nsxml_value_validator
{
	nsxml_value_validator_validation_callback *validation_callback;
	nsxml_value_validator_cleanup_callback *cleanup_callback;
	nsxml_value_validator_usage_callback *usage_callback;
	struct nsxml_value_validator *next_validator;
	int flags;
};

NSXMLAPI void nsxml_value_validator_init(struct nsxml_value_validator *validator, nsxml_value_validator_validation_callback *callback, nsxml_value_validator_cleanup_callback *cleanup, nsxml_value_validator_usage_callback *usage_cb, int flags);
NSXMLAPI void nsxml_value_validator_add(struct nsxml_value_validator **list, struct nsxml_value_validator *validator);

NSXMLAPI int nsxml_value_validator_validate_path(
    const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *, struct nsxml_validated_item *item, const char *value);

NSXMLAPI size_t nsxml_value_validator_usage_path(
    const void *self, struct nsxml_validated_item *item, char **output, size_t *output_length);

struct nsxml_value_validator_number
{
	struct nsxml_value_validator validator;
	float min_value;
	float max_value;
	size_t decimal_count;
};
NSXMLAPI int nsxml_value_validator_validate_number(
    const void *self,
    struct nsxml_parser_state *state,
    struct nsxml_program_result *result,
    struct nsxml_validated_item *item,
    const char *value);

NSXMLAPI size_t nsxml_value_validator_usage_number(
    const void *self,
    struct nsxml_validated_item *item,
    char **output,
    size_t *output_length);

struct nsxml_value_validator_enum
{
	struct nsxml_value_validator validator;
	struct nsxml_item_name *values;
};
NSXMLAPI int nsxml_value_validator_validate_enum(
    const void *self,
    struct nsxml_parser_state *state,
    struct nsxml_program_result *result,
    struct nsxml_validated_item *item,
    const char *value);

NSXMLAPI void nsxml_value_validator_cleanup_enum(void *self);

NSXMLAPI size_t nsxml_value_validator_usage_enum(
    const void *self,
    struct nsxml_validated_item *item,
    char **output,
    size_t *output_length);

/* Item info *************************************/

/** Types of element informations */
enum nsxml_item_type
{
	nsxml_item_type_program = 1, /**!< Main program */
	nsxml_item_type_subcommand, /**!< Program subcommand */
	nsxml_item_type_option, /**!< Command line option */
	nsxml_item_type_positional_argument, /** Positional argument */
	
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

/**
 * Initialize item info properties
 *
 * @param info Item info
 * @param type Item type
 * @param abstract Abstract documentation
 * @param details Detailed documentation
 */
NSXMLAPI void nsxml_item_info_init(struct nsxml_item_info *info, int type, const char *abstract, const char *details);

/** Option types */
enum nsxml_option_type
{
	nsxml_option_type_switch = 0, /**!< Boolean swith */
	nsxml_option_type_argument, /**!< Option with a unique argument */
	nsxml_option_type_multiargument,/**!< Option with one or more arguments */
	nsxml_option_type_group, /**!< Option group */
	
	nsxml_option_type_count
};

/** Type of option or positional argument value */
enum nsxml_value_type
{
	nsxml_value_type_unset = -1,/**!< Undefined value type */
	nsxml_value_type_null, /**!< Null value */
	nsxml_value_type_int, /**!< Integer value */
	nsxml_value_type_float, /**!< Floating point value */
	nsxml_value_type_string /**!< Text value */
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

/**
 * Initialize option descriptor
 *
 * @param info Option descriptor
 * @param type Option type
 * @param flags Option flags
 * @param var_name Bound variable name
 * @param names Option long and short names
 * @param parent Option parent
 */
NSXMLAPI void nsxml_option_info_init(
    struct nsxml_option_info *info,
    int type,
    int flags,
    const char *var_name,
    struct nsxml_item_name *names, const void *parent);

struct nsxml_switch_option_info
{
	struct nsxml_option_info option_info;
};

/** Option argument type */
enum nsxml_argument_type
{
	nsxml_argument_type_string, /**< A string */
	nsxml_argument_type_mixed, /**< Mixed content (alias of string) */
	nsxml_argument_type_existingcommand,/**< An existing command */
	nsxml_argument_type_hostname, /**< A host name */
	nsxml_argument_type_path, /**< A file system path */
	nsxml_argument_type_number /**< A number */
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
	int default_option_info_index;
};

enum nsxml_positional_argument_flags
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

/**
 * Initialize positional argument descriptor
 *
 * @param info Positional argument descriptor
 * @param flags Positional argument flags
 * @param arg_type
 * @param max_arg Maximum number of arguments
 */
NSXMLAPI void nsxml_positional_argument_info_init(
    struct nsxml_positional_argument_info *info,
    int flags,
    int arg_type,
    size_t max_arg);

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

struct nsxml_program_info
{
	struct nsxml_rootitem_info rootitem_info;
	const char *name;
	const char *version_string;
	size_t subcommand_info_count;
	struct nsxml_subcommand_info *subcommand_infos;
};

/**
 * Cleanup program descriptor memory
 * @param info Program descriptor
 */
NSXMLAPI void nsxml_program_info_cleanup(struct nsxml_program_info *info);
/**
 * Free program descriptor
 *
 * @param info Program descriptor
 */
NSXMLAPI void nsxml_program_info_free(struct nsxml_program_info *info);

/* Program option argument or positional argument value */

struct _nsxml_value
{
	int type;
	const char *string_value;
	int int_value;
	float float_value;
	struct _nsxml_value *next_value;
};

typedef struct _nsxml_value nsxml_value;

/* Parser internal state *************************/

struct nsxml_option_binding
{
	/**
	 * Option name (short, long or NULL for group options)
	 */
	const char *name_ref;
	/**
	 * Associated option result
	 */
	struct nsxml_option_result *result_ref;
	/**
	 * Associated option info
	 */
	const struct nsxml_option_info *info_ref;
	/**
	 * Number of parent groups
	 */
	int level;
	/**
	 * Parent group results. From the direct parent to the higher group
	 */
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
	size_t option_binding_group_count;
	
	/** Per-group option name binding counts */
	size_t *option_binding_counts;
	
	/**
	 * Array of name binding groups
	 * First index: array of bindings for program options
	 * Other: array of bindings for each subcommand options
	 */
	struct nsxml_option_binding **option_bindings;
	
	size_t subcommand_name_binding_count;
	
	struct nsxml_subcommand_name_binding *subcommand_name_bindings;
	
	/** User input */
	
	/** Number of arguments */
	int argc;
	
	/** Arguments values */
	const char *const *argv;
	
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
	struct nsxml_option_binding *active_option;
	
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
	nsxml_value *values;
};

/**
 * Create a new parser state
 * @param argc Number of argument on the command line
 * @param argv List of arguments
 * @param start_index First argument to consider
 * @return A new @c nsxml_parser_state
 */
NSXMLAPI struct nsxml_parser_state *nsxml_parser_state_new(const struct nsxml_program_info *info, int argc, const char *const *argv, int start_index);

/**
 * Allocate option name <-> Option descriptor binding
 * @param state Parser state
 * @param option_binding_group_count
 * @param option_binding_counts
 */
NSXMLAPI void nsxml_parser_state_allocate_name_bindings(
    struct nsxml_parser_state *state,
    size_t option_binding_group_count,
    size_t *option_binding_counts);

/**
 * Destroy the given parser state and set the pointer to NULL
 * @param state Parser state to free
 */
NSXMLAPI void nsxml_parser_state_free(struct nsxml_parser_state *state);

/* Parser results ********************************/

/**
 * Result structure types
 */
enum nsxml_result_type
{
	nsxml_result_type_program,
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
	nsxml_value argument;
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
	nsxml_value *arguments;
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

/**
 * Initialize switch ption result properties.
 *
 * @param option Swith option descriptor
 */
NSXMLAPI void nsxml_switch_option_result_init(struct nsxml_switch_option_result *option);

/**
 * Initialize argument option result properties.
 * @param option Argument option result
 */
NSXMLAPI void nsxml_argument_option_result_init(struct nsxml_argument_option_result *option);

/**
 * Initialize multi-argument option properties
 * @param option Argument option result
 */
NSXMLAPI void nsxml_multiargument_option_result_init(struct nsxml_multiargument_option_result *option);

/**
 * Initialize group option result properties.
 *
 * @param option Option group result
 */
NSXMLAPI void nsxml_group_option_result_init(struct nsxml_group_option_result *option);

/**
 * Clear ption result
 * @param option_result_ptr
 */
NSXMLAPI void nsxml_option_result_cleanup(void *option_result_ptr);

struct nsxml_program_result
{
	/**
	 * A list of messages generated during the command line parsing
	 * grouped by severity
	 */
	nsxml_message *messages[nsxml_message_type_count];
	
	/**
	 * A list of messages generated during the command line parsing
	 * sorted by apparition
	 */
	nsxml_message *first_message;
	
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
	nsxml_value *values;
};

/**
 * Initialize program parser result properties.
 * @param result_ptr Program parser result
 */
NSXMLAPI void nsxml_program_result_init(void *result_ptr);

/**
 * Cleanup program parser result
 * @param result_ptr Program parser result
 */
NSXMLAPI void nsxml_program_result_cleanup(void *result_ptr);

/**
 * Free program parser result
 * @param result Program result
 */
NSXMLAPI void nsxml_program_result_free(struct nsxml_program_result *result);

NSXMLAPI size_t nsxml_program_result_message_count(
    const struct nsxml_program_result *,
    int messagetype_min, int messagetype_max);

/* Usage Functions *******************************/

/**
 * Usage display format
 */
enum nsxml_usage_format
{
	nsxml_usage_format_short = 0x01, /**!< Short form */
	nsxml_usage_format_abstract = 0x02,/**!<  Abstract-only description */
	nsxml_usage_format_details = 0x07 /**!< Full description */
};

/**
 * Program usage output
 *
 * @param stream Output stream
 * @param info Program descriptor
 * @param result Command line parsing result
 * @param format Presentation format
 * @param wrap Text wrapping options
 */
NSXMLAPI void nsxml_usage(
    FILE *stream,
    const struct nsxml_program_info *info,
    struct nsxml_program_result *result,
    int format,
    const nsxml_util_text_wrap_options *wrap);

/* Parser Functions ******************************/

/**
 * Cre command line parser
 *
 * @param state Parsing state output
 * @param result Program result
 */
NSXMLAPI void nsxml_parse_core(
    struct nsxml_parser_state *state,
    struct nsxml_program_result *result);

NSXML_EXTERNC_END

#endif /* NSXML_PROGRAM_PARSER_H__ */
