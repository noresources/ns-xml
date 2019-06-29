<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012-2019 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->
<!-- C Source code in customizable XSLT form -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.generic-names.xsl" />
	<xsl:output method="text" encoding="utf-8" />
	<xsl:param name="prg.c.parser.header.filePath" select="'cmdline.h'" />
	
	<xsl:variable name="prg.c.parser.genericSource"><![CDATA[
/***************************************************************************************
 * ns-xml c parser
 ***************************************************************************************
 * Copyright © 2012 - 2019 by Renaud Guillard (dev@nore.fr)
 * Distributed under the terms of the MIT License, see LICENSE
 ***************************************************************************************
 */

#include "]]><xsl:value-of select="$prg.c.parser.header.filePath"/><![CDATA["

#if !defined (NSXML_TEXTBUFFER_BASESIZE)
#	define NSXML_TEXTBUFFER_BASESIZE 1024
#endif

#if !defined (NSXML_TEXTBUFFER_MINBLOCKSIZE)
#	define NSXML_TEXTBUFFER_MINBLOCKSIZE 64
#endif

#if !defined (NSXML_SIZET_FORMAT)
#	if defined (__STDC_VERSION__) && (__STDC_VERSION__ >= 199901L)
#		define NSXML_SIZET_FORMAT "zu"
#		if !defined (NSXML_SIZET_FORMAT_CAST)
#			define NSXML_SIZET_FORMAT_CAST(x) (x)
#		endif
#	elif defined (__cplusplus) && (__cplusplus >= 201103L)
#		define NSXML_SIZET_FORMAT "zu"
#		if !defined (NSXML_SIZET_FORMAT_CAST)
#			define NSXML_SIZET_FORMAT_CAST(x) (x)
#		endif
#	elif (defined (__x86_64__) && __x86_64__) || (defined(__x86_64) && x86_64)
#		define NSXML_SIZET_FORMAT "lu"
#		if !defined (NSXML_SIZET_FORMAT_CAST)
#			define NSXML_SIZET_FORMAT_CAST(x) ((long unsigned int)(x))
#		endif
#	else
#		define NSXML_SIZET_FORMAT "u"
#		if !defined (NSXML_SIZET_FORMAT_CAST)
#			define NSXML_SIZET_FORMAT_CAST(x) ((unsigned int)(x))
#		endif
#	endif
#endif

#define NSXML_DBG 0

#if defined(__cplusplus)
#	include <cstdio>
#	include <cstdlib>
#	include <cstring>
#	if NSXML_DBG
#		include <cassert>
#	endif
#	include <cctype>
NSXML_EXTERNC_BEGIN
#else
#	include <stdio.h>
#	include <stdlib.h>
#	include <string.h>
#	if NSXML_DBG
#		include <assert.h>
#	endif
#	include <ctype.h>
#endif

#if defined(_WIN32)
#	include <io.h>
#	if !defined(F_OK)
#		define F_OK 0
#	endif
#	if !defined(X_OK)
#		define X_OK 1
#	endif
#	if !defined(R_OK)
#		define R_OK 2
#	endif
#	if !defined(W_OK)
#		define W_OK 4
#	endif
#else
#	include <unistd.h>
#	include <libgen.h>
#endif

#include <sys/stat.h>

/* Utility functions *****************************/

size_t nsxml_util_digit_count_s(size_t n);
size_t nsxml_util_digit_count_s(size_t n)
{
	size_t c = 1;
	
	while ((n /= 10) > 10)
	{
		++c;
	}
	
	return c;
}

size_t ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(char **output, size_t *output_length, size_t offset, const char *append)
{
	size_t printed = strlen(append);
	
	if ((printed + offset) >= *output_length)
	{
		size_t added = (size_t)((size_t)(printed + 1 + offset) - *output_length);
		
		if (added < NSXML_TEXTBUFFER_MINBLOCKSIZE)
		{
			added = NSXML_TEXTBUFFER_MINBLOCKSIZE;
		}
		
		*output_length += added;
		*output = (char *) realloc(*output, sizeof(char) * (*output_length));
	}
	
	memcpy(*output + offset, append, printed);
	(*output)[offset + printed] = '\0';
	return printed;
}

size_t ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(char **output, size_t *output_length, size_t offset, const char *format, ...)
{
	int printed = 0;
	va_list list;
	size_t length;
	
	do
	{
		printed = 0;
		length = (offset <= *output_length) ? (*output_length - offset) : 0;
		va_start(list, format);
		printed += vsnprintf(*output + offset, length, format, list);
		va_end(list);
		
		if (printed <= 0)
		{
			(*output)[offset] = '\0';
			return 0;
		}
		else if ((size_t)printed >= length)
		{
			size_t added = ((size_t)((size_t)printed + 1 + offset) - *output_length);
			
			if (added < NSXML_TEXTBUFFER_MINBLOCKSIZE)
			{
				added = NSXML_TEXTBUFFER_MINBLOCKSIZE;
			}
			
			*output_length += added;
			*output = (char *) realloc(*output, sizeof(char) * (*output_length));
		}
	}
	while (printed == 0);
	
	return (size_t)printed;
}

int ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(char *output, size_t output_length, const char *input, size_t input_length)
{
	size_t len = strlen(input);
	size_t s = input_length;
	
	if (output_length < 1)
	{
		return -1;
	}
	
	if (s > (output_length - 1))
	{
		s = (output_length - 1);
	}
	
	if (s > len)
	{
		s = len;
	}
	
	memcpy(output, input, s);
	output[s] = 0;
	
	return (int)(input_length - s);
}

char *]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strdup"/><![CDATA[(const char *input)
{
	size_t size = strlen(input) + 1;
	char *result = (char *)malloc(size * sizeof(char));
	]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strcpy"/><![CDATA[(result, size, input);
	return result;
}

int ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strcpy"/><![CDATA[(char *output, size_t output_length, const char *input)
{
	return ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(output, output_length, input, (size_t)strlen(input));
}

int ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_string_starts_with"/><![CDATA[(const char *haystack, const char *needle)
{
	size_t len = strlen(needle);
	const char *a = haystack;
	const char *b = needle;
	
	while (*a && *b && (*a == *b) && len--)
	{
		++a;
		++b;
	}
	
	return (len == 0);
}

int ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_path_access_check"/><![CDATA[(const char *path, int flag)
{
#if defined(_WIN32)
	return (_access(path, flag) == 0);
#else
	return (access(path, flag) == 0);
#endif
}

void ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_options_init"/><![CDATA[(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *options, size_t tab, size_t line, int indent_mode, int eol)
{
	int i = 0;
	options->tab_size = tab;
	options->line_length = line;
	options->indent_mode = indent_mode;
	
	if (eol & ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_cr"/><![CDATA[)
	{
		options->eol[i] = '\r';
		++i;
	}
	
	if (eol & ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_lf"/><![CDATA[)
	{
		options->eol[i] = '\n';
		++i;
	}
	
	options->eol[i] = '\0';
}

void ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(FILE *stream, const char *text, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *options, size_t level)
{
	size_t i;
	const char *text_ptr = text;
	char *indent = NULL;
	char *line_buffer = NULL;
	int line_index = 0;
	int line_breakable_index = -1;
	size_t prefix_length = (level * options->tab_size);
	size_t first_prefix_length = (options->indent_mode == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_indent_first"/><![CDATA[) ? (prefix_length + options->tab_size) : prefix_length;
	size_t others_prefix_length = (options->indent_mode == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_indent_others"/><![CDATA[) ? (prefix_length + options->tab_size) : prefix_length;
	int first = 1;
	size_t max_prefix_length = (first_prefix_length > others_prefix_length) ? first_prefix_length : others_prefix_length;
	
	size_t line_length = ((options->line_length - first_prefix_length) > 0) ? (options->line_length - first_prefix_length) : 1;
	prefix_length = first_prefix_length;
	
	line_buffer = (char *) malloc(sizeof(char) * (line_length + 1));
	
	indent = (char *) malloc(sizeof(char) * (max_prefix_length + 1));
	
	for (i = 0; i < prefix_length; ++i)
	{
		indent[i] = ' ';
	}
	
	indent[prefix_length] = '\0';
	
	while (text_ptr && (*text_ptr != '\0'))
	{
		if (line_index < (int) line_length)
		{
			if (*text_ptr == '\t')
			{
				line_breakable_index = line_index;
				
				/* replace by spaces */
				for (i = 0; (i < options->tab_size) && (line_index < (int) line_length); ++i, ++line_index)
				{
					line_buffer[line_index] = ' ';
				}
			}
			else if ((*text_ptr == '\r') || (*text_ptr == '\n'))
			{
				/** print current line */
				line_buffer[line_index] = 0;
				fprintf(stream, "%s%s%s", indent, line_buffer, options->eol);
				line_index = 0;
				line_breakable_index = -1;
				
				if ((*text_ptr == '\r') && (*(text_ptr + 1) == '\n'))
				{
					++text_ptr;
				}
				
				if (first)
				{
					first = 0;
					line_length = ((options->line_length - others_prefix_length) > 0) ? (options->line_length - others_prefix_length) : 1;
					prefix_length = others_prefix_length;
					
					for (i = 0; i < prefix_length; ++i)
					{
						indent[i] = ' ';
					}
					
					indent[prefix_length] = '\0';
				}
			}
			else
			{
				if (isspace(*text_ptr))
				{
					line_breakable_index = line_index;
				}
				
				line_buffer[line_index] = *text_ptr;
				++line_index;
			}
		}
		else
		{
			/* print current line until last breakable index */
			if (line_breakable_index <= 0)
			{
				line_buffer[line_index] = 0;
				fprintf(stream, "%s%s%s", indent, line_buffer, options->eol);
				line_index = 0;
			}
			else
			{
				line_buffer[line_breakable_index] = 0;
				fprintf(stream, "%s%s%s", indent, line_buffer, options->eol);
				
				/* move remaining line_buffer text to front */
				if (line_index > line_breakable_index)
				{
					int a = 0;
					int b = line_breakable_index + 1;
					
					while ((b < line_index) && isspace(line_buffer[b]))
					{
						++b;
					}
					
					while (b < line_index)
					{
						line_buffer[a] = line_buffer[b];
						++a;
						++b;
					}
					
					line_index = a;
					line_breakable_index = -1;
				}
			}
			
			if (first)
			{
				first = 0;
				line_length = ((options->line_length - others_prefix_length) > 0) ? (options->line_length - others_prefix_length) : 1;
				prefix_length = others_prefix_length;
				
				for (i = 0; i < prefix_length; ++i)
				{
					indent[i] = ' ';
				}
				
				indent[prefix_length] = '\0';
			}
			
			continue;
		}
		
		++text_ptr;
	}
	
	if (line_index > 0)
	{
		line_buffer[line_index] = '\0';
		fprintf(stream, "%s%s%s", indent, line_buffer, options->eol);
	}
	
	free(line_buffer);
	free(indent);
}

/* Messages **************************************/

]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *nsxml_message_new_ref(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *ref)
{
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *msg = (]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *) malloc(sizeof(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[));
	msg->type = ref->type;
	msg->code = ref->code;
	msg->message = ref->message;
	msg->next_message = 0;
	return msg;
}

size_t nsxml_message_count(const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *list)
{
	const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *msg = list;
	size_t c = 0;
	
	while (msg)
	{
		++c;
		msg = msg->next_message;
	}
	
	return c;
}

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
	struct nsxml_item_name *next_name;
};

const char *nsxml_item_name_get(const struct nsxml_item_name *list, int item_index)
{
	const struct nsxml_item_name *item_name = list;
	
	if (item_name == NULL)
	{
		return NULL;
	}
	
	while ((item_index > 0) && item_name)
	{
		item_name = item_name->next_name;
		--item_index;
	}
	
	if (item_name && (item_index == 0))
	{
		return item_name->name;
	}
	
	return NULL;
}

void nsxml_item_name_free(struct nsxml_item_name *);

size_t nsxml_item_name_snprintf(const struct nsxml_item_name *, char **output, size_t *output_length, const char *prefix_text);

struct nsxml_item_name *nsxml_item_names_new(const char *name, ...)
{
	struct nsxml_item_name *item = NULL;
	struct nsxml_item_name *previous = NULL;
	struct nsxml_item_name *next = NULL;
	const char *arg_val = NULL;
	va_list arglist;
	size_t len;
	
	if (name)
	{
		len = strlen(name);
		item = (struct nsxml_item_name *) malloc(sizeof(struct nsxml_item_name));
		item->name = (char *) malloc(len + 1);
		item->next_name = NULL;
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(item->name, (size_t)(len + 1), name, (size_t)len);
		previous = item;
		
		va_start(arglist, name);
		arg_val = va_arg(arglist, const char *);
		
		while (arg_val != NULL)
		{
			len = strlen(arg_val);
			next = (struct nsxml_item_name *) malloc(sizeof(struct nsxml_item_name));
			next->name = (char *) malloc(len + 1);
			next->next_name = NULL;
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(next->name, (size_t)(len + 1), arg_val, (size_t)len);
			previous->next_name = next;
			
			previous = next;
			arg_val = va_arg(arglist, const char *);
		}
		
		va_end(arglist);
	}
	
	return item;
}

void nsxml_item_name_free(struct nsxml_item_name *item_start)
{
	struct nsxml_item_name *item = NULL;
	struct nsxml_item_name *next = NULL;
	item = item_start;
	
	while (item != NULL)
	{
		next = item->next_name;
		free(item->name);
		free(item);
		item = next;
	}
}

size_t nsxml_item_name_snprintf(const struct nsxml_item_name *names, char **output, size_t *output_length, const char *prefix_text)
{
	size_t text_buffer_length = 0;
	size_t value_count = 0;
	const struct nsxml_item_name *v = names;
	
	while (v)
	{
		++value_count;
		text_buffer_length += strlen(v->name);
		v = v->next_name;
	}
	
	text_buffer_length += ((value_count - 2) * 2) /* ', ' */
	                      + (value_count * 2) /* quetes around strings */
	                      + 4 /* ' or ' */
	                      + 2; /* \n and \0 */
	                      
	if (prefix_text)
	{
		text_buffer_length += strlen(prefix_text);
	}
	
	if (text_buffer_length > *output_length)
	{
		*output = (char *) realloc(*output, text_buffer_length);
		*output_length = text_buffer_length;
	}
	
	{
		char *t = *output;
		size_t remaining = text_buffer_length;
		int tc = 0;
		size_t i = 0;
		
		if (prefix_text)
		{
			tc = snprintf(t, remaining, "%s", prefix_text);
			t += tc;
			remaining -= (size_t) tc;
			v = names;
		}
		
		while (v)
		{
			if (i == 0)
			{
				tc = snprintf(t, remaining, "'%s'", v->name);
			}
			else if ((i + 1) == value_count)
			{
				tc = snprintf(t, remaining, " or '%s'", v->name);
			}
			else
			{
				tc = snprintf(t, remaining, ", '%s'", v->name);
			}
			
			t += tc;
			remaining -= (size_t) tc;
			++i;
			v = v->next_name;
		}
	}
	
	return text_buffer_length;
}

void nsxml_program_result_add_message(struct nsxml_program_result *result, int type, int code, const char *text);
void nsxml_program_result_add_messagef(struct nsxml_program_result *result, int type, int code, const char *format, ...);

/* Validators *************************************/

struct nsxml_validated_item
{
	/**
	 * Should be @c nsxml_item_type_option
	 * or @c nsxml_item_type_positional_argument
	 */
	int item_type;
	union
	{
		/**
		 * Option info
		 */
		struct nsxml_option_binding *binding;
		
		/**
		 * Positional argument number [1-n]
		 */
		size_t positional_argument_number;
	} item;
};

size_t nsmxl_value_validator_add_standard_error(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_validated_item *item, const char *value);
size_t nsmxl_value_validator_add_standard_error(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_validated_item *item, const char *value)
{
	const struct nsxml_value_validator *validator = (const struct nsxml_value_validator *) self;
	size_t output_length = 64;
	char *output = (char *) malloc(sizeof(char) * output_length);
	size_t usage_text_length = 0;
	(void) value;
	
	output[0] = '\0';
	
	if (validator->usage_callback)
	{
		usage_text_length = (*validator->usage_callback)(validator, item, &output, &output_length);
	}
	else
	{
		output[0] = '\0';
	}
	
	if (item->item_type == nsxml_item_type_option)
	{
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_invalid_option_argument"/><![CDATA[,
		                                  NSXML_ERROR_INVALID_OPTION_VALUE_MSGF "\n", state->active_option_cli_name, output);
	}
	else
	{
	
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_invalid_option_argument"/><![CDATA[,
		                                  NSXML_ERROR_INVALID_POSARG_VALUE_MSGF "\n", item->item.positional_argument_number, output);
		                                  
	}
	
	free(output);
	
	return usage_text_length;
}

