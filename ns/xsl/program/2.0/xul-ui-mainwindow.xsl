<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- Create the main XUL window -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<xsl:import href="./xul-ui-base.xsl" />

	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<xsl:param name="prg.xul.windowWidth" />
	<xsl:param name="prg.xul.windowHeight" />

	<xsl:template name="prg.xul.tooltiptext">
		<xsl:param name="text" select="." />
		<xsl:value-of select="normalize-space($text)" />
	</xsl:template>

	<!-- Option label (using the best element available) -->
	<xsl:template name="prg.xul.optionLabel">
		<xsl:param name="optionNode" select="." />
		<xsl:choose>
			<xsl:when test="$optionNode/prg:ui/prg:label">
				<xsl:value-of select="normalize-space($optionNode/prg:ui/prg:label)" />
			</xsl:when>
			<xsl:when test="$optionNode/prg:documentation/prg:abstract">
				<xsl:value-of select="normalize-space($optionNode/prg:documentation/prg:abstract/text())" />
			</xsl:when>
			<xsl:when test="$optionNode/prg:names/prg:long">
				<xsl:value-of select="normalize-space($optionNode/prg:names/prg:long/text())" />
			</xsl:when>
			<xsl:when test="$optionNode/prg:databinding/prg:variable">
				<xsl:value-of select="normalize-space($optionNode/prg:databinding/prg:variable/text())" />
			</xsl:when>
			<xsl:when test="$optionNode/prg:names/prg:short">
				<xsl:value-of select="normalize-space($optionNode/prg:names/prg:short/text())" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="prg.optionId">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.xul.valueLabel">
		<xsl:param name="valueNode" select="." />
		<xsl:param name="index" />
		<xsl:choose>
			<xsl:when test="$valueNode/prg:documentation/prg:abstract">
				<xsl:value-of select="$valueNode/prg:documentation/prg:abstract" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$valueNode/self::other">
						<xsl:text>Other</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$index" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.xul.fsButtonDialogMode">
		<xsl:param name="pathNode" />
		<xsl:param name="multi" select="false()" />

		<xsl:variable name="kindsNode" select="$pathNode/prg:kinds" />
		<xsl:variable name="isFolderOnly" select="$kindsNode and (count($kindsNode/descendant::*) = 1) and $kindsNode/prg:folder" />
		<xsl:variable name="isFileOnly" select="$kindsNode and (count($kindsNode/descendant::*) = 1) and $kindsNode/prg:file" />

		<xsl:choose>
			<!-- Allways treat folder-only case first. Mac OS X does not allow folder selection in non 'foldermode' modes -->
			<xsl:when test="$isFolderOnly">
				<xsl:attribute name="dialogmode">folder</xsl:attribute>
			</xsl:when>
			<xsl:when test="$multi">
				<xsl:attribute name="dialogmode">multi</xsl:attribute>
			</xsl:when>
			<xsl:when test="not($pathNode/@exist) and $isFileOnly">
				<xsl:attribute name="dialogmode">save</xsl:attribute>
			</xsl:when>
			<!-- Default behavior in other cases -->
		</xsl:choose>
	</xsl:template>

	<!-- Escape text to be used as an attribute value -->
	<xsl:template name="prg.xul.attributeEscapedValue">
		<xsl:param name="value" select="." />
		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="text" select="$value" />
			<xsl:with-param name="replace">
				<xsl:text>"</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="by">
				<xsl:text>\&quot;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Control of the left column of the grid row -->
	<xsl:template name="prg.xul.optionLabelControl">
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="parentOptionNode" select="$optionNode/../.." />
		<xsl:variable name="optionId">
			<xsl:call-template name="prg.optionId">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:element name="xul:hbox">
			<xsl:if test="$optionNode/prg:documentation/prg:details">
				<xsl:attribute name="tooltiptext">
					<xsl:call-template name="prg.xul.tooltiptext">
						<xsl:with-param name="text">
							<xsl:value-of select="$optionNode/prg:documentation/prg:details" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="$optionNode/self::prg:group">
				<xsl:element name="xul:radiogroup">
					<xsl:attribute name="id">
						<xsl:value-of select="$optionId" />
						<xsl:text>:group</xsl:text>
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
			<xsl:element name="xul:label">
				<xsl:attribute name="value">
					<xsl:call-template name="prg.xul.optionLabel">
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$optionId" />
					<xsl:text>:label</xsl:text>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:checkbox">
				<xsl:attribute name="label">
					<xsl:call-template name="prg.xul.optionLabel">
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$optionId" />
					<xsl:text>:checkbox</xsl:text>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:radio">
				<xsl:attribute name="label">
					<xsl:call-template name="prg.xul.optionLabel">
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$optionId" />
					<xsl:text>:radio</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="group">
					<xsl:call-template name="prg.optionId">
						<xsl:with-param name="optionNode" select="$parentOptionNode" />
					</xsl:call-template>
					<xsl:text>:group</xsl:text>
				</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:box">
				<xsl:attribute name="id">
					<xsl:call-template name="prg.optionId">
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>
				</xsl:attribute>
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="$optionNode/self::prg:group">
							<xsl:text>groupOption</xsl:text>
						</xsl:when>
						<xsl:when test="$optionNode/self::prg:argument">
							<xsl:text>argumentOption</xsl:text>
						</xsl:when>
						<xsl:when test="$optionNode/self::prg:multiargument">
							<xsl:text>multiargumentOption</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>switchOption</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="$optionNode[@required = 'true']">
					<xsl:attribute name="required">true</xsl:attribute>
				</xsl:if>
				<xsl:if test="$parentOptionNode">
					<xsl:attribute name="parentId">
						<xsl:call-template name="prg.optionId">
							<xsl:with-param name="optionNode" select="$parentOptionNode" />
						</xsl:call-template>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="$optionNode/self::prg:group and $optionNode/@type">
					<xsl:attribute name="groupType"><xsl:value-of select="$optionNode/@type" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$optionNode[self::prg:argument or self::prg:multiargument]">
					<xsl:attribute name="valueControlId">
						<xsl:call-template name="prg.optionId">
							<xsl:with-param name="optionNode" select="$optionNode" />
						</xsl:call-template>
						<xsl:text>:value</xsl:text>
					</xsl:attribute>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- A series of attributes used by textbox for autocompletion -->
	<xsl:template name="prg.xul.textboxAutocompleAtributes">
		<xsl:param name="selectNode" />
		<xsl:attribute name="type">autocomplete</xsl:attribute>
		<xsl:attribute name="autocompletesearch">ns-value-autocomplete</xsl:attribute>
		<xsl:attribute name="autocompletesearchparam">
			<xsl:text>[</xsl:text>
			<xsl:for-each select="$selectNode/*">
				<xsl:text>&quot;</xsl:text>
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="text" select="." />
					<xsl:with-param name="replace">"</xsl:with-param>
					<xsl:with-param name="by">\&quot;</xsl:with-param>
				</xsl:call-template>
				<xsl:text>&quot;</xsl:text>
				<xsl:if test="position() != last()">
					<xsl:text>, </xsl:text>
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:attribute>
	</xsl:template>

	<!-- Construct the file filters for a fsbutton -->
	<xsl:template name="prg.xul.fsButtonFilterAttribute">
		<xsl:param name="patternsNode" />
		<xsl:attribute name="filters">
			<xsl:for-each select="$patternsNode/prg:pattern">
				<xsl:call-template name="prg.xul.attributeEscapedValue">
					<xsl:with-param name="value" select="prg:name" />
				</xsl:call-template>
				<xsl:text>|</xsl:text>
				<xsl:for-each select="prg:rules/prg:rule">
					<xsl:choose>
						<xsl:when test="prg:startWith">
							<xsl:value-of select="prg:startWith" /><xsl:text>*</xsl:text>
						</xsl:when>
						<xsl:when test="prg:endWith">
							<xsl:text>*</xsl:text><xsl:value-of select="prg:endWith" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>*</xsl:text><xsl:value-of select="prg:contains" /><xsl:text>*</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="position() != last()">
						<xsl:text>;</xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:if test="position() != last()">
					<xsl:text>|</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:attribute>
	</xsl:template>

	<!-- Convert a prg:select to menuitems for a menulist -->
	<xsl:template name="prg.xul.selectToMenuItems">
		<xsl:param name="selectNode" />
		<xsl:param name="selectedIndex" />
		<xsl:for-each select="$selectNode/*">
			<xsl:element name="xul:menuitem">
				<xsl:attribute name="label"><xsl:value-of select="." /></xsl:attribute>
				<xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
				<xsl:if test="normalize-space($selectNode/../prg:default/text()) = normalize-space(text())">
					<xsl:attribute name="selected">true</xsl:attribute>
				</xsl:if>
				<xsl:if test="position() = $selectedIndex">
					<xsl:attribute name="selected">true</xsl:attribute>
				</xsl:if>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="prg.xul.optionLabelColumn">
		<xsl:param name="level" select="0" />
		<xsl:param name="optionNode" select="." />

		<xsl:element name="xul:hbox">
			<xsl:element name="xul:spacer">
				<xsl:attribute name="width"><xsl:value-of select="$level * 10" /></xsl:attribute>
			</xsl:element>
			<xsl:call-template name="prg.xul.optionLabelControl">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<!-- Add a dummy (hidden) radio button to handle optional group case -->
	<xsl:template name="prg.xul.groupValueControl">
		<xsl:param name="node" select="." />

		<xsl:variable name="prg.optionId">
			<xsl:call-template name="prg.optionId">
				<xsl:with-param name="optionNode" select="$node" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:element name="xul:radio">
			<xsl:attribute name="id">
				<xsl:value-of select="$optionId" />
				<xsl:text>:dummyradio</xsl:text>
			</xsl:attribute>
			<!-- <attribute name="hidden">true</attribute> -->
			<xsl:attribute name="group">
				<xsl:value-of select="$optionId" />
				<xsl:text>:group</xsl:text>
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<!-- Construct value control (single argument or anonymous value -->
	<xsl:template name="prg.xul.singleValueControl">
		<xsl:param name="node" select="." />
		<xsl:param name="valueIndex" />

		<xsl:variable name="controlId">
			<xsl:choose>
				<xsl:when test="$node/self::prg:argument">
					<xsl:call-template name="prg.optionId">
						<xsl:with-param name="optionNode" select="$node" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$node/self::prg:value">
					<xsl:call-template name="prg.xul.valueId">
						<xsl:with-param name="valueNode" select="$node" />
						<xsl:with-param name="index" select="$valueIndex" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:text>:value</xsl:text>
		</xsl:variable>
		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="$node/self::prg:argument">
					<xsl:call-template name="prg.xul.optionLabel">
						<xsl:with-param name="optionNode" select="$node" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$node/self::prg:value">
					<xsl:call-template name="prg.xul.valueLabel">
						<xsl:with-param name="valueNode" select="$node" />
						<xsl:with-param name="index" select="$valueIndex" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="typeNode" select="$node/prg:type" />
		<xsl:variable name="defaultNode" select="$node/prg:default" />
		<xsl:variable name="selectNode" select="$node/prg:select" />

		<xsl:choose>
			<!-- menu -->
			<xsl:when test="$node/prg:select[@restrict = 'true']">
				<xsl:element name="xul:box">
					<xsl:attribute name="id"><xsl:value-of select="$controlId" /></xsl:attribute>
					<xsl:attribute name="class">argumentMenuValue</xsl:attribute>
					<xsl:call-template name="prg.xul.selectToMenuItems">
						<xsl:with-param name="selectNode" select="$selectNode" />
					</xsl:call-template>
				</xsl:element>
			</xsl:when>
			<!-- Spin box -->
			<xsl:when test="($typeNode/prg:number)">
				<xsl:variable name="numberNode" select="$typeNode/prg:number" />
				<xsl:element name="xul:box">
					<xsl:attribute name="class">argumentNumberValue</xsl:attribute>
					<xsl:attribute name="id"><xsl:value-of select="$controlId" /></xsl:attribute>
					<xsl:if test="$numberNode/@min">
						<xsl:attribute name="min">
							<xsl:value-of select="$numberNode/@min" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$numberNode/@max">
						<xsl:attribute name="max">
							<xsl:value-of select="$numberNode/@max" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$numberNode/@decimal">
						<xsl:attribute name="decimal">
							<xsl:value-of select="$numberNode/@decimal" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$defaultNode">
						<xsl:attribute name="default">
							<xsl:value-of select="$defaultNode" />
						</xsl:attribute>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<!-- File box -->
			<xsl:when test="$typeNode/prg:path">
				<xsl:variable name="pathNode" select="$typeNode/prg:path" />
				<xsl:element name="xul:box">
					<xsl:attribute name="class">argumentPathValue</xsl:attribute>
					<xsl:attribute name="id"><xsl:value-of select="$controlId" /></xsl:attribute>
					<xsl:attribute name="dialogtitle">
						<xsl:value-of select="$label"></xsl:value-of>
					</xsl:attribute>
					<xsl:if test="$defaultNode">
						<xsl:attribute name="default">
							<xsl:value-of select="$defaultNode" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$selectNode">
						<xsl:call-template name="prg.xul.textboxAutocompleAtributes">
							<xsl:with-param name="selectNode" select="$selectNode" />
						</xsl:call-template>
					</xsl:if>
					<xsl:if test="$pathNode/prg:patterns">
						<xsl:call-template name="prg.xul.fsButtonFilterAttribute">
							<xsl:with-param name="patternsNode" select="$pathNode/prg:patterns" />
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="prg.xul.fsButtonDialogMode">
						<xsl:with-param name="pathNode" select="$pathNode" />
					</xsl:call-template>
				</xsl:element>
			</xsl:when>
			<!-- Textbox -->
			<xsl:otherwise>
				<xsl:element name="xul:box">
					<xsl:attribute name="class">argumentTextValue</xsl:attribute>
					<xsl:attribute name="id"><xsl:value-of select="$controlId" /></xsl:attribute>
					<xsl:if test="$defaultNode">
						<xsl:attribute name="default">
							<xsl:value-of select="$defaultNode" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$selectNode">
						<xsl:call-template name="prg.xul.textboxAutocompleAtributes">
							<xsl:with-param name="selectNode" select="$selectNode" />
						</xsl:call-template>
					</xsl:if>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.xul.multiValueControl">
		<xsl:param name="node" select="." />
		<xsl:param name="valueIndex" />

		<xsl:variable name="controlId">
			<xsl:choose>
				<xsl:when test="$node/self::prg:multiargument">
					<xsl:call-template name="prg.optionId">
						<xsl:with-param name="optionNode" select="$node" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$node/self::prg:other">
					<xsl:call-template name="prg.xul.valueId">
						<xsl:with-param name="valueNode" select="$node" />
						<xsl:with-param name="index" select="$valueIndex" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
			<xsl:text>:value</xsl:text>
		</xsl:variable>

		<xsl:variable name="label">
			<xsl:choose>
				<xsl:when test="$node/self::prg:multiargument">
					<xsl:call-template name="prg.xul.optionLabel">
						<xsl:with-param name="optionNode" select="$node" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$node/self::prg:other">
					<xsl:call-template name="prg.xul.valueLabel">
						<xsl:with-param name="valueNode" select="$node" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="proxyId">
			<xsl:value-of select="$controlId" />
			<xsl:text>:proxy</xsl:text>
		</xsl:variable>

		<xsl:variable name="inputId">
			<xsl:value-of select="$controlId" />
			<xsl:text>:input</xsl:text>
		</xsl:variable>

		<xsl:variable name="buttonId">
			<xsl:value-of select="$controlId" />
			<xsl:text>:fsbutton</xsl:text>
		</xsl:variable>

		<xsl:variable name="typeNode" select="$node/prg:type" />
		<xsl:variable name="defaultNode" select="$node/prg:default" />
		<xsl:variable name="selectNode" select="$node/prg:select" />

		<xsl:element name="xul:grid">
			<xsl:attribute name="flex">1</xsl:attribute>
			<xsl:element name="xul:columns">
				<xsl:element name="xul:column">
					<xsl:attribute name="flex">1</xsl:attribute>
				</xsl:element>
				<xsl:element name="xul:column" />
			</xsl:element>
			<xsl:element name="xul:rows">
				<xsl:variable name="useSingleRow" select="$typeNode/prg:path and not($selectNode/@restrict)" />
				<xsl:if test="not($useSingleRow)">
					<xsl:element name="xul:row">
						<xsl:choose>
							<!-- menu -->
							<xsl:when test="$selectNode[@restrict = 'true']">
								<xsl:element name="xul:box">
									<xsl:attribute name="class">argumentMenuValue</xsl:attribute>
									<xsl:attribute name="id"><xsl:value-of select="$inputId" /></xsl:attribute>
									<xsl:call-template name="prg.xul.selectToMenuItems">
										<xsl:with-param name="selectNode" select="$selectNode" />
										<xsl:with-param name="selectedIndex" select="1" />
									</xsl:call-template>
								</xsl:element>
							</xsl:when>
							<!-- spinbox -->
							<xsl:when test="($typeNode/prg:number)">
								<xsl:variable name="numberNode" select="$typeNode/prg:number" />

								<xsl:element name="xul:box">
									<xsl:attribute name="class">argumentNumberValue</xsl:attribute>
									<xsl:attribute name="id"><xsl:value-of select="$inputId" /></xsl:attribute>
									<xsl:if test="$numberNode/@min">
										<xsl:attribute name="min"><xsl:value-of select="$numberNode/@min" /></xsl:attribute>
									</xsl:if>
									<xsl:if test="$numberNode/@max">
										<xsl:attribute name="max"><xsl:value-of select="$numberNode/@max" /></xsl:attribute>
									</xsl:if>
									<xsl:if test="$numberNode/@decimal">
										<xsl:attribute name="decimal"><xsl:value-of select="$numberNode/@decimal" /></xsl:attribute>
									</xsl:if>
									<xsl:if test="$defaultNode">
										<xsl:attribute name="default"><xsl:value-of select="$defaultNode/prg:default" /></xsl:attribute>
									</xsl:if>
								</xsl:element>
							</xsl:when>
							<!-- textbox -->
							<xsl:otherwise>
								<xsl:element name="xul:box">
									<xsl:attribute name="class">argumentTextValue</xsl:attribute>
									<xsl:attribute name="id"><xsl:value-of select="$inputId" /></xsl:attribute>
									<xsl:if test="$defaultNode">
										<xsl:attribute name="default"><xsl:value-of select="$defaultNode" /></xsl:attribute>
									</xsl:if>
									<xsl:if test="$selectNode">
										<xsl:call-template name="prg.xul.textboxAutocompleAtributes">
											<xsl:with-param name="selectNode" select="$selectNode" />
										</xsl:call-template>
									</xsl:if>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:element name="xul:button">
							<xsl:attribute name="label">Add</xsl:attribute>
							<xsl:attribute name="id"><xsl:value-of select="$buttonId" /></xsl:attribute>
							<xsl:attribute name="oncommand">
								<xsl:value-of select="$prg.xul.js.mainWindowInstanceName" /><xsl:text>.addInputToMultiValue('</xsl:text>
								<xsl:value-of select="$controlId" /><xsl:text>');</xsl:text>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="xul:row">
					<xsl:element name="xul:box">
						<xsl:attribute name="flex">1</xsl:attribute>
						<xsl:attribute name="class">multiargumentListbox</xsl:attribute>
						<xsl:attribute name="id"><xsl:value-of select="$controlId" /></xsl:attribute>
					</xsl:element>
					<xsl:element name="xul:vbox">
						<xsl:if test="$useSingleRow">
							<xsl:variable name="pathNode" select="$typeNode/prg:path" />
							<xsl:element name="xul:box">
								<xsl:attribute name="class">fsbutton</xsl:attribute>
								<xsl:attribute name="label">Add...</xsl:attribute>
								<xsl:attribute name="id"><xsl:value-of select="$buttonId" /></xsl:attribute>
								<xsl:attribute name="onchange">
									<xsl:value-of select="$prg.xul.js.mainWindowInstanceName" /><xsl:text>.addInputToMultiValue('</xsl:text>
									<xsl:value-of select="$controlId" /><xsl:text>', this);</xsl:text>
								</xsl:attribute>
								<xsl:if test="$pathNode/prg:patterns">
									<xsl:call-template name="prg.xul.fsButtonFilterAttribute">
										<xsl:with-param name="patternsNode" select="$pathNode/prg:patterns" />
									</xsl:call-template>
								</xsl:if>
								<xsl:call-template name="prg.xul.fsButtonDialogMode">
									<xsl:with-param name="pathNode" select="$pathNode" />
									<xsl:with-param name="multi" select="true()" />
								</xsl:call-template>
							</xsl:element>
						</xsl:if>
						<xsl:element name="xul:box">
							<xsl:attribute name="class">itemarrangementbuttonbox</xsl:attribute>
							<xsl:attribute name="id"><xsl:value-of select="$proxyId" /></xsl:attribute>
							<xsl:attribute name="targetId"><xsl:value-of select="$controlId" /></xsl:attribute>
							<xsl:if test="$node/@max">
								<xsl:attribute name="maxItems">
									<xsl:value-of select="$node/@max" />
								</xsl:attribute>
							</xsl:if>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Construct the value control (if any) for an option -->
	<xsl:template name="prg.xul.optionValueColumn">
		<xsl:param name="level" select="0" />
		<xsl:param name="optionNode" select="." />

		<xsl:choose>
			<xsl:when test="$optionNode/self::prg:group">
				<!-- <call-template name="prg.xul.groupValueControl"> <with-param name="node"
					select="$optionNode" /> </call-template> -->
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:argument">
				<xsl:call-template name="prg.xul.singleValueControl">
					<xsl:with-param name="node" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:multiargument">
				<xsl:call-template name="prg.xul.multiValueControl">
					<xsl:with-param name="node" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Construct option controls (label + value) as a grid row -->
	<xsl:template name="prg.xul.optionRow">
		<xsl:param name="level" select="0" />
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="groupOptionNodes" select="$optionNode/prg:options/*[not(prg:ui) or not(prg:ui/@mode) or prg:ui[@mode = 'default']]" />

		<!-- Check empty group case -->
		<xsl:variable name="isEmptyGroup" select="$optionNode/self::prg:group and (count($groupOptionNodes) = 0)" />

		<xsl:variable name="isSingleElementGroup" select="$optionNode/self::prg:group and (count($groupOptionNodes) = 1)" />

		<xsl:comment>
			<xsl:value-of select="name($optionNode)" />
			<xsl:text> </xsl:text>
			<xsl:call-template name="prg.xul.optionLabel">
				<xsl:with-param name="optionNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:comment>

		<xsl:choose>
			<!-- Flatten single-element groups -->
			<!-- @todo disable 'radiobox' case in option or simulate a pseudo radiogroup -->
			<xsl:when test="$isSingleElementGroup">
				<xsl:call-template name="prg.xul.optionRow">
					<xsl:with-param name="level" select="$level" />
					<xsl:with-param name="optionNode" select="$groupOptionNodes" />
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="not($isEmptyGroup)">
				<xsl:element name="xul:row">
					<xsl:call-template name="prg.xul.optionLabelColumn">
						<xsl:with-param name="level" select="$level" />
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>

					<xsl:call-template name="prg.xul.optionValueColumn">
						<xsl:with-param name="level" select="$level" />
						<xsl:with-param name="optionNode" select="$optionNode" />
					</xsl:call-template>
				</xsl:element>

				<xsl:if test="$optionNode/self::prg:group">
					<xsl:for-each select="$groupOptionNodes">
						<xsl:call-template name="prg.xul.optionRow">
							<xsl:with-param name="level" select="$level + 1" />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Construct the opiion grid fo a root prg:options node -->
	<xsl:template name="prg.xul.optionsGrid">
		<xsl:param name="optionsNode" select="." />

		<xsl:element name="xul:grid">
			<xsl:attribute name="flex">1</xsl:attribute>
			<xsl:element name="xul:columns">
				<xsl:comment>
					<xsl:text>Option label / Option selection</xsl:text>
				</xsl:comment>
				<xsl:element name="xul:column">
					<xsl:attribute name="flex">1</xsl:attribute>
				</xsl:element>
				<xsl:comment>
					<xsl:text>Option argument value(s)</xsl:text>
				</xsl:comment>
				<xsl:element name="xul:column">
					<xsl:attribute name="flex">1</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="xul:rows">
				<xsl:for-each select="$optionsNode/*[not(prg:ui) or not(prg:ui/@mode) or prg:ui[@mode = 'default']]">
					<xsl:call-template name="prg.xul.optionRow">
						<xsl:with-param name="level" select="0" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template name="prg.xul.anonymousValueLabelColumn">
		<xsl:param name="valueNode" select="." />
		<xsl:param name="index" />
		<xsl:variable name="valueId">
			<xsl:call-template name="prg.xul.valueId">
				<xsl:with-param name="valueNode" select="$valueNode" />
				<xsl:with-param name="index" select="$index" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:element name="xul:hbox">
			<xsl:attribute name="class">programValue</xsl:attribute>
			<xsl:attribute name="id">
				<xsl:value-of select="$valueId" />
			</xsl:attribute>
			<xsl:if test="$valueNode/prg:documentation/prg:details">
				<xsl:attribute name="tooltiptext">
					<xsl:call-template name="prg.xul.tooltiptext">
						<xsl:with-param name="text">
							<xsl:value-of select="$valueNode/prg:documentation/prg:details" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="label">
				<xsl:call-template name="prg.xul.valueLabel">
						<xsl:with-param name="valueNode" select="$valueNode" />
						<xsl:with-param name="index" select="$index" />
					</xsl:call-template>				
			</xsl:attribute>
			<xsl:attribute name="valueControlId">
				<xsl:value-of select="$valueId" />
				<xsl:text>:value</xsl:text>
			</xsl:attribute>
			<xsl:attribute name="index">
				<xsl:value-of select="$index" />
			</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template name="prg.xul.anonymousValueValueColumn">
		<xsl:param name="valueNode" select="." />
		<xsl:param name="index" />

		<xsl:variable name="typeNode" select="$valueNode/prg:type" />
		<xsl:variable name="selectNode" select="$valueNode/prg:select" />

		<xsl:variable name="valueId">
			<xsl:call-template name="prg.xul.valueId">
				<xsl:with-param name="valueNode" select="$valueNode" />
				<xsl:with-param name="index" select="$index"></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$valueNode/self::prg:value">
				<xsl:call-template name="prg.xul.singleValueControl">
					<xsl:with-param name="node" select="$valueNode" />
					<xsl:with-param name="valueIndex" select="$index" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$valueNode/self::prg:other">
				<xsl:call-template name="prg.xul.multiValueControl">
					<xsl:with-param name="node" select="$valueNode" />
					<xsl:with-param name="valueIndex" select="$index" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.xul.anonymousValueRow">
		<xsl:param name="valueNode" select="." />
		<xsl:param name="index" />

		<xsl:comment>
			<xsl:if test="$valueNode/self::prg:other">
				<xsl:text>Other </xsl:text>
			</xsl:if>
			<xsl:text>Value</xsl:text>
			<xsl:if test="$valueNode/self::prg:value">
				<xsl:text> </xsl:text>
				<xsl:value-of select="$index" />
			</xsl:if>
		</xsl:comment>

		<xsl:element name="xul:row">
			<xsl:call-template name="prg.xul.anonymousValueLabelColumn">
				<xsl:with-param name="valueNode" select="$valueNode" />
				<xsl:with-param name="index" select="$index" />
			</xsl:call-template>

			<xsl:call-template name="prg.xul.anonymousValueValueColumn">
				<xsl:with-param name="valueNode" select="$valueNode" />
				<xsl:with-param name="index" select="$index" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template name="prg.xul.anonymousValueGrid">
		<xsl:param name="valuesNode" select="." />

		<xsl:element name="xul:grid">
			<xsl:attribute name="flex">1</xsl:attribute>
			<xsl:element name="xul:columns">
				<xsl:comment>
					<xsl:text>Anonymous value labels</xsl:text>
				</xsl:comment>
				<xsl:element name="xul:column">
					<xsl:attribute name="flex">1</xsl:attribute>
				</xsl:element>
				<xsl:comment>
					<xsl:text>Anonymous value ... value control</xsl:text>
				</xsl:comment>
				<xsl:element name="xul:column">
					<xsl:attribute name="flex">1</xsl:attribute>
				</xsl:element>
			</xsl:element>
			<xsl:element name="xul:rows">
				<xsl:for-each select="$valuesNode/prg:value">
					<xsl:call-template name="prg.xul.anonymousValueRow">
						<xsl:with-param name="index" select="position()" />
					</xsl:call-template>
				</xsl:for-each>
				<xsl:if test="$valuesNode/prg:other">
					<xsl:call-template name="prg.xul.anonymousValueRow">
						<xsl:with-param name="valueNode" select="$valuesNode/prg:other" />
					</xsl:call-template>
				</xsl:if>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<!-- Frame for debug mode -->
	<xsl:template name="prg.xul.debugFrame">
		<xsl:param name="programNode" select="." />
		<xsl:param name="width" />
		<xsl:param name="height" />

		<xsl:variable name="debugHeight">
			<xsl:choose>
				<xsl:when test="$height &lt; 768" >
					<xsl:text>768</xsl:text>
				</xsl:when>
				<xsl:when test="$height">
					<xsl:value-of select="$height" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>768</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$prg.debug">
			<xsl:comment>
				<xsl:call-template name="endl" />
				<xsl:text>Ref size: </xsl:text>
				<xsl:value-of select="$width" />
				<xsl:text>x</xsl:text>
				<xsl:value-of select="$height" />
				<xsl:call-template name="endl" />
				<xsl:text>Used size: </xsl:text>
				<xsl:value-of select="$width" />
				<xsl:text>x</xsl:text>
				<xsl:value-of select="$debugHeight" />
				<xsl:call-template name="endl" />
			</xsl:comment>
		</xsl:if>

		<xsl:element name="xul:hbox">
			<xsl:element name="xul:vbox">
				<xsl:attribute name="width">600</xsl:attribute>
				<xsl:attribute name="height"><xsl:value-of select="$debugHeight" /></xsl:attribute>

				<xsl:comment>
					<text>Debug frame</text>
				</xsl:comment>

				<!-- console -->
				<xsl:element name="xul:iframe">
					<xsl:attribute name="src">chrome://global/content/console.xul</xsl:attribute>
					<xsl:attribute name="width">600</xsl:attribute>
					<xsl:attribute name="flex">1</xsl:attribute>
				</xsl:element>
				<!-- Refresh buttons -->
				<xsl:element name="xul:toolbar">
					<xsl:element name="xul:hbox">
						<xsl:element name="xul:button">
							<xsl:attribute name="label">Reload</xsl:attribute>
							<xsl:attribute name="oncommand">document.location = document.location</xsl:attribute>
						</xsl:element>
						<xsl:element name="xul:button">
							<xsl:attribute name="label">Rebuild</xsl:attribute>
							<xsl:attribute name="oncommand"><xsl:value-of select="$prg.xul.js.mainWindowInstanceName" />
							<xsl:text>.rebuildWindow()</xsl:text>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<xsl:comment>
				<text>Main frame</text>
			</xsl:comment>
			<xsl:call-template name="prg.xul.mainFrame">
				<xsl:with-param name="programNode" select="$programNode" />
				<xsl:with-param name="width" select="$width" />
				<xsl:with-param name="height" select="$debugHeight" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template name="prg.xul.mainFrame">
		<xsl:param name="programNode" select="." />
		<xsl:param name="width" />
		<xsl:param name="height" />

		<xsl:element name="xul:vbox">
			<xsl:attribute name="flex">1</xsl:attribute>
			<xsl:attribute name="style">overflow: -moz-scrollbars-vertical;</xsl:attribute>
			<xsl:attribute name="width"><xsl:value-of select="$width" /></xsl:attribute>
			<xsl:attribute name="height"><xsl:value-of select="$height" /></xsl:attribute>

			<!-- Global options -->
			<xsl:variable name="availableOptions" select="/prg:program/prg:options/*[not(prg:ui) or not(prg:ui/@mode) or prg:ui[@mode = 'default']]" />

			<xsl:if test="$availableOptions">
				<xsl:element name="xul:groupbox">
					<xsl:element name="xul:caption">
						<xsl:element name="xul:label">
							<xsl:attribute name="value">General options</xsl:attribute>
						</xsl:element>
					</xsl:element>
					<xsl:call-template name="prg.xul.optionsGrid">
						<xsl:with-param name="optionsNode" select="/prg:program/prg:options" />
					</xsl:call-template>
				</xsl:element>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="$prg.xul.availableSubcommands">
					<xsl:call-template name="prg.xul.subcommandFrame" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="/prg:program/prg:values">
						<xsl:element name="xul:groupbox">
							<xsl:element name="xul:caption">
								<xsl:element name="xul:label">
									<xsl:attribute name="value">Values</xsl:attribute>
								</xsl:element>
							</xsl:element>
							<xsl:call-template name="prg.xul.anonymousValueGrid">
								<xsl:with-param name="valuesNode" select="/prg:program/prg:values" />
							</xsl:call-template>
						</xsl:element>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:element>
	</xsl:template>

	<!-- Frame displaying options & values (general and per-subcommand) -->
	<xsl:template name="prg.xul.subcommandFrame">
		<xsl:variable name="subcommandDeckId">
			<xsl:text>ui:subcommandDeckId</xsl:text>
		</xsl:variable>

		<xsl:element name="xul:vbox">
			<xsl:element name="xul:menulist">
				<xsl:attribute name="flex">1</xsl:attribute>
				<xsl:attribute name="id">prg.xul.ui.subcommandList</xsl:attribute>
				<xsl:attribute name="oncommand">
					<xsl:value-of select="$prg.xul.js.mainWindowInstanceName" /><xsl:text>.subcommand = this.value;</xsl:text>
					<xsl:text>document.getElementById('</xsl:text>
					<xsl:value-of select="$subcommandDeckId" />
					<xsl:text>').selectedIndex = <![CDATA[(this.selectedIndex < 1) ? 0 : (this.selectedIndex - 1);]]></xsl:text>
					<xsl:value-of select="$prg.xul.js.mainWindowInstanceName" /><xsl:text>.updatePreview();</xsl:text>
				</xsl:attribute>
				<xsl:element name="xul:menupopup">
					<xsl:element name="xul:menuitem">
						<xsl:attribute name="label"><xsl:text>-- General --</xsl:text></xsl:attribute>
					</xsl:element>
					<xsl:element name="xul:menuspacer" />
					<xsl:for-each select="$prg.xul.availableSubcommands">
						<xsl:element name="xul:menuitem">
							<xsl:variable name="prg.xul.subCommandLabel">
								<xsl:call-template name="prg.xul.subCommandLabel" />
							</xsl:variable>
							<xsl:attribute name="label"><xsl:value-of select="$prg.xul.subCommandLabel" /></xsl:attribute>
							<xsl:attribute name="value"><xsl:value-of select="prg:name" /></xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>

			<xsl:element name="xul:deck">
				<xsl:attribute name="selectedIndex">0</xsl:attribute>
				<xsl:attribute name="id"><xsl:value-of select="$subcommandDeckId" /></xsl:attribute>
				<xsl:element name="xul:vbox">
					<xsl:if test="/prg:program/prg:values">
						<xsl:element name="xul:groupbox">
							<xsl:element name="xul:caption">
								<xsl:element name="xul:label">
									<xsl:attribute name="value">Values</xsl:attribute>
								</xsl:element>
							</xsl:element>
							<xsl:call-template name="prg.xul.anonymousValueGrid">
								<xsl:with-param name="valuesNode" select="/prg:program/prg:values" />
							</xsl:call-template>
						</xsl:element>
					</xsl:if>
				</xsl:element>

				<!-- Sub command pages -->
				<xsl:for-each select="$prg.xul.availableSubcommands">
					<xsl:variable name="prg.xul.subCommandLabel">
						<xsl:call-template name="prg.xul.subCommandLabel" />
					</xsl:variable>
					<xsl:element name="xul:vbox">
						<xsl:variable name="availableOptions" select="prg:options/*[not(prg:ui) or not(prg:ui/@mode) or prg:ui[@mode = 'default']]" />
						<xsl:if test="$availableOptions">
							<xsl:element name="xul:groupbox">
								<xsl:element name="xul:label">
									<xsl:attribute name="value">
									<xsl:value-of select="$prg.xul.subCommandLabel" /><xsl:text> options</xsl:text>
								</xsl:attribute>
								</xsl:element>
								<xsl:call-template name="prg.xul.optionsGrid">
									<xsl:with-param name="optionsNode" select="prg:options" />
								</xsl:call-template>
							</xsl:element>
						</xsl:if>
						<xsl:if test="prg:values">
							<xsl:element name="xul:groupbox">
								<xsl:element name="xul:caption">
									<xsl:element name="xul:label">
										<xsl:attribute name="value">
									<xsl:value-of select="$prg.xul.subCommandLabel" /><xsl:text> values</xsl:text>
								</xsl:attribute>
									</xsl:element>
								</xsl:element>
								<xsl:call-template name="prg.xul.anonymousValueGrid">
									<xsl:with-param name="valuesNode" select="prg:values" />
								</xsl:call-template>
							</xsl:element>
						</xsl:if>
					</xsl:element>
				</xsl:for-each>

			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="/">
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/css" href="chrome://global/skin/"</xsl:text>
		</xsl:processing-instruction>
		<xsl:call-template name="endl" />
		<xsl:comment>
			<xsl:text> Generation options</xsl:text>
			<xsl:call-template name="endl" />
			<xsl:if test="$prg.debug">
				<xsl:text> - Debug mode</xsl:text>
				<xsl:call-template name="endl" />
			</xsl:if>
		</xsl:comment>
		<xsl:processing-instruction name="xml-stylesheet">
			<xsl:text>type="text/css" href="chrome://</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>/content/</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>.css"</xsl:text>
		</xsl:processing-instruction>
		<xsl:call-template name="endl" />
		<xsl:processing-instruction name="xul-overlay">
			<xsl:text>href="chrome://</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>/content/</xsl:text>
			<xsl:value-of select="$prg.xul.appName" />
			<xsl:text>-overlay.xul"</xsl:text>
		</xsl:processing-instruction>
		<xsl:call-template name="endl" />
		<xsl:apply-templates select="prg:program" />
	</xsl:template>

	<xsl:template match="/prg:program">
		<xsl:element name="xul:window">
			<xsl:attribute name="id"><xsl:value-of select="$prg.xul.appName" /><xsl:text>_window</xsl:text></xsl:attribute>
			<xsl:attribute name="title">
				<xsl:call-template name="prg.programDisplayName" />
			</xsl:attribute>
			<xsl:attribute name="xmlns:xul" namespace="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul</xsl:attribute>
			<xsl:attribute name="accelerated">true</xsl:attribute>
			<xsl:attribute name="onload"><xsl:value-of select="$prg.xul.js.mainWindowInstanceName" /><xsl:text>.initialize();</xsl:text></xsl:attribute>
			<!-- Closing the main window will close the app -->
			<xsl:attribute name="onclose"><xsl:value-of select="$prg.xul.js.applicationInstanceName" /><xsl:text>.quitApplication();</xsl:text></xsl:attribute>
			<xsl:element name="xul:script">
				<xsl:attribute name="type">application/javascript</xsl:attribute>
				<xsl:attribute name="src">chrome://<xsl:value-of select="$prg.xul.appName" />/content/<xsl:value-of select="$prg.xul.appName" />.js</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:script"><![CDATA[
			Components.utils.import("chrome://]]><xsl:value-of select="$prg.xul.appName" /><![CDATA[/content/]]><xsl:value-of select="$prg.xul.appName" /><![CDATA[.jsm");
			try
			{
				var ]]><xsl:value-of select="$prg.xul.js.mainWindowInstanceName" /><![CDATA[ = new MainWindow(]]><xsl:value-of select="$prg.xul.js.applicationInstanceName" /><![CDATA[);
			}
			catch(e)
			{
				alert(e);
			}
			]]></xsl:element>
			<xsl:element name="xul:keyset">
				<xsl:attribute name="id">prg.ui.keyset</xsl:attribute>
			</xsl:element>
			<xsl:element name="xul:commandset">
				<xsl:attribute name="id">prg.ui.commandset</xsl:attribute>
			</xsl:element>

			<!-- Do not add menubar under Mac OS X (set in hidden window) -->
			<xsl:if test="$prg.xul.platform != 'macosx'">
				<xsl:element name="xul:menubar">
					<xsl:attribute name="id">main-menubar</xsl:attribute>
				</xsl:element>
			</xsl:if>

			<xsl:element name="xul:toolbar">
				<xsl:element name="xul:hbox">
					<xsl:attribute name="align">center</xsl:attribute>
					<xsl:attribute name="flex">1</xsl:attribute>
					<xsl:element name="xul:label">
						<xsl:attribute name="value"><xsl:text>Command line: </xsl:text></xsl:attribute>
						<xsl:attribute name="align">center</xsl:attribute>
					</xsl:element>
					<xsl:element name="xul:textbox">
						<xsl:attribute name="id"><xsl:text>commandline-preview</xsl:text></xsl:attribute>
						<xsl:attribute name="flex">1</xsl:attribute>
						<xsl:attribute name="readonly">true</xsl:attribute>
						<xsl:attribute name="value"><xsl:value-of select="$prg.xul.appName" /></xsl:attribute>
					</xsl:element>
					<xsl:element name="xul:button">
						<xsl:attribute name="label">Execute</xsl:attribute>
						<xsl:attribute name="id">prg.xul.ui.executeButton</xsl:attribute>
						<xsl:attribute name="oncommand">
						<xsl:value-of select="$prg.xul.js.mainWindowInstanceName" />
							<xsl:text>.execute()</xsl:text>
						</xsl:attribute>
					</xsl:element>
				</xsl:element>
			</xsl:element>

			<!-- Compute width and height -->
			<xsl:variable name="width">
				<xsl:choose>
					<xsl:when test="$prg.xul.windowWidth">
						<xsl:value-of select="$prg.xul.windowWidth" />
					</xsl:when>
					<xsl:when test="./prg:ui/prg:window/@width">
						<xsl:value-of select="./prg:ui/prg:window/@width" />
					</xsl:when>
					<xsl:otherwise>
						<text>1024</text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="height">
				<xsl:choose>
					<xsl:when test="$prg.xul.windowHeight">
						<xsl:value-of select="$prg.xul.windowHeight" />
					</xsl:when>
					<xsl:when test="./prg:ui/prg:window/@height">
						<xsl:value-of select="./prg:ui/prg:window/@height" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>768</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$prg.debug">
				<xsl:comment>
					<xsl:call-template name="endl" />
					<xsl:text>Schema ui size: </xsl:text>
					<xsl:value-of select="./prg:ui/prg:window/@width" />
					<xsl:text>x</xsl:text>
					<xsl:value-of select="./prg:ui/prg:window/@height" />
					<xsl:call-template name="endl" />
					<xsl:text>Parameters ui size: </xsl:text>
					<xsl:value-of select="$prg.xul.windowWidth" />
					<xsl:text>x</xsl:text>
					<xsl:value-of select="$prg.xul.windowHeight" />
					<xsl:call-template name="endl" />
					<xsl:text>Used size: </xsl:text>
					<xsl:value-of select="$width" />
					<xsl:text>x</xsl:text>
					<xsl:value-of select="$height" />
					<xsl:call-template name="endl" />
				</xsl:comment>
			</xsl:if>

			<xsl:choose>
				<xsl:when test="$prg.debug">
					<xsl:call-template name="prg.xul.debugFrame">
						<xsl:with-param name="programNode" select="." />
						<xsl:with-param name="width" select="$width" />
						<xsl:with-param name="height" select="$height" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="prg.xul.mainFrame">
						<xsl:with-param name="programNode" select="." />
						<xsl:with-param name="width" select="$width" />
						<xsl:with-param name="height" select="$height" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
