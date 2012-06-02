<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- String manipulation functions -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform">

	<param name="str.endlChar">
		<text>&#10;</text>
	</param>

	<param name="str.blanks" select="'&#9;&#32;'" />

	<!-- Add a new line -->
	<template name="endl">
		<value-of select="$str.endlChar" />
	</template>

	<!-- Unix-style end-of-line marker -->
	<template name="unixEndl">
		<text>&#10;</text>
	</template>

	<!-- Microsoft Windows end-of-line marker -->
	<template name="windowsEndl">
		<text>&#13;</text>
		<text>&#10;</text>
	</template>

	<!-- MacOS end-of-line marker -->
	<template name="macEndl">
		<text>&#13;</text>
	</template>

	<template name="str.isBlank">
		<param name="text" select="." />
		<param name="_position" select="1" />

		<variable name="c" select="substring($text, 1, 1)" />

		<choose>
			<when test="string-length($c) = 1">
				<variable name="cv">
					<call-template name="srt.isBlankChar">
						<with-param name="char" select="$c" />
					</call-template>
				</variable>
				<variable name="others">
					<call-template name="srt.isBlank">
						<with-param name="text" select="substring($text, 2)" />
					</call-template>
				</variable>
				<value-of select="$cv + $others" />
			</when>
			<otherwise>
				<value-of select="0" />
			</otherwise>
		</choose>
	</template>

	<template name="str.isBlankChar">
		<param name="char" select="substring(., 1, 1)" />
		<param name="_position" select="1" />

		<variable name="c" select="substring($char, 1, 1)" />

		<choose>
			<when test="contains($str.blanks, $c)">
				<value-of select="1" />
			</when>
			<otherwise>
				<value-of select="0" />
			</otherwise>
		</choose>
	</template>

	<!-- Get the substring before the last occurence of the given delimiter -->
	<template name="str.substringBeforeLast">
		<param name="text" />
		<param name="delimiter" />

		<if test="contains($text, $delimiter)">
			<variable name="b" select="substring-before($text, $delimiter)" />
			<variable name="a" select="substring-after($text, $delimiter)" />
			<value-of select="$b" />
			<variable name="next">
				<call-template name="str.substringBeforeLast">
					<with-param name="text" select="$a" />
					<with-param name="delimiter" select="$delimiter" />
				</call-template>
			</variable>
			<if test="string-length($next) &gt; 0">
				<value-of select="$delimiter" />
				<value-of select="$next" />
			</if>
		</if>
	</template>

	<!-- Get the substring after the last occurence of the given delimiter -->
	<template name="str.substringAfterLast">
		<param name="text" />
		<param name="delimiter" />
		<choose>
			<when test="contains($text, $delimiter)">
				<call-template name="str.substringAfterLast">
					<with-param name="text" select="substring-after($text, $delimiter)" />
					<with-param name="delimiter" select="$delimiter" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$text" />
			</otherwise>
		</choose>

	</template>

	<!-- Replace a string by another -->
	<template name="str.replaceAll">
		<!-- Text to process -->
		<param name="text" />
		<!-- Text to replace -->
		<param name="replace" />
		<!-- Replacement string -->
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

	<template name="str.count">
		<!-- Text to process -->
		<param name="text" />

		<!-- Substring to count -->
		<param name="substring" />

		<!-- Internal parameter -->
		<param name="_count" select="0" />

		<choose>
			<when test="contains($text, $substring)">
				<call-template name="str.count">
					<with-param name="text" select="substring-after($text, $substring)" />
					<with-param name="substring" select="$substring" />
					<with-param name="_count" select="$_count + 1" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$_count" />
			</otherwise>
		</choose>
	</template>

	<template name="str.repeat">
		<param name="iterations" select="1" />
		<param name="text">
			<text>&#32;</text>
		</param>
		<if test="$iterations &gt; 0">
			<value-of select="$text" />

			<call-template name="str.repeat">
				<with-param name="iterations" select="$iterations - 1" />
				<with-param name="text" select="$text" />
			</call-template>
		</if>
	</template>

	<template name="str.elementLocalPart">
		<param name="node" select="." />
		<value-of select="substring-after(name($node), ':' )" />
	</template>

	<template>

	</template>

	<!-- Find the last breakable character index -->
	<template name="str.lastBreakableCharacterPosition">
		<!-- Text to process -->
		<param name="text" select="." />
		<!-- Internal use -->
		<param name="_position" select="1" />
		<!-- Internal use -->
		<param name="_bestValue" select="-1" />

		<variable name="breakables" select="'&#32;&#9;,;:?.!'" />

		<variable name="c">
			<value-of select="substring($breakables, $_position, 1)" />
		</variable>

		<choose>
			<when test="(string-length($text) &gt; 0) and (string-length($c) = 1)">
				<choose>
					<when test="contains($text, $c)">
						<variable name="sub">
							<call-template name="str.substringBeforeLast">
								<with-param name="text" select="$text" />
								<with-param name="delimiter" select="$c" />
							</call-template>
						</variable>

						<variable name="subIndex" select="string-length($sub)" />

						<variable name="newBest">
							<choose>
								<when test="$subIndex &gt; $_bestValue">
									<value-of select="$subIndex" />
								</when>
								<otherwise>
									<value-of select="$_bestValue" />
								</otherwise>
							</choose>
						</variable>

						<call-template name="str.lastBreakableCharacterPosition">
							<with-param name="text" select="$text" />
							<with-param name="_position" select="$_position + 1" />
							<with-param name="_bestValue" select="$newBest" />
						</call-template>
					</when>
					<otherwise>
						<call-template name="str.lastBreakableCharacterPosition">
							<with-param name="text" select="$text" />
							<with-param name="_position" select="$_position + 1" />
							<with-param name="_bestValue" select="$_bestValue" />
						</call-template>
					</otherwise>
				</choose>
			</when>

			<otherwise>
				<choose>
					<when test="$_bestValue &gt;= 0">
						<value-of select="$_bestValue + 1" />
					</when>
					<otherwise>
						<value-of select="string-length($text) + 1" />
					</otherwise>
				</choose>
			</otherwise>
		</choose>

	</template>

	<!-- Wrap text -->
	<template name="str.wrap">

		<!-- Text to wrap -->
		<param name="text" select="." />

		<!-- Maximum number of character per line -->
		<param name="lineMaxLength" select="80" />

		<!-- End-of-line string -->
		<param name="endlChar" select="$str.endlChar" />

		<variable name="hasEndl" select="contains($text, $endlChar)" />
		<variable name="item">
			<choose>
				<when test="$hasEndl">
					<value-of select="substring-before($text, $endlChar)" />
				</when>
				<otherwise>
					<value-of select="$text" />
				</otherwise>
			</choose>
		</variable>

		<if test="string-length($item) &gt; 0">
			<choose>
				<when test="string-length($item) &gt; $lineMaxLength">
					<variable name="splititem" select="substring($item, 1, $lineMaxLength)" />
					<variable name="breakPosition">
						<call-template name="str.lastBreakableCharacterPosition">
							<with-param name="text" select="$splititem" />
						</call-template>
					</variable>

					<variable name="b" select="substring($splititem, $breakPosition, 1)" />

					<variable name="isBlank">
						<choose>
							<when test="string-length($b) &gt; 0">
								<call-template name="str.isBlankChar">
									<with-param name="char" select="$b" />
								</call-template>
							</when>
						</choose>
					</variable>

					<variable name="len">
						<choose>
							<when test="$breakPosition &gt; $lineMaxLength">
								<value-of select="$lineMaxLength" />
							</when>
							<otherwise>
								<value-of select="$breakPosition" />
							</otherwise>
						</choose>
					</variable>

					<variable name="part">
						<choose>
							<when test="$breakPosition = 1 and ($isBlank &gt; 0)">
								<value-of select="substring($item, 2, $len - 1)" />
							</when>
							<otherwise>
								<value-of select="substring($item, 1, $len)" />
							</otherwise>
						</choose>
					</variable>
					
					<if test="string-length($part) &gt; 0">
						<value-of select="$part" />
						<value-of select="$endlChar" />
					</if>

					<!-- remaining part -->
					<call-template name="str.wrap">
						<with-param name="text" select="substring($text, $len + 1)" />
						<with-param name="lineMaxLength" select="$lineMaxLength" />
						<with-param name="endlChar" select="$endlChar" />
					</call-template>
				</when>
				<otherwise>
					<value-of select="$item" />
				</otherwise>
			</choose>
		</if>

		<!-- other lines -->
		<if test="$hasEndl = true()">
			<value-of select="$endlChar" />
			<call-template name="str.wrap">
				<with-param name="text" select="substring-after($text, $endlChar)" />
				<with-param name="lineMaxLength" select="$lineMaxLength" />
				<with-param name="endlChar" select="$endlChar" />
			</call-template>
		</if>
	</template>

	<!-- Indent a text block by adding indentaction characters at the beginning of all text lines -->
	<template name="str.prependLine">
		<param name="text" />
		<param name="level" select="1" />
		<param name="prependedText">
			<text>&#9;</text>
		</param>
		<param name="endlChar" select="$str.endlChar" />
		<param name="wrap" select="false()" />
		<param name="lineMaxLength" select="80" />

		<variable name="fullPrependedText">
			<call-template name="str.repeat">
				<with-param name="iterations" select="$level" />
				<with-param name="text" select="$prependedText" />
			</call-template>
		</variable>
		
		<variable name="realLineMaxLength" select="$lineMaxLength - string-length($fullPrependedText)" />
		
		<variable name="content">
			<choose>
				<when test="$wrap">
					<call-template name="str.wrap">
						<with-param name="text" select="$text" />
						<with-param name="endlChar" select="$endlChar" />
						<with-param name="lineMaxLength" select="$realLineMaxLength" />
					</call-template>
				</when>
				<otherwise>
					<value-of select="$text" />
				</otherwise>
			</choose>
		</variable>

		<value-of select="$fullPrependedText" />
		<call-template name="str.replaceAll">
			<with-param name="text">
				<value-of select="$content" />
			</with-param>
			<with-param name="replace">
				<value-of select="$endlChar" />
			</with-param>
			<with-param name="by">
				<value-of select="$endlChar" />
				<value-of select="$fullPrependedText" />
			</with-param>
		</call-template>
	</template>

	<template name="str.trim">
		<param name="text" select="." />
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
		<value-of select="$trimmed" />
	</template>

	<template name="str.trimLeft">
		<param name="text" />
		<choose>
			<when test="starts-with($text,'&#9;') or starts-with($text,'&#10;') or starts-with($text,'&#13;') or starts-with($text,'	')">
				<call-template name="str.trimLeft">
					<with-param name="text" select="substring($text, 2)" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$text" />
			</otherwise>
		</choose>
	</template>

	<template name="str.trimRight">
		<param name="text" />
		<variable name="last-char">
			<value-of select="substring($text, string-length($text), 1)" />
		</variable>
		<choose>
			<when test="($last-char = '&#9;') or ($last-char = '&#10;') or ($last-char = '&#13;') or ($last-char = ' ')">
				<call-template name="str.trimRight">
					<with-param name="text" select="substring($text, 1, string-length($text) - 1)" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$text" />
			</otherwise>
		</choose>
	</template>

	<variable name="str.smallCase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<variable name="str.upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

	<template name="str.toUpper">
		<param name="content" select="." />
		<value-of select="translate($content, $str.smallCase, $str.upperCase)" />
	</template>

	<template name="str.toLower">
		<param name="content" select="." />
		<value-of select="translate($content, $str.upperCase, $str.smallCase)" />
	</template>

</stylesheet>