void nsxml_value_validator_free(struct nsxml_value_validator *validator);

void nsxml_value_validator_init(struct nsxml_value_validator *validator, nsxml_value_validator_validation_callback *callback, nsxml_value_validator_cleanup_callback *cleanup, nsxml_value_validator_usage_callback *usage_cb, int flags)
{
	validator->cleanup_callback = cleanup;
	validator->validation_callback = callback;
	validator->usage_callback = usage_cb;
	validator->flags = flags;
	validator->next_validator = NULL;
}

void nsxml_value_validator_add(struct nsxml_value_validator **list, struct nsxml_value_validator *validator)
{
	if (*list == NULL)
	{
		*list = validator;
	}
	else
	{
		struct nsxml_value_validator *v = *list;
		
		while (v->next_validator != NULL)
		{
			v = v->next_validator;
		}
		
		v->next_validator = validator;
	}
	
	validator->next_validator = NULL;
}

void nsxml_value_validator_free(struct nsxml_value_validator *validator)
{
	struct nsxml_value_validator *v = validator;
	struct nsxml_value_validator *next = NULL;
	
	while (v)
	{
		next = v->next_validator;
		
		if (v->cleanup_callback)
		{
			(*v->cleanup_callback)(v);
		}
		
		free(v);
		v = next;
	}
}

int nsxml_value_validator_validate_path(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_validated_item *item, const char *value)
{
	const struct nsxml_value_validator *validator = (const struct nsxml_value_validator *) self;
	(void) result;
	(void) state;
	(void) item;
	
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "path validation %d\n", validator->flags);
#endif /* NSXML_DEBUG */
	
	if (validator->flags & nsxml_value_validator_path_exists)
	{
		if (!]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_path_access_check"/><![CDATA[(value, R_OK))
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "%s Can't be accessed\n", value);
#endif /* NSXML_DEBUG */
			
			return 0;
		}
		
		if ((validator->flags & nsxml_value_validator_path_writable) && !]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_path_access_check"/><![CDATA[(value, W_OK))
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "%s is not writable\n", value);
#endif /* NSXML_DEBUG */
			
			return 0;
		}
		
		if ((validator->flags & nsxml_value_validator_path_executable) && !]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_path_access_check"/><![CDATA[(value, X_OK))
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "%s is not executable\n", value);
#endif /* NSXML_DEBUG */
			
			return 0;
		}
	}
	
	if (]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_path_access_check"/><![CDATA[(value, F_OK))
	{
		int types = (validator->flags & nsxml_value_validator_path_type_all);
		struct stat statBuffer;
		
		if ((types != 0) && (types != nsxml_value_validator_path_type_all))
		{
			int typeFound = 0;
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "path type checks %d\n", types);
#endif /* NSXML_DEBUG */
			
			stat(value, &statBuffer);
			
			if ((types & nsxml_value_validator_path_type_folder) && S_ISDIR(statBuffer.st_mode))
			{
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Is directory\n");
#endif /* NSXML_DEBUG */
				
				typeFound++;
			}
			
			else if ((types & nsxml_value_validator_path_type_symlink) && S_ISLNK(statBuffer.st_mode))
			{
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Is symlink\n");
#endif /* NSXML_DEBUG */
				
				typeFound++;
			}
			
			else if ((types & nsxml_value_validator_path_type_file) && S_ISREG(statBuffer.st_mode))
			{
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Is regular file\n");
#endif /* NSXML_DEBUG */
				
				typeFound++;
			}
			
			if (typeFound == 0)
			{
				/**
				 * @todo error
				 */
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "None of specified types\n");
#endif /* NSXML_DEBUG */
				
				return 0;
			}
		}
	}
	
	return 1;
}

int nsxml_value_validator_validate_number(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_validated_item *item, const char *value)
{
	const struct nsxml_value_validator_number *nvalidator = (const struct nsxml_value_validator_number *) self;
	float f;
	int res;
	int passed = 1;
	char *tmp = (char *) malloc(sizeof(char) * strlen(value) + 1);
	tmp[0] = '\0';
	
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "number validation %d [%f, %f]\n", nvalidator->validator.flags, (double)nvalidator->min_value, (double)nvalidator->max_value);
#endif /* NSXML_DEBUG */
	
	res = sscanf(value, "%f%s", &f, tmp);
	
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, " - res = %d (%f %s)\n", res, (double)f, tmp);
#endif /* NSXML_DEBUG */
	
	free(tmp);
	
	if (res != 1)
	{
		passed = 0;
	}
	
	if (passed && (nvalidator->validator.flags & nsxml_value_validator_checkmin) && (f < nvalidator->min_value))
	{
		passed = 0;
	}
	
	if (passed && (nvalidator->validator.flags & nsxml_value_validator_checkmax) && (f > nvalidator->max_value))
	{
		passed = 0;
	}
	
	if (!passed)
	{
		nsmxl_value_validator_add_standard_error(self, state, result, item, value);
	}
	
	return passed;
}

int nsxml_value_validator_validate_enum(const void *self, struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_validated_item *item, const char *value)
{
	const struct nsxml_value_validator_enum *evalidator = (const struct nsxml_value_validator_enum *) self;
	struct nsxml_item_name *v;
	
	if (!(evalidator->validator.flags & nsxml_value_validator_enum_strict))
	{
		return 1;
	}
	
	v = evalidator->values;
	
	while (v)
	{
		if (strcmp(v->name, value) == 0)
		{
			return 1;
		}
		
		v = v->next_name;
	}
	
	{
		size_t output_length = 64;
		char *output = (char *) malloc(sizeof(char) * output_length);
		nsxml_item_name_snprintf(evalidator->values, &output, &output_length, "Expect: ");
		
		if (item->item_type == nsxml_item_type_option)
		{
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_invalid_option_argument"/><![CDATA[,
			                                  NSXML_ERROR_INVALID_OPTION_VALUE_MSGF "\n", state->active_option_cli_name, output);
		}
		else
		{
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_invalid_pa_argument"/><![CDATA[,
			                                  NSXML_ERROR_INVALID_POSARG_VALUE_MSGF "\n", item->item.positional_argument_number, output);
		}
		
		free(output);
	}
	
	return 0;
}

void nsxml_value_validator_cleanup_enum(void *self)
{
	struct nsxml_value_validator_enum *evalidator = (struct nsxml_value_validator_enum *) self;
	nsxml_item_name_free(evalidator->values);
	evalidator->values = NULL;
}

/* Item info **************************************/

/* Hidden API declarations */

void nsxml_argument_option_info_free(struct nsxml_argument_option_info *argumentoption_info);
void nsxml_positional_argument_info_cleanup(struct nsxml_positional_argument_info *info);
void nsxml_item_info_cleanup(struct nsxml_item_info *item_info);
void nsxml_option_info_name_display(FILE *, const char *);
void nsxml_option_info_names_display(FILE *, const struct nsxml_option_info *option_info, const char *, const char *);
void nsxml_option_info_cleanup(struct nsxml_option_info *option_info);
void nsxml_switch_option_info_free(struct nsxml_switch_option_info *switch_option_info);
void nsxml_multiargument_option_info_free(struct nsxml_multiargument_option_info *multiargumentoption_info);
void nsxml_group_option_info_free(struct nsxml_group_option_info *group_option_info);
void nsxml_rootitem_info_cleanup(struct nsxml_rootitem_info *rootitem_info);
void nsxml_subcommand_info_cleanup(struct nsxml_subcommand_info *subcommand_info);

/* Definitions */

void nsxml_item_info_init(struct nsxml_item_info *info, int type, const char *abstract, const char *details)
{
	info->item_type = type;
	
	if (abstract)
	{
		info->abstract = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strdup"/><![CDATA[(abstract);
	}
	else
	{
		info->abstract = NULL;
	}
	
	if (details)
	{
		info->details = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strdup"/><![CDATA[(details);
	}
	else
	{
		info->details = NULL;
	}
}

void nsxml_item_info_cleanup(struct nsxml_item_info *item_info)
{
	free(item_info->abstract);
	free(item_info->details);
}

void nsxml_option_info_name_display(FILE *stream, const char *name)
{
	if (strlen(name) > 1)
	{
		fprintf(stream, "--%s", name);
	}
	else
	{
		fprintf(stream, "-%s", name);
	}
}

