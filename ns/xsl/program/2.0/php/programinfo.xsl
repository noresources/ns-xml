<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Create and fill a PHP ProgramInfo object -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../../../languages/php.xsl" />
	<xsl:import href="../base.xsl" />
	<xsl:import href="./base.xsl" />

	<xsl:output method="text" encoding="utf-8" />

	<!-- If empty, use <appname>ProgramInfo -->
	<xsl:param name="prg.php.programinfo.classname" select="''" />

	<!-- Generate a unique variable name from item info -->
	<xsl:template name="prg.php.tempVarName">
		<xsl:param name="itemNode" select="." />
		<xsl:text>$</xsl:text>
		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="text">
				<xsl:call-template name="prg.optionId">
					<xsl:with-param name="optionNode" select="$itemNode" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="replace">
				<xsl:text>-</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="by">
				<xsl:text>_</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Create an array of values -->
	<xsl:template name="prg.php.valueArray">
		<xsl:param name="rootNode" />
		<xsl:param name="evaluate" select="false()" />

		<xsl:variable name="quoteChar">
			<xsl:choose>
				<xsl:when test="$evaluate">
					<xsl:value-of select="'&quot;'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select='"&apos;"' />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:text>array(</xsl:text>
		<xsl:for-each select="$rootNode/*">
			<xsl:value-of select="$quoteChar" />
			<xsl:call-template name="php.escapeLiteral">
				<xsl:with-param name="value" select="." />
				<xsl:with-param name="quoteChar" select="$quoteChar" />
				<xsl:with-param name="evaluate" select="$evaluate" />
			</xsl:call-template>
			<xsl:value-of select="$quoteChar" />
			<xsl:if test="position() != last()">
				<xsl:text>, </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<!-- Constructor parameter list for switches, argument and multiargument options -->
	<xsl:template name="prg.php.chunk.leafOptionInfoCtorParameters">
		<xsl:param name="optionNode" select="." />

		<xsl:choose>
			<xsl:when test="$optionNode/prg:databinding/prg:variable">
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>null</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="prg.php.valueArray">
			<xsl:with-param name="rootNode" select="$optionNode/prg:names" />
		</xsl:call-template>
		<xsl:text>, (0</xsl:text>
		<xsl:if test="$optionNode/@required">
			<xsl:text> | </xsl:text>
			<xsl:call-template name="prg.php.base.classname">
				<xsl:with-param name="classname" select="'ItemInfo'" />
			</xsl:call-template>
			<xsl:text>::REQUIRED</xsl:text>
		</xsl:if>
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template name="prg.php.chunk.argumentType">
		<xsl:param name="typeNode" />

		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'ArgumentType'" />
		</xsl:call-template>
		<xsl:text>::</xsl:text>
		<xsl:choose>
			<xsl:when test="$typeNode/*[1]">
				<xsl:call-template name="str.toUpper">
					<xsl:with-param name="text" select="local-name($typeNode/*[1])" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>MIXED</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.php.switchOptionInfo">
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="optionVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$optionVariable" />
		<xsl:text> = new </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'SwitchOptionInfo'" />
		</xsl:call-template>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="prg.php.chunk.leafOptionInfoCtorParameters">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template name="prg.php.argumentOptionInfo">
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="optionVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$optionVariable" />
		<xsl:text> = new </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'ArgumentOptionInfo'" />
		</xsl:call-template>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="prg.php.chunk.leafOptionInfoCtorParameters">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:if test="$optionNode/prg:default">
			<xsl:value-of select="$optionVariable" />
			<xsl:text>->defaultValue = '</xsl:text>
			<xsl:apply-templates select="$optionNode/prg:default" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$optionNode/prg:type">
			<xsl:value-of select="$optionVariable" />
			<xsl:text>->argumentType = </xsl:text>
			<xsl:call-template name="prg.php.chunk.argumentType">
				<xsl:with-param name="typeNode" select="$optionNode/prg:type" />
			</xsl:call-template>
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.php.multiArgumentOptionInfo">
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="optionVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$optionVariable" />
		<xsl:text> = new </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'MultiArgumentOptionInfo'" />
		</xsl:call-template>
		<xsl:text>(</xsl:text>
		<xsl:call-template name="prg.php.chunk.leafOptionInfoCtorParameters">
			<xsl:with-param name="optionNode" select="$optionNode" />
		</xsl:call-template>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:if test="$optionNode/prg:type">
			<xsl:value-of select="$optionVariable" />
			<xsl:text>->argumentType = </xsl:text>
			<xsl:call-template name="prg.php.chunk.argumentType">
				<xsl:with-param name="typeNode" select="$optionNode/prg:type" />
			</xsl:call-template>
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$optionNode/@min &gt; 0">
			<xsl:value-of select="$optionVariable" />
			<xsl:text>->minArgumentCount = </xsl:text>
			<xsl:value-of select="$optionNode/@min" />
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$optionNode/@max &gt; 0">
			<xsl:value-of select="$optionVariable" />
			<xsl:text>->maxArgumentCount = </xsl:text>
			<xsl:value-of select="$optionNode/@max" />
			<xsl:text>;</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.php.groupOptionInfo">
		<xsl:param name="optionNode" select="." />

		<xsl:variable name="optionVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$optionVariable" />
		<xsl:text> = new </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'GroupOptionInfo'" />
		</xsl:call-template>
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/prg:databinding/prg:variable">
				<xsl:text>"</xsl:text>
				<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
				<xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>null</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'GroupOptionInfo'" />
		</xsl:call-template>
		<xsl:choose>
			<xsl:when test="$optionNode/@type = 'exclusive'">
				<xsl:text>::TYPE_EXCLUSIVE</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>::TYPE_NORMAL</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, (0</xsl:text>
		<xsl:choose>
			<xsl:when test="$optionNode/@required">
				<xsl:text> | </xsl:text>
				<xsl:call-template name="prg.php.base.classname">
					<xsl:with-param name="classname" select="'ItemInfo'" />
				</xsl:call-template>
				<xsl:text>::REQUIRED</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:text>)</xsl:text>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />
		<xsl:for-each select="$optionNode/prg:options/*">
			<xsl:call-template name="prg.php.optionInfo">
				<xsl:with-param name="parentVariable" select="$optionVariable" />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:if test="$optionNode/prg:default">
			<xsl:variable name="defaultOptionId" select="$optionNode/prg:default/@id" />
			<xsl:variable name="defaultOptionNode" select="$optionNode/prg:options/*[@id=$defaultOptionId]" />
			<xsl:variable name="defaultOptionVariable">
				<xsl:call-template name="prg.php.tempVarName">
					<xsl:with-param name="itemNode" select="$defaultOptionNode" />
				</xsl:call-template>
			</xsl:variable>

			<xsl:value-of select="$str.endl" />
			<xsl:call-template name="php.comment">
				<xsl:with-param name="content" select="$defaultOptionId"/>
			</xsl:call-template>
			<xsl:value-of select="$str.endl" />
			<xsl:call-template name="php.comment">
			<xsl:with-param name="content">
				<xsl:value-of select="name($defaultOptionNode)" />
				<xsl:text> </xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />
			
			<xsl:value-of select="$optionVariable" />
			<xsl:text>-&gt;defaultOption = </xsl:text>
			<xsl:value-of select="$defaultOptionVariable" />
			<xsl:text>;</xsl:text>
		</xsl:if>

	</xsl:template>

	<xsl:template name="prg.php.validators">
		<xsl:param name="itemNode" />
		<xsl:param name="itemVariable" />

		<!-- Validators -->
		<xsl:variable name="typeNode" select="$itemNode/prg:type" />

		<xsl:if test="$typeNode/prg:path">
			<xsl:variable name="pathNode" select="$typeNode/prg:path" />
			<xsl:variable name="validatorClass">
				<xsl:call-template name="prg.php.base.classname">
					<xsl:with-param name="classname" select="'PathValueValidator'" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$itemVariable" />
			<xsl:text>->validators[] = new </xsl:text>
			<xsl:value-of select="$validatorClass" />
			<xsl:text>(0</xsl:text>
			<xsl:if test="$pathNode/@exist">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::EXISTS</xsl:text>
			</xsl:if>
			<xsl:if test="contains($pathNode/@access, 'r')">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::ACCESS_READ</xsl:text>
			</xsl:if>
			<xsl:if test="contains($pathNode/@access, 'w')">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::ACCESS_WRITE</xsl:text>
			</xsl:if>
			<xsl:if test="contains($pathNode/@access, 'x')">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::ACCESS_EXECUTE</xsl:text>
			</xsl:if>

			<xsl:if test="$pathNode/prg:kinds/prg:file">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::TYPE_FILE</xsl:text>
			</xsl:if>
			<xsl:if test="$pathNode/prg:kinds/prg:folder">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::TYPE_FOLDER</xsl:text>
			</xsl:if>
			<xsl:if test="$pathNode/prg:kinds/prg:symlink">
				<xsl:text> | </xsl:text>
				<xsl:value-of select="$validatorClass" />
				<xsl:text>::TYPE_SYMLINK</xsl:text>
			</xsl:if>
			<xsl:text>);</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$typeNode/prg:number">
			<xsl:variable name="numberNode" select="$typeNode/prg:number" />
			<xsl:variable name="validatorClass">
				<xsl:call-template name="prg.php.base.classname">
					<xsl:with-param name="classname" select="'NumberValueValidator'" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$itemVariable" />
			<xsl:text>->validators[] = new </xsl:text>
			<xsl:value-of select="$validatorClass" />
			<xsl:text>(</xsl:text>
			<xsl:choose>
				<xsl:when test="$numberNode/@min">
					<xsl:value-of select="$numberNode/@min" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>null</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>, </xsl:text>
			<xsl:choose>
				<xsl:when test="$numberNode/@max">
					<xsl:value-of select="$numberNode/@max" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>null</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:text>);</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:if test="$itemNode/prg:select[@restrict = 'true']">
			<xsl:variable name="selectNode" select="$itemNode/prg:select" />
			<xsl:variable name="validatorClass">
				<xsl:call-template name="prg.php.base.classname">
					<xsl:with-param name="classname" select="'EnumerationValueValidator'" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$itemVariable" />
			<xsl:text>->validators[] = new </xsl:text>
			<xsl:value-of select="$validatorClass" />
			<xsl:text>(</xsl:text>
			<xsl:call-template name="prg.php.valueArray">
				<xsl:with-param name="rootNode" select="$selectNode" />
			</xsl:call-template>
			<xsl:text>);</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.php.optionInfo">
		<xsl:param name="optionNode" select="." />
		<xsl:param name="parentVariable" select="." />

		<xsl:variable name="optionVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="$optionNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$str.endl" />
		<xsl:call-template name="php.comment">
			<xsl:with-param name="content">
				<xsl:value-of select="name($optionNode)" />
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="$optionNode/prg:databinding/prg:variable" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:choose>
			<xsl:when test="$optionNode/self::prg:switch">
				<xsl:call-template name="prg.php.switchOptionInfo">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:argument">
				<xsl:call-template name="prg.php.argumentOptionInfo">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:multiargument">
				<xsl:call-template name="prg.php.multiArgumentOptionInfo">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$optionNode/self::prg:group">
				<xsl:call-template name="prg.php.groupOptionInfo">
					<xsl:with-param name="optionNode" select="$optionNode" />
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>

		<xsl:if test="$optionNode/prg:documentation/prg:abstract">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$optionVariable" />
			<xsl:text>->abstract = '</xsl:text>
			<xsl:apply-templates select="$optionNode/prg:documentation/prg:abstract" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:if test="$optionNode/prg:documentation/prg:details">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$optionVariable" />
			<xsl:text>-&gt;details = '</xsl:text>
			<xsl:apply-templates select="$optionNode/prg:documentation/prg:details" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:call-template name="prg.php.validators">
			<xsl:with-param name="itemNode" select="$optionNode" />
			<xsl:with-param name="itemVariable" select="$optionVariable" />
		</xsl:call-template>

		<xsl:value-of select="$parentVariable" />
		<xsl:text>->appendOption(</xsl:text>
		<xsl:value-of select="$optionVariable" />
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />
	</xsl:template>

	<xsl:template name="prg.php.positionalArgumentInfo">
		<xsl:param name="positionalArgumentNode" select="." />
		<xsl:param name="parentVariable" />

		<xsl:variable name="paiVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="$positionalArgumentNode" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:value-of select="$paiVariable" />
		<xsl:text> = </xsl:text>
		<xsl:value-of select="$parentVariable" />
		<xsl:text>->appendPositionalArgument( new </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'PositionalArgumentInfo'" />
		</xsl:call-template>
		<xsl:text>(</xsl:text>
		<xsl:choose>
			<xsl:when test="$positionalArgumentNode/self::prg:value">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:when test="$positionalArgumentNode/self::prg:other/@max">
				<!-- @note Not yet supported by schema -->
				<xsl:value-of select="$positionalArgumentNode/@max" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>-1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>, </xsl:text>
		<xsl:call-template name="prg.php.chunk.argumentType">
			<xsl:with-param name="typeNode" select="$positionalArgumentNode/prg:type" />
		</xsl:call-template>
		<xsl:text>, (0</xsl:text>
		<!-- @note Not supported by schema (yet) -->
		<xsl:if test="$positionalArgumentNode/@required">
			<xsl:text> | </xsl:text>
			<xsl:call-template name="prg.php.base.classname">
				<xsl:with-param name="classname" select="'ItemInfo'" />
			</xsl:call-template>
			<xsl:text>::REQUIRED</xsl:text>
		</xsl:if>
		<xsl:text>)</xsl:text>
		<xsl:text>)</xsl:text>
		<xsl:text>);</xsl:text>
		<xsl:value-of select="$str.endl" />
		<!-- Validators -->
		<xsl:call-template name="prg.php.validators">
			<xsl:with-param name="itemVariable" select="$paiVariable" />
			<xsl:with-param name="itemNode" select="$positionalArgumentNode" />
		</xsl:call-template>

		<xsl:if test="$positionalArgumentNode/prg:documentation/prg:abstract">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$paiVariable" />
			<xsl:text>-&gt;abstract = '</xsl:text>
			<xsl:apply-templates select="$positionalArgumentNode/prg:documentation/prg:abstract" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:if test="$positionalArgumentNode/prg:documentation/prg:details">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$paiVariable" />
			<xsl:text>-&gt;details = '</xsl:text>
			<xsl:apply-templates select="$positionalArgumentNode/prg:documentation/prg:details" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.php.rootItemInfo">
		<xsl:param name="rootNode" select="." />
		<xsl:param name="rootVariable" select="'$this'" />

		<xsl:if test="$rootNode/prg:documentation/prg:abstract">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$rootVariable" />
			<xsl:text>-&gt;abstract = '</xsl:text>
			<xsl:apply-templates select="$rootNode/prg:documentation/prg:abstract" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
		<xsl:if test="$rootNode/prg:documentation/prg:details">
			<xsl:value-of select="$str.endl" />
			<xsl:value-of select="$rootVariable" />
			<xsl:text>-&gt;details = '</xsl:text>
			<xsl:apply-templates select="$rootNode/prg:documentation/prg:details" />
			<xsl:text>';</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:for-each select="$rootNode/prg:options/*">
			<xsl:call-template name="prg.php.optionInfo">
				<xsl:with-param name="parentVariable" select="$rootVariable" />
			</xsl:call-template>
		</xsl:for-each>

		<xsl:for-each select="$rootNode/prg:values/*">
			<xsl:call-template name="prg.php.positionalArgumentInfo">
				<xsl:with-param name="parentVariable" select="$rootVariable" />
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="prg:subcommand">

		<xsl:variable name="rootVariable">
			<xsl:call-template name="prg.php.tempVarName">
				<xsl:with-param name="itemNode" select="." />
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="php.comment">
			<xsl:with-param name="content" select="concat('subcommand ', prg:name)" />
		</xsl:call-template>
		<xsl:value-of select="$str.endl" />

		<xsl:value-of select="$rootVariable" />
		<xsl:text> = $this->appendSubcommand(new </xsl:text>
		<xsl:call-template name="prg.php.base.classname">
			<xsl:with-param name="classname" select="'SubcommandInfo'" />
		</xsl:call-template>
		<xsl:text>("</xsl:text>
		<xsl:apply-templates select="prg:name" />
		<xsl:text>", </xsl:text>
		<xsl:call-template name="prg.php.valueArray">
			<xsl:with-param name="rootNode" select="prg:aliases" />
		</xsl:call-template>
		<xsl:text>));</xsl:text>
		<xsl:value-of select="$str.endl" />

		<xsl:call-template name="prg.php.rootItemInfo">
			<xsl:with-param name="rootVariable" select="$rootVariable" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:program">
		<xsl:variable name="classname">
			<xsl:choose>
				<xsl:when test="string-length($prg.php.programinfo.classname) &gt; 0">
					<xsl:value-of select="$prg.php.programinfo.classname" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="code.identifierNamingStyle">
						<xsl:with-param name="identifier">
							<xsl:apply-templates select="./prg:name" />
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text>ProgramInfo</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:call-template name="php.class">
			<xsl:with-param name="name" select="$classname" />
			<xsl:with-param name="extends">
				<xsl:call-template name="prg.php.base.classname">
					<xsl:with-param name="classname" select="'ProgramInfo'" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:call-template name="php.method">
					<xsl:with-param name="name" select="'__construct'" />
					<xsl:with-param name="content">
						<xsl:text>parent::__construct("</xsl:text>
						<xsl:apply-templates select="./prg:name" />
						<xsl:text>");</xsl:text>
						<xsl:value-of select="$str.endl" />
						<xsl:call-template name="prg.php.rootItemInfo" />
						<xsl:for-each select="./prg:subcommands/*">
							<xsl:value-of select="$str.endl" />
							<xsl:apply-templates select="." />
						</xsl:for-each>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:variable|prg:short|prg:long">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>

	<xsl:template match="prg:abstract | prg:details/text() | prg:block/text()">
		<xsl:call-template name="str.replaceAll">
			<xsl:with-param name="text">
				<xsl:call-template name="str.replaceAll">
					<xsl:with-param name="text" select="normalize-space(.)" />
					<xsl:with-param name="replace" select="'\'" />
					<xsl:with-param name="by" select="'\\'" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="replace" select='"&apos;"' />
			<xsl:with-param name="by" select='concat("\", "&apos;")' />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:br|prg:endl">
		<xsl:text>' . PHP_EOL . '</xsl:text>
	</xsl:template>

	<xsl:template match="prg:block">
		<xsl:text>' . PHP_EOL . '</xsl:text>
		<xsl:call-template name="str.prependLine">
			<xsl:with-param name="text">
				<xsl:apply-templates />
			</xsl:with-param>
			<xsl:with-param name="prependedText">
				<xsl:text>' . "\t" . '</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="prg:default|prg:select/prg:option">
		<xsl:call-template name="php.escapeLiteral">
			<xsl:with-param name="value" select="." />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.php.programinfo.output">
		<xsl:param name="rootNode" select="/" />
		<xsl:call-template name="php.namespace">
			<xsl:with-param name="name" select="$prg.php.programinfo.namespace" />
			<xsl:with-param name="forceDeclaration" select="$prg.php.namespace.forceDeclaration" />
			<xsl:with-param name="content">
				<xsl:apply-templates select="$rootNode/prg:program" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="/">
		<xsl:if test="$prg.php.phpmarkers">
			<xsl:text>&lt;?php</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>

		<xsl:call-template name="prg.php.programinfo.output" />

		<xsl:if test="$prg.php.phpmarkers">
			<xsl:text>?&gt;</xsl:text>
			<xsl:value-of select="$str.endl" />
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>