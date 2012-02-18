<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<!-- Create a bash completion script for the program -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<import href="./xul-ui-base.xsl" />

	<output method="xml" encoding="utf-8" indent="yes" />

	<strip-space elements="*" />

	<param name="prg.xul.windowWidth" select="1024" />
	<param name="prg.xul.windowHeight" select="768" />

	<!-- Option label (using the best element available) -->
	<template name="prg.xul.optionLabel">
		<param name="optionNode" select="." />
		<choose>
			<when test="$optionNode/prg:ui/prg:label">
				<value-of select="normalize-space($optionNode/prg:ui/prg:label/text())" />
			</when>
			<when test="$optionNode/prg:documentation/prg:abstract">
				<value-of select="normalize-space($optionNode/prg:documentation/prg:abstract/text())" />
			</when>
			<when test="$optionNode/prg:names/prg:long">
				<value-of select="normalize-space($optionNode/prg:names/prg:long/text())" />
			</when>
			<when test="$optionNode/prg:databinding/prg:variable">
				<value-of select="normalize-space($optionNode/prg:databinding/prg:variable/text())" />
			</when>
			<when test="$optionNode/prg:names/prg:short">
				<value-of select="normalize-space($optionNode/prg:names/prg:short/text())" />
			</when>
			<otherwise>
				<call-template name="prg.optionId">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</otherwise>
		</choose>
	</template>

	<template name="prg.xul.valueLabel">
		<param name="valueNode" select="." />
		<param name="index" />
		<choose>
			<when test="$valueNode/prg:documentation/prg:abstract">
				<value-of select="$valueNode/prg:documentation/prg:abstract" />
			</when>
			<otherwise>
				<choose>
					<when test="$valueNode/self::other">
						<text>Other</text>
					</when>
					<otherwise>
						<value-of select="$index" />
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<template name="prg.xul.fsButtonDialogMode">
		<param name="pathNode" />

		<variable name="kindsNode" select="$pathNode/prg:kinds" />
		<variable name="isFolderOnly" select="$kindsNode and (count($kindsNode/descendant::*) = 1) and $kindsNode/prg:folder" />
		<variable name="isFileOnly" select="$kindsNode and (count($kindsNode/descendant::*) = 1) and $kindsNode/prg:file" />

		<choose>
			<when test="$isFolderOnly">
				<attribute name="dialogmode">folder</attribute>
			</when>
			<when test="not($pathNode/@exist) and $isFileOnly">
				<attribute name="dialogmode">save</attribute>
			</when>
			<!-- Default behavior in other cases -->
		</choose>
	</template>

	<!-- Escape text to be used as an attribute value -->
	<template name="prg.xul.attributeEscapedValue">
		<param name="value" select="." />
		<call-template name="str.replaceAll">
			<with-param name="text" select="$value" />
			<with-param name="replace">
				<text>"</text>
			</with-param>
			<with-param name="by">
				<text>\&quot;</text>
			</with-param>
		</call-template>
	</template>

	<!-- Control of the left column of the grid row -->
	<template name="prg.xul.optionLabelControl">
		<param name="optionNode" select="." />

		<variable name="parentOptionNode" select="$optionNode/../.." />
		<variable name="optionId">
			<call-template name="prg.optionId">
				<with-param name="optionNode" select="$optionNode" />
			</call-template>
		</variable>

		<element name="xul:hbox">
			<if test="$optionNode/self::prg:group">
				<element name="xul:radiogroup">
					<attribute name="id">
						<value-of select="$optionId" />
						<text>:group</text>
					</attribute>
				</element>
			</if>
			<element name="xul:label">
				<attribute name="value">
					<call-template name="prg.xul.optionLabel">
						<with-param name="optionNode" select="$optionNode" />
					</call-template>
				</attribute>
				<attribute name="id">
					<value-of select="$optionId" />
					<text>:label</text>
				</attribute>
			</element>
			<element name="xul:checkbox">
				<attribute name="label">
					<call-template name="prg.xul.optionLabel">
						<with-param name="optionNode" select="$optionNode" />
					</call-template>
				</attribute>
				<attribute name="id">
					<value-of select="$optionId" />
					<text>:checkbox</text>
				</attribute>
			</element>
			<element name="xul:radio">
				<attribute name="label">
					<call-template name="prg.xul.optionLabel">
						<with-param name="optionNode" select="$optionNode" />
					</call-template>
				</attribute>
				<attribute name="id">
					<value-of select="$optionId" />
					<text>:radio</text>
				</attribute>
				<attribute name="group">
					<call-template name="prg.optionId">
						<with-param name="optionNode" select="$parentOptionNode" />
					</call-template>
					<text>:group</text>
				</attribute>
			</element>
			<element name="xul:box">
				<attribute name="id">
					<call-template name="prg.optionId">
						<with-param name="optionNode" select="$optionNode" />
					</call-template>
				</attribute>
				<attribute name="class">
					<choose>
						<when test="$optionNode/self::prg:group">
							<text>groupOption</text>
						</when>
						<when test="$optionNode/self::prg:argument">
							<text>argumentOption</text>
						</when>
						<when test="$optionNode/self::prg:multiargument">
							<text>multiargumentOption</text>
						</when>
						<otherwise>
							<text>switchOption</text>
						</otherwise>
					</choose>
				</attribute>
				<if test="$optionNode[@required = 'true']">
					<attribute name="required">true</attribute>
				</if>
				<if test="$parentOptionNode">
					<attribute name="parentId">
						<call-template name="prg.optionId">
							<with-param name="optionNode" select="$parentOptionNode" />
						</call-template>
					</attribute>
				</if>
				<if test="$optionNode/self::prg:group and $optionNode/@type">
					<attribute name="groupType"><value-of select="$optionNode/@type" /></attribute>
				</if>
				<if test="$optionNode[self::prg:argument or self::prg:multiargument]">
					<attribute name="valueControlId">
						<call-template name="prg.optionId">
							<with-param name="optionNode" select="$optionNode" />
						</call-template>
						<text>:value</text>
					</attribute>
				</if>
			</element>
		</element>
	</template>

	<!-- A series of attributes used by textbox for autocompletion -->
	<template name="prg.xul.textboxAutocompleAtributes">
		<param name="selectNode" />
		<attribute name="type">autocomplete</attribute>
		<attribute name="autocompletesearch">ns-value-autocomplete</attribute>
		<attribute name="autocompletesearchparam">
			<text>[</text>
			<for-each select="$selectNode/*">
				<text>&quot;</text>
				<call-template name="str.replaceAll">
					<with-param name="text" select="." />
					<with-param name="replace">"</with-param>
					<with-param name="by">\&quot;</with-param>
				</call-template>
				<text>&quot;</text>
				<if test="position() != last()">
					<text>, </text>
				</if>
			</for-each>
			<text>]</text>
		</attribute>
	</template>

	<!-- Construct the file filters for a fsbutton -->
	<template name="prg.xul.fsButtonFilterAttribute">
		<param name="patternsNode" />
		<attribute name="filters">
			<for-each select="$patternsNode/prg:pattern">
				<call-template name="prg.xul.attributeEscapedValue">
					<with-param name="value" select="prg:name" />
				</call-template>
				<text>|</text>
				<for-each select="prg:rules/prg:rule">
					<choose>
						<when test="prg:startWith">
							<value-of select="prg:startWith" /><text>*</text>
						</when>
						<when test="prg:endWith">
							<text>*</text><value-of select="prg:endWith" />
						</when>
						<otherwise>
							<text>*</text><value-of select="prg:contains" /><text>*</text>
						</otherwise>
					</choose>
					<if test="position() != last()">
						<text>;</text>
					</if>
				</for-each>
				<if test="position() != last()">
					<text>|</text>
				</if>
			</for-each>
		</attribute>
	</template>

	<!-- Convert a prg:select to menuitems for a menulist -->
	<template name="prg.xul.selectToMenuItems">
		<param name="selectNode" />
		<param name="selectedIndex" />
		<for-each select="$selectNode/*">
			<element name="xul:menuitem">
				<attribute name="label"><value-of select="." /></attribute>
				<attribute name="value"><value-of select="." /></attribute>
				<if test="normalize-space($selectNode/../prg:default/text()) = normalize-space(text())">
					<attribute name="selected">true</attribute>
				</if>
				<if test="position() = $selectedIndex">
					<attribute name="selected">true</attribute>
				</if>
			</element>
		</for-each>
	</template>

	<template name="prg.xul.optionLabelColumn">
		<param name="level" select="0" />
		<param name="optionNode" select="." />

		<element name="xul:hbox">
			<element name="xul:spacer">
				<attribute name="width"><value-of select="$level * 10" /></attribute>
			</element>
			<call-template name="prg.xul.optionLabelControl">
				<with-param name="optionNode" select="$optionNode" />
			</call-template>
		</element>
	</template>

	<!-- Add a dummy (hidden) radio button to handle optional group case -->
	<template name="prg.xul.groupValueControl">
		<param name="node" select="." />

		<variable name="prg.optionId">
			<call-template name="prg.optionId">
				<with-param name="optionNode" select="$node" />
			</call-template>
		</variable>

		<element name="xul:radio">
			<attribute name="id">
				<value-of select="$optionId" />
				<text>:dummyradio</text>
			</attribute>
			<!-- <attribute name="hidden">true</attribute> -->
			<attribute name="group">
				<value-of select="$optionId" />
				<text>:group</text>
			</attribute>
		</element>
	</template>

	<!-- Construct value control (single argument or anonymous value -->
	<template name="prg.xul.singleValueControl">
		<param name="node" select="." />
		<param name="valueIndex" />

		<variable name="controlId">
			<choose>
				<when test="$node/self::prg:argument">
					<call-template name="prg.optionId">
						<with-param name="optionNode" select="$node" />
					</call-template>
				</when>
				<when test="$node/self::prg:value">
					<call-template name="prg.xul.valueId">
						<with-param name="valueNode" select="$node" />
						<with-param name="index" select="$valueIndex" />
					</call-template>
				</when>
			</choose>
			<text>:value</text>
		</variable>
		<variable name="label">
			<choose>
				<when test="$node/self::prg:argument">
					<call-template name="prg.xul.optionLabel">
						<with-param name="optionNode" select="$node" />
					</call-template>
				</when>
				<when test="$node/self::prg:value">
					<call-template name="prg.xul.valueLabel">
						<with-param name="valueNode" select="$node" />
						<with-param name="index" select="$valueIndex" />
					</call-template>
				</when>
			</choose>
		</variable>
		<variable name="typeNode" select="$node/prg:type" />
		<variable name="defaultNode" select="$node/prg:default" />
		<variable name="selectNode" select="$node/prg:select" />

		<choose>
			<when test="$node/prg:select[@restrict = 'true']">
				<element name="xul:box">
					<attribute name="id"><value-of select="$controlId" /></attribute>
					<attribute name="class">argumentMenuValue</attribute>
					<call-template name="prg.xul.selectToMenuItems">
						<with-param name="selectNode" select="$selectNode" />
					</call-template>
				</element>
			</when>
			<when test="($typeNode/prg:number)">
				<variable name="numberNode" select="$typeNode/prg:number" />
				<element name="xul:box">
					<attribute name="class">argumentNumberValue</attribute>
					<attribute name="id"><value-of select="$controlId" /></attribute>
					<if test="$numberNode/@min">
						<attribute name="min">
							<value-of select="$numberNode/@min" />
						</attribute>
					</if>
					<if test="$numberNode/@max">
						<attribute name="max">
							<value-of select="$numberNode/@max" />
						</attribute>
					</if>
					<if test="$numberNode/@decimal">
						<attribute name="decimal">
							<value-of select="$numberNode/@decimal" />
						</attribute>
					</if>
					<if test="$defaultNode">
						<attribute name="default">
							<value-of select="$defaultNode" />
						</attribute>
					</if>
				</element>
			</when>
			<when test="$typeNode/prg:path">
				<variable name="pathNode" select="$typeNode/prg:path" />
				<element name="xul:box">
					<attribute name="class">argumentPathValue</attribute>
					<attribute name="id"><value-of select="$controlId" /></attribute>
					<attribute name="dialogtitle">
						<value-of select="$label"></value-of>
					</attribute>
					<if test="$defaultNode">
						<attribute name="default">
							<value-of select="$defaultNode" />
						</attribute>
					</if>
					<if test="$selectNode">
						<call-template name="prg.xul.textboxAutocompleAtributes">
							<with-param name="selectNode" select="$selectNode" />
						</call-template>
					</if>
					<if test="$pathNode/prg:patterns">
						<call-template name="prg.xul.fsButtonFilterAttribute">
							<with-param name="patternsNode" select="$pathNode/prg:patterns" />
						</call-template>
					</if>
					<call-template name="prg.xul.fsButtonDialogMode">
						<with-param name="pathNode" select="$pathNode" />
					</call-template>
				</element>
			</when>
			<when test="(not ($typeNode)) or ($typeNode[prg:string or prg:mixed])">
				<element name="xul:box">
					<attribute name="class">argumentTextValue</attribute>
					<attribute name="id"><value-of select="$controlId" /></attribute>
					<if test="$defaultNode">
						<attribute name="default">
							<value-of select="$defaultNode" />
						</attribute>
					</if>
					<if test="$selectNode">
						<call-template name="prg.xul.textboxAutocompleAtributes">
							<with-param name="selectNode" select="$selectNode" />
						</call-template>
					</if>
				</element>
			</when>
		</choose>
	</template>

	<template name="prg.xul.multiValueControl">
		<param name="node" select="." />
		<param name="valueIndex" />

		<variable name="controlId">
			<choose>
				<when test="$node/self::prg:multiargument">
					<call-template name="prg.optionId">
						<with-param name="optionNode" select="$node" />
					</call-template>
				</when>
				<when test="$node/self::prg:other">
					<call-template name="prg.xul.valueId">
						<with-param name="valueNode" select="$node" />
						<with-param name="index" select="$valueIndex" />
					</call-template>
				</when>
			</choose>
			<text>:value</text>
		</variable>

		<variable name="label">
			<choose>
				<when test="$node/self::prg:multiargument">
					<call-template name="prg.xul.optionLabel">
						<with-param name="optionNode" select="$node" />
					</call-template>
				</when>
				<when test="$node/self::prg:other">
					<call-template name="prg.xul.valueLabel">
						<with-param name="valueNode" select="$node" />
					</call-template>
				</when>
			</choose>
		</variable>

		<variable name="proxyId">
			<value-of select="$controlId" />
			<text>:proxy</text>
		</variable>

		<variable name="inputId">
			<value-of select="$controlId" />
			<text>:input</text>
		</variable>

		<variable name="typeNode" select="$node/prg:type" />
		<variable name="defaultNode" select="$node/prg:default" />
		<variable name="selectNode" select="$node/prg:select" />

		<element name="xul:grid">
			<attribute name="flex">1</attribute>
			<element name="xul:columns">
				<element name="xul:column">
					<attribute name="flex">1</attribute>
				</element>
				<element name="xul:column" />
			</element>
			<element name="xul:rows">
				<variable name="useSingleRow" select="$typeNode/prg:path and not($selectNode/@restrict)" />
				<if test="not($useSingleRow)">
					<element name="xul:row">
						<choose>
							<when test="$selectNode[@restrict = 'true']">
								<element name="xul:box">
									<attribute name="class">argumentMenuValue</attribute>
									<attribute name="id"><value-of select="$inputId" /></attribute>
									<call-template name="prg.xul.selectToMenuItems">
										<with-param name="selectNode" select="$selectNode" />
										<with-param name="selectedIndex" select="1" />
									</call-template>
								</element>
							</when>
							<when test="($typeNode/prg:number)">
								<variable name="numberNode" select="$typeNode/prg:number" />

								<element name="xul:box">
									<attribute name="class">argumentNumberValue</attribute>
									<attribute name="id"><value-of select="$inputId" /></attribute>
									<if test="$numberNode/@min">
										<attribute name="min"><value-of select="$numberNode/@min" /></attribute>
									</if>
									<if test="$numberNode/@max">
										<attribute name="max"><value-of select="$numberNode/@max" /></attribute>
									</if>
									<if test="$numberNode/@decimal">
										<attribute name="decimal"><value-of select="$numberNode/@decimal" /></attribute>
									</if>
									<if test="$defaultNode">
										<attribute name="default"><value-of select="$defaultNode/prg:default" /></attribute>
									</if>
								</element>
							</when>
							<when test="(not ($typeNode)) or ($typeNode[prg:string or prg:mixed])">
								<element name="xul:box">
									<attribute name="class">argumentTextValue</attribute>
									<attribute name="id"><value-of select="$inputId" /></attribute>
									<if test="$defaultNode">
										<attribute name="default"><value-of select="$defaultNode" /></attribute>
									</if>
									<if test="$selectNode">
										<call-template name="prg.xul.textboxAutocompleAtributes">
											<with-param name="selectNode" select="$selectNode" />
										</call-template>
									</if>
								</element>
							</when>
						</choose>
						<element name="xul:button">
							<attribute name="label">Add</attribute>
							<attribute name="oncommand">
								<value-of select="$prg.xul.js.mainWindowInstanceName" /><text>.addInputToMultiValue('</text>
								<value-of select="$controlId" /><text>');</text>
							</attribute>
						</element>
					</element>
				</if>
				<element name="xul:row">
					<element name="xul:box">
						<attribute name="flex">1</attribute>
						<attribute name="class">multiargumentListbox</attribute>
						<attribute name="id"><value-of select="$controlId" /></attribute>
					</element>
					<element name="xul:vbox">
						<if test="$useSingleRow">
							<variable name="pathNode" select="$typeNode/prg:path" />
							<element name="xul:box">
								<attribute name="class">fsbutton</attribute>
								<attribute name="label">Add...</attribute>
								<attribute name="onchange">
									<text>document.getElementById('</text><value-of select="$proxyId" /><text>').addElement(this.value);</text>
								</attribute>
								<if test="$pathNode/prg:patterns">
									<call-template name="prg.xul.fsButtonFilterAttribute">
										<with-param name="patternsNode" select="$pathNode/prg:patterns" />
									</call-template>
								</if>
								<call-template name="prg.xul.fsButtonDialogMode">
									<with-param name="pathNode" select="$pathNode" />
								</call-template>
							</element>
						</if>
						<element name="xul:box">
							<attribute name="class">itemarrangementbuttonbox</attribute>
							<attribute name="id"><value-of select="$proxyId" /></attribute>
							<attribute name="targetId"><value-of select="$controlId" /></attribute>
						</element>
					</element>
				</element>
			</element>
		</element>
	</template>

	<!-- Construct the value control (if any) for an option -->
	<template name="prg.xul.optionValueColumn">
		<param name="level" select="0" />
		<param name="optionNode" select="." />

		<choose>
			<when test="$optionNode/self::prg:group">
				<!-- <call-template name="prg.xul.groupValueControl"> <with-param name="node"
					select="$optionNode" /> </call-template> -->
			</when>
			<when test="$optionNode/self::prg:argument">
				<call-template name="prg.xul.singleValueControl">
					<with-param name="node" select="$optionNode" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:multiargument">
				<call-template name="prg.xul.multiValueControl">
					<with-param name="node" select="$optionNode" />
				</call-template>
			</when>
		</choose>
	</template>

	<!-- Construct option controls (label + value) as a grid row -->
	<template name="prg.xul.optionRow">
		<param name="level" select="0" />
		<param name="optionNode" select="." />

		<variable name="groupOptionNodes" select="$optionNode/prg:options/*[not(prg:ui) or prg:ui[@mode = 'default']]" />

		<!-- Check empty group case -->
		<variable name="isEmptyGroup" select="$optionNode/self::prg:group and (count($groupOptionNodes) = 0)" />

		<variable name="isSingleElementGroup" select="$optionNode/self::prg:group and (count($groupOptionNodes) = 1)" />

		<choose>
			<!-- Flatten single-element groups -->
			<!-- @todo disable 'radiobox' case in option or simulate a pseudo radiogroup -->
			<when test="$isSingleElementGroup">
				<call-template name="prg.xul.optionRow">
					<with-param name="level" select="$level" />
					<with-param name="optionNode" select="$groupOptionNodes" />
				</call-template>
			</when>

			<when test="not($isEmptyGroup)">
				<comment>
					<value-of select="name($optionNode)" />
					<text> </text>
					<call-template name="prg.xul.optionLabel" />
				</comment>

				<element name="xul:row">
					<call-template name="prg.xul.optionLabelColumn">
						<with-param name="level" select="$level" />
						<with-param name="optionNode" select="$optionNode" />
					</call-template>

					<call-template name="prg.xul.optionValueColumn">
						<with-param name="level" select="$level" />
						<with-param name="optionNode" select="$optionNode" />
					</call-template>
				</element>

				<if test="$optionNode/self::prg:group">
					<for-each select="$groupOptionNodes">
						<call-template name="prg.xul.optionRow">
							<with-param name="level" select="$level + 1" />
						</call-template>
					</for-each>
				</if>
			</when>
		</choose>
	</template>

	<!-- Construct the opiion grid fo a root prg:options node -->
	<template name="prg.xul.optionsGrid">
		<param name="optionsNode" select="." />

		<element name="xul:grid">
			<attribute name="flex">1</attribute>
			<element name="xul:columns">
				<comment>
					<text>Option label / Option selection</text>
				</comment>
				<element name="xul:column">
					<attribute name="flex">1</attribute>
				</element>
				<comment>
					<text>Option argument value(s)</text>
				</comment>
				<element name="xul:column">
					<attribute name="flex">1</attribute>
				</element>
			</element>
			<element name="xul:rows">
				<for-each select="$optionsNode/*[not(prg:ui) or prg:ui[@mode = 'default']]">
					<call-template name="prg.xul.optionRow">
						<with-param name="level" select="0" />
					</call-template>
				</for-each>
			</element>
		</element>
	</template>

	<template name="prg.xul.anonymousValueLabelColumn">
		<param name="valueNode" select="." />
		<param name="index" />
		<variable name="valueId">
			<call-template name="prg.xul.valueId">
				<with-param name="valueNode" select="$valueNode" />
				<with-param name="index" select="$index" />
			</call-template>
		</variable>

		<element name="xul:hbox">
			<attribute name="class">programValue</attribute>
			<attribute name="id">
				<value-of select="$valueId" />
			</attribute>
			<attribute name="label">
				<call-template name="prg.xul.valueLabel">
						<with-param name="valueNode" select="$valueNode" />
						<with-param name="index" select="$index" />
					</call-template>				
			</attribute>
			<attribute name="valueControlId">
				<value-of select="$valueId" />
				<text>:value</text>
			</attribute>
			<attribute name="index">
				<value-of select="$index" />
			</attribute>
		</element>
	</template>

	<template name="prg.xul.anonymousValueValueColumn">
		<param name="valueNode" select="." />
		<param name="index" />

		<variable name="typeNode" select="$valueNode/prg:type" />
		<variable name="selectNode" select="$valueNode/prg:select" />

		<variable name="valueId">
			<call-template name="prg.xul.valueId">
				<with-param name="valueNode" select="$valueNode" />
				<with-param name="index" select="$index"></with-param>
			</call-template>
		</variable>

		<choose>
			<when test="$valueNode/self::prg:value">
				<call-template name="prg.xul.singleValueControl">
					<with-param name="node" select="$valueNode" />
					<with-param name="valueIndex" select="$index" />
				</call-template>
			</when>
			<when test="$valueNode/self::prg:other">
				<call-template name="prg.xul.multiValueControl">
					<with-param name="node" select="$valueNode" />
					<with-param name="valueIndex" select="$index" />
				</call-template>
			</when>
		</choose>
	</template>

	<template name="prg.xul.anonymousValueRow">
		<param name="valueNode" select="." />
		<param name="index" />

		<comment>
			<if test="$valueNode/self::prg:other">
				<text>Other </text>
			</if>
			<text>Value</text>
			<if test="$valueNode/self::prg:value">
				<text> </text>
				<value-of select="$index" />
			</if>
		</comment>

		<element name="xul:row">
			<call-template name="prg.xul.anonymousValueLabelColumn">
				<with-param name="valueNode" select="$valueNode" />
				<with-param name="index" select="$index" />
			</call-template>

			<call-template name="prg.xul.anonymousValueValueColumn">
				<with-param name="valueNode" select="$valueNode" />
				<with-param name="index" select="$index" />
			</call-template>
		</element>
	</template>

	<template name="prg.xul.anonymousValueGrid">
		<param name="valuesNode" select="." />

		<element name="xul:grid">
			<attribute name="flex">1</attribute>
			<element name="xul:columns">
				<comment>
					<text>Anonymous value labels</text>
				</comment>
				<element name="xul:column">
					<attribute name="flex">1</attribute>
				</element>
				<comment>
					<text>Anonymous value ... value control</text>
				</comment>
				<element name="xul:column">
					<attribute name="flex">1</attribute>
				</element>
			</element>
			<element name="xul:rows">
				<for-each select="$valuesNode/prg:value">
					<call-template name="prg.xul.anonymousValueRow">
						<with-param name="index" select="position()" />
					</call-template>
				</for-each>
				<if test="$valuesNode/prg:other">
					<call-template name="prg.xul.anonymousValueRow">
						<with-param name="valueNode" select="$valuesNode/prg:other" />
					</call-template>
				</if>
			</element>
		</element>
	</template>

	<!-- Frame for debug mode -->
	<template name="prg.xul.debugFrame">
		<element name="xul:hbox">
			<element name="xul:vbox">
				<attribute name="width">600</attribute>
				<!-- debug frame force window size to something usable -->
				<attribute name="height">768</attribute>
				<!-- console -->
				<element name="xul:iframe">
					<attribute name="src">chrome://global/content/console.xul</attribute>
					<attribute name="width">600</attribute>
					<attribute name="flex">1</attribute>
				</element>
				<!-- Refresh buttons -->
				<element name="xul:toolbar">
					<element name="xul:hbox">
						<element name="xul:button">
							<attribute name="label">Reload</attribute>
							<attribute name="oncommand">document.location = document.location</attribute>
						</element>
						<element name="xul:button">
							<attribute name="label">Rebuild</attribute>
							<attribute name="oncommand"><value-of select="$prg.xul.js.mainWindowInstanceName" />
							<text>.rebuildWindow()</text>
							</attribute>
						</element>
					</element>
				</element>
			</element>
			<call-template name="prg.xul.mainFrame" />
		</element>
	</template>

	<template name="prg.xul.mainFrame">
		<element name="xul:vbox">
			<attribute name="flex">1</attribute>
			<attribute name="style">overflow: -moz-scrollbars-vertical;</attribute>
			<attribute name="width"><value-of select="$prg.xul.windowWidth" /></attribute>
			<attribute name="height"><value-of select="$prg.xul.windowHeight" /></attribute>

			<!-- Global options -->
			<variable name="availableOptions" select="/prg:program/prg:options/*[not(prg:ui) or prg:ui[@mode = 'default']]" />

			<if test="$availableOptions">
				<element name="xul:groupbox">
					<element name="xul:caption">
						<element name="xul:label">
							<attribute name="value">General options</attribute>
						</element>
					</element>
					<call-template name="prg.xul.optionsGrid">
						<with-param name="optionsNode" select="/prg:program/prg:options" />
					</call-template>
				</element>
			</if>

			<choose>
				<when test="$prg.xul.availableSubcommands">
					<call-template name="prg.xul.subcommandFrame" />
				</when>
				<otherwise>
					<if test="/prg:program/prg:values">
						<element name="xul:groupbox">
							<element name="xul:caption">
								<element name="xul:label">
									<attribute name="value">Values</attribute>
								</element>
							</element>
							<call-template name="prg.xul.anonymousValueGrid">
								<with-param name="valuesNode" select="/prg:program/prg:values" />
							</call-template>
						</element>
					</if>
				</otherwise>
			</choose>

		</element>
	</template>

	<!-- Frame displaying options & values (general and per-subcommand) -->
	<template name="prg.xul.subcommandFrame">
		<variable name="subcommandDeckId">
			<text>ui:subcommandDeckId</text>
		</variable>

		<element name="xul:vbox">
			<element name="xul:menulist">
				<attribute name="flex">1</attribute>
				<attribute name="oncommand">
					<value-of select="$prg.xul.js.mainWindowInstanceName" /><text>.subcommand = this.value;</text>
					<text>document.getElementById('</text>
					<value-of select="$subcommandDeckId" />
					<text>').selectedIndex = <![CDATA[(this.selectedIndex < 1) ? 0 : (this.selectedIndex - 1);]]></text>
					<value-of select="$prg.xul.js.mainWindowInstanceName" /><text>.updatePreview();</text>
				</attribute>
				<element name="xul:menupopup">
					<element name="xul:menuitem">
						<attribute name="label"><text>-- General --</text></attribute>
					</element>
					<element name="xul:menuspacer" />
					<for-each select="$prg.xul.availableSubcommands">
						<element name="xul:menuitem">
							<variable name="prg.xul.subCommandLabel">
								<call-template name="prg.xul.subCommandLabel" />
							</variable>
							<attribute name="label"><value-of select="$prg.xul.subCommandLabel" /></attribute>
							<attribute name="value"><value-of select="prg:name" /></attribute>
						</element>
					</for-each>
				</element>
			</element>

			<element name="xul:deck">
				<attribute name="selectedIndex">0</attribute>
				<attribute name="id"><value-of select="$subcommandDeckId" /></attribute>
				<element name="xul:vbox">
					<if test="/prg:program/prg:values">
						<element name="xul:groupbox">
							<element name="xul:caption">
								<element name="xul:label">
									<attribute name="value">Values</attribute>
								</element>
							</element>
							<call-template name="prg.xul.anonymousValueGrid">
								<with-param name="valuesNode" select="/prg:program/prg:values" />
							</call-template>
						</element>
					</if>
				</element>

				<!-- Sub command pages -->
				<for-each select="$prg.xul.availableSubcommands">
					<variable name="prg.xul.subCommandLabel">
						<call-template name="prg.xul.subCommandLabel" />
					</variable>
					<element name="xul:vbox">
						<variable name="availableOptions" select="prg:options/*[not(prg:ui) or prg:ui[@mode = 'default']]" />
						<if test="$availableOptions">
							<element name="xul:groupbox">
								<element name="xul:label">
									<attribute name="value">
									<value-of select="$prg.xul.subCommandLabel" /><text> options</text>
								</attribute>
								</element>
								<call-template name="prg.xul.optionsGrid">
									<with-param name="optionsNode" select="prg:options" />
								</call-template>
							</element>
						</if>
						<if test="prg:values">
							<element name="xul:groupbox">
								<element name="xul:caption">
									<element name="xul:label">
										<attribute name="value">
									<value-of select="$prg.xul.subCommandLabel" /><text> values</text>
								</attribute>
									</element>
								</element>
								<call-template name="prg.xul.anonymousValueGrid">
									<with-param name="valuesNode" select="prg:values" />
								</call-template>
							</element>
						</if>
					</element>
				</for-each>

			</element>
		</element>
	</template>

	<template match="/">
		<processing-instruction name="xml-stylesheet">
			<text>type="text/css" href="chrome://global/skin/"</text>
		</processing-instruction>
		<call-template name="endl" />
		<comment>
			<text> Generation options</text>
			<call-template name="endl" />
			<if test="$prg.debug">
				<text> - Debug mode</text>
				<call-template name="endl" />
			</if>
		</comment>
		<processing-instruction name="xml-stylesheet">
			<text>type="text/css" href="chrome://</text>
			<value-of select="$prg.xul.appName" />
			<text>/content/</text>
			<value-of select="$prg.xul.appName" />
			<text>.css"</text>
		</processing-instruction>
		<call-template name="endl" />
		<processing-instruction name="xul-overlay">
			<text>href="chrome://</text>
			<value-of select="$prg.xul.appName" />
			<text>/content/</text>
			<value-of select="$prg.xul.appName" />
			<text>-overlay.xul"</text>
		</processing-instruction>
		<call-template name="endl" />
		<apply-templates select="prg:program" />
	</template>

	<template match="/prg:program">
		<element name="xul:window">
			<attribute name="id"><value-of select="$prg.xul.appName" /><text>_window</text></attribute>
			<attribute name="title">
				<call-template name="prg.programDisplayName" />
			</attribute>
			<attribute name="xmlns:xul" namespace="whatever">http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul</attribute>
			<attribute name="accelerated">true</attribute>
			<attribute name="onload"><value-of select="$prg.xul.js.mainWindowInstanceName" /><text>.initialize();</text></attribute>
			<!-- Closing the main window will close the app -->
			<attribute name="onclose"><value-of select="$prg.xul.js.applicationInstanceName" /><text>.quitApplication();</text></attribute>
			<element name="xul:script">
				<attribute name="type">application/javascript</attribute>
				<attribute name="src">chrome://<value-of select="$prg.xul.appName" />/content/<value-of select="$prg.xul.appName" />.js</attribute>
			</element>
			<element name="xul:script"><![CDATA[
			Components.utils.import("chrome://]]><value-of select="$prg.xul.appName" /><![CDATA[/content/]]><value-of select="$prg.xul.appName" /><![CDATA[.jsm");
			try
			{
				var ]]><value-of select="$prg.xul.js.mainWindowInstanceName" /><![CDATA[ = new MainWindow(]]><value-of select="$prg.xul.js.applicationInstanceName" /><![CDATA[);
			}
			catch(e)
			{
				alert(e);
			}
			]]></element>
			<element name="xul:keyset">
				<attribute name="id">prg.ui.keyset</attribute>
			</element>
			<element name="xul:commandset">
				<attribute name="id">prg.ui.commandset</attribute>
			</element>
			<element name="xul:menubar">
				<attribute name="id">prg.ui.mainMenubar</attribute>
			</element>

			<element name="xul:toolbar">
				<element name="xul:hbox">
					<attribute name="align">center</attribute>
					<attribute name="flex">1</attribute>
					<element name="xul:label">
						<attribute name="value"><text>Command line: </text></attribute>
						<attribute name="align">center</attribute>
					</element>
					<element name="xul:textbox">
						<attribute name="id"><text>commandline-preview</text></attribute>
						<attribute name="flex">1</attribute>
						<attribute name="readonly">true</attribute>
						<attribute name="value"><value-of select="$prg.xul.appName" /></attribute>
					</element>
					<element name="xul:button">
						<attribute name="label">Execute</attribute>
						<attribute name="oncommand">
						<value-of select="$prg.xul.js.mainWindowInstanceName" />
						<text>.execute()</text>
					</attribute>
					</element>
				</element>
			</element>

			<choose>
				<when test="$prg.debug">
					<call-template name="prg.xul.debugFrame" />
				</when>
				<otherwise>
					<call-template name="prg.xul.mainFrame" />
				</otherwise>
			</choose>

		</element>
	</template>
</stylesheet>