void nsxml_option_info_names_display(FILE *stream, const struct nsxml_option_info *option_info, const char *separator, const char *end_separator)
{
	struct nsxml_item_name *n = option_info->names;
	int first = 1;
	
	while (n)
	{
		if (first)
		{
			first = 0;
		}
		else if (n->next_name && separator)
		{
			fprintf(stream, "%s", separator);
		}
		else if ((n->next_name == NULL) && end_separator)
		{
			fprintf(stream, "%s", end_separator);
		}
		
		nsxml_option_info_name_display(stream, n->name);
		
		n = n->next_name;
	}
}

void nsxml_option_info_init(struct nsxml_option_info *info, int type, int flags, const char *var_name, struct nsxml_item_name *names, const void *parent_ptr)
{
	const struct nsxml_group_option_info *parent = (const struct nsxml_group_option_info *) parent_ptr;
	info->option_type = type;
	info->option_flags = flags;
	
	if (var_name && (strlen(var_name) > 0))
	{
		info->var_name = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strdup"/><![CDATA[(var_name);
	}
	else
	{
		info->var_name = NULL;
	}
	
	info->names = names;
	info->parent = parent;
	info->validators = NULL;
}

void nsxml_option_info_cleanup(struct nsxml_option_info *option_info)
{
	nsxml_item_name_free(option_info->names);
	free(option_info->var_name);
	option_info->names = NULL;
	nsxml_value_validator_free(option_info->validators);
	nsxml_item_info_cleanup(&option_info->item_info);
}

void nsxml_positional_argument_info_init(struct nsxml_positional_argument_info *info, int flags, int arg_type, size_t max_arg)
{
	info->positional_argument_flags = flags;
	info->argument_type = arg_type;
	info->max_argument = max_arg;
	info->validators = NULL;
}

void nsxml_positional_argument_info_cleanup(struct nsxml_positional_argument_info *info)
{
	nsxml_item_info_cleanup(&info->item_info);
	nsxml_value_validator_free(info->validators);
}

void nsxml_switch_option_info_free(struct nsxml_switch_option_info *switch_option_info)
{
	nsxml_option_info_cleanup(&switch_option_info->option_info);
	free(switch_option_info);
}

void nsxml_argument_option_info_free(struct nsxml_argument_option_info *argumentoption_info)
{
	nsxml_option_info_cleanup(&argumentoption_info->option_info);
	free(argumentoption_info->default_value);
	free(argumentoption_info);
}

void nsxml_multiargument_option_info_free(struct nsxml_multiargument_option_info *multiargumentoption_info)
{
	nsxml_option_info_cleanup(&multiargumentoption_info->option_info);
	free(multiargumentoption_info);
}

void nsxml_group_option_info_free(struct nsxml_group_option_info *group_option_info)
{
	nsxml_option_info_cleanup(&group_option_info->option_info);
	free(group_option_info->option_info_refs);
	free(group_option_info);
}

void nsxml_rootitem_info_cleanup(struct nsxml_rootitem_info *rootitem_info)
{
	size_t i;
	struct nsxml_option_info *o;
	void *ptr;
	
	for (i = 0; i < rootitem_info->option_info_count; ++i)
	{
		ptr = rootitem_info->option_infos[i];
		o = rootitem_info->option_infos[i];
		
		switch (o->option_type)
		{
			case nsxml_option_type_switch:
			{
				nsxml_switch_option_info_free((struct nsxml_switch_option_info *) ptr);
			}
			break;
			
			case nsxml_option_type_argument:
			{
				nsxml_argument_option_info_free((struct nsxml_argument_option_info *) ptr);
			}
			break;
			
			case nsxml_option_type_multiargument:
			{
				nsxml_multiargument_option_info_free((struct nsxml_multiargument_option_info *) ptr);
			}
			break;
			
			case nsxml_option_type_group:
			{
				nsxml_group_option_info_free((struct nsxml_group_option_info *) ptr);
			}
			break;
			
			default:
			{
			}
			break;
		}
	}
	
	free(rootitem_info->option_infos);
	
	for (i = 0; i < rootitem_info->positional_argument_info_count; ++i)
	{
		nsxml_positional_argument_info_cleanup(&rootitem_info->positional_argument_infos[i]);
	}
	
	free(rootitem_info->positional_argument_infos);
	
	nsxml_item_info_cleanup(&rootitem_info->item_info);
	
	rootitem_info->option_infos = NULL;
}

void nsxml_subcommand_info_cleanup(struct nsxml_subcommand_info *subcommand_info)
{
	nsxml_rootitem_info_cleanup(&subcommand_info->rootitem_info);
	nsxml_item_name_free(subcommand_info->names);
	subcommand_info->names = NULL;
}

void nsxml_program_info_cleanup(struct nsxml_program_info *info)
{
	size_t i;
	nsxml_rootitem_info_cleanup(&info->rootitem_info);
	
	for (i = 0; i < info->subcommand_info_count; ++i)
	{
		nsxml_subcommand_info_cleanup(&(info->subcommand_infos[i]));
	}
	
	free(info->subcommand_infos);
	info->subcommand_infos = NULL;
}

void nsxml_program_info_free(struct nsxml_program_info *info)
{
	nsxml_program_info_cleanup(info);
	free(info);
}

/* Option argument or positional argument value ***/

/* Hidden API declarations */

]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *nsxml_value_new(int, const char *);
void nsxml_value_init(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *);
void nsxml_value_set(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *item, int value_type, const char *value);
void nsxml_value_append(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ **list, int type, const char *value);
void nsxml_value_cleanup(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *single_value);
void nsxml_value_free(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *list);
int nsxml_argument_type_to_value_type(int argument_type);

/* Declarations */

]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *nsxml_value_new(int type, const char *argv)
{
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *value = (]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *) malloc(sizeof(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[));
	nsxml_value_init(value);
	value->type = type;
	nsxml_value_set(value, type, argv);
	return value;
}

void nsxml_value_init(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *value)
{
	value->type = ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_unset"/><![CDATA[;
	value->string_value = NULL;
	value->next_value = NULL;
	value->int_value = 0;
	value->float_value = 0.F;
}

void nsxml_value_set(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *item, int value_type, const char *value)
{
	if (value_type > ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_null"/><![CDATA[)
	{
		item->string_value = value;
	}
	
	if (value_type == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_int"/><![CDATA[)
	{
		if (value)
		{
			item->int_value = (int)(atof(value) + (double) 0.5F);
		}
		else
		{
			item->int_value = 0;
		}
		
		item->float_value = (float) item->int_value;
	}
	
	if (value_type == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_float"/><![CDATA[)
	{
		if (value)
		{
			item->float_value = (float) atof(value);
		}
		else
		{
			item->float_value = 0.F;
		}
		
		item->int_value = (int)(item->float_value + 0.5F);
	}
}

void nsxml_value_append(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ **list, int value_type, const char *value)
{
	if ((*list) == NULL)
	{
		*list = nsxml_value_new(value_type, value);
	}
	else
	{
		]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *item = *list;
		
		while (item->next_value)
		{
			item = item->next_value;
		}
		
		item->next_value = nsxml_value_new(value_type, value);
	}
	
#if 0
	
	if (count == 0)
	{
		nsxml_value_set(list, value_type, value);
	}
	else
	{
		]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *item = list;
		
		while (--count)
		{
			item = item->next_value;
		}
		
		item->next_value = nsxml_value_new(value_type, value);
	}
	
#endif
}

void nsxml_value_cleanup(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *single_value)
{
	single_value->type = ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_unset"/><![CDATA[;
	single_value->string_value = NULL;
	single_value->int_value = 0;
	single_value->float_value = 0.F;
	single_value->next_value = NULL;
}

void nsxml_value_free(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *list)
{
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *next = NULL;
	
	while (list)
	{
		next = list->next_value;
		free(list);
		list = next;
	}
	
#if 0
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *value = 0;
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *next = 0;
	
	start_value->type = ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_unset"/><![CDATA[;
	start_value->string_value = NULL;
	start_value->int_value = 0;
	start_value->float_value = 0;
	
	value = start_value->next_value;
	
	while (value)
	{
		next = value->next_value;
		free(value);
		value = next;
	}
	
	start_value->next_value = NULL;
#endif
}

int nsxml_argument_type_to_value_type(int argument_type)
{
	switch (argument_type)
	{
		case nsxml_argument_type_number:
		{
			return ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_float"/><![CDATA[;
		}
		break;
		
		case nsxml_argument_type_string:
		case nsxml_argument_type_path:
		case nsxml_argument_type_mixed:
		case nsxml_argument_type_hostname:
		case nsxml_argument_type_existingcommand:
		default:
			return ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_string"/><![CDATA[;
	}
}

/* Parser internal state **************************/

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
	/** Processing was aborted by a fatal error */
	nsxml_parser_state_abort = (1 << 2)
};

struct nsxml_parser_state *nsxml_parser_state_new(const struct nsxml_program_info *info, int argc, const char **argv, int start_index)
{
	struct nsxml_parser_state *state = (struct nsxml_parser_state *) malloc(sizeof(struct nsxml_parser_state));
	
	/** Program info */
	state->program_info_ref = info;
	state->option_binding_group_count = 0;
	state->option_binding_counts = NULL;
	state->option_bindings = NULL;
	
	state->subcommand_name_binding_count = 0;
	state->subcommand_name_bindings = NULL;
	
	/** user input */
	state->argc = argc;
	state->argv = argv;
	
	/** Parser state */
	state->arg_index = start_index;
	state->state_flags = 0;
	state->subcommand_index = 0;
	
	state->active_option = NULL;
	state->active_option_cli_name[0] = '\0';
	state->active_option_argc = 0;
	state->active_option_argv = NULL;
	
	if (argc > 0)
	{
		state->active_option_argv = (const char **) malloc(sizeof(char *) * (size_t) state->argc);
	}
	
	state->anonymous_option_result_count = 0;
	state->anonymous_option_results = NULL;
	
	state->value_count = 0;
	state->values = NULL;
	
	return state;
}

void nsxml_parser_state_allocate_name_bindings(struct nsxml_parser_state *state, size_t option_binding_group_count, size_t *option_binding_counts)
{
	size_t i, j;
	state->option_binding_group_count = option_binding_group_count;
	state->option_binding_counts = (size_t *) malloc(sizeof(size_t) * option_binding_group_count);
	
	if (option_binding_group_count > 0)
	{
		state->option_bindings = (struct nsxml_option_binding **) malloc(sizeof(struct nsxml_option_binding *) * option_binding_group_count);
	}
	else
	{
		state->option_bindings = NULL;
	}
	
	for (i = 0; i < option_binding_group_count; ++i)
	{
		state->option_binding_counts[i] = option_binding_counts[i];
		
		if (option_binding_counts[i] > 0)
		{
			state->option_bindings[i] = (struct nsxml_option_binding *) malloc(sizeof(struct nsxml_option_binding) * option_binding_counts[i]);
			
			for (j = 0; j < option_binding_counts[i]; ++j)
			{
				state->option_bindings[i][j].name_ref = NULL;
				state->option_bindings[i][j].info_ref = NULL;
				state->option_bindings[i][j].result_ref = NULL;
				state->option_bindings[i][j].parent_tree_refs = NULL;
			}
		}
		else
		{
			state->option_bindings[i] = NULL;
		}
	}
}

void nsxml_parser_state_free(struct nsxml_parser_state *state)
{
	size_t g, o;
	
	for (g = 0; g < state->option_binding_group_count; ++g)
	{
		for (o = 0; o < state->option_binding_counts[g]; ++o)
		{
			free(state->option_bindings[g][o].parent_tree_refs);
		}
		
		free(state->option_bindings[g]);
	}
	
	free(state->option_binding_counts);
	free(state->option_bindings);
	free(state->active_option_argv);
	free(state->subcommand_name_bindings);
	
	if (state->anonymous_option_result_count > 0)
	{
		for (o = 0; o < state->anonymous_option_result_count; ++o)
		{
			nsxml_option_result_cleanup(state->anonymous_option_results[o]);
			free(state->anonymous_option_results[o]);
		}
		
		free(state->anonymous_option_results);
	}
	
	nsxml_value_free(state->values);
	state->value_count = 0;
	state->values = NULL;
	
	free(state);
}

/* Parser results *********************************/

union nsxml_option_result_group_option_result
{
	struct nsxml_option_result *option;
	struct nsxml_group_option_result *group;
};

