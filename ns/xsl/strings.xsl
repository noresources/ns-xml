<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<param name="str.endlChar">
		<text>&#10;</text>
	</param>

	<!-- Add a new line -->
	<template name="endl">
		<value-of select="$str.endlChar" />
	</template>

	<template name="unixEndl">
		<text>&#10;</text>
	</template>

	<template name="windowsEndl">
		<text>&#13;</text>
		<text>&#10;</text>
	</template>

	<template name="macEndl">
		<text>&#13;</text>
	</template>

	<!-- Replace a string by another -->
	<template name="str.replaceAll">
		<param name="text" />
		<param name="replace" />
		<param name="by" />
		<choose>
			<when test="contains($text, $replace)">
				<value-of select="substring-before($text,$replace)" />
				<value-of select="$by" />
				<call-template name="str.replaceAll">
					<with-param name="text" select="substring-after($text,$replace)" />
					<with-param name="replace" select="$replace" />
					<with-param name="by" select="$by" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$text" />
			</otherwise>
		</choose>
	</template>

	<template name="str.repeat">
		<param name="iterations" select="1" />
		<param name="text">&#32;
		</param>
		<value-of select="$text" />
		<if test="$iterations > 1">
			<call-template name="str.repeat">
				<with-param name="iterations" select="$iterations - 1" />
				<with-param name="str" select="$text" />
			</call-template>
		</if>
	</template>

	<template name="str.elementLocalPart">
		<param name="node" select="." />
		<value-of select="substring-after(name($node), ':' )" />
	</template>

		<!-- Indent a text block by adding indentaction characters at the beginning of all text lines -->
	<template name="str.prependLine">
		<param name="level" select="1" />
		<param name="prependedText"><text>&#9;</text></param>
		<param name="endlChar" select="$str.endlChar"/>
		<param name="content" />
		<variable name="fullPrependedText">
			<call-template name="str.repeat">
				<with-param name="iterations" select="$level" />
				<with-param name="text" select="$prependedText"/>
			</call-template>
		</variable>
		<value-of select="$fullPrependedText" />
		<call-template name="str.replaceAll">
			<with-param name="text">
				<value-of select="$content" />
			</with-param>
			<with-param name="replace">
				<value-of select="$endlChar"/>
			</with-param>
			<with-param name="by">
				<value-of select="$endlChar"/>
				<value-of select="$fullPrependedText" />
			</with-param>
		</call-template>
	</template>
	
	<template name="str.trim">
    <param name="text" select="."/>
    <variable name="lTrimmed">
      <call-template name="str.trimLeft">
        <with-param name="text" select="$text" />
      </call-template>
    </variable>
    <variable name="trimmed">
      <call-template name="str.trimRight">
        <with-param name="text" select="$lTrimmed" />
      </call-template>
    </variable>
    <value-of select="$trimmed"/>
  </template>

  <template name="str.trimLeft">
    <param name="text" />
    <choose>
      <when test="starts-with($text,'&#9;') or starts-with($text,'&#10;') or starts-with($text,'&#13;') or starts-with($text,'	')">
        <call-template name="str.trimLeft">
          <with-param name="text" select="substring($text, 2)"/>
        </call-template>
      </when>
      <otherwise>
        <value-of select="$text"/>
      </otherwise>
    </choose>
  </template>

  <template name="str.trimRight">
    <param name="text"/>
    <variable name="last-char">
      <value-of select="substring($text, string-length($text), 1)"/>
    </variable>
    <choose>
      <when test="($last-char = '&#9;') or ($last-char = '&#10;') or ($last-char = '&#13;') or ($last-char = ' ')">
        <call-template name="str.trimRight">
          <with-param name="text" select="substring($text, 1, string-length($text) - 1)"/>
        </call-template>
      </when>
      <otherwise>
        <value-of select="$text"/>
      </otherwise>
    </choose>
  </template>
	
	<variable name="str.smallCase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<variable name="str.upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
	
	<template name="str.toUpper">
		<param name="content" select="."/>
  		<value-of select="translate($content, $str.smallCase, $str.upperCase)" />
	</template>
	
	<template name="str.toLower">
		<param name="content" select="."/>
  		<value-of select="translate($content, $str.upperCase, $str.smallCase)" />
	</template>

</stylesheet>