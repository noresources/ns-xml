<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- String manipulation functions -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<!-- UNIX-style end of line character (LF) -->
	<variable name="str.unix.endl">
		<value-of select="'&#10;'"/>
	</variable>
	
	<!-- MacOS-style end of line character (CR) -->
	<variable name="str.mac.endl">
		<value-of select="'&#13;'"/>
	</variable>
	
	<!-- Windows-style end of line character (CRLF) -->
	<variable name="str.windows.endl">
		<value-of select="'&#13;&#10;'"/>
	</variable>
	
	<!-- Default End-of-line character(s) -->
	<param name="str.endl">
		<value-of select="$str.unix.endl"/>
	</param>
	
	<param name="str.blanks" select="'&#9; '"/>
	
	<!-- Add a new line. Deprecated: use str.endl directly -->
	<template name="endl">
		<value-of select="$str.endl"/>
	</template>

	<!-- Unix-style end-of-line marker. Deprecated: use str.unix.endl directly -->
	<template name="unixEndl">
		<value-of select="$str.unix.endl"/>
	</template>

	<!-- Microsoft Windows end-of-line marker. Deprecated: use str.windows.endl directly -->
	<template name="windowsEndl">
		<value-of select="$str.windows.endl"/>
	</template>

	<!-- MacOS end-of-line marker. Deprecated: use str.mac.endl directly -->
	<template name="macEndl">
		<value-of select="$str.mac.endl"/>
	</template>

	<!-- Indicates if text contains blank chars -->
	<template name="str.isBlank">
		<!-- Text to check -->
		<param name="text"/>
		<!-- Reserved -->
		<param name="_position" select="1"/>
		<variable name="c" select="substring($text, 1, 1)"/>
		<choose>
			<when test="string-length($c) = 1">
				<variable name="cv">
					<call-template name="str.isBlankChar">
						<with-param name="char" select="$c"/>
					</call-template>
				</variable>
				<variable name="others">
					<call-template name="str.isBlank">
						<with-param name="text" select="substring($text, 2)"/>
					</call-template>
				</variable>
				<value-of select="$cv + $others"/>
			</when>
			<otherwise>
				<value-of select="0"/>
			</otherwise>
		</choose>
	</template>

	<!-- Indicates if a characted is a blank character -->
	<template name="str.isBlankChar">
		<!-- Characted to test -->
		<param name="char" select="substring(., 1, 1)"/>
		<param name="_position" select="1"/>
		<variable name="c" select="substring($char, 1, 1)"/>
		<choose>
			<when test="contains($str.blanks, $c)">
				<value-of select="1"/>
			</when>
			<otherwise>
				<value-of select="0"/>
			</otherwise>
		</choose>
	</template>

	<!-- Get the substring before the last occurrence of the given delimiter -->
	<template name="str.substringBeforeLast">
		<param name="text"/>
		<param name="delimiter"/>
		<if test="contains($text, $delimiter)">
			<variable name="b" select="substring-before($text, $delimiter)"/>
			<variable name="a" select="substring-after($text, $delimiter)"/>
			<value-of select="$b"/>
			<variable name="next">
				<call-template name="str.substringBeforeLast">
					<with-param name="text" select="$a"/>
					<with-param name="delimiter" select="$delimiter"/>
				</call-template>
			</variable>
			<if test="string-length($next) &gt; 0">
				<value-of select="$delimiter"/>
				<value-of select="$next"/>
			</if>
		</if>
	</template>

	<!-- Get the substring after the last occurence of the given delimiter -->
	<template name="str.substringAfterLast">
		<param name="text"/>
		<param name="delimiter"/>
		<choose>
			<when test="contains($text, $delimiter)">
				<call-template name="str.substringAfterLast">
					<with-param name="text" select="substring-after($text, $delimiter)"/>
					<with-param name="delimiter" select="$delimiter"/>
				</call-template>
			</when>
			<otherwise>
				<value-of select="$text"/>
			</otherwise>
		</choose>
	</template>

	<!-- Number of occurrence of a given string at the beginning of another string -->
	<template name="str.startsWithCount">
		<!-- Text -->
		<param name="text"/>
		<!-- Substring to search -->
		<param name="needle"/>
		<!-- Internal use -->
		<param name="offset" select="1"/>
		<!-- Internal use -->
		<param name="count" select="0"/>
		<variable name="needleLength" select="string-length($needle)"/>
		<variable name="subtext" select="substring($text, $offset)"/>
		<choose>
			<when test="$needleLength = 0">
				<value-of select="$count"/>
			</when>
			<when test="starts-with($subtext, $needle)">
				<call-template name="str.startsWithCount">
					<with-param name="text" select="$text"/>
					<with-param name="needle" select="$needle"/>
					<with-param name="offset" select="$offset + $needleLength"/>
					<with-param name="count" select="$count + 1"/>
				</call-template>
			</when>
			<otherwise>
				<value-of select="$count"/>
			</otherwise>
		</choose>
	</template>

	<template name="str.endsWith">
		<!-- Text -->
		<param name="text"/>
		<!-- Substring to search -->
		<param name="needle"/>
		
		<variable name="needleLength" select="string-length($needle)"/>
		<variable name="textLength" select="string-length($text)"/>
		<variable name="end" select="substring($text, (($textLength - $needleLength) + 1))"/>
		
		<value-of select="($end = $needle)" />	
	</template>
	
	<!-- Number of occurrence of a given string at the end of another string -->
	<template name="str.endsWithCount">
		<!-- Text -->
		<param name="text"/>
		<!-- Substring to search -->
		<param name="needle"/>
		<!-- Internal use -->
		<param name="offset" select="0"/>
		<!-- Internal use -->
		<param name="count" select="0"/>
		<variable name="needleLength" select="string-length($needle)"/>
		<variable name="subtext" select="substring($text, 1, string-length($text) - $offset)"/>
		<variable name="subtextLength" select="string-length($subtext)"/>
		<variable name="toTest" select="substring($subtext, (($subtextLength - $needleLength) + 1))"/>
		<choose>
			<when test="($needleLength = 0) or ($subtextLength &lt; $needleLength)">
				<value-of select="$count"/>
			</when>
			<when test="$toTest = $needle">
				<call-template name="str.endsWithCount">
					<with-param name="text" select="$text"/>
					<with-param name="needle" select="$needle"/>
					<with-param name="offset" select="$offset + $needleLength"/>
					<with-param name="count" select="$count + 1"/>
				</call-template>
			</when>
			<otherwise>
				<value-of select="$count"/>
			</otherwise>
		</choose>
	</template>

	<!-- Replace a string by another -->
	<template name="str.replaceAll">
		<!-- Text to process -->
		<param name="text"/>
		<!-- Text to replace -->
		<param name="replace"/>
		<!-- Replacement string -->
		<param name="by"/>
		<choose>
			<when test="contains($text, $replace)">
				<value-of select="substring-before($text,$replace)"/>
				<value-of select="$by"/>
				<call-template name="str.replaceAll">
					<with-param name="text" select="substring-after($text,$replace)"/>
					<with-param name="replace" select="$replace"/>
					<with-param name="by" select="$by"/>
				</call-template>
			</when>
			<otherwise>
				<value-of select="$text"/>
			</otherwise>
		</choose>
	</template>

	<!-- Count occurences of a string in another -->
	<template name="str.count">
		<!-- Text to process -->
		<param name="text"/>
		<!-- Substring to count -->
		<param name="substring"/>
		<!-- Reserved -->
		<param name="_count" select="0"/>
		<choose>
			<when test="contains($text, $substring)">
				<call-template name="str.count">
					<with-param name="text" select="substring-after($text, $substring)"/>
					<with-param name="substring" select="$substring"/>
					<with-param name="_count" select="$_count + 1"/>
				</call-template>
			</when>
			<otherwise>
				<value-of select="$_count"/>
			</otherwise>
		</choose>
	</template>

	<!-- Repeat a string -->
	<template name="str.repeat">
		<!-- Text to repeat -->
		<param name="text" select="' '"/>
		<!-- Repetitions -->
		<param name="iterations" select="1"/>
		<if test="$iterations &gt; 0">
			<value-of select="$text"/>
			<call-template name="str.repeat">
				<with-param name="iterations" select="$iterations - 1"/>
				<with-param name="text" select="$text"/>
			</call-template>
		</if>
	</template>

	<template name="str.elementLocalPart">
		<param name="node" select="."/>
		<value-of select="substring-after(name($node), ':' )"/>
	</template>

	<!-- Find the last breakable character index -->
	<template name="str.lastBreakableCharacterPosition">
		<!-- Text to process -->
		<param name="text" select="."/>
		<!-- Internal use -->
		<param name="_position" select="1"/>
		<!-- Internal use -->
		<param name="_bestValue" select="-1"/>
		<!-- the first 2 characters are always breakable,
		the others requires a space after -->
		<variable name="breakables" select="' &#9;,;:?.!'"/>
		<variable name="c">
			<value-of select="substring($breakables, $_position, 1)"/>
			<if test="$_position &gt; 2">
				<value-of select="' '" />
			</if>
		</variable>
		<choose>
			<when test="(string-length($text) &gt; 0) and (string-length($c) = 1)">
				<choose>
					<when test="contains($text, $c)">
						<variable name="sub">
							<call-template name="str.substringBeforeLast">
								<with-param name="text" select="$text"/>
								<with-param name="delimiter" select="$c"/>
							</call-template>
						</variable>
						<variable name="subIndex" select="string-length($sub)"/>
						<variable name="newBest">
							<choose>
								<when test="$subIndex &gt; $_bestValue">
									<value-of select="$subIndex"/>
								</when>
								<otherwise>
									<value-of select="$_bestValue"/>
								</otherwise>
							</choose>
						</variable>
						<call-template name="str.lastBreakableCharacterPosition">
							<with-param name="text" select="$text"/>
							<with-param name="_position" select="$_position + 1"/>
							<with-param name="_bestValue" select="$newBest"/>
						</call-template>
					</when>
					<otherwise>
						<call-template name="str.lastBreakableCharacterPosition">
							<with-param name="text" select="$text"/>
							<with-param name="_position" select="$_position + 1"/>
							<with-param name="_bestValue" select="$_bestValue"/>
						</call-template>
					</otherwise>
				</choose>
			</when>
			<otherwise>
				<choose>
					<when test="$_bestValue &gt;= 0">
						<value-of select="$_bestValue + 1"/>
					</when>
					<otherwise>
						<value-of select="string-length($text) + 1"/>
					</otherwise>
				</choose>
			</otherwise>
		</choose>
	</template>

	<!-- Wrap text -->
	<template name="str.wrap">
		<!-- Text to wrap -->
		<param name="text" select="."/>
		<!-- Maximum number of character per line -->
		<param name="lineMaxLength" select="80"/>
		<!-- End-of-line string -->
		<param name="endlChar" select="$str.endl"/>
		
		<variable name="hasEndl" select="contains($text, $endlChar)"/>
		
		<!-- Get a line -->
		<variable name="item">
			<choose>
				<when test="$hasEndl">
					<value-of select="substring-before($text, $endlChar)"/>
				</when>
				<otherwise>
					<value-of select="$text"/>
				</otherwise>
			</choose>
		</variable>
		
		<!-- Get left blanks -->
		<variable name="leftTrimmedItem">
			<call-template name="str.trimLeft">
				<with-param name="text" select="$item" />
			</call-template>
		</variable>
		<variable name="leftBlankCount" select="(string-length($item) - string-length($leftTrimmedItem))" />
		<variable name="remainingPartPadding" select="substring($item, 1, $leftBlankCount)" />
		
		<if test="string-length($item) &gt; 0">
			<!-- <text>(process: </text><value-of select="$item" /><text> of </text><value-of select="$text" /><text>)</text> -->
			<choose>
				<when test="string-length($item) &gt; $lineMaxLength">
					<!-- Text chunk before line length limit -->
					<variable name="splititem" select="substring($item, 1, $lineMaxLength)"/>
					<!-- Position of the last breakable char in text chunk -->
					<variable name="breakPosition">
						<call-template name="str.lastBreakableCharacterPosition">
							<with-param name="text" select="$splititem"/>
						</call-template>
					</variable>
					<variable name="b" select="substring($splititem, $breakPosition, 1)"/>
					<variable name="isBlank">
						<choose>
							<when test="string-length($b) &gt; 0">
								<call-template name="str.isBlankChar">
									<with-param name="char" select="$b"/>
								</call-template>
							</when>
						</choose>
					</variable>
					<variable name="len">
						<choose>
							<when test="$breakPosition &gt; $lineMaxLength">
								<value-of select="$lineMaxLength"/>
							</when>
							<otherwise>
								<value-of select="$breakPosition"/>
							</otherwise>
						</choose>
					</variable>
					<!-- Text chunk before breakable -->
					<variable name="part">
						<choose>
							<when test="($breakPosition = 1) and ($isBlank &gt; 0)">
								<value-of select="substring($item, 2, $len - 1)"/>
							</when>
							<otherwise>
								<value-of select="substring($item, 1, $len)"/>
							</otherwise>
						</choose>
					</variable>
					<if test="string-length($part) &gt; 0">
						<value-of select="$part"/>
						<value-of select="$endlChar"/>
					</if>
					<variable name="remaining" select="concat($remainingPartPadding, substring($item, $len + 1))"/>
					<!-- remaining part -->
					<if test="string-length($remaining) &gt; 0">
						<!-- <text>(remain: </text><value-of select="$remaining" /><text>)</text> -->
						<call-template name="str.wrap">
							<with-param name="text" select="$remaining"/>
							<with-param name="lineMaxLength" select="$lineMaxLength"/>
							<with-param name="endlChar" select="$endlChar"/>
						</call-template>
					</if>
				</when>
				<otherwise>
					<value-of select="$item"/>
				</otherwise>
			</choose>
		</if>
		<!-- other lines -->
		<if test="$hasEndl = true()">
			<value-of select="$endlChar"/>
			<variable name="otherLines" select="substring-after($text, $endlChar)"/>
			<if test="string-length($otherLines) &gt; 0">
				<!-- <text>(continue with: </text><value-of select="$otherLines" /><text>)</text> -->
				<call-template name="str.wrap">
					<with-param name="text" select="$otherLines"/>
					<with-param name="lineMaxLength" select="$lineMaxLength"/>
					<with-param name="endlChar" select="$endlChar"/>
				</call-template>
			</if>
		</if>
	</template>

	<!-- Indent a text block by adding indentaction characters at the beginning of all text lines -->
	<template name="str.prependLine">
		<param name="text"/>
		<param name="level" select="1"/>
		<param name="prependedText">
			<text>	</text>
		</param>
		<param name="endlChar" select="$str.endl"/>
		<param name="wrap" select="false()"/>
		<param name="lineMaxLength" select="80"/>
		<variable name="fullPrependedText">
			<call-template name="str.repeat">
				<with-param name="iterations" select="$level"/>
				<with-param name="text" select="$prependedText"/>
			</call-template>
		</variable>
		<variable name="realLineMaxLength" select="$lineMaxLength - string-length($fullPrependedText)"/>
		<variable name="content">
			<choose>
				<when test="$wrap">
					<call-template name="str.wrap">
						<with-param name="text" select="$text"/>
						<with-param name="endlChar" select="$endlChar"/>
						<with-param name="lineMaxLength" select="$realLineMaxLength"/>
					</call-template>
				</when>
				<otherwise>
					<value-of select="$text"/>
				</otherwise>
			</choose>
		</variable>
		<value-of select="$fullPrependedText"/>
		<call-template name="str.replaceAll">
			<with-param name="text">
				<value-of select="$content"/>
			</with-param>
			<with-param name="replace">
				<value-of select="$endlChar"/>
			</with-param>
			<with-param name="by">
				<value-of select="$endlChar"/>
				<value-of select="$fullPrependedText"/>
			</with-param>
		</call-template>
	</template>

	<!-- Trim text at the beginning and the end -->
	<template name="str.trim">
		<!-- Text to trim -->
		<param name="text" select="."/>
		<variable name="lTrimmed">
			<call-template name="str.trimLeft">
				<with-param name="text" select="$text"/>
			</call-template>
		</variable>
		<call-template name="str.trimRight">
			<with-param name="text" select="$lTrimmed"/>
		</call-template>
	</template>

	<template name="str.trimLeft">
		<param name="text"/>
		<choose>
			<when test="starts-with($text,'&#9;') or starts-with($text,'&#10;') or starts-with($text,'&#13;') or starts-with($text,' ')">
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

	<variable name="str.smallCase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<variable name="str.upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<template name="str.toUpper">
		<param name="text" select="."/>
		<value-of select="translate($text, $str.smallCase, $str.upperCase)"/>
	</template>

	<template name="str.toLower">
		<param name="text" select="."/>
		<value-of select="translate($text, $str.upperCase, $str.smallCase)"/>
	</template>

	<variable name="str.ascii">
		<text> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</text>
	</variable>
	<variable name="str.hex">
		<text>0123456789ABCDEF</text>
	</variable>
	<!-- http://lists.xml.org/archives/xml-dev/200109/msg00248.html -->
	<template name="str.asciiToHex">
		<param name="text"/>
		<param name="prefix"/>
		<param name="suffix"/>
		<if test="$text">
			<variable name="firstChar" select="substring($text, 1, 1)"/>
			<variable name="asciiValue" select="string-length(substring-before($str.ascii, $firstChar)) + 32"/>
			<variable name="hexDigit1" select="substring($str.hex, floor($asciiValue div 16) + 1, 1)"/>
			<variable name="hexDigit2" select="substring($str.hex, $asciiValue mod 16 + 1, 1)"/>
			<if test="$prefix">
				<value-of select="$prefix"/>
			</if>
			<value-of select="concat($hexDigit1, $hexDigit2)"/>
			<if test="$suffix">
				<value-of select="$suffix"/>
			</if>
			<if test="string-length($text) &gt; 1">
				<call-template name="str.asciiToHex">
					<with-param name="text" select="substring($text, 2)"/>
					<with-param name="prefix" select="$prefix"/>
					<with-param name="suffix" select="$suffix"/>
				</call-template>
			</if>
		</if>
	</template>

</stylesheet>