void nsxml_program_result_init(void *result_ptr)
{
	struct nsxml_program_result *result = (struct nsxml_program_result *) result_ptr;
	int i;
	
	result->first_message = NULL;
	
	for (i = 0; i < ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/><![CDATA[; ++i)
	{
		result->messages[i] = NULL;
	}
	
	result->subcommand_name = NULL;
	result->value_count = 0;
	result->values = NULL;
}

void nsxml_program_result_cleanup(void *result_ptr)
{
	struct nsxml_program_result *result = (struct nsxml_program_result *) result_ptr;
	int i;
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *msg = 0;
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *next = 0;
	
	msg = result->first_message;
	
	while (msg != 0)
	{
		next = msg->next_message;
		free(msg);
		msg = next;
	}
	
	for (i = 0; i < ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/><![CDATA[; ++i)
	{
		msg = result->messages[i];
		
		while (msg != 0)
		{
			next = msg->next_message;
			free(msg->message);
			free(msg);
			msg = next;
		}
		
		result->messages[i] = 0;
	}
	
	nsxml_value_free(result->values);
	result->value_count = 0;
	result->values = NULL;
}

void nsxml_program_result_free(struct nsxml_program_result *result)
{
	nsxml_program_result_cleanup(result);
	free(result);
}

void nsxml_program_result_add_message(struct nsxml_program_result *result, int type, int code, const char *text)
{
	nsxml_program_result_add_messagef(result, type, code, "%s", text);
}

void nsxml_program_result_add_messagef(struct nsxml_program_result *result, int type, int code, const char *format, ...)
{
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *msg = NULL;
	size_t message_size = (strlen(format) * 2) + 1;
	int printed = 0;
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *msg2;
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *parent;
	va_list list;
#if NSXML_DBG
	va_list dbg;
#endif
	
	if ((type < 0) || (type >= ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_count"/><![CDATA[))
	{
		return;
	}
	
#if NSXML_DBG
	printf("%d: ", type);
	va_start(dbg, format);
	vprintf(format, dbg);
	va_end(dbg);
#endif
	
	msg = (]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *) malloc(sizeof(]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[));
	msg->message = (char *) malloc(sizeof(char) * message_size + 1);
	
	do
	{
		printed = 0;
		va_start(list, format);
		printed += vsnprintf(msg->message, message_size, format, list);
		va_end(list);
		
		if (printed <= 0)
		{
			msg->message[0] = '\0';
			break;
		}
		else if ((size_t)printed >= message_size)
		{
			message_size = (size_t)(printed + 1);
			msg->message = (char *) realloc(msg->message, sizeof(char) * (message_size + 1));
		}
	}
	while (printed == 0);
	
	msg->type = type;
	msg->code = code;
	msg->next_message = NULL;
	
	msg2 = nsxml_message_new_ref(msg);
	parent = 0;
	
	parent = result->messages[type];
	
	if (parent)
	{
		while (parent->next_message)
		{
			parent = parent->next_message;
		}
		
		parent->next_message = msg;
	}
	else
	{
		result->messages[type] = msg;
	}
	
	parent = result->first_message;
	
	if (parent == 0)
	{
		result->first_message = msg2;
	}
	else
	{
		while (parent->next_message)
		{
			parent = parent->next_message;
		}
		
		parent->next_message = msg2;
	}
}

size_t nsxml_program_result_message_count(const struct nsxml_program_result *result, int messagetype_min, int messagetype_max)
{
	int i = messagetype_min;
	int mx = (messagetype_max >= messagetype_min) ? messagetype_max : ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/><![CDATA[;
	size_t c = 0;
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_message"/><![CDATA[ *m;
	
	for (; i <= mx; ++i)
	{
		m = result->messages[i];
		
		while (m)
		{
			++c;
			m = m->next_message;
		}
	}
	
	return c;
}

void nsxml_switch_option_result_init(struct nsxml_switch_option_result *option)
{
	option->is_set = 0;
	option->result_type = nsxml_result_type_switch;
}

void nsxml_argument_option_result_init(struct nsxml_argument_option_result *option)
{
	option->is_set = 0;
	option->result_type = nsxml_result_type_argument;
	nsxml_value_init(&option->argument);
}

void nsxml_multiargument_option_result_init(struct nsxml_multiargument_option_result *option)
{
	option->is_set = 0;
	option->result_type = nsxml_result_type_multiargument;
	option->argument_count = 0;
	option->arguments = NULL;
}

void nsxml_group_option_result_init(struct nsxml_group_option_result *option)
{
	option->is_set = 0;
	option->result_type = nsxml_result_type_group;
	option->selected_option = NULL;
	option->selected_option_name = NULL;
}

void nsxml_option_result_cleanup(void *option_result_ptr)
{
	struct nsxml_option_result *option_result = (struct nsxml_option_result *) option_result_ptr;
	
	if (!option_result)
	{
		return;
	}
	
	switch (option_result->result_type)
	{
		case nsxml_result_type_switch:
		{
		
		}
		break;
		
		case nsxml_result_type_argument:
		{
			struct nsxml_argument_option_result *a = (struct nsxml_argument_option_result *)(option_result_ptr);
			nsxml_value_cleanup(&a->argument);
		}
		break;
		
		case nsxml_result_type_multiargument:
		{
			struct nsxml_multiargument_option_result *ma = (struct nsxml_multiargument_option_result *)(option_result_ptr);
			nsxml_value_free(ma->arguments);
			ma->arguments = NULL;
			ma->argument_count = 0;
		}
		break;
		
		case nsxml_result_type_group:
		{
			/*
			 * Not really needed ^^
			 struct nsxml_group_option_result * g = (struct nsxml_group_option_result *)(option_result_ptr);
			 g->selected_option = NULL;
			 g->selected_option_name = NULL;
			 */
		}
		break;
		
		default:
		{
		}
		break;
	}
}

/* Usage Functions *******************************/

/* Hidden API declarations */
const char *nsxml_usage_get_first_short_name(const struct nsxml_option_info *option_info);
const char *nsxml_usage_get_first_long_name(const struct nsxml_option_info *option_info);
const char *nsxml_usage_option_argument_type_string(int argument_type);
const char *nsxml_usage_path_type_string(int fs_type);
size_t nsxml_usage_path_type_count(int fs_type);
const char *nsxml_usage_path_access_string(int fs_access);
size_t nsxml_usage_path_access_count(int fs_);
size_t nsxml_usage_option_argument_type(char **text_buffer_ptr, size_t *text_buffer_length_ptr, size_t offset, int argumenttype, int short_name);
size_t nsxml_usage_option_inline_details(char **text_buffer_ptr, size_t *text_buffer_length_ptr, size_t offset, const struct nsxml_option_info *info, int short_name);
void nsxml_usage_option_root_short(char **text_buffer_ptr, size_t *text_buffer_length_ptr, size_t text_length, const struct nsxml_rootitem_info *info, int info_index, int *visited);
void nsxml_usage_option_root_detailed(FILE *stream, const struct nsxml_rootitem_info *info, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, char **text_buffer_ptr, size_t *text_buffer_length_ptr);
void nsxml_usage_option_detailed(FILE *stream, const struct nsxml_option_info *info, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, size_t level, char **text_buffer_ptr, size_t *text_buffer_length_ptr);
void nsxml_usage_positional_argument_detailed(FILE *stream, const struct nsxml_positional_argument_info *info, size_t index, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, size_t level, char **text_buffer_ptr, size_t *text_buffer_length_ptr);

/* Validator usage definitions */

size_t nsxml_value_validator_usage_path(const void *self, struct nsxml_validated_item *item, char **output, size_t *output_length)
{
	const struct nsxml_value_validator *validator = (const struct nsxml_value_validator *) self;
	int f;
	char text_buffer[256]; /* enough for everything */
	char *t = text_buffer;
	int tc = 0;
	size_t tr = 255;
	size_t path_type_count = nsxml_usage_path_type_count(validator->flags);
	size_t path_access_count = nsxml_usage_path_access_count(validator->flags);
	(void)item;
	
	if (path_type_count > 0)
	{
		size_t i = 0;
		tc = snprintf(t, tr, "%s", "Expected path type: ");
		tr -= (size_t) tc;
		t += tc;
		
		for (f = nsxml_value_validator_path_type_file; f <= nsxml_value_validator_path_type_symlink; f = (f << 1))
		{
			if (validator->flags & f)
			{
				if (i == 0)
				{
					if (path_type_count == 1)
					{
						tc = snprintf(t, tr, "%s\n", nsxml_usage_path_type_string(f));
					}
					else
					{
						tc = snprintf(t, tr, "%s", nsxml_usage_path_type_string(f));
					}
				}
				else if ((i + 1) == path_type_count)
				{
					tc = snprintf(t, tr, " or %s\n", nsxml_usage_path_type_string(f));
				}
				else
				{
					tc += snprintf(t, tr, ", %s", nsxml_usage_path_type_string(f));
				}
				
				++i;
				tr -= (size_t) tc;
				t += tc;
			}
		}
	}
	
	if (path_access_count > 0)
	{
		size_t i = 0;
		tc = snprintf(t, tr, "%s", "Path argument must be ");
		tr -= (size_t) tc;
		t += tc;
		
		for (f = nsxml_value_validator_path_readable; f <= nsxml_value_validator_path_executable; f = (f << 1))
		{
			if (validator->flags & f)
			{
				if (i == 0)
				{
					if (path_access_count == 1)
					{
						tc = snprintf(t, tr, "%s\n", nsxml_usage_path_access_string(f));
					}
					else
					{
						tc = snprintf(t, tr, "%s", nsxml_usage_path_access_string(f));
					}
				}
				else if ((i + 1) == path_access_count)
				{
					tc = snprintf(t, tr, " and %s\n", nsxml_usage_path_access_string(f));
				}
				else
				{
					tc += snprintf(t, tr, ", %s", nsxml_usage_path_access_string(f));
				}
				
				++i;
				tr -= (size_t) tc;
				t += tc;
			}
		}
	}
	
	if ((path_access_count + path_type_count) > 0)
	{
		return ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, "%s", text_buffer);
	}
	
	return 0;
}

size_t nsxml_value_validator_usage_number(const void *self, struct nsxml_validated_item *item, char **output, size_t *output_length)
{
	const struct nsxml_value_validator_number *nvalidator = (const struct nsxml_value_validator_number *) self;
	int min_and_max = (nsxml_value_validator_checkmin | nsxml_value_validator_checkmax);
	size_t printed = 0;
#	define message_format_buffer_length 64
	char message_format[message_format_buffer_length];
	(void) item;
	
	if ((nvalidator->validator.flags & min_and_max) == min_and_max)
	{
		if (nvalidator->decimal_count > 0)
		{
			snprintf(message_format, (size_t)message_format_buffer_length, "Argument value must be between %%.%df and %%.%df", (int) nvalidator->decimal_count, (int) nvalidator->decimal_count);
			printed = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, message_format, (double) nvalidator->min_value, (double) nvalidator->max_value);
		}
		else
		{
			strncpy(message_format, "Argument value must be between %d and %d", (size_t)message_format_buffer_length);
			printed = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, message_format, (int) nvalidator->min_value, (int) nvalidator->max_value);
		}
	}
	else if (nvalidator->validator.flags & nsxml_value_validator_checkmin)
	{
		if (nvalidator->decimal_count > 0)
		{
			snprintf(message_format, (size_t)message_format_buffer_length, "Argument value must be greater or equal to %%.%df", (int) nvalidator->decimal_count);
			printed = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, message_format, (double) nvalidator->min_value);
		}
		else
		{
			strncpy(message_format, "Argument value must be greater or equal %d", (size_t) message_format_buffer_length);
			printed = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, message_format, (int) nvalidator->min_value);
		}
	}
	else if (nvalidator->validator.flags & nsxml_value_validator_checkmax)
	{
		if (nvalidator->decimal_count > 0)
		{
			snprintf(message_format, (size_t)message_format_buffer_length, "Argument value must be lesser or equal to %%.%df", (int) nvalidator->decimal_count);
			printed = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, message_format, (double) nvalidator->max_value);
		}
		else
		{
			strncpy(message_format, "Argument value must be lesser or equal %d", (size_t) message_format_buffer_length);
			printed = ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(output, output_length, (size_t)0, message_format, (int) nvalidator->max_value);
		}
	}
	
#	undef message_format_buffer_length
	
	return printed;
}

size_t nsxml_value_validator_usage_enum(const void *self, struct nsxml_validated_item *item, char **output, size_t *output_length)
{
	const struct nsxml_value_validator_enum *evalidator = (const struct nsxml_value_validator_enum *) self;
	static const char *kPrefixedText[2] =
	{ "Possible values: ", "Expected values: " };
	int prefix_index = 0;
	(void) item;
	
	if (evalidator->validator.flags & nsxml_value_validator_enum_strict)
	{
		prefix_index = 1;
	}
	
	return nsxml_item_name_snprintf(evalidator->values, output, output_length, kPrefixedText[prefix_index]);
}

/* Definitions */

const char *nsxml_usage_get_first_short_name(const struct nsxml_option_info *option_info)
{
	const struct nsxml_item_name *name = option_info->names;
	
	for (; name; name = name->next_name)
	{
		if (strlen(name->name) == 1)
		{
			return name->name;
		}
	}
	
	return NULL;
}

const char *nsxml_usage_get_first_long_name(const struct nsxml_option_info *option_info)
{
	const struct nsxml_item_name *name = option_info->names;
	
	for (; name; name = name->next_name)
	{
		if (strlen(name->name) > 1)
		{
			return name->name;
		}
	}
	
	return NULL;
}

const char *nsxml_usage_option_argument_type_string(int argument_type)
{
	switch (argument_type)
	{
		case nsxml_argument_type_existingcommand:
			return ("command");
			
		case nsxml_argument_type_hostname:
			return ("hostname");
			
		case nsxml_argument_type_number:
			return ("number");
			
		case nsxml_argument_type_path:
			return ("path");
			
		case nsxml_argument_type_string:
			return ("string");
			
		default:
			return ("?");
	}
	
	return ("?");
}

size_t nsxml_usage_path_type_count(int fs_type)
{
	size_t c = 0;
	
	if ((fs_type & nsxml_value_validator_path_type_all) == nsxml_value_validator_path_type_all)
	{
		return 0;
	}
	
	if ((fs_type & nsxml_value_validator_path_type_file) == nsxml_value_validator_path_type_file)
	{
		++c;
	}
	
	if ((fs_type & nsxml_value_validator_path_type_folder) == nsxml_value_validator_path_type_folder)
	{
		++c;
	}
	
	if ((fs_type & nsxml_value_validator_path_type_symlink) == nsxml_value_validator_path_type_symlink)
	{
		++c;
	}
	
	return c;
}

const char *nsxml_usage_path_type_string(int fs_type)
{
	if ((fs_type & nsxml_value_validator_path_type_file) == nsxml_value_validator_path_type_file)
	{
		return ("file");
	}
	
	if ((fs_type & nsxml_value_validator_path_type_folder) == nsxml_value_validator_path_type_folder)
	{
		return ("folder");
	}
	
	if ((fs_type & nsxml_value_validator_path_type_symlink) == nsxml_value_validator_path_type_symlink)
	{
		return ("symbolic link");
	}
	
	return ("?");
}

size_t nsxml_usage_path_access_count(int fs_access)
{
	size_t c = 0;
	
	if (fs_access & nsxml_value_validator_path_readable)
	{
		++c;
	}
	
	if (fs_access & nsxml_value_validator_path_writable)
	{
		++c;
	}
	
	if (fs_access & nsxml_value_validator_path_executable)
	{
		++c;
	}
	
	return c;
}

const char *nsxml_usage_path_access_string(int fs_access)
{
	if (fs_access & nsxml_value_validator_path_readable)
	{
		return ("readable");
	}
	
	if (fs_access & nsxml_value_validator_path_writable)
	{
		return ("writable");
	}
	
	if (fs_access & nsxml_value_validator_path_executable)
	{
		return ("executable");
	}
	
	return ("?");
}

size_t nsxml_usage_option_argument_type(char **text_buffer_ptr, size_t *text_buffer_length_ptr, size_t offset, int argument_type, int short_name)
{
	size_t printed = 0;
	
	if (short_name == 1)
	{
		printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, " <");
	}
	else
	{
		printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "=");
	}
	
	switch (argument_type)
	{
		case nsxml_argument_type_existingcommand:
			printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "command");
			break;
			
		case nsxml_argument_type_hostname:
			printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "hostname");
			break;
			
		case nsxml_argument_type_number:
			printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "number");
			break;
			
		case nsxml_argument_type_path:
			printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "path");
			break;
			
		case nsxml_argument_type_string:
			printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "string");
			break;
			
		default:
			printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, "...");
			break;
	}
	
	if (short_name == 1)
	{
		printed += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, offset + printed, ">");
	}
	
	return printed;
}

