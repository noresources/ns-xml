<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Shell parser variables -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="sh-parser.base.xsl" />
	
	<variable name="prg.sh.parser.vName_shell">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>shell</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_input">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>input</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_itemcount">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>itemcount</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_startindex">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>startindex</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_index">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>index</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_subindex">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>subindex</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_item">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>item</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_option">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>option</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_optiontail">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>optiontail</text>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.vName_ma_local_count">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>ma_local_count</text>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.vName_ma_total_count">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>ma_total_count</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_subcommand">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>subcommand</text>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.var_subcommand">
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_subcommand" />
			<with-param name="quoted" select="true()" />
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_subcommand_expected">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>subcommand_expected</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_values">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>values</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_required">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>required</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_warnings">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>warnings</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_errors">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>errors</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_fatalerrors">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.variableNamePrefix" />
				<text>fatalerrors</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_OK">
		<call-template name="str.toUpper">
			<with-param name="text">
				<call-template name="prg.prefixedName">
					<with-param name="name">
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text>OK</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.var_OK">
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_OK" />
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_ERROR">
		<call-template name="str.toUpper">
			<with-param name="text">
				<call-template name="prg.prefixedName">
					<with-param name="name">
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text>ERROR</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.var_ERROR">
		<call-template name="sh.var">
			<with-param name="name" select="$prg.sh.parser.vName_ERROR" />
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_SC_OK">
		<call-template name="str.toUpper">
			<with-param name="text">
				<call-template name="prg.prefixedName">
					<with-param name="name">
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text>SC_OK</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.vName_SC_ERROR">
		<call-template name="str.toUpper">
			<with-param name="text">
				<call-template name="prg.prefixedName">
					<with-param name="name">
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text>SC_ERROR</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_SC_UNKNOWN">
		<call-template name="str.toUpper">
			<with-param name="text">
				<call-template name="prg.prefixedName">
					<with-param name="name">
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text>SC_UNKNOWN</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.vName_SC_SKIP">
		<call-template name="str.toUpper">
			<with-param name="text">
				<call-template name="prg.prefixedName">
					<with-param name="name">
						<value-of select="$prg.sh.parser.variableNamePrefix" />
						<text>SC_SKIP</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_parse">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<text>parse</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_enumcheck">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>enumcheck</text>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.fName_addvalue">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>addvalue</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_displayerrors">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>displayerrors</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_setoptionpresence">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>setoptionpresence</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_checkrequired">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>checkrequired</text>
			</with-param>
		</call-template>
	</variable>
	
	<variable name="prg.sh.parser.fName_checkminmax">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>checkminmax</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_addmessage">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>addmessage</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_addwarning">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>addwarning</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_adderror">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>adderror</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_addfatalerror">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>addfatalerror</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_debug">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>debug</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_process_subcommand_option">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>process_subcommand_option</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_process_option">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>process_option</text>
			</with-param>
		</call-template>
	</variable>

	<variable name="prg.sh.parser.fName_pathaccesscheck">
		<call-template name="prg.prefixedName">
			<with-param name="name">
				<value-of select="$prg.sh.parser.functionNamePrefix" />
				<text>pathaccesscheck</text>
			</with-param>
		</call-template>
	</variable>

</stylesheet>
