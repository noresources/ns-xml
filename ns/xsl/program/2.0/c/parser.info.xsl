<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Convert program infos to C structs -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="parser.base.xsl"/>
	<import href="parser.generic-names.xsl"/>
	<import href="parser.names.xsl"/>
	<template name="prg.c.parser.memberSet">
		<param name="variable"/>
		<param name="pointer"/>
		<value-of select="$variable"/>
		<choose>
			<when test="$pointer">
				<text>-&gt;</text>
			</when>
			<otherwise>
				<text>.</text>
			</otherwise>
		</choose>
	</template>

	<!-- Create validators for option and positional arguments -->
	<template name="prg.c.parser.infoValidators">
		<param name="itemNode"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<!-- Path validator -->
		<variable name="pathNode" select="$itemNode/prg:type/prg:path"/>
		<if test="$pathNode/@access | $pathNode/prg:kinds | $pathNode/@exist">
			<call-template name="endl"/>
			<text>validator_flags = 0;</text>
			<if test="contains($pathNode/@access, 'r')">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_path_readable;</text>
			</if>
			<if test="contains($pathNode/@access, 'w')">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_path_writable;</text>
			</if>
			<if test="contains($pathNode/@access, 'x')">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_path_executable;</text>
			</if>
			<if test="$pathNode/@exist = 'true'">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_path_exists;</text>
			</if>
			<if test="$pathNode/prg:kinds">
				<if test="$pathNode/prg:kinds/prg:file">
					<call-template name="endl"/>
					<text>validator_flags |= nsxml_value_validator_path_type_file;</text>
				</if>
				<if test="$pathNode/prg:kinds/prg:folder">
					<call-template name="endl"/>
					<text>validator_flags |= nsxml_value_validator_path_type_folder;</text>
				</if>
				<if test="$pathNode/prg:kinds/prg:symlink">
					<call-template name="endl"/>
					<text>validator_flags |= nsxml_value_validator_path_type_symlink;</text>
				</if>
			</if>
			<call-template name="endl"/>
			<text>validator = (struct nsxml_value_validator *)malloc(sizeof(struct nsxml_value_validator));</text>
			<call-template name="endl"/>
			<text> validator_ptr = validator;</text>
			<call-template name="endl"/>
			<text>nsxml_value_validator_init(validator, &amp;nsxml_value_validator_validate_path, NULL, &amp;nsxml_value_validator_usage_path, validator_flags);</text>
			<call-template name="endl"/>
			<text>nsxml_value_validator_add(</text>
			<text>&amp;</text>
			<value-of select="$memberSet"/>
			<text>validators</text>
			<text>, validator);</text>
			<call-template name="endl"/>
		</if>
		<!-- number validator -->
		<variable name="numberNode" select="$itemNode/prg:type/prg:number"/>
		<if test="$numberNode">
			<call-template name="endl"/>
			<text>validator_flags = 0;</text>
			<if test="$numberNode/@min">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_checkmin;</text>
			</if>
			<if test="$numberNode/@max">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_checkmax;</text>
			</if>
			<call-template name="endl"/>
			<text>validator = (struct nsxml_value_validator *)malloc(sizeof(struct nsxml_value_validator_number));</text>
			<call-template name="endl"/>
			<text> validator_ptr = validator;</text>
			<call-template name="endl"/>
			<text>nsxml_value_validator_init(validator, &amp;nsxml_value_validator_validate_number, NULL, &amp;nsxml_value_validator_usage_number, validator_flags);</text>
			<call-template name="endl"/>
			<text>((struct nsxml_value_validator_number *)(validator_ptr))-&gt;min_value = </text>
			<choose>
				<when test="$numberNode/@min">
					<value-of select="$numberNode/@min"/>
					<text>.F</text>
				</when>
				<otherwise>
					<text>0.F</text>
				</otherwise>
			</choose>
			<text>;</text>
			<call-template name="endl"/>
			<text>((struct nsxml_value_validator_number *)(validator_ptr))-&gt;max_value = </text>
			<choose>
				<when test="$numberNode/@max">
					<value-of select="$numberNode/@max"/>
					<text>.F</text>
				</when>
				<otherwise>
					<text>0.F</text>
				</otherwise>
			</choose>
			<text>;</text>
			<call-template name="endl"/>
			<text>nsxml_value_validator_add(</text>
			<!-- <value-of select="$variable"/> -->
			<text>&amp;</text>
			<value-of select="$memberSet"/>
			<text>validators</text>
			<text>, validator);</text>
		</if>
		<!-- enumeration validator -->
		<variable name="selectNode" select="$itemNode/prg:select"/>
		<if test="$selectNode">
			<call-template name="endl"/>
			<text>validator_flags = 0;</text>
			<if test="$selectNode/@restrict = 'true'">
				<call-template name="endl"/>
				<text>validator_flags |= nsxml_value_validator_enum_strict;</text>
			</if>
			<call-template name="endl"/>
			<text>validator = (struct nsxml_value_validator *)malloc(sizeof(struct nsxml_value_validator_enum));</text>
			<call-template name="endl"/>
			<text> validator_ptr = validator;</text>
			<call-template name="endl"/>
			<text>nsxml_value_validator_init(validator, &amp;nsxml_value_validator_validate_enum, &amp;nsxml_value_validator_cleanup_enum, &amp;nsxml_value_validator_usage_enum, validator_flags);</text>
			<call-template name="endl"/>
			<text>((struct nsxml_value_validator_enum *)(validator_ptr))-&gt;values = nsxml_item_names_new(</text>
			<for-each select="$selectNode/prg:option">
				<text>"</text>
				<apply-templates select="."/>
				<text>", </text>
			</for-each>
			<text>NULL);</text>
			<call-template name="endl"/>
			<text>nsxml_value_validator_add(</text>
			<!-- <value-of select="$variable"/> -->
			<text>&amp;</text>
			<value-of select="$memberSet"/>
			<text>validators</text>
			<text>, validator);</text>
		</if>
	</template>

	<!-- Initioalize item_info -->
	<template name="prg.c.parser.itemInfoInit">
		<param name="itemNode"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<variable name="abstract">
			<apply-templates select="$itemNode/prg:documentation/prg:abstract"/>
		</variable>
		<variable name="details">
			<apply-templates select="$itemNode/prg:documentation/prg:details"/>
		</variable>
		<text>nsxml_item_info_init(&amp;</text>
		<value-of select="$variable"/>
		<text>, nsxml_item_type_</text>
		<call-template name="prg.c.parser.itemTypeName">
			<with-param name="itemNode" select="$itemNode"/>
			<with-param name="base" select="true()"/>
		</call-template>
		<text>, </text>
		<choose>
			<when test="string-length($abstract) &gt; 0">
				<text>"</text>
				<value-of select="$abstract"/>
				<text>"</text>
			</when>
			<otherwise>
				<text>NULL</text>
			</otherwise>
		</choose>
		<text>, </text>
		<choose>
			<when test="string-length($details) &gt; 0">
				<text>"</text>
				<value-of select="$details"/>
				<text>"</text>
			</when>
			<otherwise>
				<text>NULL</text>
			</otherwise>
		</choose>
		<text>);</text>
	</template>

	<!-- Initialize option_info -->
	<template name="prg.c.parser.optionItemInfoInit">
		<param name="optionNode"/>
		<param name="variable"/>
		<param name="containerVariable"/>
		<param name="rootNode"/>
		<param name="pointer" select="false()"/>
		<call-template name="prg.c.parser.itemInfoInit">
			<with-param name="itemNode" select="$optionNode"/>
			<with-param name="variable" select="concat($variable, '-&gt;item_info')"/>
		</call-template>
		<call-template name="endl"/>
		<text>nsxml_option_info_init(</text>
		<value-of select="$variable"/>
		<text>, nsxml_option_type_</text>
		<call-template name="prg.c.parser.itemTypeName">
			<with-param name="itemNode" select="$optionNode"/>
		</call-template>
		<text>, (0</text>
		<if test="$optionNode/@required">
			<text>| nsxml_option_flag_required</text>
		</if>
		<text>), </text>
		<choose>
			<when test="$optionNode/prg:databinding/prg:variable">
				<text>"</text>
				<!-- Note: here we do not protect variable name -->
				<value-of select="normalize-space($optionNode/prg:databinding/prg:variable)"/>
				<text>"</text>
			</when>
			<otherwise>
				<text>NULL</text>
			</otherwise>
		</choose>
		<text>, nsxml_item_names_new(</text>
		<for-each select="$optionNode/prg:names/*">
			<text>"</text>
			<apply-templates select="."/>
			<text>", </text>
		</for-each>
		<text>NULL), </text>
		<choose>
			<when test="$optionNode/../../self::prg:group">
				<value-of select="$containerVariable"/>
				<text>[</text>
				<call-template name="prg.c.parser.optionIndex">
					<with-param name="rootNode" select="$rootNode"/>
					<with-param name="optionNode" select="$optionNode/../../self::prg:group"/>
				</call-template>
				<text>]</text>
			</when>
			<otherwise>
				<text>NULL</text>
			</otherwise>
		</choose>
		<text>);</text>
		<call-template name="endl"/>
		<!-- Validators -->
		<call-template name="prg.c.parser.infoValidators">
			<with-param name="itemNode" select="$optionNode"/>
			<with-param name="variable" select="$variable"/>
			<with-param name="pointer" select="true()"/>
		</call-template>
	</template>

	<!-- Initialize switch info -->
	<template name="prg.c.parser.switch_optionItemInfoInit">
		<param name="optionNode"/>
		<param name="optionInfoVariable"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<param name="containerVariable"/>
		<param name="rootNode"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<call-template name="prg.c.parser.optionItemInfoInit">
			<with-param name="optionNode" select="$optionNode"/>
			<with-param name="variable">
				<choose>
					<when test="$optionInfoVariable">
						<value-of select="$optionInfoVariable"/>
					</when>
					<otherwise>
						<value-of select="concat($memberSet, 'option_info')"/>
					</otherwise>
				</choose>
			</with-param>
			<with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)"/>
			<with-param name="containerVariable" select="$containerVariable"/>
			<with-param name="rootNode" select="$rootNode"/>
		</call-template>
	</template>

	<!-- argument type enum name -->
	<template name="prg.c.parser.argumentType">
		<param name="typeNode"/>
		<text>nsxml_argument_type_</text>
		<choose>
			<when test="$typeNode/prg:existingcommand">
				<text>existingcommand</text>
			</when>
			<when test="$typeNode/prg:hostname">
				<text>hostname</text>
			</when>
			<when test="$typeNode/prg:number">
				<text>number</text>
			</when>
			<when test="$typeNode/prg:path">
				<text>path</text>
			</when>
			<when test="$typeNode/prg:string">
				<text>string</text>
			</when>
			<otherwise>
				<text>mixed</text>
			</otherwise>
		</choose>
	</template>

	<!-- Initialize argument option -->
	<template name="prg.c.parser.optionArgumentInfoInit">
		<param name="memberSet"/>
		<param name="optionNode"/>
		<param name="containerVariable"/>
		<param name="rootNode"/>
		<value-of select="$memberSet"/>
		<text>argument_type = </text>
		<call-template name="prg.c.parser.argumentType">
			<with-param name="typeNode" select="$optionNode/prg:type"/>
		</call-template>
		<text>;</text>
	</template>

	<!--  -->
	<template name="prg.c.parser.argumentOptionItemInfoInit">
		<param name="optionNode"/>
		<param name="optionInfoVariable"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<param name="containerVariable"/>
		<param name="rootNode"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<call-template name="prg.c.parser.optionItemInfoInit">
			<with-param name="optionNode" select="$optionNode"/>
			<with-param name="variable">
				<choose>
					<when test="$optionInfoVariable">
						<value-of select="$optionInfoVariable"/>
					</when>
					<otherwise>
						<value-of select="concat($memberSet, 'option_info')"/>
					</otherwise>
				</choose>
			</with-param>
			<with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)"/>
			<with-param name="containerVariable" select="$containerVariable"/>
			<with-param name="rootNode" select="$rootNode"/>
		</call-template>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>default_value = </text>
		<choose>
			<when test="$optionNode/prg:default">
				<text>strdup("</text>
				<apply-templates select="$optionNode/prg:default"/>
				<text>");</text>
			</when>
			<otherwise>
				<text>NULL;</text>
			</otherwise>
		</choose>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.optionArgumentInfoInit">
			<with-param name="memberSet" select="$memberSet"/>
			<with-param name="optionNode" select="$optionNode"/>
		</call-template>
	</template>

	<!--  -->
	<template name="prg.c.parser.multiargumentOptionItemInfoInit">
		<param name="optionNode"/>
		<param name="optionInfoVariable"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<param name="containerVariable"/>
		<param name="rootNode"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<call-template name="prg.c.parser.optionItemInfoInit">
			<with-param name="optionNode" select="$optionNode"/>
			<with-param name="variable">
				<choose>
					<when test="$optionInfoVariable">
						<value-of select="$optionInfoVariable"/>
					</when>
					<otherwise>
						<value-of select="concat($memberSet, 'option_info')"/>
					</otherwise>
				</choose>
			</with-param>
			<with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)"/>
			<with-param name="containerVariable" select="$containerVariable"/>
			<with-param name="rootNode" select="$rootNode"/>
		</call-template>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>min_argument = </text>
		<choose>
			<when test="$optionNode/@min">
				<value-of select="$optionNode/@min"/>
			</when>
			<otherwise>
				<text>1</text>
			</otherwise>
		</choose>
		<text>;</text>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>max_argument = </text>
		<choose>
			<when test="$optionNode/@max">
				<value-of select="$optionNode/@max"/>
			</when>
			<otherwise>
				<text>0</text>
			</otherwise>
		</choose>
		<text>;</text>
		<call-template name="endl"/>
		<call-template name="prg.c.parser.optionArgumentInfoInit">
			<with-param name="memberSet" select="$memberSet"/>
			<with-param name="optionNode" select="$optionNode"/>
		</call-template>
	</template>

	<!--  -->
	<template name="prg.c.parser.group_optionItemInfoInit">
		<param name="optionNode"/>
		<param name="optionInfoVariable"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<param name="containerVariable"/>
		<param name="rootNode"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<call-template name="prg.c.parser.optionItemInfoInit">
			<with-param name="optionNode" select="$optionNode"/>
			<with-param name="variable">
				<choose>
					<when test="$optionInfoVariable">
						<value-of select="$optionInfoVariable"/>
					</when>
					<otherwise>
						<value-of select="concat($memberSet, 'option_info')"/>
					</otherwise>
				</choose>
			</with-param>
			<with-param name="pointer" select="(string-length($optionInfoVariable) &gt; 0)"/>
			<with-param name="containerVariable" select="$containerVariable"/>
			<with-param name="rootNode" select="$rootNode"/>
		</call-template>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>group_type = nsxml_group_option_</text>
		<choose>
			<when test="$optionNode/@type = 'exclusive'">
				<text>exclusive</text>
			</when>
			<otherwise>
				<text>standard</text>
			</otherwise>
		</choose>
		<text>;</text>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>option_info_count = </text>
		<value-of select="count($optionNode/prg:options/*)"/>
		<text>;</text>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>option_info_refs = (struct nsxml_option_info **)malloc(sizeof(struct nsxml_option_info *) * </text>
		<value-of select="count($optionNode/prg:options/*)"/>
		<text>);</text>
	</template>

	<!--  -->
	<template name="prg.c.parser.rootItemInfoInit">
		<param name="rootNode"/>
		<param name="variable"/>
		<param name="pointer" select="false()"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<call-template name="prg.c.parser.itemInfoInit">
			<with-param name="itemNode" select="$rootNode"/>
			<with-param name="variable" select="concat($memberSet, 'item_info')"/>
		</call-template>
		<call-template name="endl"/>
		<variable name="optionCount" select="count($rootNode/prg:options/* | $rootNode/prg:options//prg:options/*)"/>
		<value-of select="$memberSet"/>
		<text>option_info_count = </text>
		<value-of select="$optionCount"/>
		<text>;</text>
		<call-template name="endl"/>
		<choose>
			<when test="$optionCount = 0">
				<value-of select="$memberSet"/>
				<text>option_infos = NULL;</text>
			</when>
			<otherwise>
				<value-of select="$memberSet"/>
				<text>option_infos = (struct nsxml_option_info**) malloc(sizeof(struct nsxml_option_info*) * </text>
				<value-of select="$optionCount"/>
				<text>);</text>
				<call-template name="c.block">
					<with-param name="content">
						<text>struct nsxml_option_info *o = NULL;</text>
						<call-template name="endl"/>
						<text>void *o_ptr = NULL;</text>
						<call-template name="endl"/>
						<variable name="containerVariable">
							<value-of select="$memberSet"/>
							<text>option_infos</text>
						</variable>
						<for-each select="$rootNode/prg:options/* | $rootNode/prg:options//prg:options/*">
							<variable name="optionIndex" select="position() - 1"/>
							<variable name="optionVariable">
								<value-of select="$containerVariable"/>
								<text>[</text>
								<value-of select="$optionIndex"/>
								<text>]</text>
							</variable>
							<call-template name="c.inlineComment">
								<with-param name="content">
									<value-of select="$optionIndex"/>
									<if test="./prg:databinding/prg:variable">
										<text>: </text>
										<apply-templates select="./prg:databinding/prg:variable"/>
									</if>
								</with-param>
							</call-template>
							<call-template name="endl"/>
							<value-of select="$optionVariable"/>
							<text> = </text>
							<choose>
								<when test="./self::prg:switch">
									<text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_switch_option_info));</text>
									<call-template name="endl"/>
									<text>o = </text>
									<value-of select="$optionVariable"/>
									<text>;</text>
									<text>o_ptr = o;</text>
									<call-template name="endl"/>
									<call-template name="prg.c.parser.switch_optionItemInfoInit">
										<with-param name="optionNode" select="."/>
										<with-param name="optionInfoVariable" select="'o'"/>
										<with-param name="variable">
											<text>((struct nsxml_switch_option_info*)o_ptr)</text>
										</with-param>
										<with-param name="pointer" select="true()"/>
										<with-param name="containerVariable" select="$containerVariable"/>
										<with-param name="rootNode" select="$rootNode"/>
									</call-template>
								</when>
								<when test="./self::prg:argument">
									<text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_argument_option_info));</text>
									<call-template name="endl"/>
									<text>o = </text>
									<value-of select="$optionVariable"/>
									<text>;</text>
									<text>o_ptr = o;</text>
									<call-template name="endl"/>
									<call-template name="prg.c.parser.argumentOptionItemInfoInit">
										<with-param name="optionNode" select="."/>
										<with-param name="optionInfoVariable" select="'o'"/>
										<with-param name="variable">
											<text>((struct nsxml_argument_option_info*)o_ptr)</text>
										</with-param>
										<with-param name="pointer" select="true()"/>
										<with-param name="containerVariable" select="$containerVariable"/>
										<with-param name="rootNode" select="$rootNode"/>
									</call-template>
								</when>
								<when test="./self::prg:multiargument">
									<text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_multiargument_option_info));</text>
									<call-template name="endl"/>
									<text>o = </text>
									<value-of select="$optionVariable"/>
									<text>;</text>
									<text>o_ptr = o;</text>
									<call-template name="endl"/>
									<call-template name="prg.c.parser.multiargumentOptionItemInfoInit">
										<with-param name="optionNode" select="."/>
										<with-param name="optionInfoVariable" select="'o'"/>
										<with-param name="variable">
											<text>((struct nsxml_multiargument_option_info*)o_ptr)</text>
										</with-param>
										<with-param name="pointer" select="true()"/>
										<with-param name="containerVariable" select="$containerVariable"/>
										<with-param name="rootNode" select="$rootNode"/>
									</call-template>
								</when>
								<when test="./self::prg:group">
									<text>(struct nsxml_option_info*) malloc(sizeof(struct nsxml_group_option_info));</text>
									<call-template name="endl"/>
									<text>o = </text>
									<value-of select="$optionVariable"/>
									<text>;</text>
									<text>o_ptr = o;</text>
									<call-template name="endl"/>
									<call-template name="prg.c.parser.group_optionItemInfoInit">
										<with-param name="optionNode" select="."/>
										<with-param name="optionInfoVariable" select="'o'"/>
										<with-param name="variable">
											<text>((struct nsxml_group_option_info*)o_ptr)</text>
										</with-param>
										<with-param name="pointer" select="true()"/>
										<with-param name="containerVariable" select="$containerVariable"/>
										<with-param name="rootNode" select="$rootNode"/>
									</call-template>
								</when>
							</choose>
							<call-template name="endl"/>
						</for-each>
						<!-- Link group options -->
						<for-each select="$rootNode//prg:group">
							<variable name="optionIndex">
								<call-template name="prg.c.parser.optionIndex">
									<with-param name="rootNode" select="$rootNode"/>
									<with-param name="optionNode" select="."/>
								</call-template>
							</variable>
							<variable name="groupNode" select="."/>
							<text>o = info-&gt;rootitem_info.option_infos[</text>
							<value-of select="$optionIndex"/>
							<text>];</text>
							<text>o_ptr = o;</text>
							<call-template name="endl"/>
							<for-each select="$groupNode/prg:options/*">
								<text>((struct nsxml_group_option_info *)(o_ptr))-&gt;option_info_refs[</text>
								<value-of select="position() - 1"/>
								<text>] = info-&gt;rootitem_info.option_infos[</text>
								<call-template name="prg.c.parser.optionIndex">
									<with-param name="rootNode" select="$rootNode"/>
									<with-param name="optionNode" select="."/>
								</call-template>
								<text>];</text>
								<call-template name="endl"/>
							</for-each>
						</for-each>
					</with-param>
				</call-template>
			</otherwise>
		</choose>
		<!-- Positional arguments -->
		<call-template name="endl"/>
		<variable name="valueCount" select="count($rootNode/prg:values/*)"/>
		<value-of select="$memberSet"/>
		<text>positional_argument_info_count = </text>
		<value-of select="$valueCount"/>
		<text>;</text>
		<call-template name="endl"/>
		<value-of select="$memberSet"/>
		<text>positional_argument_infos = </text>
		<choose>
			<when test="$valueCount = 0">
				<text>NULL</text>
			</when>
			<otherwise>
				<text>(struct nsxml_positional_argument_info*)malloc (sizeof(struct nsxml_positional_argument_info) * </text>
				<value-of select="$valueCount"/>
				<text>)</text>
			</otherwise>
		</choose>
		<text>;</text>
		<if test="$valueCount &gt; 0">
			<call-template name="c.block">
				<with-param name="content">
					<text>int flags = 0;</text>
					<for-each select="$rootNode/prg:values/*">
						<variable name="info">
							<value-of select="$memberSet"/>
							<text>positional_argument_infos[</text>
							<value-of select="position() - 1"/>
							<text>]</text>
						</variable>
						<call-template name="endl"/>
						<!-- item info -->
						<call-template name="prg.c.parser.itemInfoInit">
							<with-param name="itemNode" select="."/>
							<with-param name="variable" select="concat($info, '.item_info')"/>
						</call-template>
						<call-template name="endl"/>
						<text>flags = 0;</text>
						<call-template name="endl"/>
						<if test="./@required = 'true'">
							<text>flags |= nsxml_positional_argument_required;</text>
							<call-template name="endl"/>
						</if>
						<text>nsxml_positional_argument_info_init(&amp;</text>
						<value-of select="$info"/>
						<!-- flags -->
						<text>, flags</text>
						<!-- arg type -->
						<text>, </text>
						<call-template name="prg.c.parser.argumentType">
							<with-param name="typeNode" select="./prg:type"/>
						</call-template>
						<text>, </text>
						<choose>
							<when test="./self::prg:value">
								<text>1</text>
							</when>
							<when test="./self::prg:other and ./@max">
								<value-of select="./@max"/>
							</when>
							<otherwise>
								<text>0</text>
							</otherwise>
						</choose>
						<text>);</text>
						<call-template name="endl"/>
						<!-- validators -->
						<call-template name="prg.c.parser.infoValidators">
							<with-param name="itemNode" select="."/>
							<with-param name="variable" select="$info"/>
						</call-template>
					</for-each>
				</with-param>
			</call-template>
		</if>
	</template>

	<!--  -->
	<template name="prg.c.parser.subcommandInfoInit">
		<param name="subcommandNode" select="."/>
		<param name="variable"/>
		<param name="pointer" select="true()"/>
		<variable name="memberSet">
			<call-template name="prg.c.parser.memberSet">
				<with-param name="variable" select="$variable"/>
				<with-param name="pointer" select="$pointer"/>
			</call-template>
		</variable>
		<value-of select="$memberSet"/>
		<text>names = nsxml_item_names_new("</text>
		<apply-templates select="$subcommandNode/prg:name"/>
		<text>", </text>
		<for-each select="$subcommandNode/prg:aliases/prg:alias">
			<text>"</text>
			<apply-templates select="."/>
			<text>", </text>
		</for-each>
		<text>NULL);</text>
		<call-template name="endl"/>
		<!-- rootitem members -->
		<call-template name="prg.c.parser.rootItemInfoInit">
			<with-param name="rootNode" select="$subcommandNode"/>
			<with-param name="variable">
				<value-of select="$variable"/>
				<text>-&gt;rootitem_info</text>
			</with-param>
		</call-template>
	</template>

	<!-- Typedefs -->
	<template name="prg.c.parser.programInfoTypedefs">
		<text>typedef struct nsxml_program_info </text>
		<value-of select="$prg.c.parser.structName.program_info"/>
		<text>;</text>
	</template>

	<!-- Program info initioalization function declaration -->
	<template name="prg.c.parser.programInfoInitFunctionDeclaration">
		<param name="programNode" select="."/>
		<call-template name="c.functionDeclaration">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_init"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info initioalization function definition -->
	<template name="prg.c.parser.programInfoInitFunctionDefinition">
		<param name="programNode" select="."/>
		<variable name="infoParam" select="'info'"/>
		<variable name="subcommandCount" select="count($programNode/prg:subcommands/*)"/>
		<call-template name="c.functionDefinition">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_init"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info</text>
			</with-param>
			<with-param name="content">
				<text>struct nsxml_value_validator *validator;</text>
				<text> void *validator_ptr;</text>
				<call-template name="endl"/>
				<text>int validator_flags;</text>
				<call-template name="endl"/>
				<text>validator = NULL;</text>
				<call-template name="endl"/>
				<text> validator_ptr = validator;</text>
				<call-template name="endl"/>
				<text>validator_flags = 0;</text>
				<call-template name="endl"/>
				<!-- nsxml_program_info member -->
				<value-of select="$infoParam"/>
				<text>-&gt;name = "</text>
				<apply-templates select="$programNode/prg:name"/>
				<text>";</text>
				<call-template name="endl"/>
				<value-of select="$infoParam"/>
				<text>-&gt;subcommand_info_count = </text>
				<value-of select="$subcommandCount"/>
				<text>;</text>
				<call-template name="endl"/>
				<value-of select="$infoParam"/>
				<text>-&gt;subcommand_infos = </text>
				<choose>
					<when test="$subcommandCount = 0">
						<text>NULL;</text>
					</when>
					<otherwise>
						<text>(struct nsxml_subcommand_info *)(malloc(sizeof(struct nsxml_subcommand_info) *</text>
						<value-of select="$subcommandCount"/>
						<text>));</text>
						<for-each select="$programNode/prg:subcommands/prg:subcommand">
							<variable name="subcommandIndex" select="position() - 1"/>
							<call-template name="c.block">
								<with-param name="content">
									<call-template name="c.inlineComment">
										<with-param name="content" select="prg:name"/>
									</call-template>
									<call-template name="endl"/>
									<text>struct nsxml_subcommand_info *s = &amp;(</text>
									<value-of select="$infoParam"/>
									<text>-&gt;subcommand_infos[</text>
									<value-of select="$subcommandIndex"/>
									<text>]);</text>
									<call-template name="endl"/>
									<call-template name="prg.c.parser.subcommandInfoInit">
										<with-param name="variable" select="'s'"/>
									</call-template>
								</with-param>
							</call-template>
						</for-each>
					</otherwise>
				</choose>
				<call-template name="endl"/>
				<!-- rootitem members -->
				<call-template name="prg.c.parser.rootItemInfoInit">
					<with-param name="rootNode" select="$programNode"/>
					<with-param name="variable">
						<value-of select="$infoParam"/>
						<text>-&gt;rootitem_info</text>
					</with-param>
				</call-template>
				<call-template name="endl"/>
				<text>/*shut up compiler */</text>
				<call-template name="endl"/>
				<text>validator_flags = (int)sizeof(validator);</text>
				<call-template name="endl"/>
				<text>validator_ptr = &amp;validator_flags;</text>
				<call-template name="endl"/>
				<text> validator = (struct nsxml_value_validator *)validator_ptr;</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info creation function declaration -->
	<template name="prg.c.parser.programInfoNewFunctionDeclaration">
		<param name="programNode" select="."/>
		<call-template name="c.functionDeclaration">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_new"/>
			<with-param name="returnType">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info creation function definition -->
	<template name="prg.c.parser.programInfoNewFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_new"/>
			<with-param name="returnType">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *</text>
			</with-param>
			<with-param name="content">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info = (</text>
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *)malloc(sizeof(</text>
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text>));</text>
				<call-template name="endl"/>
				<value-of select="$prg.c.parser.functionName.program_info_init"/>
				<text>(info);</text>
				<call-template name="endl"/>
				<text>return info;</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info cleanup function declaration -->
	<template name="prg.c.parser.programInfoCleanupFunctionDeclaration">
		<param name="programNode" select="."/>
		<call-template name="c.functionDeclaration">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_cleanup"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info cleanup function definition -->
	<template name="prg.c.parser.programInfoCleanupFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_cleanup"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info</text>
			</with-param>
			<with-param name="content">
				<text>nsxml_program_info_cleanup(info);</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info free function declaration -->
	<template name="prg.c.parser.programInfoFreeFunctionDeclaration">
		<param name="programNode" select="."/>
		<call-template name="c.functionDeclaration">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_free"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info</text>
			</with-param>
		</call-template>
	</template>

	<!-- Program info free function definition -->
	<template name="prg.c.parser.programInfoFreeFunctionDefinition">
		<param name="programNode" select="."/>
		<call-template name="c.functionDefinition">
			<with-param name="name" select="$prg.c.parser.functionName.program_info_free"/>
			<with-param name="parameters">
				<value-of select="$prg.c.parser.structName.program_info"/>
				<text> *info</text>
			</with-param>
			<with-param name="content">
				<value-of select="$prg.c.parser.functionName.program_info_cleanup"/>
				<text>(info);</text>
				<call-template name="endl"/>
				<text>free(info);</text>
			</with-param>
		</call-template>
	</template>

</stylesheet>