size_t nsxml_usage_option_inline_details(char **text_buffer_ptr, size_t *text_buffer_length_ptr, size_t offset, const struct nsxml_option_info *info, int short_name)
{
	size_t printed = 0;
	const void *ptr = info;
	
	if (info->option_type == nsxml_option_type_argument)
	{
		printed += nsxml_usage_option_argument_type(text_buffer_ptr, text_buffer_length_ptr, offset, ((const struct nsxml_argument_option_info *)(ptr))->argument_type, short_name);
	}
	else if (info->option_type == nsxml_option_type_multiargument)
	{
		/**
		 * @todo
		 */
	}
	
	return printed;
}

void nsxml_usage_subcommand_short(FILE *stream, const struct nsxml_subcommand_info *info, int format, size_t level, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, char **text_buffer_ptr, size_t *text_buffer_length_ptr);
void nsxml_usage_subcommand_short(FILE *stream, const struct nsxml_subcommand_info *info, int format, size_t level, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, char **text_buffer_ptr, size_t *text_buffer_length_ptr)
{
	/**
	 * name, aliases: Abstract
	 * 	Options: short form options
	 */
	
	size_t text_length = 0;
	struct nsxml_item_name *n;
	
	for (n = info->names; n; n = n->next_name)
	{
		if (text_length > 0)
		{
			text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, ", ");
		}
		
		text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, n->name);
	}
	
	if ((format & ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_abstract"/><![CDATA[) == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_abstract"/><![CDATA[)
	{
		if (info->rootitem_info.item_info.abstract)
		{
			text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, ": ");
			text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, info->rootitem_info.item_info.abstract);
		}
	}
	
	]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level);
	
	text_length = 0;
	
	if (info->rootitem_info.option_info_count > 0)
	{
		size_t c = info->rootitem_info.option_info_count;
		size_t a;
		int *visited = (int *) malloc(sizeof(int) * c);
		
		for (a = 0; a < c; ++a)
		{
			visited[a] = 0;
		}
		
		text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "Options:");
		nsxml_usage_option_root_short(text_buffer_ptr, text_buffer_length_ptr, text_length, &info->rootitem_info, -1, visited);
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
		
		free(visited);
	}
}

void nsxml_usage_option_root_short(char **text_buffer_ptr, size_t *text_buffer_length_ptr, size_t text_length, const struct nsxml_rootitem_info *info, int info_index, int *visited)
{
	int is_first = 1;
	size_t i;
	size_t c = info->option_info_count;
	size_t pac = info->positional_argument_info_count;
	const char *n;
	const struct nsxml_group_option_info *parent = NULL;
	const void *ptr;
	
	if (info_index >= 0)
	{
		ptr = info->option_infos[info_index];
		parent = (const struct nsxml_group_option_info *) ptr;
	}
	
	/* First pass, switch options with short names */
	if (!(parent && (parent->group_type == nsxml_group_option_exclusive)))
	{
		for (i = 0; i < c; ++i)
		{
			const struct nsxml_option_info *o = info->option_infos[i];
			
			if ((visited[i] == 0) && (o->parent == parent) && (o->option_type == nsxml_option_type_switch))
			{
				n = nsxml_usage_get_first_short_name(o);
				
				if (n)
				{
					visited[i] = 1;
					
					if (is_first == 1)
					{
						text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "-%s", n);
						is_first = 0;
					}
					else
					{
						text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "%s", n);
					}
				}
			}
		}
	}
	
	/* Other options */
	for (i = 0; i < c; ++i)
	{
		const struct nsxml_option_info *o = info->option_infos[i];
		
		if ((visited[i] == 0) && (o->parent == parent))
		{
			if (is_first == 0)
			{
				if (parent && (parent->group_type == nsxml_group_option_exclusive))
				{
					text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, " | ");
				}
				else
				{
					text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, " ");
				}
			}
			
			is_first = 0;
			visited[i] = 1;
			n = nsxml_usage_get_first_short_name(o);
			
			if (n)
			{
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "-%s", n);
				text_length += nsxml_usage_option_inline_details(text_buffer_ptr, text_buffer_length_ptr, text_length, o, 1);
			}
			else if ((n = nsxml_usage_get_first_long_name(o)) != NULL)
			{
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "--%s", n);
				text_length += nsxml_usage_option_inline_details(text_buffer_ptr, text_buffer_length_ptr, text_length, o, 0);
			}
			else if (o->option_type == nsxml_option_type_group)
			{
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "(");
				nsxml_usage_option_root_short(text_buffer_ptr, text_buffer_length_ptr, text_length, info, (int) i, visited);
				text_length = strlen(*text_buffer_ptr);
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, ")");
			}
		}
	}
	
	/* Positional arguments */
	if (info_index == -1)
	{
		const struct nsxml_positional_argument_info *pai;
		
		for (i = 0; i < pac; ++i)
		{
			pai = &info->positional_argument_infos[i];
			
			text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length,
			                                 ((pai->positional_argument_flags & nsxml_positional_argument_required) ? " <" : " ["));
			                                 
			if (pai->item_info.abstract)
			{
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, pai->item_info.abstract);
			}
			else
			{
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, "arg %d", (int)(i + 1));
			}
			
			if (pai->max_argument != 1)
			{
				text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length, " ...");
			}
			
			text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, text_length,
			                                 ((pai->positional_argument_flags & nsxml_positional_argument_required) ? ">" : "]"));
		}
	}
}

void nsxml_usage_option_detailed(FILE *stream, const struct nsxml_option_info *info, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, size_t level, char **text_buffer_ptr, size_t *text_buffer_length_ptr)
{
	size_t i;
	/* Option names */
	size_t names_length = 0;
	size_t name_count = 0;
	size_t abstract_length = 0;
	const struct nsxml_item_name *n = info->names;
	struct nsxml_value_validator *v;
	char *text_ptr;
	struct nsxml_validated_item validated_item;
	struct nsxml_option_binding validated_option_binding;
	
	validated_item.item_type = nsxml_item_type_option;
	validated_item.item.binding = &validated_option_binding;
	validated_option_binding.name_ref = NULL;
	validated_option_binding.result_ref = NULL;
	
	/**
	 * @todo use asnprintf
	 */
	
	while (n)
	{
		if (n->name)
		{
			names_length += strlen(n->name);
			names_length += (strlen(n->name) > 1) ? 2 : 1;
			++name_count;
		}
		
		n = n->next_name;
	}
	
	abstract_length = names_length + name_count; /* names + spaces */
	
	if (info->item_info.abstract)
	{
		abstract_length += strlen(info->item_info.abstract) + 2; /* names + ": " + abstract */
	}
	
	abstract_length += 2; /* \n and \0 */
	
	if (abstract_length > *text_buffer_length_ptr)
	{
		*text_buffer_ptr = (char *) realloc(*text_buffer_ptr, abstract_length);
		*text_buffer_length_ptr = abstract_length;
	}
	
	text_ptr = *text_buffer_ptr;
	
	if (names_length > 0)
	{
		int c = 0;
		size_t t = 0;
		n = info->names;
		
		while (n)
		{
			if (n->name)
			{
				if (t == 0)
				{
					c = snprintf(text_ptr, (*text_buffer_length_ptr - t), "%s%s", ((strlen(n->name) > 1) ? "--" : "-"), n->name);
					
				}
				else
				{
					c = snprintf(text_ptr, *text_buffer_length_ptr - t, " %s%s", ((strlen(n->name) > 1) ? "--" : "-"), n->name);
				}
				
				t += (size_t) c;
				text_ptr += c;
			}
			
			n = n->next_name;
		}
		
		if (info->item_info.abstract)
		{
			text_ptr += snprintf(text_ptr, *text_buffer_length_ptr - t, ": %s\n", info->item_info.abstract);
		}
	}
	else if (info->item_info.abstract)
	{
		text_ptr += snprintf(text_ptr, *text_buffer_length_ptr, "%s\n", info->item_info.abstract);
	}
	
	*text_ptr = '\0';
	
	]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level);
	
	if (info->item_info.details && (format & ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_details"/><![CDATA[) == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_details"/><![CDATA[)
	{
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, info->item_info.details, wrap, level + 1);
	}
	
	if (info->option_type == nsxml_option_type_argument)
	{
		const void *ptr = info;
		const struct nsxml_argument_option_info *a = (const struct nsxml_argument_option_info *) ptr;
		
		if (a->argument_type > nsxml_argument_type_mixed)
		{
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, (size_t)0, "Argument type: %s\n", nsxml_usage_option_argument_type_string(a->argument_type));
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
		}
		
		if (a->default_value && (*a->default_value != '\0'))
		{
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, (size_t)0, "Default value: %s\n", a->default_value);
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
		}
	}
	
	if (info->option_type == nsxml_option_type_multiargument)
	{
		const void *ptr = info;
		const struct nsxml_multiargument_option_info *m = (const struct nsxml_multiargument_option_info *) ptr;
		
		if (m->argument_type > nsxml_argument_type_mixed)
		{
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, (size_t)0, "Arguments type: %s\n", nsxml_usage_option_argument_type_string(m->argument_type));
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
		}
		
		if (m->min_argument > 0)
		{
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, (size_t)0, "Minimum number of arguments: %d\n", m->min_argument);
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
		}
		
		if (m->max_argument > 0)
		{
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, (size_t)0, "Maximum number of arguments: %d\n", m->max_argument);
			]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
		}
	}
	
	v = info->validators;
	
	while (v)
	{
		if (v->usage_callback)
		{
			validated_option_binding.info_ref = info;
			
			if ((*v->usage_callback)(v, &validated_item, text_buffer_ptr, text_buffer_length_ptr) > 0)
			{
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
			}
		}
		
		v = v->next_validator;
	}
	
	if (info->option_type == nsxml_option_type_group)
	{
		const void *ptr = info;
		const struct nsxml_group_option_info *g = (const struct nsxml_group_option_info *) ptr;
		
		for (i = 0; i < g->option_info_count; ++i)
		{
			nsxml_usage_option_detailed(stream, g->option_info_refs[i], format, wrap, level + 1, text_buffer_ptr, text_buffer_length_ptr);
		}
	}
}

