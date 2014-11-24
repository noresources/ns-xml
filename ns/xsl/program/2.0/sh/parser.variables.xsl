<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Shell parser variables -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.base.xsl" />

	<xsl:variable name="prg.sh.parser.vName_program_author">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>program_author</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="prg.sh.parser.vName_program_version">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>program_version</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<!-- Name of the used shell interpreter -->
	<xsl:variable name="prg.sh.parser.vName_shell">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>shell</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Command line items -->
	<xsl:variable name="prg.sh.parser.vName_input">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>input</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Command line item count -->
	<xsl:variable name="prg.sh.parser.vName_itemcount">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>itemcount</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Value of the first index in a table -->
	<xsl:variable name="prg.sh.parser.vName_startindex">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>startindex</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.var_startindex">
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_startindex" />
		</xsl:call-template>
	</xsl:variable>

	<!-- Index of the processed command line item -->
	<xsl:variable name="prg.sh.parser.vName_index">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>index</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Character index in the processed command line item -->
	<xsl:variable name="prg.sh.parser.vName_subindex">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>subindex</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Current command line item -->
	<xsl:variable name="prg.sh.parser.vName_item">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>item</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_option">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>option</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_optiontail">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>optiontail</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_optionhastail">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>optionhastail</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_isfirstpositionalargument">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>isfirstpositionalargument</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_ma_local_count">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>ma_local_count</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_ma_total_count">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>ma_total_count</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<!-- Selected subcommand -->
	<xsl:variable name="prg.sh.parser.vName_subcommand">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>subcommand</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.var_subcommand">
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_subcommand" />
			<xsl:with-param name="quoted" select="true()" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.vName_subcommand_expected">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>subcommand_expected</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_values">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>values</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_required">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>required</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_present">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>present</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_warnings">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>warnings</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.vName_errors">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>errors</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_fatalerrors">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>fatalerrors</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_set_default">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>set_default</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_aborted">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
				<xsl:text>aborted</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_OK">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.prefixedName">
					<xsl:with-param name="name">
						<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
						<xsl:text>OK</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.var_OK">
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_OK" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.vName_ERROR">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.prefixedName">
					<xsl:with-param name="name">
						<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
						<xsl:text>ERROR</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.var_ERROR">
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$prg.sh.parser.vName_ERROR" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.vName_SC_OK">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.prefixedName">
					<xsl:with-param name="name">
						<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
						<xsl:text>SC_OK</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_SC_ERROR">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.prefixedName">
					<xsl:with-param name="name">
						<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
						<xsl:text>SC_ERROR</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="prg.sh.parser.vName_SC_UNKNOWN">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.prefixedName">
					<xsl:with-param name="name">
						<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
						<xsl:text>SC_UNKNOWN</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.vName_SC_SKIP">
		<xsl:call-template name="str.toUpper">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.prefixedName">
					<xsl:with-param name="name">
						<xsl:value-of select="$prg.sh.parser.variableNamePrefix" />
						<xsl:text>SC_SKIP</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- The main command line parser function -->
	<xsl:variable name="prg.sh.parser.fName_parse">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:text>parse</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Check number interval -->
	<xsl:variable name="prg.sh.parser.fName_numberLesserEqualcheck">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>numberlesserequalcheck</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Restricted values validator -->
	<xsl:variable name="prg.sh.parser.fName_enumcheck">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>enumcheck</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_addvalue">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>addvalue</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_displayerrors">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>displayerrors</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_setoptionpresence">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>setoptionpresence</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="prg.sh.parser.fName_isoptionpresent">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>isoptionpresent</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_addrequiredoption">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>addrequiredoption</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_checkrequired">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>checkrequired</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_checkminmax">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>checkminmax</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<!-- Set default values for single argument options -->
	<xsl:variable name="prg.sh.parser.fName_setdefaultarguments">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>setdefaultarguments</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_addmessage">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>addmessage</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_addwarning">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>addwarning</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_adderror">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>adderror</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_addfatalerror">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>addfatalerror</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_debug">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>debug</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_process_subcommand_option">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>process_subcommand_option</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_process_option">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>process_option</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="prg.sh.parser.fName_pathaccesscheck">
		<xsl:call-template name="prg.prefixedName">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.sh.parser.functionNamePrefix" />
				<xsl:text>pathaccesscheck</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
</xsl:stylesheet>