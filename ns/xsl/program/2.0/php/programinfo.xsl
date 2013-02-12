<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Create and fill a PHP ProgramInfo object -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<import href="../../../languages/php.xsl" />
	<import href="../base.xsl" />
	<import href="./base.xsl" />

	<output method="text" encoding="utf-8" />

	<!-- If empty, use <appname>ProgramInfo -->
	<param name="prg.php.programinfo.classname" select="''" />
	
	<!-- Generate a unique variable name from item info -->
	<template name="prg.php.tempVarName">
		<param name="itemNode" select="." />
		<text>$</text>
		<call-template name="str.replaceAll">
			<with-param name="text">
				<call-template name="prg.optionId">
					<with-param name="itemNode" select="$itemNode" />
				</call-template>
			</with-param>
			<with-param name="replace">
				<text>-</text>
			</with-param>
			<with-param name="by">
				<text>_</text>
			</with-param>
		</call-template>
	</template>

	<!-- Create an array of values -->
	<template name="prg.php.valueArray">
		<param name="rootNode" />
		<text>array(</text>
		<for-each select="$rootNode/*">
			<text>"</text>
			<apply-templates select="." />
			<text>"</text>
			<if test="position() != last()">
				<text>, </text>
			</if>
		</for-each>
		<text>)</text>
	</template>

	<!-- Constructor parameter list for switches, argument and multiargument options -->
	<template name="prg.php.chunk.leafOptionInfoCtorParameters">
		<param name="optionNode" select="." />

		<choose>
			<when test="$optionNode/prg:databinding/prg:variable">
				<text>"</text>
				<apply-templates select="$optionNode/prg:databinding/prg:variable" />
				<text>"</text>
			</when>
			<otherwise>
				<text>null</text>
			</otherwise>
		</choose>
		<text>, </text>
		<call-template name="prg.php.valueArray">
			<with-param name="rootNode" select="$optionNode/prg:names" />
		</call-template>
		<text>, (0</text>
		<if test="$optionNode/@required">
			<text> | </text>
			<call-template name="prg.php.base.classname">
				<with-param name="classname" select="'ItemInfo'" />
			</call-template>
			<text>::REQUIRED</text>
		</if>
		<text>)</text>
	</template>

	<template name="prg.php.chunk.argumentType">
		<param name="typeNode" />

		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'ArgumentType'" />
		</call-template>
		<text>::</text>
		<choose>
			<when test="$typeNode/*[1]">
				<call-template name="str.toUpper">
					<with-param name="text" select="local-name($typeNode/*[1])" />
				</call-template>
			</when>
			<otherwise>
				<text>MIXED</text>
			</otherwise>
		</choose>
	</template>

	<template name="prg.php.switchOptionInfo">
		<param name="optionNode" select="." />

		<variable name="optionVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="$optionNode" />
			</call-template>
		</variable>

		<value-of select="$optionVariable" />
		<text> = new </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'SwitchOptionInfo'" />
		</call-template>
		<text>(</text>
		<call-template name="prg.php.chunk.leafOptionInfoCtorParameters">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>);</text>
		<value-of select="$str.endl" />
	</template>

	<template name="prg.php.argumentOptionInfo">
		<param name="optionNode" select="." />

		<variable name="optionVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="$optionNode" />
			</call-template>
		</variable>

		<value-of select="$optionVariable" />
		<text> = new </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'ArgumentOptionInfo'" />
		</call-template>
		<text>(</text>
		<call-template name="prg.php.chunk.leafOptionInfoCtorParameters">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>);</text>
		<value-of select="$str.endl" />

		<if test="$optionNode/prg:default">
			<value-of select="$optionVariable" />
			<text>->defaultValue = "</text>
			<apply-templates select="$optionNode/prg:default" />
			<text>";</text>
			<value-of select="$str.endl" />
		</if>

		<if test="$optionNode/prg:type">
			<value-of select="$optionVariable" />
			<text>->argumentType = </text>
			<call-template name="prg.php.chunk.argumentType">
				<with-param name="typeNode" select="$optionNode/prg:type" />
			</call-template>
			<text>;</text>
			<value-of select="$str.endl" />
		</if>
	</template>

	<template name="prg.php.multiArgumentOptionInfo">
		<param name="optionNode" select="." />

		<variable name="optionVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="$optionNode" />
			</call-template>
		</variable>

		<value-of select="$optionVariable" />
		<text> = new </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'MultiArgumentOptionInfo'" />
		</call-template>
		<text>(</text>
		<call-template name="prg.php.chunk.leafOptionInfoCtorParameters">
			<with-param name="optionNode" select="$optionNode" />
		</call-template>
		<text>);</text>
		<value-of select="$str.endl" />

		<if test="$optionNode/prg:type">
			<value-of select="$optionVariable" />
			<text>->argumentType = </text>
			<call-template name="prg.php.chunk.argumentType">
				<with-param name="typeNode" select="$optionNode/prg:type" />
			</call-template>
			<text>;</text>
			<value-of select="$str.endl" />
		</if>

		<if test="$optionNode/@min &gt; 0">
			<value-of select="$optionVariable" />
			<text>->minArgumentCount = </text>
			<value-of select="$optionNode/@min" />
			<text>;</text>
			<value-of select="$str.endl" />
		</if>

		<if test="$optionNode/@max &gt; 0">
			<value-of select="$optionVariable" />
			<text>->maxArgumentCount = </text>
			<value-of select="$optionNode/@max" />
			<text>;</text>
			<value-of select="$str.endl" />
		</if>
	</template>

	<template name="prg.php.groupOptionInfo">
		<param name="optionNode" select="." />

		<variable name="optionVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="$optionNode" />
			</call-template>
		</variable>

		<value-of select="$optionVariable" />
		<text> = new </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'GroupOptionInfo'" />
		</call-template>
		<text>(</text>
		<choose>
			<when test="$optionNode/prg:databinding/prg:variable">
				<text>"</text>
				<apply-templates select="$optionNode/prg:databinding/prg:variable" />
				<text>"</text>
			</when>
			<otherwise><text>NULL</text></otherwise>
		</choose>
		<text>, </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'GroupOptionInfo'" />
		</call-template>
		<choose>
			<when test="$optionNode/@type = 'exclusive'">
				<text>::TYPE_EXCLUSIVE</text>
			</when>
			<otherwise>
				<text>::TYPE_NORMAL</text>
			</otherwise>
		</choose>
		<text>, (0</text>
		<choose>
			<when test="$optionNode/@required">
				<text> | </text>
				<call-template name="prg.php.base.classname">
					<with-param name="classname" select="'ItemInfo'" />
				</call-template>
				<text>::REQUIRED</text>
			</when>
		</choose>
		<text>)</text>
		<text>);</text>
		<value-of select="$str.endl" />
		<for-each select="$optionNode/prg:options/*">
			<call-template name="prg.php.optionInfo">
				<with-param name="parentVariable" select="$optionVariable" />
			</call-template>
		</for-each>
	</template>

	<template name="prg.php.validators">
		<param name="itemNode" />
		<param name="itemVariable" />

		<!-- Validators -->
		<variable name="typeNode" select="$itemNode/prg:type" />

		<if test="$typeNode/prg:path">
			<variable name="pathNode" select="$typeNode/prg:path" />
			<variable name="validatorClass">
				<call-template name="prg.php.base.classname">
					<with-param name="classname" select="'PathValueValidator'" />
				</call-template>
			</variable>
			<value-of select="$itemVariable" />
			<text>->validators[] = new </text>
			<value-of select="$validatorClass" />
			<text>(0</text>
			<if test="$pathNode/@exist">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::EXISTS</text>
			</if>
			<if test="contains($pathNode/@access, 'r')">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::ACCESS_READ</text>
			</if>
			<if test="contains($pathNode/@access, 'w')">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::ACCESS_WRITE</text>
			</if>
			<if test="contains($pathNode/@access, 'x')">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::ACCESS_EXECUTE</text>
			</if>

			<if test="$pathNode/prg:kinds/prg:file">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::TYPE_FILE</text>
			</if>
			<if test="$pathNode/prg:kinds/prg:folder">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::TYPE_FOLDER</text>
			</if>
			<if test="$pathNode/prg:kinds/prg:symlink">
				<text> | </text>
				<value-of select="$validatorClass" />
				<text>::TYPE_SYMLINK</text>
			</if>
			<text>);</text>
			<value-of select="$str.endl" />
		</if>

		<if test="$typeNode/prg:number">
			<variable name="numberNode" select="$typeNode/prg:number" />
			<variable name="validatorClass">
				<call-template name="prg.php.base.classname">
					<with-param name="classname" select="'NumberValueValidator'" />
				</call-template>
			</variable>
			<value-of select="$itemVariable" />
			<text>->validators[] = new </text>
			<value-of select="$validatorClass" />
			<text>(</text>
			<choose>
				<when test="$numberNode/@min">
					<value-of select="$numberNode/@min" />
				</when>
				<otherwise>
					<text>null</text>
				</otherwise>
			</choose>
			<text>, </text>
			<choose>
				<when test="$numberNode/@max">
					<value-of select="$numberNode/@max" />
				</when>
				<otherwise>
					<text>null</text>
				</otherwise>
			</choose>
			<text>);</text>
			<value-of select="$str.endl" />
		</if>

		<if test="$itemNode/prg:select[@restrict = 'true']">
			<variable name="selectNode" select="$itemNode/prg:select" />
			<variable name="validatorClass">
				<call-template name="prg.php.base.classname">
					<with-param name="classname" select="'EnumerationValueValidator'" />
				</call-template>
			</variable>
			<value-of select="$itemVariable" />
			<text>->validators[] = new </text>
			<value-of select="$validatorClass" />
			<text>(</text>
			<call-template name="prg.php.valueArray">
				<with-param name="rootNode" select="$selectNode" />
			</call-template>
			<text>);</text>
			<value-of select="$str.endl" />
		</if>
	</template>

	<template name="prg.php.optionInfo">
		<param name="optionNode" select="." />
		<param name="parentVariable" select="." />

		<variable name="optionVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="$optionNode" />
			</call-template>
		</variable>

		<value-of select="$str.endl" />
		<call-template name="php.comment">
			<with-param name="content">
				<value-of select="name($optionNode)" />
				<text> </text>
				<apply-templates select="$optionNode/prg:databinding/prg:variable" />
			</with-param>
		</call-template>
		<value-of select="$str.endl" />

		<choose>
			<when test="$optionNode/self::prg:switch">
				<call-template name="prg.php.switchOptionInfo">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:argument">
				<call-template name="prg.php.argumentOptionInfo">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:multiargument">
				<call-template name="prg.php.multiArgumentOptionInfo">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</when>
			<when test="$optionNode/self::prg:group">
				<call-template name="prg.php.groupOptionInfo">
					<with-param name="optionNode" select="$optionNode" />
				</call-template>
			</when>
		</choose>
		
		<if test="$optionNode/prg:documentation/prg:abstract">
			<value-of select="$str.endl" />
			<value-of select="$optionVariable" />
			<text>->abstract = "</text>
			<apply-templates select="$optionNode/prg:documentation/prg:abstract" />
			<text>";</text>
			<value-of select="$str.endl" />
		</if>
		<if test="$optionNode/prg:documentation/prg:details">
			<value-of select="$str.endl" />
			<value-of select="$optionVariable" />
			<text>->details = "</text>
			<apply-templates select="$optionNode/prg:documentation/prg:details" />
			<text>";</text>
			<value-of select="$str.endl" />
		</if>

		<call-template name="prg.php.validators">
			<with-param name="itemNode" select="$optionNode" />
			<with-param name="itemVariable" select="$optionVariable" />
		</call-template>

		<value-of select="$parentVariable" />
		<text>->appendOption(</text>
		<value-of select="$optionVariable" />
		<text>);</text>
		<value-of select="$str.endl" />
	</template>

	<template name="prg.php.positionalArgumentInfo">
		<param name="positionalArgumentNode" select="." />
		<param name="parentVariable" />

		<variable name="paiVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="$positionalArgumentNode" />
			</call-template>
		</variable>

		<value-of select="$paiVariable" />
		<text> = </text>
		<value-of select="$parentVariable" />
		<text>->appendPositionalArgument( new </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'PositionalArgumentInfo'" />
		</call-template>
		<text>(</text>
		<choose>
			<when test="$positionalArgumentNode/self::prg:value">
				<text>1</text>
			</when>
			<when test="$positionalArgumentNode/self::prg:other/@max">
				<!-- @note Note yet supported by schema -->
				<value-of select="$positionalArgumentNode/@max" />
			</when>
			<otherwise>
				<text>-1</text>
			</otherwise>
		</choose>
		<text>, </text>
		<call-template name="prg.php.chunk.argumentType">
			<with-param name="typeNode" select="$positionalArgumentNode/prg:type" />
		</call-template>
		<text>, (0</text>
		<!-- @note Not supported by schema (yet) -->
		<if test="$positionalArgumentNode/@required">
			<text> | </text>
			<call-template name="prg.php.base.classname">
				<with-param name="classname" select="'ItemInfo'" />
			</call-template>
			<text>::REQUIRED</text>
		</if>
		<text>)</text>
		<text>)</text>
		<text>);</text>
		<value-of select="$str.endl" />
	</template>

	<template name="prg.php.rootItemInfo">
		<param name="rootNode" select="." />
		<param name="rootVariable" select="'$this'" />
		
		<if test="$rootNode/prg:documentation/prg:abstract">
			<value-of select="$str.endl" />
			<value-of select="$rootVariable" />
			<text>->abstract = "</text>
			<apply-templates select="$rootNode/prg:documentation/prg:abstract" />
			<text>";</text>
			<value-of select="$str.endl" />
		</if>
		<if test="$rootNode/prg:documentation/prg:details">
			<value-of select="$str.endl" />
			<value-of select="$rootVariable" />
			<text>->details = "</text>
			<apply-templates select="$rootNode/prg:documentation/prg:details" />
			<text>";</text>
			<value-of select="$str.endl" />
		</if>

		<for-each select="$rootNode/prg:options/*">
			<call-template name="prg.php.optionInfo">
				<with-param name="parentVariable" select="$rootVariable" />
			</call-template>
		</for-each>

		<for-each select="$rootNode/prg:values/*">
			<call-template name="prg.php.positionalArgumentInfo">
				<with-param name="parentVariable" select="$rootVariable" />
			</call-template>
		</for-each>
		
	</template>

	<template match="prg:subcommand">

		<variable name="rootVariable">
			<call-template name="prg.php.tempVarName">
				<with-param name="itemNode" select="." />
			</call-template>
		</variable>

		<call-template name="php.comment">
			<with-param name="content" select="concat('subcommand ', prg:name)" />
		</call-template>
		<value-of select="$str.endl" />

		<value-of select="$rootVariable" />
		<text> = $this->appendSubcommand(new </text>
		<call-template name="prg.php.base.classname">
			<with-param name="classname" select="'SubcommandInfo'" />
		</call-template>
		<text>("</text>
		<apply-templates select="prg:name" />
		<text>", </text>
		<call-template name="prg.php.valueArray">
			<with-param name="rootNode" select="prg:aliases" />
		</call-template>
		<text>));</text>
		<value-of select="$str.endl" />

		<call-template name="prg.php.rootItemInfo">
			<with-param name="rootVariable" select="$rootVariable" />
		</call-template>
	</template>

	<template match="prg:program">
		<variable name="classname">
			<choose>
				<when test="string-length($prg.php.programinfo.classname) &gt; 0">
					<value-of select="$prg.php.programinfo.classname" />
				</when>
				<otherwise>
					<call-template name="code.identifierNamingStyle">
					<with-param name="identifier">
						<apply-templates select="./prg:name" />
					</with-param>
				</call-template>
				<text>ProgramInfo</text>
				</otherwise>
			</choose>
		</variable>
		
		<call-template name="php.class">
			<with-param name="name" select="$classname" />
			<with-param name="extends">
				<call-template name="prg.php.base.classname">
					<with-param name="classname" select="'ProgramInfo'" />
				</call-template>
			</with-param>
			<with-param name="content">
				<call-template name="php.method">
					<with-param name="name" select="'__construct'" />
					<with-param name="content">
						<text>parent::__construct("</text>
						<apply-templates select="./prg:name" />
						<text>");</text>
						<value-of select="$str.endl" />
						<call-template name="prg.php.rootItemInfo" />
						<for-each select="./prg:subcommands/*">
							<value-of select="$str.endl" />
							<apply-templates select="." />
						</for-each>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template match="prg:variable|prg:short|prg:long">
		<value-of select="normalize-space(.)" />
	</template>
		
	<template match="prg:abstract/text() | prg:details/text() | prg:block/text()">
		<call-template name="str.replaceAll">
			<with-param name="text">
				<call-template name="str.replaceAll">
					<with-param name="text" select="normalize-space(.)"/>
					<with-param name="replace" select="'\'"/>
					<with-param name="by" select="'\\'"/>
				</call-template>
			</with-param>
			<with-param name="replace" select="'&quot;'"/>
			<with-param name="by" select="'\&quot;'"/>
		</call-template>
	</template>

	<template match="prg:br|prg:endl">
		<text>\n</text>
	</template>

	<template match="prg:block">
		<text>\n</text>
		<call-template name="str.prependLine">
			<with-param name="text">
				<apply-templates/>
			</with-param>
			<with-param name="prependedText" select="'\t'"/>
		</call-template>
	</template>
	
	<template name="prg.php.programinfo.output">
		<param name="rootNode" select="/" />
		<choose>
			<when test="$prg.php.programinfo.namespace and (string-length($prg.php.programinfo.namespace) &gt; 0)">
				<call-template name="php.namespace">
					<with-param name="name" select="$prg.php.programinfo.namespace" />
					<with-param name="content">
						<apply-templates select="$rootNode/prg:program" />
					</with-param>
				</call-template>
			</when>
			<otherwise>
				<apply-templates select="$rootNode/prg:program" />
			</otherwise>
		</choose>
	</template>
	
	<template match="/">
		<if test="$prg.php.phpmarkers">
			<text>&lt;?php</text>
			<value-of select="$str.endl" />
		</if>
		
		<call-template name="prg.php.programinfo.output" />
		
		<if test="$prg.php.phpmarkers">
			<text>?&gt;</text>
			<value-of select="$str.endl" />
		</if>
	</template>

</stylesheet>