void nsxml_usage_positional_argument_detailed(FILE *stream, const struct nsxml_positional_argument_info *info, size_t index, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, size_t level, char **text_buffer_ptr, size_t *text_buffer_length_ptr)
{
	size_t abstract_length;
	char *text_ptr;
	struct nsxml_value_validator *v;
	
	struct nsxml_validated_item validated_item;
	
	validated_item.item_type = nsxml_item_type_positional_argument;
	validated_item.item.positional_argument_number = index;
	
	abstract_length = nsxml_util_digit_count_s(index + 1) + 1; /* n. */
	
	if (info->item_info.abstract)
	{
		abstract_length += 1 + strlen(info->item_info.abstract); /* #. + ' ' + abstract */
	}
	
	abstract_length += 2; /* \n and \0 */
	
	/* Positional argument number & abstract */
	text_ptr = *text_buffer_ptr;
	
	if (info->item_info.abstract)
	{
		text_ptr += snprintf(*text_buffer_ptr, *text_buffer_length_ptr, "%" NSXML_SIZET_FORMAT ". %s\n", NSXML_SIZET_FORMAT_CAST(index + 1), info->item_info.abstract);
	}
	else
	{
		text_ptr += snprintf(*text_buffer_ptr, *text_buffer_length_ptr, "%" NSXML_SIZET_FORMAT ".\n", NSXML_SIZET_FORMAT_CAST(index + 1));
	}
	
	*text_ptr = '\0';
	
	]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level);
	
	/* details */
	if (info->item_info.details && (format & ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_details"/><![CDATA[) == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_details"/><![CDATA[)
	{
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, info->item_info.details, wrap, level + 1);
	}
	
	/* Argument infos */
	if (info->argument_type > nsxml_argument_type_mixed)
	{
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(text_buffer_ptr, text_buffer_length_ptr, (size_t)0, "Argument type: %s\n", nsxml_usage_option_argument_type_string(info->argument_type));
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
	}
	
	v = info->validators;
	
	while (v)
	{
		if (v->usage_callback)
		{
			if ((*v->usage_callback)(v, &validated_item, text_buffer_ptr, text_buffer_length_ptr) > 0)
			{
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, *text_buffer_ptr, wrap, level + 1);
			}
		}
		
		v = v->next_validator;
	}
	
}

void nsxml_usage_option_root_detailed(FILE *stream, const struct nsxml_rootitem_info *info, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap, char **text_buffer_ptr, size_t *text_buffer_length_ptr)
{
	size_t i;
	
	for (i = 0; i < info->option_info_count; ++i)
	{
		const struct nsxml_option_info *o = info->option_infos[i];
		
		if (!o->parent)
		{
			nsxml_usage_option_detailed(stream, o, format, wrap, (size_t)2, text_buffer_ptr, text_buffer_length_ptr);
		}
	}
}

void nsxml_usage(FILE *stream, const struct nsxml_program_info *info, struct nsxml_program_result *result, int format, const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *user_wrap)
{
	size_t i;
	size_t option_count = info->rootitem_info.option_info_count;
	int *visited = (int *) malloc(sizeof(int) * option_count);
	struct nsxml_subcommand_info *scinfo = NULL;
	const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ *wrap;
	size_t text_length = 0;
	size_t text_buffer_length = NSXML_TEXTBUFFER_BASESIZE;
	char *text_buffer = (char *) malloc(sizeof(char) * text_buffer_length);
	]]><xsl:value-of select="$prg.c.parser.structName.nsxml_util_text_wrap_options"/><![CDATA[ default_wrap;
	]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_options_init"/><![CDATA[(&default_wrap, (size_t)2, (size_t)80, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_indent_others"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_util_text_wrap_eol_lf"/><![CDATA[);
	wrap = user_wrap;
	
	if (!user_wrap)
	{
		wrap = &default_wrap;
	}
	
	for (i = 0; i < option_count; ++i)
	{
		visited[i] = 0;
	}
	
	if (result && result->subcommand_name)
	{
		for (i = 0; i < info->subcommand_info_count; ++i)
		{
			if (strcmp(result->subcommand_name, info->subcommand_infos[i].names->name) == 0)
			{
				scinfo = &info->subcommand_infos[i];
				break;
			}
		}
	}
	
	text_length = 0;
	text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_append"/><![CDATA[(&text_buffer, &text_buffer_length, text_length, "Usage: ");
	
	if (scinfo)
	{
		size_t c = scinfo->rootitem_info.option_info_count;
		text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(&text_buffer, &text_buffer_length, text_length, "%s %s%s", info->name, result->subcommand_name, (c ? " " : ""));
		nsxml_usage_option_root_short(&text_buffer, &text_buffer_length, strlen(text_buffer), &scinfo->rootitem_info, -1, visited);
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, text_buffer, wrap, (size_t)0);
	}
	else
	{
		size_t c = info->rootitem_info.option_info_count;
		text_length += ]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_asnprintf"/><![CDATA[(&text_buffer, &text_buffer_length, text_length, "%s%s%s", info->name, (info->subcommand_info_count ? " [subcommand name]" : ""), (c ? " " : ""));
		nsxml_usage_option_root_short(&text_buffer, &text_buffer_length, strlen(text_buffer), &info->rootitem_info, -1, visited);
		]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, text_buffer, wrap, (size_t)0);
	}
	
	if ((format & ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_abstract"/><![CDATA[) == ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_usage_format_abstract"/><![CDATA[)
	{
		if (scinfo) /* Selected subcommand */
		{
			if (scinfo->rootitem_info.option_info_count)
			{
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, "Subcommand options:", wrap, (size_t)1);
				nsxml_usage_option_root_detailed(stream, &scinfo->rootitem_info, format, wrap, &text_buffer, &text_buffer_length);
			}
			
			if (info->rootitem_info.option_info_count)
			{
				if (scinfo->rootitem_info.option_info_count)
				{
					fprintf(stream, "%s", wrap->eol);
				}
				
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, "Program options:", wrap, (size_t)1);
				nsxml_usage_option_root_detailed(stream, &info->rootitem_info, format, wrap, &text_buffer, &text_buffer_length);
			}
		}
		else /* Main program */
		{
			if (info->subcommand_info_count > 0)
			{
				size_t a;
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, "Subcommands:", wrap, (size_t)1);
				
				for (a = 0; a < info->subcommand_info_count; ++a)
				{
					nsxml_usage_subcommand_short(stream, &info->subcommand_infos[a], format, (size_t)2, wrap, &text_buffer, &text_buffer_length);
				}
			}
			
			if (info->rootitem_info.option_info_count)
			{
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, "\nOptions:", wrap, (size_t)0);
				nsxml_usage_option_root_detailed(stream, &info->rootitem_info, format, wrap, &text_buffer, &text_buffer_length);
			}
		}
		
		/* Positional arguments */
		{
			const struct nsxml_rootitem_info *rootinfo = &info->rootitem_info;
			size_t pac;
			const struct nsxml_positional_argument_info *pai;
			
			if (scinfo)
			{
				rootinfo = &scinfo->rootitem_info;
			}
			
			pac = rootinfo->positional_argument_info_count;
			
			if (pac)
			{
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_text_wrap_fprint"/><![CDATA[(stream, "\nPositional arguments:", wrap, (size_t)0);
				
				for (i = 0; i < pac; ++i)
				{
					pai = &rootinfo->positional_argument_infos[i];
					nsxml_usage_positional_argument_detailed(stream, pai, i, format, wrap, (size_t)1, &text_buffer, &text_buffer_length);
				}
			}
		}
	}
	
	free(text_buffer);
	free(visited);
	fprintf(stream, "%s\n", "");
}

/* Parser Functions ******************************/

/* Hidden API declarations */

struct nsxml_option_binding *nsxml_parse_find_option_at(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *name, int group_index);
struct nsxml_option_binding *nsxml_parse_find_option(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *name);
int nsxml_parse_argument_validates(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value);
int nsxml_parse_positional_argument_validates(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_positional_argument_info *info, size_t positional_argument_number, const char *value);
int nsxml_parse_option_expected(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_option_binding *option);
int nsxml_parse_option_required(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_option_binding *option);
void nsxml_parse_mark_option(struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_binding *option, int is_set);
void nsxml_parse_unset_active_option(struct nsxml_parser_state *state, struct nsxml_program_result *result);
int nsxml_parse_active_option_accepts_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result);
void nsxml_parse_append_option_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value);
void nsxml_parse_process_positional_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value);
size_t nsxml_parse_option_postprocess(struct nsxml_parser_state *state, struct nsxml_program_result *result);
size_t nsxml_parse_positional_argument_process(struct nsxml_parser_state *state, struct nsxml_program_result *result);

/* Definitions */

struct nsxml_option_binding *nsxml_parse_find_option_at(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *name, int group_index)
{
	size_t o;
	(void) result;
	
	for (o = 0; o < state->option_binding_counts[group_index]; ++o)
	{
		const char *n = state->option_bindings[group_index][o].name_ref;
		
		if (n == NULL)
		{
			continue;
		}
		
		if (strcmp(n, name) == 0)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Found name %s\n", name);
#endif /* NSXML_DEBUG */
			
			return &state->option_bindings[group_index][o];
		}
	}
	
	return NULL;
}

struct nsxml_option_binding *nsxml_parse_find_option(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *name)
{
	struct nsxml_option_binding *option = NULL;
	
	if (state->subcommand_index > 0)
	{
		option = nsxml_parse_find_option_at(state, result, name, state->subcommand_index);
	}
	
	if (option == NULL)
	{
		option = nsxml_parse_find_option_at(state, result, name, 0);
	}
	
	return option;
}

int nsxml_parse_argument_validates(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value)
{
	struct nsxml_value_validator *validator = state->active_option->info_ref->validators;
	struct nsxml_validated_item item;
	int validates = 1;
	
	item.item_type = nsxml_item_type_option;
	item.item.binding = state->active_option;
	
	while (validator)
	{
		if (validator->validation_callback)
		{
			if ((*validator->validation_callback)(validator, state, result, &item, value) == 0)
			{
				validates = 0;
			}
		}
		
		validator = validator->next_validator;
	}
	
	return validates;
}

int nsxml_parse_positional_argument_validates(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_positional_argument_info *info, size_t positional_argument_number, const char *value)
{
	struct nsxml_value_validator *validator = info->validators;
	struct nsxml_validated_item item;
	int validates = 1;
	
	item.item_type = nsxml_item_type_positional_argument;
	item.item.positional_argument_number = positional_argument_number;
	
	while (validator)
	{
		if (validator->validation_callback)
		{
			if ((*validator->validation_callback)(validator, state, result, &item, value) == 0)
			{
				validates = 0;
			}
		}
		
		validator = validator->next_validator;
	}
	
	return validates;
}

