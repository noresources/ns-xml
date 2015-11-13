<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Convert program infos to C structs -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="parser.base.xsl" />
	<xsl:import href="parser.generic-names.xsl" />
	<xsl:import href="parser.names.xsl" />
	<xsl:template name="prg.c.parser.memberSet">
		<xsl:param name="variable" />
		<xsl:param name="pointer" />
		<xsl:value-of select="$variable" />
		<xsl:choose>
			<xsl:when test="$pointer">
				<xsl:text>-&gt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Create validators for option and positional arguments -->
	<xsl:template name="prg.c.parser.infoValidators">
		<xsl:param name="itemNode" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<!-- Path validator -->
		<xsl:variable name="pathNode" select="$itemNode/prg:type/prg:path" />
		<xsl:if test="$pathNode/@access | $pathNode/prg:kinds | $pathNode/@exist">
			<xsl:value-of select="$str.endl" />
			<xsl:text>validator_flags = 0;</xsl:text>
			<xsl:if test="contains($pathNode/@access, 'r')">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_path_readable;</xsl:text>
			</xsl:if>
			<xsl:if test="contains($pathNode/@access, 'w')">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_path_writable;</xsl:text>
			</xsl:if>
			<xsl:if test="contains($pathNode/@access, 'x')">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_path_executable;</xsl:text>
			</xsl:if>
			<xsl:if test="$pathNode/@exist = 'true'">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_path_exists;</xsl:text>
			</xsl:if>
			<xsl:if test="$pathNode/prg:kinds">
				<xsl:if test="$pathNode/prg:kinds/prg:file">
					<xsl:value-of select="$str.endl" />
					<xsl:text>validator_flags |= nsxml_value_validator_path_type_file;</xsl:text>
				</xsl:if>
				<xsl:if test="$pathNode/prg:kinds/prg:folder">
					<xsl:value-of select="$str.endl" />
					<xsl:text>validator_flags |= nsxml_value_validator_path_type_folder;</xsl:text>
				</xsl:if>
				<xsl:if test="$pathNode/prg:kinds/prg:symlink">
					<xsl:value-of select="$str.endl" />
					<xsl:text>validator_flags |= nsxml_value_validator_path_type_symlink;</xsl:text>
				</xsl:if>
			</xsl:if>
			<xsl:value-of select="$str.endl" />
			<xsl:text>validator = (struct nsxml_value_validator *)malloc(sizeof(struct nsxml_value_validator));</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text> validator_ptr = validator;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>nsxml_value_validator_init(validator, &amp;nsxml_value_validator_validate_path, NULL, &amp;nsxml_value_validator_usage_path, validator_flags);</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>nsxml_value_validator_add(</xsl:text>
			<xsl:text>&amp;</xsl:text>
			<xsl:value-of select="$memberSet" />
			<xsl:text>validators</xsl:text>
			<xsl:text>, validator);</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<!-- number validator -->
		<xsl:variable name="numberNode" select="$itemNode/prg:type/prg:number" />
		<xsl:if test="$numberNode">
			<xsl:value-of select="$str.endl" />
			<xsl:text>validator_flags = 0;</xsl:text>
			<xsl:if test="$numberNode/@min">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_checkmin;</xsl:text>
			</xsl:if>
			<xsl:if test="$numberNode/@max">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_checkmax;</xsl:text>
			</xsl:if>
			<xsl:value-of select="$str.endl" />
			<xsl:text>validator = (struct nsxml_value_validator *)malloc(sizeof(struct nsxml_value_validator_number));</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text> validator_ptr = validator;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>nsxml_value_validator_init(validator, &amp;nsxml_value_validator_validate_number, NULL, &amp;nsxml_value_validator_usage_number, validator_flags);</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>((struct nsxml_value_validator_number *)(validator_ptr))-&gt;decimal_count = </xsl:text>
			<xsl:choose>
				<xsl:when test="$numberNode/@decimal">
					<xsl:value-of select="$numberNode/@decimal"></xsl:value-of>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>((struct nsxml_value_validator_number *)(validator_ptr))-&gt;min_value = </xsl:text>
			<xsl:choose>
				<xsl:when test="$numberNode/@min">
					<xsl:value-of select="$numberNode/@min" />
					<xsl:if test="not(contains($numberNode/@min, '.'))">
						<xsl:text>.</xsl:text>
					</xsl:if>
					<xsl:text>F</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0.F</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>((struct nsxml_value_validator_number *)(validator_ptr))-&gt;max_value = </xsl:text>
			<xsl:choose>
				<xsl:when test="$numberNode/@max">
					<xsl:value-of select="$numberNode/@max" />
					<xsl:if test="not(contains($numberNode/@max, '.'))">
						<xsl:text>.</xsl:text>
					</xsl:if>
					<xsl:text>F</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>0.F</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>nsxml_value_validator_add(</xsl:text>
			<!-- <value-of select="$variable"/> -->
			<xsl:text>&amp;</xsl:text>
			<xsl:value-of select="$memberSet" />
			<xsl:text>validators</xsl:text>
			<xsl:text>, validator);</xsl:text>
		</xsl:if>
		<!-- enumeration validator -->
		<xsl:variable name="selectNode" select="$itemNode/prg:select" />
		<xsl:if test="$selectNode">
			<xsl:value-of select="$str.endl" />
			<xsl:text>validator_flags = 0;</xsl:text>
			<xsl:if test="$selectNode/@restrict = 'true'">
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags |= nsxml_value_validator_enum_strict;</xsl:text>
			</xsl:if>
			<xsl:value-of select="$str.endl" />
			<xsl:text>validator = (struct nsxml_value_validator *)malloc(sizeof(struct nsxml_value_validator_enum));</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text> validator_ptr = validator;</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>nsxml_value_validator_init(validator, &amp;nsxml_value_validator_validate_enum, &amp;nsxml_value_validator_cleanup_enum, &amp;nsxml_value_validator_usage_enum, validator_flags);</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>((struct nsxml_value_validator_enum *)(validator_ptr))-&gt;values = nsxml_item_names_new(</xsl:text>
			<xsl:for-each select="$selectNode/prg:option">
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="." />
				<xsl:text>", </xsl:text>
			</xsl:for-each>
			<xsl:text>NULL);</xsl:text>
			<xsl:value-of select="$str.endl" />
			<xsl:text>nsxml_value_validator_add(</xsl:text>
			<!-- <value-of select="$variable"/> -->
			<xsl:text>&amp;</xsl:text>
			<xsl:value-of select="$memberSet" />
			<xsl:text>validators</xsl:text>
			<xsl:text>, validator);</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Initioalize item_info -->
	<xsl:template name="prg.c.parser.itemInfoInit">
		<xsl:param name="itemNode" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:variable name="abstract">
			<xsl:apply-templates select="$itemNode/prg:documentation/prg:abstract" />
		</xsl:variable>
		<xsl:variable name="details">
			<xsl:apply-templates select="$itemNode/prg:documentation/prg:details" />
		</xsl:variable>
		<xsl:text>nsxml_item_info_init(&amp;</xsl:text>
		<xsl:value-of select="$variable" />
		<xsl:text>, nsxml_item_type_</xsl:text>
		<xsl:call-template name="prg.c.parser.itemTypeName">
			<xsl:with-param name="itemNode" select="$itemNode" />
			<xsl:with-param name="base" select="true()" />
		</xsl:call-template>
		<xsl:text>, </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length($abstract) &gt; 0">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$abstract" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NULL</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length($details) &gt; 0">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$details" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NULL</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);</xsl:text>
	</xsl:template>

	<!-- Initialize option_info -->
	<xsl:template name="prg.c.parser.optionItemInfoInit">
		<xsl:param name="optionNode" />
		<xsl:param name="variable" />
		<xsl:param name="containerVariable" />
		<xsl:param name="rootNode" />
		<xsl:param name="pointer" select="false()" />
		<xsl:call-template name="prg.c.parser.itemInfoInit">
			<xsl:with-param name="itemNode" select="$optionNode" />
			<xsl:with-param name="variable" select="concat($variable, '-&gt;item_info')" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:text>nsxml_option_info_init(</xsl:text>
		<xsl:value-of select="$variable" />
		<xsl:text>, nsxml_option_type_</xsl:text>
		<xsl:call-template name="prg.c.parser.itemTypeName">
			<xsl:with-param name="itemNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:text>, (0</xsl:text>
		<xsl:if test="$optionNode/@required">
			<xsl:text>| nsxml_option_flag_required</xsl:text>
		</xsl:if>
		<xsl:text>), </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:databinding/prg:variable">
				<xsl:text>"</xsl:text>
				<!-- Note: here we do not protect variable name -->
				<xsl:value-of select="normalize-space($optionNode/prg:databinding/prg:variable)" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NULL</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, nsxml_item_names_new(</xsl:text>
		<xsl:for-each select="$optionNode/prg:names/*">
			<xsl:text>"</xsl:text>
			<xsl:apply-templates select="." />
			<xsl:text>", </xsl:text>
		</xsl:for-each>
		<xsl:text>NULL), </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/../../self::prg:group">
				<xsl:value-of select="$containerVariable" />
				<xsl:text>[</xsl:text>
				<xsl:call-template name="prg.c.parser.optionIndex">
					<xsl:with-param name="rootNode" select="$rootNode" />
					<xsl:with-param name="optionNode" select="$optionNode/../../self::prg:group" />
				</xsl:call-template>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NULL</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />
		<!-- Validators -->
		<xsl:call-template name="prg.c.parser.infoValidators">
			<xsl:with-param name="itemNode" select="$optionNode" />
			<xsl:with-param name="variable" select="$variable" />
			<xsl:with-param name="pointer" select="true()" />
		</xsl:call-template>
	</xsl:template>

	<!-- Initialize switch info -->
	<xsl:template name="prg.c.parser.switch_optionItemInfoInit">
		<xsl:param name="optionNode" />
		<xsl:param name="optionInfoVariable" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:param name="containerVariable" />
		<xsl:param name="rootNode" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="prg.c.parser.optionItemInfoInit">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="variable">
				<xsl:choose>
					<xsl:when test="$optionInfoVariable">
						<xsl:value-of select="$optionInfoVariable" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($memberSet, 'option_info')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)" />
			<xsl:with-param name="containerVariable" select="$containerVariable" />
			<xsl:with-param name="rootNode" select="$rootNode" />
		</xsl:call-template>
	</xsl:template>

	<!-- argument type enum name -->
	<xsl:template name="prg.c.parser.argumentType">
		<xsl:param name="typeNode" />
		<xsl:text>nsxml_argument_type_</xsl:text>
		<xsl:choose>
			<xsl:when test="$typeNode/prg:existingcommand">
				<xsl:text>existingcommand</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:hostname">
				<xsl:text>hostname</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:number">
				<xsl:text>number</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:path">
				<xsl:text>path</xsl:text>
			</xsl:when>
			<xsl:when test="$typeNode/prg:string">
				<xsl:text>string</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>mixed</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Initialize argument option -->
	<xsl:template name="prg.c.parser.optionArgumentInfoInit">
		<xsl:param name="memberSet" />
		<xsl:param name="optionNode" />
		<xsl:param name="containerVariable" />
		<xsl:param name="rootNode" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>argument_type = </xsl:text>
		<xsl:call-template name="prg.c.parser.argumentType">
			<xsl:with-param name="typeNode" select="$optionNode/prg:type" />
		</xsl:call-template>
		<xsl:text>;</xsl:text>
	</xsl:template>

	<!-- -->
	<xsl:template name="prg.c.parser.argumentOptionItemInfoInit">
		<xsl:param name="optionNode" />
		<xsl:param name="optionInfoVariable" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:param name="containerVariable" />
		<xsl:param name="rootNode" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="prg.c.parser.optionItemInfoInit">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="variable">
				<xsl:choose>
					<xsl:when test="$optionInfoVariable">
						<xsl:value-of select="$optionInfoVariable" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($memberSet, 'option_info')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)" />
			<xsl:with-param name="containerVariable" select="$containerVariable" />
			<xsl:with-param name="rootNode" select="$rootNode" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>default_value = </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:default">
				<xsl:text>strdup("</xsl:text>
				<xsl:apply-templates select="$optionNode/prg:default" />
				<xsl:text>");</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>NULL;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.optionArgumentInfoInit">
			<xsl:with-param name="memberSet" select="$memberSet" />
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
	</xsl:template>

	<!-- -->
	<xsl:template name="prg.c.parser.multiargumentOptionItemInfoInit">
		<xsl:param name="optionNode" />
		<xsl:param name="optionInfoVariable" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:param name="containerVariable" />
		<xsl:param name="rootNode" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="prg.c.parser.optionItemInfoInit">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="variable">
				<xsl:choose>
					<xsl:when test="$optionInfoVariable">
						<xsl:value-of select="$optionInfoVariable" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($memberSet, 'option_info')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)" />
			<xsl:with-param name="containerVariable" select="$containerVariable" />
			<xsl:with-param name="rootNode" select="$rootNode" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>min_argument = </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/@min">
				<xsl:value-of select="$optionNode/@min" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>max_argument = </xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/@max">
				<xsl:value-of select="$optionNode/@max" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>0</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="prg.c.parser.optionArgumentInfoInit">
			<xsl:with-param name="memberSet" select="$memberSet" />
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
	</xsl:template>

	<!-- -->
	<xsl:template name="prg.c.parser.group_optionItemInfoInit">
		<xsl:param name="optionNode" />
		<xsl:param name="optionInfoVariable" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:param name="containerVariable" />
		<xsl:param name="rootNode" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="prg.c.parser.optionItemInfoInit">
			<xsl:with-param name="optionNode" select="$optionNode" />
			<xsl:with-param name="variable">
				<xsl:choose>
					<xsl:when test="$optionInfoVariable">
						<xsl:value-of select="$optionInfoVariable" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($memberSet, 'option_info')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)" />
			<xsl:with-param name="containerVariable" select="$containerVariable" />
			<xsl:with-param name="rootNode" select="$rootNode" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>group_type = nsxml_group_option_</xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/@type = 'exclusive'">
				<xsl:text>exclusive</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>standard</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>option_info_count = </xsl:text>
		<xsl:value-of select="count($optionNode/prg:options/*)" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>option_info_refs = (struct nsxml_option_info **)malloc(sizeof(struct nsxml_option_info *) * </xsl:text>
		<xsl:value-of select="count($optionNode/prg:options/*)" />
		<xsl:text>);</xsl:text>
	</xsl:template>

	<!-- -->
	<xsl:template name="prg.c.parser.rootItemInfoInit">
		<xsl:param name="rootNode" />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="false()" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="prg.c.parser.itemInfoInit">
			<xsl:with-param name="itemNode" select="$rootNode" />
			<xsl:with-param name="variable" select="concat($memberSet, 'item_info')" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
		<xsl:variable name="optionCount" select="count($rootNode/prg:options/* | $rootNode/prg:options//prg:options/*)" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>option_info_count = </xsl:text>
		<xsl:value-of select="$optionCount" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:choose>
			<xsl:when test="$optionCount = 0">
				<xsl:value-of select="$memberSet" />
				<xsl:text>option_infos = NULL;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$memberSet" />
				<xsl:text>option_infos = (struct nsxml_option_info**) malloc(sizeof(struct nsxml_option_info*) * </xsl:text>
				<xsl:value-of select="$optionCount" />
				<xsl:text>);</xsl:text>
				<xsl:call-template name="c.block">
					<xsl:with-param name="content">
						<xsl:text>struct nsxml_option_info *o = NULL;</xsl:text>
						<xsl:value-of select="$str.endl" />
						<xsl:variable name="haveArgOptions" select="count ($rootNode/prg:options//prg:argument | $rootNode/prg:options//prg:multiargument) &gt; 0" />
						<xsl:if test="$haveArgOptions">
							<xsl:text>void *o_ptr = NULL;</xsl:text>
						</xsl:if>
						<xsl:value-of select="$str.endl" />
						<xsl:variable name="containerVariable">
							<xsl:value-of select="$memberSet" />
							<xsl:text>option_infos</xsl:text>
						</xsl:variable>
						<xsl:for-each select="$rootNode/prg:options/* | $rootNode/prg:options//prg:options/*">
							<xsl:variable name="optionIndex" select="position() - 1" />
							<xsl:variable name="optionVariable">
								<xsl:value-of select="$containerVariable" />
								<xsl:text>[</xsl:text>
								<xsl:value-of select="$optionIndex" />
								<xsl:text>]</xsl:text>
							</xsl:variable>
							<xsl:call-template name="c.inlineComment">
								<xsl:with-param name="content">
									<xsl:value-of select="$optionIndex" />
									<xsl:if test="./prg:databinding/prg:variable">
										<xsl:text>: </xsl:text>
										<xsl:apply-templates select="./prg:databinding/prg:variable" />
									</xsl:if>
								</xsl:with-param>
							</xsl:call-template>
							<xsl:value-of select="$str.endl" />
							<xsl:value-of select="$optionVariable" />
							<xsl:text> = </xsl:text>
							<xsl:choose>
								<xsl:when test="./self::prg:switch">
									<xsl:text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_switch_option_info));</xsl:text>
									<xsl:value-of select="$str.endl" />
									<xsl:text>o = </xsl:text>
									<xsl:value-of select="$optionVariable" />
									<xsl:text>;</xsl:text>
									<xsl:if test="$haveArgOptions">
										<xsl:text>o_ptr = o;</xsl:text>
									</xsl:if>
									<xsl:value-of select="$str.endl" />
									<xsl:call-template name="prg.c.parser.switch_optionItemInfoInit">
										<xsl:with-param name="optionNode" select="." />
										<xsl:with-param name="optionInfoVariable" select="'o'" />
										<xsl:with-param name="variable">
											<xsl:text>((struct nsxml_switch_option_info*)o_ptr)</xsl:text>
										</xsl:with-param>
										<xsl:with-param name="pointer" select="true()" />
										<xsl:with-param name="containerVariable" select="$containerVariable" />
										<xsl:with-param name="rootNode" select="$rootNode" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="./self::prg:argument">
									<xsl:text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_argument_option_info));</xsl:text>
									<xsl:value-of select="$str.endl" />
									<xsl:text>o = </xsl:text>
									<xsl:value-of select="$optionVariable" />
									<xsl:text>;</xsl:text>
									<xsl:if test="$haveArgOptions">
										<xsl:text>o_ptr = o;</xsl:text>
									</xsl:if>
									<xsl:value-of select="$str.endl" />
									<xsl:call-template name="prg.c.parser.argumentOptionItemInfoInit">
										<xsl:with-param name="optionNode" select="." />
										<xsl:with-param name="optionInfoVariable" select="'o'" />
										<xsl:with-param name="variable">
											<xsl:text>((struct nsxml_argument_option_info*)o_ptr)</xsl:text>
										</xsl:with-param>
										<xsl:with-param name="pointer" select="true()" />
										<xsl:with-param name="containerVariable" select="$containerVariable" />
										<xsl:with-param name="rootNode" select="$rootNode" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="./self::prg:multiargument">
									<xsl:text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_multiargument_option_info));</xsl:text>
									<xsl:value-of select="$str.endl" />
									<xsl:text>o = </xsl:text>
									<xsl:value-of select="$optionVariable" />
									<xsl:text>;</xsl:text>
									<xsl:if test="$haveArgOptions">
										<xsl:text>o_ptr = o;</xsl:text>
									</xsl:if>
									<xsl:value-of select="$str.endl" />
									<xsl:call-template name="prg.c.parser.multiargumentOptionItemInfoInit">
										<xsl:with-param name="optionNode" select="." />
										<xsl:with-param name="optionInfoVariable" select="'o'" />
										<xsl:with-param name="variable">
											<xsl:text>((struct nsxml_multiargument_option_info*)o_ptr)</xsl:text>
										</xsl:with-param>
										<xsl:with-param name="pointer" select="true()" />
										<xsl:with-param name="containerVariable" select="$containerVariable" />
										<xsl:with-param name="rootNode" select="$rootNode" />
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="./self::prg:group">
									<xsl:text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_group_option_info));</xsl:text>
									<xsl:value-of select="$str.endl" />
									<xsl:text>o = </xsl:text>
									<xsl:value-of select="$optionVariable" />
									<xsl:text>;</xsl:text>
									<xsl:if test="$haveArgOptions">
										<xsl:text>o_ptr = o;</xsl:text>
									</xsl:if>
									<xsl:value-of select="$str.endl" />
									<xsl:call-template name="prg.c.parser.group_optionItemInfoInit">
										<xsl:with-param name="optionNode" select="." />
										<xsl:with-param name="optionInfoVariable" select="'o'" />
										<xsl:with-param name="variable">
											<xsl:text>((struct nsxml_group_option_info*)o_ptr)</xsl:text>
										</xsl:with-param>
										<xsl:with-param name="pointer" select="true()" />
										<xsl:with-param name="containerVariable" select="$containerVariable" />
										<xsl:with-param name="rootNode" select="$rootNode" />
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of select="$str.endl" />
						</xsl:for-each>
						<!-- Link group options -->
						<xsl:for-each select="$rootNode//prg:group">
							<xsl:variable name="optionIndex">
								<xsl:call-template name="prg.c.parser.optionIndex">
									<xsl:with-param name="rootNode" select="$rootNode" />
									<xsl:with-param name="optionNode" select="." />
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="groupNode" select="." />
							<xsl:text>o = info-&gt;rootitem_info.option_infos[</xsl:text>
							<xsl:value-of select="$optionIndex" />
							<xsl:text>];</xsl:text>
							<xsl:if test="$haveArgOptions">
								<xsl:text>o_ptr = o;</xsl:text>
							</xsl:if>
							<xsl:value-of select="$str.endl" />
							<xsl:for-each select="$groupNode/prg:options/*">
								<xsl:text>((struct nsxml_group_option_info *)(o_ptr))-&gt;option_info_refs[</xsl:text>
								<xsl:value-of select="position() - 1" />
								<xsl:text>] = info-&gt;rootitem_info.option_infos[</xsl:text>
								<xsl:call-template name="prg.c.parser.optionIndex">
									<xsl:with-param name="rootNode" select="$rootNode" />
									<xsl:with-param name="optionNode" select="." />
								</xsl:call-template>
								<xsl:text>];</xsl:text>
								<xsl:value-of select="$str.endl" />
							</xsl:for-each>
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Positional arguments -->
		<xsl:value-of select="$str.endl" />
		<xsl:variable name="valueCount" select="count($rootNode/prg:values/*)" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>positional_argument_info_count = </xsl:text>
		<xsl:value-of select="$valueCount" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:value-of select="$memberSet" />
		<xsl:text>positional_argument_infos = </xsl:text>
		<xsl:choose>
			<xsl:when test="$valueCount = 0">
				<xsl:text>NULL</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>(struct nsxml_positional_argument_info*)malloc (sizeof(struct nsxml_positional_argument_info) * </xsl:text>
				<xsl:value-of select="$valueCount" />
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>;</xsl:text>
		<xsl:if test="$valueCount &gt; 0">
			<xsl:call-template name="c.block">
				<xsl:with-param name="content">
					<xsl:text>int flags = 0;</xsl:text>
					<xsl:for-each select="$rootNode/prg:values/*">
						<xsl:variable name="info">
							<xsl:value-of select="$memberSet" />
							<xsl:text>positional_argument_infos[</xsl:text>
							<xsl:value-of select="position() - 1" />
							<xsl:text>]</xsl:text>
						</xsl:variable>
						<xsl:value-of select="$str.endl" />
						<!-- item info -->
						<xsl:call-template name="prg.c.parser.itemInfoInit">
							<xsl:with-param name="itemNode" select="." />
							<xsl:with-param name="variable" select="concat($info, '.item_info')" />
						</xsl:call-template>
						<xsl:value-of select="$str.endl" />
						<xsl:text>flags = 0;</xsl:text>
						<xsl:value-of select="$str.endl" />
						<xsl:if test="./@required = 'true'">
							<xsl:text>flags |= nsxml_positional_argument_required;</xsl:text>
							<xsl:value-of select="$str.endl" />
						</xsl:if>
						<xsl:text>nsxml_positional_argument_info_init(&amp;</xsl:text>
						<xsl:value-of select="$info" />
						<!-- flags -->
						<xsl:text>, flags</xsl:text>
						<!-- arg type -->
						<xsl:text>, </xsl:text>
						<xsl:call-template name="prg.c.parser.argumentType">
							<xsl:with-param name="typeNode" select="./prg:type" />
						</xsl:call-template>
						<xsl:text>, </xsl:text>
						<xsl:choose>
							<xsl:when test="./self::prg:value">
								<xsl:text>1</xsl:text>
							</xsl:when>
							<xsl:when test="./self::prg:other and ./@max">
								<xsl:value-of select="./@max" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>0</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>);</xsl:text>
						<xsl:value-of select="$str.endl" />
						<!-- validators -->
						<xsl:call-template name="prg.c.parser.infoValidators">
							<xsl:with-param name="itemNode" select="." />
							<xsl:with-param name="variable" select="$info" />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- -->
	<xsl:template name="prg.c.parser.subcommandInfoInit">
		<xsl:param name="subcommandNode" select="." />
		<xsl:param name="variable" />
		<xsl:param name="pointer" select="true()" />
		<xsl:variable name="memberSet">
			<xsl:call-template name="prg.c.parser.memberSet">
				<xsl:with-param name="variable" select="$variable" />
				<xsl:with-param name="pointer" select="$pointer" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$memberSet" />
		<xsl:text>names = nsxml_item_names_new("</xsl:text>
		<xsl:apply-templates select="$subcommandNode/prg:name" />
		<xsl:text>", </xsl:text>
		<xsl:for-each select="$subcommandNode/prg:aliases/prg:alias">
			<xsl:text>"</xsl:text>
			<xsl:apply-templates select="." />
			<xsl:text>", </xsl:text>
		</xsl:for-each>
		<xsl:text>NULL);</xsl:text>
		<xsl:value-of select="$str.endl" />
		<!-- rootitem members -->
		<xsl:call-template name="prg.c.parser.rootItemInfoInit">
			<xsl:with-param name="rootNode" select="$subcommandNode" />
			<xsl:with-param name="variable">
				<xsl:value-of select="$variable" />
				<xsl:text>-&gt;rootitem_info</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Typedefs -->
	<xsl:template name="prg.c.parser.programInfoTypedefs">
		<xsl:text>typedef struct nsxml_program_info </xsl:text>
		<xsl:value-of select="$prg.c.parser.structName.program_info" />
		<xsl:text>;</xsl:text>
	</xsl:template>

	<!-- Program info initioalization function declaration -->
	<xsl:template name="prg.c.parser.programInfoInitFunctionDeclaration">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDeclaration">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_init" />
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info initioalization function definition -->
	<xsl:template name="prg.c.parser.programInfoInitFunctionDefinition">
		<xsl:param name="programNode" select="." />
		<xsl:variable name="infoParam" select="'info'" />
		<xsl:variable name="subcommandCount" select="count($programNode/prg:subcommands/*)" />
		<xsl:call-template name="c.functionDefinition">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_init" />
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:text>struct nsxml_value_validator *validator;</xsl:text>
				<xsl:text> void *validator_ptr;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>int validator_flags;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator = NULL;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text> validator_ptr = validator;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags = 0;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<!-- nsxml_program_info member -->
				<xsl:value-of select="$infoParam" />
				<xsl:text>-&gt;name = "</xsl:text>
				<xsl:apply-templates select="$programNode/prg:name" />
				<xsl:text>";</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$infoParam" />
				<xsl:text>-&gt;subcommand_info_count = </xsl:text>
				<xsl:value-of select="$subcommandCount" />
				<xsl:text>;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$infoParam" />
				<xsl:text>-&gt;subcommand_infos = </xsl:text>
				<xsl:choose>
					<xsl:when test="$subcommandCount = 0">
						<xsl:text>NULL;</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>(struct nsxml_subcommand_info *)(malloc(sizeof(struct nsxml_subcommand_info) *</xsl:text>
						<xsl:value-of select="$subcommandCount" />
						<xsl:text>));</xsl:text>
						<xsl:for-each select="$programNode/prg:subcommands/prg:subcommand">
							<xsl:variable name="subcommandIndex" select="position() - 1" />
							<xsl:call-template name="c.block">
								<xsl:with-param name="content">
									<xsl:call-template name="c.inlineComment">
										<xsl:with-param name="content" select="prg:name" />
									</xsl:call-template>
									<xsl:value-of select="$str.endl" />
									<xsl:text>struct nsxml_subcommand_info *s = &amp;(</xsl:text>
									<xsl:value-of select="$infoParam" />
									<xsl:text>-&gt;subcommand_infos[</xsl:text>
									<xsl:value-of select="$subcommandIndex" />
									<xsl:text>]);</xsl:text>
									<xsl:value-of select="$str.endl" />
									<xsl:call-template name="prg.c.parser.subcommandInfoInit">
										<xsl:with-param name="variable" select="'s'" />
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$str.endl" />
				<!-- rootitem members -->
				<xsl:call-template name="prg.c.parser.rootItemInfoInit">
					<xsl:with-param name="rootNode" select="$programNode" />
					<xsl:with-param name="variable">
						<xsl:value-of select="$infoParam" />
						<xsl:text>-&gt;rootitem_info</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.endl" />
				<xsl:text>/*shut up compiler */</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_flags = (int)sizeof(validator);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>validator_ptr = &amp;validator_flags;</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text> validator = (struct nsxml_value_validator *)validator_ptr;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info creation function declaration -->
	<xsl:template name="prg.c.parser.programInfoNewFunctionDeclaration">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDeclaration">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_new" />
			<xsl:with-param name="returnType">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info creation function definition -->
	<xsl:template name="prg.c.parser.programInfoNewFunctionDefinition">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDefinition">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_new" />
			<xsl:with-param name="returnType">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info = (</xsl:text>
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *)malloc(sizeof(</xsl:text>
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text>));</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:value-of select="$prg.c.parser.functionName.program_info_init" />
				<xsl:text>(info);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>return info;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info cleanup function declaration -->
	<xsl:template name="prg.c.parser.programInfoCleanupFunctionDeclaration">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDeclaration">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_cleanup" />
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info cleanup function definition -->
	<xsl:template name="prg.c.parser.programInfoCleanupFunctionDefinition">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDefinition">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_cleanup" />
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:text>nsxml_program_info_cleanup(info);</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info free function declaration -->
	<xsl:template name="prg.c.parser.programInfoFreeFunctionDeclaration">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDeclaration">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_free" />
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Program info free function definition -->
	<xsl:template name="prg.c.parser.programInfoFreeFunctionDefinition">
		<xsl:param name="programNode" select="." />
		<xsl:call-template name="c.functionDefinition">
			<xsl:with-param name="name" select="$prg.c.parser.functionName.program_info_free" />
			<xsl:with-param name="parameters">
				<xsl:value-of select="$prg.c.parser.structName.program_info" />
				<xsl:text> *info</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:value-of select="$prg.c.parser.functionName.program_info_cleanup" />
				<xsl:text>(info);</xsl:text>
				<xsl:value-of select="$str.endl" />
				<xsl:text>free(info);</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