int nsxml_parse_option_expected(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_option_binding *option)
{
	int a;
	(void) result;
	(void) state;
	
	if (option->level > 0)
	{
		const struct nsxml_group_option_info *parent_info = option->info_ref->parent;
		const struct nsxml_option_result *previous_ancestor = (const struct nsxml_option_result *)(option->result_ref);
		
		for (a = 0; a < option->level; ++a)
		{
			const struct nsxml_group_option_result *ancestor_res = option->parent_tree_refs[a];
			const void *ptr = ancestor_res;
			
			if ((parent_info->group_type == nsxml_group_option_exclusive) && (ancestor_res->is_set > 0) && (ancestor_res->selected_option != previous_ancestor))
			{
#if NSXML_DEBUG
				const char *option_name = option->info_ref->names->name;
				const char *ancestor_name = (parent_info->option_info.names) ? parent_info->option_info.names->name : NULL;
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "option %s is unexpected due to exclusive rule of group at level %d (%s)\n", ((option_name) ? option_name : "?"), a, ((ancestor_name) ? ancestor_name : parent_info->option_info.item_info.abstract));
#endif /* NSXML_DEBUG */
				
				return 0;
			}
			
			previous_ancestor = (const struct nsxml_option_result *) ptr;
			parent_info = parent_info->option_info.parent;
		}
	}
	
	return 1;
}

int nsxml_parse_option_required(struct nsxml_parser_state *state, struct nsxml_program_result *result, const struct nsxml_option_binding *option)
{
	int a;
	(void) result;
	(void) state;
	
	if (!(option->info_ref->option_flags & nsxml_option_flag_required))
	{
		return 0;
	}
	
	if (option->level > 0)
	{
		const struct nsxml_group_option_info *parent_info = option->info_ref->parent;
		const struct nsxml_option_result *previous_ancestor = (const struct nsxml_option_result *)(option->result_ref);
		
		for (a = 0; a < option->level; ++a)
		{
			const struct nsxml_group_option_result *ancestor_res = option->parent_tree_refs[a];
			const void *ptr = ancestor_res;
			
			if (parent_info->group_type == nsxml_group_option_exclusive)
			{
				if ((ancestor_res->is_set == 0) || (ancestor_res->selected_option != previous_ancestor))
				{
					return 0;
				}
			}
			
			previous_ancestor = (const struct nsxml_option_result *) ptr;
			parent_info = parent_info->option_info.parent;
		}
	}
	
	return 1;
}

void nsxml_parse_mark_option(struct nsxml_parser_state *state, struct nsxml_program_result *result, struct nsxml_option_binding *option, int is_set)
{
	int p;
	const struct nsxml_option_info *info = option->info_ref;
	const struct nsxml_group_option_info *parent_info = info->parent;
	struct nsxml_option_result *res = option->result_ref;
	union nsxml_option_result_group_option_result child_res;
	union nsxml_option_result_group_option_result parent_res;
	(void) result;
	(void) state;
	res->is_set = (is_set) ? 1 : 0;
	
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Mark option %s: %d (%d)\n", option->info_ref->names->name, is_set, res->is_set);
#endif /* NSXML_DEBUG */
	
	child_res.option = res;
	
	for (p = 0; p < option->level; ++p)
	{
		parent_res.group = option->parent_tree_refs[p];
		parent_res.group->is_set += (is_set) ? 1 : -1;
		
		if (parent_info->group_type == nsxml_group_option_exclusive)
		{
			if (is_set)
			{
				parent_res.group->selected_option = child_res.option;
				parent_res.group->selected_option_name = info->var_name;
			}
		}
		
		if (parent_res.group->is_set == 0)
		{
			parent_res.group->selected_option = NULL;
			parent_res.group->selected_option_name = NULL;
		}
		
		info = &parent_info->option_info;
#if NSXML_DEBUG
		{
			const char *name = (info->var_name) ? info->var_name : ((info->names && info->names->name) ? info->names->name : info->item_info.abstract);
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Mark parent option %s: %d (%d)\n", ((name) ? name : "?"), is_set, parent_res.group->is_set);
		}
#endif /* NSXML_DEBUG */
		
		parent_info = parent_info->option_info.parent;
		child_res.option = (struct nsxml_option_result *) parent_res.option;
	}
}

void nsxml_parse_unset_active_option(struct nsxml_parser_state *state, struct nsxml_program_result *result)
{
	int mark_set = 0;
	size_t a;
	
	if (state->active_option == NULL)
	{
		return;
	}
	
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Unset option %s\n", state->active_option_cli_name);
#endif /* NSXML_DEBUG */
	
	if (state->state_flags & nsxml_parser_state_option_unexpected)
	{
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_unexpected_option"/><![CDATA[, "Unexpected option %s\n", state->active_option_cli_name);
	}
	
	if (state->active_option->info_ref->option_type == nsxml_option_type_switch)
	{
		mark_set = 1;
		
		if (state->active_option_argc > 0)
		{
			if ((state->active_option_argc > 1) || (strlen(state->active_option_argv[0]) > 0))
			{
				mark_set = 0;
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_option_argument_not_allowed"/><![CDATA[, "Option %s does not allow an argument\n", state->active_option_cli_name);
			}
		}
	}
	else if (state->active_option->info_ref->option_type == nsxml_option_type_argument)
	{
		void *res_ptr = state->active_option->result_ref;
		struct nsxml_argument_option_result *res = (struct nsxml_argument_option_result *) res_ptr;
		const void *ainfo_ptr = state->active_option->info_ref;
		const struct nsxml_argument_option_info *ainfo = (const struct nsxml_argument_option_info *) ainfo_ptr;
		
		if (state->active_option_argc > 0)
		{
			if (!(state->state_flags & nsxml_parser_state_option_unexpected) && nsxml_parse_argument_validates(state, result, state->active_option_argv[0]))
			{
				mark_set = 1;
				nsxml_value_set(&res->argument, nsxml_argument_type_to_value_type(ainfo->argument_type), state->active_option_argv[0]);
			}
			else
			{
				nsxml_value_set(&res->argument, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_null"/><![CDATA[, NULL);
			}
		}
		else
		{
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_option_argument"/><![CDATA[, "Missing argument for option %s\n", state->active_option_cli_name);
		}
	}
	else if (state->active_option->info_ref->option_type == nsxml_option_type_multiargument)
	{
		void *res_ptr = state->active_option->result_ref;
		struct nsxml_multiargument_option_result *res = (struct nsxml_multiargument_option_result *) res_ptr;
		const void *ainfo_ptr = state->active_option->info_ref;
		const struct nsxml_multiargument_option_info *ainfo = (const struct nsxml_multiargument_option_info *) ainfo_ptr;
		
		if (state->active_option_argc > 0)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Assigning %d arguments to result\n", state->active_option_argc);
#endif /* NSXML_DEBUG */
			
			for (a = 0; a < state->active_option_argc; ++a)
			{
				if ((ainfo->max_argument > 0) && (res->argument_count >= ainfo->max_argument))
				{
					break;
				}
				
				if (!(state->state_flags & nsxml_parser_state_option_unexpected) && nsxml_parse_argument_validates(state, result, state->active_option_argv[a]))
				{
					mark_set = 1;
					nsxml_value_append(&res->arguments, nsxml_argument_type_to_value_type(ainfo->argument_type), state->active_option_argv[a]);
				}
				else
				{
					/**
					 * Temporary add a dummy arg
					 */
					nsxml_value_append(&res->arguments, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_null"/><![CDATA[, NULL);
				}
				
				++res->argument_count;
			}
		}
		else
		{
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_option_argument"/><![CDATA[, "Missing argument for option %s\n", state->active_option_cli_name);
		}
	}
	
	if (!(state->state_flags & nsxml_parser_state_option_unexpected) && mark_set && state->active_option->result_ref)
	{
		nsxml_parse_mark_option(state, result, state->active_option, 1);
	}
	
	state->active_option_argc = 0;
	state->active_option = NULL;
	state->active_option_cli_name[0] = '\0';
	state->active_option_name = NULL;
	state->state_flags &= ~(nsxml_parser_state_option_unexpected);
}

int nsxml_parse_active_option_accepts_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result)
{
	(void) result;
	
	if (state->active_option->info_ref->option_type == nsxml_option_type_switch)
	{
#if NSXML_DEBUG
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Switch never accepts arguments");
#endif /* NSXML_DEBUG */
		
		return 0;
	}
	
	if (state->active_option->info_ref->option_type == nsxml_option_type_multiargument)
	{
		const void *info_ptr = state->active_option->info_ref;
		const struct nsxml_multiargument_option_info *info = (const struct nsxml_multiargument_option_info *) info_ptr;
		void *res_ptr = state->active_option->result_ref;
		struct nsxml_multiargument_option_result *res = (struct nsxml_multiargument_option_result *) res_ptr;
		
		if ((info->max_argument > 0) && res)
		{
			if ((state->active_option_argc + res->argument_count) >= info->max_argument)
			{
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Multi argument reach its max %d + %d >= %d\n", state->active_option_argc, res->argument_count, info->max_argument);
#endif /* NSXML_DEBUG */
				
				return 0;
			}
		}
	}
	else if (state->active_option->info_ref->option_type == nsxml_option_type_argument)
	{
		if (state->active_option_argc > 0)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "SingleArgument option got its arguments\n");
#endif /* NSXML_DEBUG */
			
			return 0;
		}
	}
	
	return 1;
}

void nsxml_parse_append_option_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value)
{
	(void) result;
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Append '%s' as argument %d of option %s\n", value, state->active_option_argc, state->active_option_cli_name);
#endif /* NSXML_DEBUG */
	
	state->active_option_argv[state->active_option_argc] = value;
	++state->active_option_argc;
}

void nsxml_parse_process_positional_argument(struct nsxml_parser_state *state, struct nsxml_program_result *result, const char *value)
{
	size_t s;
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "treat %s as subcommand or positional argument\n", value);
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, " EOO: %d, sc index: %d, value count: %d\n", (state->state_flags & nsxml_parser_state_endofoptions), state->subcommand_index, state->value_count);
#endif /* NSXML_DEBUG */
	
	if (!(state->state_flags & nsxml_parser_state_endofoptions) && (state->subcommand_index == 0) && (state->value_count == 0))
	{
#if NSXML_DEBUG
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Search for a subcommand name (%d names)\n", (int) state->subcommand_name_binding_count);
#endif /* NSXML_DEBUG */
		
		for (s = 0; s < state->subcommand_name_binding_count; ++s)
		{
			if (strcmp(state->subcommand_name_bindings[s].name_ref, value) == 0)
			{
				state->subcommand_index = state->subcommand_name_bindings[s].subcommand_index;
				result->subcommand_name = state->subcommand_name_bindings[s].info_ref->names->name;
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Found subcommand %d %s -> %s\n", s, value, state->subcommand_name_bindings[s].info_ref->names->name);
#endif /* NSXML_DEBUG */
				
				return;
			}
		}
	}
	
	nsxml_value_append(&state->values, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_value_type_string"/><![CDATA[, value);
	++state->value_count;
}

size_t nsxml_parse_option_postprocess(struct nsxml_parser_state *state, struct nsxml_program_result *result)
{
	size_t g, o;
	size_t mark_change_count = 0;
	
	/**
	 * Post check min_argument in multi-argument
	 * Cleanup values for unset options
	 */
	for (g = 0; g < state->option_binding_group_count; ++g)
	{
		const struct nsxml_option_info *info = NULL;
		
		for (o = 0; o < state->option_binding_counts[g]; ++o)
		{
			struct nsxml_option_binding *binding = &state->option_bindings[g][o];
			const struct nsxml_option_info *i = binding->info_ref;
			
			if (i == info) /* same option, different names */
			{
				continue;
			}
			
			info = i;
			
			if (i->option_type == nsxml_option_type_argument)
			{
				void *res_ptr = binding->result_ref;
				struct nsxml_argument_option_result *res = (struct nsxml_argument_option_result *) res_ptr;
				
				if (res->is_set == 0)
				{
					const void *i_ptr = i;
					const struct nsxml_argument_option_info *ainfo = (const struct nsxml_argument_option_info *) i_ptr;
					
					if (ainfo->default_value && nsxml_parse_option_expected(state, result, binding))
					{
						/**
						 * @todo Validate the default value ?
						 */
#if NSXML_DEBUG
						nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Set default value '%s' for option %s%s\n", ainfo->default_value, (strlen(i->names->name) > 1) ? "--" : "-", i->names->name);
#endif /* NSXML_DEBUG */
						
						nsxml_value_set(&res->argument, nsxml_argument_type_to_value_type(ainfo->argument_type), ainfo->default_value);
						nsxml_parse_mark_option(state, result, binding, 1);
						++mark_change_count;
					}
					else
					{
						nsxml_value_cleanup(&res->argument);
					}
				}
			}
			else if (i->option_type == nsxml_option_type_multiargument)
			{
				const void *i_ptr = i;
				const struct nsxml_multiargument_option_info *mi = (const struct nsxml_multiargument_option_info *) i_ptr;
				void *res_ptr = binding->result_ref;
				struct nsxml_multiargument_option_result *res = (struct nsxml_multiargument_option_result *) res_ptr;
				
				if ((res->is_set == 1) && ((mi->min_argument > 0) && (res->argument_count < mi->min_argument)))
				{
					nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_not_enough_arguments"/><![CDATA[, "At least %d arguments required for %s%s option, got %d\n", mi->min_argument, (strlen(i->names->name) > 1) ? "--" : "-", i->names->name, res->argument_count);
					nsxml_parse_mark_option(state, result, binding, 0);
					++mark_change_count;
				}
				
				if (res->is_set == 0)
				{
					res->argument_count = 0;
					nsxml_value_free(res->arguments);
					res->arguments = NULL;
					res->argument_count = 0;
				}
			}
		}
	}
	
	return mark_change_count;
}

size_t nsxml_parse_positional_argument_process(struct nsxml_parser_state *state, struct nsxml_program_result *result)
{
	size_t i;
	const struct nsxml_rootitem_info *root = &state->program_info_ref->rootitem_info;
	const struct nsxml_positional_argument_info *pai = NULL;
	const ]]><xsl:value-of select="$prg.c.parser.structName.nsxml_value"/><![CDATA[ *v = state->values;
	size_t valid_positional_argument_count = 0;
	size_t positional_argument_number = 1;
	size_t pai_index = 0;
	size_t current_pai_value_count = 0;
	
	if (state->subcommand_index > 0)
	{
		root = &state->program_info_ref->subcommand_infos[state->subcommand_index - 1].rootitem_info;
	}
	
#if NSXML_DEBUG
	nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Positional arguments processing (%d values / %d PA infos)\n", state->value_count, root->positional_argument_info_count);
#endif /* NSXML_DEBUG */
	
	if ((root->positional_argument_info_count == 0) && (state->value_count > 0))
	{
		if (state->subcommand_index > 0)
		{
			nsxml_program_result_add_message(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_subcommand_pa_not_allowed"/><![CDATA[, "Subcommand does not accept positional arguments\n");
		}
		else
		{
			nsxml_program_result_add_message(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_program_pa_not_allowed"/><![CDATA[, "Program does not accept positional arguments\n");
		}
		
		return valid_positional_argument_count;
	}
	
	while (v && (pai_index < root->positional_argument_info_count))
	{
#if NSXML_DEBUG
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Process positional argument %d (%d of PAI %d)\n", positional_argument_number, current_pai_value_count, pai_index);
#endif /* NSXML_DEBUG */
		
		pai = &root->positional_argument_infos[pai_index];
		++current_pai_value_count;
		
		if (nsxml_parse_positional_argument_validates(state, result, pai, positional_argument_number, v->string_value))
		{
			/*
			 * @todo detach/move rather than new copy
			 */
			nsxml_value_append(&result->values, v->type, v->string_value);
			result->value_count++;
			++valid_positional_argument_count;
		}
		else
		{
			/**
			 * @todo continue or abort ?
			 */
		}
		
		if ((pai->max_argument > 0) && (current_pai_value_count >= pai->max_argument))
		{
			current_pai_value_count = 0;
			++pai_index;
		}
		
		v = v->next_value;
		++positional_argument_number;
	}
	
	if (v)
	{
		/**
		 * @todo warning or error ?
		 */
		nsxml_program_result_add_message(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_too_many_pa"/><![CDATA[, "Too many positional arguments\n");
	}
	else if (pai_index < root->positional_argument_info_count)
	{
		/**
		 * @note not yet supported by schema
		 */
		for (i = pai_index; i < root->positional_argument_info_count; ++i)
		{
			if (root->positional_argument_infos[i].positional_argument_flags & nsxml_positional_argument_required)
			{
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_required_pa"/><![CDATA[, "Required positional argument %d is missing\n", i);
			}
		}
	}
	
	return valid_positional_argument_count;
}

void nsxml_parse_core(struct nsxml_parser_state *state, struct nsxml_program_result *result)
{
	int a;
	size_t g, o;
	
	state->active_option_argc = 0;
	state->active_option = NULL;
	state->active_option_cli_name[0] = '\0';
	
	for (a = state->arg_index; a < state->argc; ++a)
	{
#if NSXML_DEBUG
		nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Processing '%s'\n", state->argv[a]);
#endif /* NSXML_DEBUG */
		
		if (state->active_option)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Check current option\n");
#endif /* NSXML_DEBUG */
			
			if (nsxml_parse_active_option_accepts_argument(state, result) == 0)
			{
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "No more arguments accepted\n");
#endif /* NSXML_DEBUG */
				
				nsxml_parse_unset_active_option(state, result);
			}
		}
		
		if (state->state_flags & nsxml_parser_state_endofoptions)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "EOO\n");
#endif /* NSXML_DEBUG */
			
			nsxml_parse_process_positional_argument(state, result, state->argv[a]);
		}
		else if (strcmp(state->argv[a], "--") == 0)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "EOO marker\n");
#endif /* NSXML_DEBUG */
			
			state->state_flags |= nsxml_parser_state_endofoptions;
			nsxml_parse_unset_active_option(state, result);
		}
		else if (strcmp(state->argv[a], "-") == 0)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "EOA marker\n");
#endif /* NSXML_DEBUG */
			
			if (state->active_option)
			{
				if (state->active_option->info_ref->option_type == nsxml_option_type_multiargument)
				{
					if (state->active_option_argc == 0)
					{
						nsxml_program_result_add_message(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_warning"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_warning_ignore_endofarguments"/><![CDATA[, "Ignore end-of-argument marker\n");
						nsxml_parse_append_option_argument(state, result, state->argv[a]);
					}
					else
					{
						nsxml_parse_unset_active_option(state, result);
					}
				}
				else if (state->active_option->info_ref->option_type == nsxml_option_type_argument) /* and accepts arguments which should be true */
				{
					nsxml_parse_append_option_argument(state, result, state->argv[a]);
				}
				
				/* 'switch' case should not happens */
			}
			else
			{
				nsxml_parse_process_positional_argument(state, result, state->argv[a]);
			}
		}
		else if (]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_string_starts_with"/><![CDATA[(state->argv[a], "\\-"))
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Protected value\n");
#endif /* NSXML_DEBUG */
			
			if (state->active_option)
			{
				nsxml_parse_append_option_argument(state, result, (state->argv[a] + 1));
			}
			else
			{
				nsxml_parse_process_positional_argument(state, result, (state->argv[a] + 1));
			}
		}
		else if (state->active_option && state->active_option_argc == 0)
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Always add first argument\n");
#endif /* NSXML_DEBUG */
			
			nsxml_parse_append_option_argument(state, result, state->argv[a]);
		}
		else if (]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_string_starts_with"/><![CDATA[(state->argv[a], "--"))
		{
			const char *tail = strstr(state->argv[a], "=");
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Long option\n");
#endif /* NSXML_DEBUG */
			
			if (state->active_option)
			{
				nsxml_parse_unset_active_option(state, result);
			}
			
			if (tail)
			{
				size_t tail_length = strlen(tail);
				size_t arg_length = strlen(state->argv[a]);
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(state->active_option_cli_name, (size_t)NSXML_OPTION_NAME_BUFFER_LENGTH, state->argv[a], (size_t)(arg_length - tail_length));
				++tail;
			}
			else
			{
				]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_strncpy"/><![CDATA[(state->active_option_cli_name, (size_t)NSXML_OPTION_NAME_BUFFER_LENGTH, state->argv[a], (size_t)strlen(state->argv[a]));
			}
			
			state->active_option_name = state->active_option_cli_name + 2;
			
			state->active_option = nsxml_parse_find_option(state, result, state->active_option_name);
			
			if (state->active_option)
			{
				if (nsxml_parse_option_expected(state, result, state->active_option) == 0)
				{
					state->state_flags |= nsxml_parser_state_option_unexpected;
				}
				
				if (tail)
				{
					nsxml_parse_append_option_argument(state, result, tail);
				}
			}
			else
			{
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_fatal_error_unknown_option"/><![CDATA[,
				                                  NSXML_FATALERROR_UNKNOWN_OPTION_MSGF "\n", state->active_option_cli_name);
				state->state_flags |= nsxml_parser_state_abort;
				state->active_option_cli_name[0] = '\0';
				state->active_option_name = NULL;
				break;
			}
		}
		else if (]]><xsl:value-of select="$prg.c.parser.functionName.nsxml_util_string_starts_with"/><![CDATA[(state->argv[a], "-"))
		{
			const char *current_option = (state->argv[a] + 1);
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Short option\n");
#endif /* NSXML_DEBUG */
			
			if (state->active_option)
			{
				nsxml_parse_unset_active_option(state, result);
			}
			
			while (current_option && (*current_option != '\0'))
			{
#if NSXML_DEBUG
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Sub parsing -%c\n", *current_option);
#endif /* NSXML_DEBUG */
				
				if (state->active_option)
				{
					nsxml_parse_unset_active_option(state, result);
				}
				
				state->active_option_cli_name[0] = '-';
				state->active_option_cli_name[1] = *current_option;
				state->active_option_cli_name[2] = '\0';
				state->active_option_name = state->active_option_cli_name + 1;
				state->active_option = nsxml_parse_find_option(state, result, state->active_option_name);
				
				if (state->active_option)
				{
					if (nsxml_parse_option_expected(state, result, state->active_option) == 0)
					{
						state->state_flags |= nsxml_parser_state_option_unexpected;
					}
					
					if (((state->active_option->info_ref->option_type == nsxml_option_type_argument) || (state->active_option->info_ref->option_type == nsxml_option_type_multiargument)) && (*(current_option + 1) != '\0'))
					{
						nsxml_parse_append_option_argument(state, result, current_option + 1);
						break;
					}
				}
				else
				{
					nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_fatal_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_fatal_error_unknown_option"/><![CDATA[, "Unknown option %s\n", state->active_option_cli_name);
					state->state_flags |= nsxml_parser_state_abort;
					state->active_option_cli_name[0] = '\0';
					state->active_option_name = NULL;
					break;
				}
				
				if (state->state_flags & nsxml_parser_state_abort)
				{
					break;
				}
				
				++current_option;
			}
		}
		else if (state->active_option)
		{
			nsxml_parse_append_option_argument(state, result, state->argv[a]);
		}
		else
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Other\n");
#endif /* NSXML_DEBUG */
			
			nsxml_parse_process_positional_argument(state, result, state->argv[a]);
		}
		
		if (state->state_flags & nsxml_parser_state_abort)
		{
			break;
		}
		
		++state->arg_index;
	}
	
	if (state->active_option)
	{
		nsxml_parse_unset_active_option(state, result);
	}
	
	/**
	 * Post processing options
	 */
	{
		size_t change_count = 0;
		int pass = 0;
		
		do
		{
#if NSXML_DEBUG
			nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Post process pass %d\n", pass);
#endif /* NSXML_DEBUG */
			
			change_count = nsxml_parse_option_postprocess(state, result);
			
#if NSXML_DEBUG
			
			if (change_count > 0)
			{
				nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_debug"/><![CDATA[, 0, "Post process pass %d produces %d changes\n", pass, change_count);
			}
			
#endif /* NSXML_DEBUG */
			
			++pass;
		}
		
		while (change_count > 0);
	}
	
	/* Required option checks */
	{
		const struct nsxml_option_info *last_info = NULL;
		
		for (g = 0; g < state->option_binding_group_count; ++g)
		{
			if ((g > 0) && ((int) g != state->subcommand_index))
			{
				continue;
			}
			
			for (o = 0; o < state->option_binding_counts[g]; ++o)
			{
				struct nsxml_option_binding *binding = &state->option_bindings[g][o];
				const struct nsxml_option_info *i = binding->info_ref;
				
				if (last_info && (last_info == i))
				{
					continue;
				}
				
				last_info = i;
				
				if ((binding->result_ref->is_set == 0) && nsxml_parse_option_required(state, result, binding))
				{
					if (i->option_type == nsxml_option_type_group)
					{
						/**
						 * @todo More explicit message +
						 * 	return ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_required_group_option"/><![CDATA[
						 * 		or ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_required_xgroup_option"/><![CDATA[
						 */
						nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_required_option"/><![CDATA[, "Missing required option group\n");
					}
					else
					{
						nsxml_program_result_add_messagef(result, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_type_error"/><![CDATA[, ]]><xsl:value-of select="$prg.c.parser.variableName.nsxml_message_error_missing_required_option"/><![CDATA[, "Missing required option %s%s\n", (strlen(i->names->name) > 1) ? "--" : "-", i->names->name);
					}
				}
			}
		}
	}
	
	nsxml_parse_positional_argument_process(state, result);
}

NSXML_EXTERNC_END
]]></xsl:variable>

	<xsl:template match="//prg:program">
		<xsl:value-of select="$prg.c.parser.genericSource"/>
	</xsl:template>
</xsl:stylesheet>

