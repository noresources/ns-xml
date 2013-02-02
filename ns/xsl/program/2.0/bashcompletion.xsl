<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- compgen options -a, -A alias -> alias -->
<!-- -b, -A builtin -> builtin functions -->
<!-- -c, -A command -> commands -->
<!-- -d, -A directory -> directory -->
<!-- -e, -A export -> exported variables -->
<!-- -f, -A file -> file -->
<!-- -g -> groups -->
<!-- -j, -A job -> job names -->
<!-- -k, -A keyword -> language keyword -->
<!-- -u, -A user -> users -->
<!-- -v, -A variable -> variables -->
<!-- -A hostname -> hostnames -->

<!-- Create a bash completion script for the program -->
<stylesheet xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" version="1.0">
	<import href="../../languages/shellscript.xsl" />
	<output method="text" indent="no" encoding="utf-8" />
	<param name="prg.bash.completion.programFileExtension" />
	<variable name="prg.bash.completion.completionFunctionName">
		<text>__</text>
		<call-template name="prg.bash.completion.shellFunctionName">
			<with-param name="name" select="/prg:program/prg:name" />
		</call-template>
		<text>_bashcompletion</text>
	</variable>
	<variable name="prg.bash.completion.getArgOptionFunctionName">
		<text>__</text>
		<call-template name="prg.bash.completion.shellFunctionName">
			<with-param name="name" select="/prg:program/prg:name" />
		</call-template>
		<text>_getoptionname</text>
	</variable>
	<variable name="prg.bash.completion.appendFileSystemItemsFunctionName">
		<text>__</text>
		<call-template name="prg.bash.completion.shellFunctionName">
			<with-param name="name" select="/prg:program/prg:name" />
		</call-template>
		<text>_appendfsitems</text>
	</variable>
	<variable name="programGetFindPermissionOptionsFunctionName">
		<text>__</text>
		<call-template name="prg.bash.completion.shellFunctionName">
			<with-param name="name" select="/prg:program/prg:name" />
		</call-template>
		<text>_getfindpermoptions</text>
	</variable>
	<!-- Chunks -->
	<template name="prg.bash.completion.itemList">
		<param name="path" />
		<param name="prepend" />
		<param name="separator">
			<text> </text>
		</param>
		<param name="quoted" select="false()" />
		<for-each select="$path">
			<value-of select="$prepend" />
			<if test="$quoted">
				<text>"</text>
			</if>
			<value-of select="." />
			<if test="$quoted">
				<text>"</text>
			</if>
			<if test="position() != last()">
				<value-of select="$separator" />
			</if>
		</for-each>
	</template>

	<!-- Add trailing folder / to all folder results -->
	<template name="prg.bash.completion.compreplyAddFoldersSlashes">
		<param name="variableName">
			<text>COMPREPLY</text>
		</param>
		<call-template name="sh.for">
			<with-param name="condition">
				<text>((i=0;${i}&lt;${#</text>
				<value-of select="$variableName" />
				<text>[*]};i++))</text>
			</with-param>
			<with-param name="do">
				<text>[ -d "${</text>
				<value-of select="$variableName" />
				<text>[$i]}" ] &amp;&amp; </text>
				<value-of select="$variableName" />
				<text>[$i]="${</text>
				<value-of select="$variableName" />
				<text>[$i]%/}/"</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.bash.completion.compreplyAddSpaces">
		<text>for ((i=0;$i&lt;${#COMPREPLY[*]};i++)); do COMPREPLY[${i}]="${COMPREPLY[${i}]} ";done</text>
		<value-of select="$str.unix.endl"/>
	</template>

	<template name="prg.bash.completion.shellFunctionName">
		<param name="name" />
		<variable name="tname">
			<call-template name="str.trim">
				<with-param name="text" select="$name" />
			</call-template>
		</variable>
		<value-of select="translate($tname,'- ./', '_')" />
	</template>

	<template name="prg.bash.completion.subCommandCompletionFunctionName">
		<param name="subcommand" select="." />
		<param name="name" />
		<text>__sc_</text>
		<call-template name="prg.bash.completion.shellFunctionName">
			<with-param name="name">
				<choose>
					<when test="$name">
						<value-of select="$name" />
					</when>
					<otherwise>
						<value-of select="normalize-space($subcommand/prg:name)" />
					</otherwise>
				</choose>
			</with-param>
		</call-template>
		<text>_bashcompletion</text>
	</template>

	<template name="prg.bash.completion.appendFileSystemItemFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.bash.completion.appendFileSystemItemsFunctionName" />
			<with-param name="content">
				<!-- Call find command -->
				<text>local current="${1}"</text>
				<value-of select="$str.unix.endl"/>
				<text>shift</text>
				<value-of select="$str.unix.endl"/>
				<text>local currentLength="${#current}"</text>
				<value-of select="$str.unix.endl"/>
				<text>local d</text>
				<value-of select="$str.unix.endl"/>
				<text>local b</text>
				<value-of select="$str.unix.endl"/>
				<text>local isHomeShortcut=false</text>
				<value-of select="$str.unix.endl"/>
				<text>[ "${current:0:1}" == "~" ] &amp;&amp; current="${HOME}${current:1}" &amp;&amp; isHomeShortcut=true</text>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ "${current:$(expr ${currentLength} - 1)}" == "/" ]</text>
					</with-param>
					<with-param name="then">
						<text>d="${current%/}"</text>
						<value-of select="$str.unix.endl"/>
						<text>b=""</text>
					</with-param>
					<with-param name="else">
						<text>d="$(dirname "${current}")"</text>
						<value-of select="$str.unix.endl"/>
						<text>b="$(basename "${current}")"</text>
					</with-param>
				</call-template>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ -d "${d}" ]</text>
					</with-param>
					<with-param name="then">
						<text>local findCommand="find \"${d}\" -mindepth 1 -maxdepth 1 -name \"${b}*\" -a \\( ${@} \\)"</text>
						<value-of select="$str.unix.endl"/>
						<text>local files="$(eval ${findCommand} | while read file; do printf "%q\n" "${file#./}"; done)"</text>
						<value-of select="$str.unix.endl"/>
						<!-- Transform to array -->
						<text>local IFS=$'\n'</text>
						<value-of select="$str.unix.endl"/>
						<text>local temporaryRepliesArray=(${files})</text>
						<value-of select="$str.unix.endl"/>
						<call-template name="sh.arrayForEach">
							<with-param name="name">
								<text>temporaryRepliesArray</text>
							</with-param>
							<with-param name="do">
								<text>local p="${temporaryRepliesArray[$i]}"</text>
								<value-of select="$str.unix.endl"/>
								<text>[ "${d}" != "." ] &amp;&amp; p="${d}/$(basename "${p}")"</text>
								<value-of select="$str.unix.endl"/>
								<text>[ -d "${p}" ] &amp;&amp; p="${p%/}/"</text>
								<value-of select="$str.unix.endl"/>
								<text>temporaryRepliesArray[$i]="${p}"</text>
								<value-of select="$str.unix.endl"/>
							</with-param>
						</call-template>
						<value-of select="$str.unix.endl"/>
						<!-- Copy results to COMPREPLY -->
						<call-template name="sh.arrayCopy">
							<with-param name="from">
								<text>temporaryRepliesArray</text>
							</with-param>
							<with-param name="to">
								<text>COMPREPLY</text>
							</with-param>
							<with-param name="append" select="true()" />
						</call-template>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<!-- "" <=> not an argument -->
	<template name="prg.bash.completion.getArgOptionNameFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$prg.bash.completion.getArgOptionFunctionName" />
			<with-param name="content">
				<text>local arg="${1}"</text>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ "${arg}"  = "--" ]</text>
					</with-param>
					<with-param name="then">
						<text># End of options marker</text>
						<value-of select="$str.unix.endl"/>
						<text>return 0</text>
					</with-param>
				</call-template>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ "${arg:0:2}"  = "--" ]</text>
					</with-param>
					<with-param name="then">
						<text># It's a long option</text>
						<value-of select="$str.unix.endl"/>
						<text>echo "${arg:2}"</text>
						<value-of select="$str.unix.endl"/>
						<text>return 0</text>
					</with-param>
				</call-template>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ "${arg:0:1}"  = "-" ] &amp;&amp; [ ${#arg} -gt 1 ]</text>
					</with-param>
					<with-param name="then">
						<text># It's a short option (or a combination of)</text>
						<value-of select="$str.unix.endl"/>
						<text>local index="$(expr ${#arg} - 1)"</text>
						<value-of select="$str.unix.endl"/>
						<text>echo "${arg:${index}}"</text>
						<value-of select="$str.unix.endl"/>
						<text>return 0</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.bash.completion.getFindPermissionsOptionsFunction">
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$programGetFindPermissionOptionsFunctionName" />
			<with-param name="content">
				<text>local access="${1}"</text>
				<value-of select="$str.unix.endl"/>
				<text>local res=""</text>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.while">
					<with-param name="condition">
						<text>[ ! -z "${access}" ]</text>
					</with-param>
					<with-param name="do">
						<text>res="${res} -perm /u=${access:0:1},g=${access:0:1},o=${access:0:1}"</text>
						<value-of select="$str.unix.endl"/>
						<text>access="${access:1}"</text>
					</with-param>
				</call-template>
				<value-of select="$str.unix.endl"/>
				<text>echo "${res}"</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.bash.completion.argumentCompletion">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="path" />
		<param name="todo" />
		<if test="$path">
			<call-template name="sh.case">
				<with-param name="case">
					<call-template name="sh.var">
						<with-param name="name">
							<value-of select="$optionName" />
						</with-param>
					</call-template>
				</with-param>
				<with-param name="in">
					<call-template name="sh.caseblock">
						<with-param name="case">
							<call-template name="prg.bash.completion.itemList">
								<with-param name="path" select="$path/prg:names/prg:long" />
								<with-param name="quoted" select="true()" />
								<with-param name="separator">
									<text> | </text>
								</with-param>
							</call-template>
							<call-template name="prg.bash.completion.itemList">
								<with-param name="path" select="$path/prg:names/prg:short" />
								<with-param name="quoted" select="true()" />
								<with-param name="prepend">
									<text> | </text>
								</with-param>
								<with-param name="separator" />
							</call-template>
						</with-param>
						<with-param name="content">
							<value-of select="$todo" />
						</with-param>
					</call-template>
				</with-param>
			</call-template>
			<value-of select="$str.unix.endl"/>
		</if>
	</template>

	<template name="prg.bash.completion.argumentCompletionByTypeBlock">
		<param name="path" />
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<call-template name="sh.case">
			<with-param name="case">
				<call-template name="sh.var">
					<with-param name="name">
						<value-of select="$optionName" />
					</with-param>
				</call-template>
			</with-param>
			<with-param name="in">
				<for-each select="$path">
					<call-template name="sh.caseblock">
						<with-param name="case">
							<call-template name="prg.bash.completion.itemList">
								<with-param name="path" select="./prg:names/prg:long" />
								<with-param name="quoted" select="true()" />
								<with-param name="separator">
									<text> | </text>
								</with-param>
							</call-template>
							<call-template name="prg.bash.completion.itemList">
								<with-param name="path" select="./prg:names/prg:short" />
								<with-param name="quoted" select="true()" />
								<with-param name="prepend">
									<text> | </text>
								</with-param>
								<with-param name="separator" />
							</call-template>
						</with-param>
						<with-param name="content">
							<choose>
								<!-- Display only enum values -->
								<when test="./prg:select[@restrict]">
									<call-template name="prg.bash.completion.argumentCompletionEnum">
										<with-param name="optionName" select="$optionName" />
										<with-param name="currentVarName" select="$currentVarName" />
										<with-param name="root" select="." />
									</call-template>
								</when>
								<otherwise>
									<!-- Display enum values (if any) and other depending on type -->
									<if test="./prg:select">
										<call-template name="prg.bash.completion.argumentCompletionEnum">
											<with-param name="optionName" select="$optionName" />
											<with-param name="currentVarName" select="$currentVarName" />
											<with-param name="root" select="." />
										</call-template>
									</if>
									<value-of select="$str.unix.endl"/>
									<choose>
										<when test="./prg:type/prg:string">
											<call-template name="prg.bash.completion.argumentCompletionString">
												<with-param name="optionName" select="$optionName" />
												<with-param name="currentVarName" select="$currentVarName" />
												<with-param name="root" select="." />
											</call-template>
										</when>
										<!-- <when test="./prg:type/prg:number"> </when> <when test="./prg:type/prg:integer"> </when> <when test="./prg:type/prg:existingcommand"> </when> -->
										<when test="./prg:type/prg:existingcommand">
											<call-template name="prg.bash.completion.argumentCompletionCommand">
												<with-param name="optionName" select="$optionName" />
												<with-param name="currentVarName" select="$currentVarName" />
												<with-param name="root" select="." />
											</call-template>
										</when>
										<when test="./prg:type/prg:path">
											<call-template name="prg.bash.completion.argumentCompletionPath">
												<with-param name="optionName" select="$optionName" />
												<with-param name="currentVarName" select="$currentVarName" />
												<with-param name="root" select="." />
											</call-template>
										</when>
										<when test="./prg:type/prg:hostname">
											<call-template name="prg.bash.completion.argumentCompletionHostname">
												<with-param name="optionName" select="$optionName" />
												<with-param name="currentVarName" select="$currentVarName" />
												<with-param name="root" select="." />
											</call-template>
										</when>
										<otherwise>
											<call-template name="prg.bash.completion.argumentCompletionOther">
												<with-param name="optionName" select="$optionName" />
												<with-param name="currentVarName" select="$currentVarName" />
												<with-param name="root" select="." />
											</call-template>
										</otherwise>
									</choose>
								</otherwise>
							</choose>
							<value-of select="$str.unix.endl"/>
							<call-template name="sh.if">
								<with-param name="condition">
									<text>[ ${#COMPREPLY[*]} -gt 0 ]</text>
								</with-param>
								<with-param name="then">
									<text>return 0</text>
								</with-param>
							</call-template>
						</with-param>
					</call-template>
				</for-each>
			</with-param>
		</call-template>
		<value-of select="$str.unix.endl"/>
	</template>

	<template name="prg.bash.completion.argumentCompletionString">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<text>[ ${#COMPREPLY[*]} -eq 0 ] &amp;&amp; COMPREPLY[0]="\"${</text>
		<value-of select="$currentVarName" />
		<text>#\"}"</text>
		<value-of select="$str.unix.endl"/>
		<text>return 0</text>
	</template>

	<template name="prg.bash.completion.argumentCompletionEnum">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<param name="root" select="." />
		<text>COMPREPLY=()</text>
		<value-of select="$str.unix.endl"/>
		<call-template name="sh.for">
			<with-param name="condition">
				<text>e in </text>
				<call-template name="prg.bash.completion.itemList">
					<with-param name="path" select="$root/prg:select/prg:option" />
					<with-param name="quoted" select="true()" />
				</call-template>
			</with-param>
			<with-param name="do">
				<text>local res="$(compgen -W "${e}" -- </text>
				<call-template name="sh.var">
					<with-param name="name" select="$currentVarName" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text>)"</text>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ ! -z "${res}" ]</text>
					</with-param>
					<with-param name="then">
						<text>COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<template name="prg.bash.completion.argumentCompletionCompgenBased">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<param name="compgenOptions" />
		<param name="postProcess" />
		<!-- compgen -->
		<text>local temporaryRepliesArray=( $(compgen </text>
		<value-of select="$compgenOptions" />
		<text> -- </text>
		<call-template name="sh.var">
			<with-param name="name" select="$currentVarName" />
			<with-param name="quoted" select="true()" />
		</call-template>
		<text>) )</text>
		<value-of select="$str.unix.endl"/>
		<!-- post processing compgen results -->
		<if test="$postProcess">
			<value-of select="$postProcess" />
			<value-of select="$str.unix.endl"/>
		</if>
		<!-- Copy compgen result to COMPREPLY -->
		<call-template name="sh.arrayCopy">
			<with-param name="from">
				<text>temporaryRepliesArray</text>
			</with-param>
			<with-param name="to">
				<text>COMPREPLY</text>
			</with-param>
			<with-param name="append" select="true()" />
		</call-template>
	</template>

	<template name="prg.bash.completion.argumentCompletionCommand">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<param name="root" />
		<call-template name="prg.bash.completion.argumentCompletionCompgenBased">
			<with-param name="optionName" select="$optionName" />
			<with-param name="currentVarName" select="$currentVarName" />
			<with-param name="compgenOptions">
				<text>-A command</text>
			</with-param>
		</call-template>
	</template>

	<template name="prg.bash.completion.argumentCompletionHostname">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<param name="root" />
		<call-template name="prg.bash.completion.argumentCompletionCompgenBased">
			<with-param name="optionName" select="$optionName" />
			<with-param name="currentVarName" select="$currentVarName" />
			<with-param name="compgenOptions">
				<text>-A hostname</text>
			</with-param>
		</call-template>
	</template>

	<!-- Add path type related restrictions -->
	<template name="prg.bash.completion.argumentCompletionPath">
		<param name="optionName" select="'option'" />
		<param name="currentVarName" select="'current'" />
		<param name="root" />
		<variable name="pathNode" select="$root/prg:type/prg:path" />
		<variable name="kinds" select="$pathNode/prg:kinds" />
		<variable name="patterns" select="$pathNode/prg:patterns" />
		<variable name="findOptions">
			<if test="$pathNode/@access">
				<text>$(</text>
				<value-of select="$programGetFindPermissionOptionsFunctionName" />
				<text> </text>
				<value-of select="$pathNode/@access" />
				<text>) </text>
			</if>
			<if test="$patterns and $patterns[@restrict = 'true']">
				<for-each select="$patterns/prg:pattern">
					<variable name="p" select="position()" />
					<for-each select="./prg:rules/prg:rule">
						<if test="($p != 1) or (position() != 1)">
							<text> -o</text>
						</if>
						<text> -name </text>
						<choose>
							<when test="./prg:endWith">
								<text>\"*</text>
								<value-of select="./prg:endWith" />
								<text>\"</text>
							</when>
							<when test="./prg:startWith">
								<text>\"</text>
								<value-of select="./prg:endWith" />
								<text>*\"</text>
							</when>
							<when test="./prg:contains">
								<text>\"*</text>
								<value-of select="./prg:endWith" />
								<text>*\"</text>
							</when>
						</choose>
					</for-each>
				</for-each>
			</if>
			<!-- stricly search for supported kinks -->
			<for-each select="$kinds/* [self::prg:file or self::prg:folder or self::prg:symlink]">
				<choose>
					<when test="./self::prg:file">
						<text> -type f</text>
					</when>
					<when test="./self::prg:folder">
						<text> -type d</text>
					</when>
					<when test="./self::prg:symlink">
						<text> -type l</text>
					</when>
				</choose>
				<if test="position() != last()">
					<text> -o </text>
				</if>
			</for-each>
		</variable>
		<choose>
			<when test="true()">
				<!-- Using find command -->
				<value-of select="$prg.bash.completion.appendFileSystemItemsFunctionName" />
				<text> </text>
				<call-template name="sh.var">
					<with-param name="name" select="$currentVarName" />
					<with-param name="quoted" select="true()" />
				</call-template>
				<text> </text>
				<value-of select="$findOptions" />
				<text> </text>
			</when>
			<otherwise>
				<!-- Using compgen command -->
				<call-template name="prg.bash.completion.argumentCompletionCompgenBased">
					<with-param name="optionName" select="$optionName" />
					<with-param name="currentVarName" select="$currentVarName" />
					<with-param name="compgenOptions">
						<choose>
							<when test="$kinds/prg:folder and $kinds/prg:file">
								<text>-fd</text>
							</when>
							<when test="$kinds/prg:file">
								<text>-f</text>
							</when>
							<when test="$kinds/prg:folder">
								<text>-d</text>
							</when>
							<otherwise>
								<text>-fd</text>
							</otherwise>
						</choose>
					</with-param>
					<with-param name="postProcess">
						<!-- TODO access checks -->
						<call-template name="prg.bash.completion.compreplyAddFoldersSlashes">
							<with-param name="variableName">
								<text>temporaryRepliesArray</text>
							</with-param>
						</call-template>
					</with-param>
				</call-template>
			</otherwise>
		</choose>
	</template>

	<template name="prg.bash.completion.argumentCompletionOther">
		<param name="optionName">
			<text>option</text>
		</param>
		<param name="currentVarName">
			<text>current</text>
		</param>
		<param name="root" />
		<call-template name="prg.bash.completion.argumentCompletionCompgenBased">
			<with-param name="optionName" select="$optionName" />
			<with-param name="currentVarName" select="$currentVarName" />
			<with-param name="compgenOptions">
				<text>-fd</text>
			</with-param>
			<with-param name="postProcess">
				<call-template name="prg.bash.completion.compreplyAddFoldersSlashes">
					<with-param name="variableName">
						<text>temporaryRepliesArray</text>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>

	<!-- declare a subcommand option completion function -->
	<template name="prg.bash.completion.subcommandCompletionFunction">
		<param name="subcommand" select="." />
		<variable name="functionName">
			<call-template name="prg.bash.completion.subCommandCompletionFunctionName" />
		</variable>
		<call-template name="sh.functionDefinition">
			<with-param name="name" select="$functionName" />
			<with-param name="content">
				<text># Context</text>
				<value-of select="$str.unix.endl"/>
				<text>local current="${COMP_WORDS[COMP_CWORD]}"</text>
				<value-of select="$str.unix.endl"/>
				<text>local previous="${COMP_WORDS[COMP_CWORD-1]}"</text>
				<value-of select="$str.unix.endl"/>
				<text># argument option</text>
				<value-of select="$str.unix.endl"/>
				<text>local option="$(</text>
				<value-of select="$prg.bash.completion.getArgOptionFunctionName" />
				<text> ${previous})"</text>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[ -z "${option}" ]</text>
					</with-param>
					<with-param name="then">
						<text>return 1</text>
					</with-param>
				</call-template>
				<value-of select="$str.unix.endl"/>
				<value-of select="$str.unix.endl"/>
				<call-template name="prg.bash.completion.argumentCompletionByTypeBlock">
					<with-param name="path" select="$subcommand/prg:options//prg:argument" />
				</call-template>
				<text>return 1</text>
			</with-param>
		</call-template>
	</template>

	<!-- The main template Called only if prg:program/prg:name exists -->
	<template name="prg.bash.completion.main">
		<param name="program" select=".." />
		<call-template name="prg.bash.completion.getArgOptionNameFunction" />
		<value-of select="$str.unix.endl"/>
		<call-template name="prg.bash.completion.getFindPermissionsOptionsFunction" />
		<value-of select="$str.unix.endl"/>
		<call-template name="prg.bash.completion.appendFileSystemItemFunction" />
		<value-of select="$str.unix.endl"/>
		<if test="../prg:subcommands">
			<for-each select="../prg:subcommands/prg:subcommand">
				<call-template name="prg.bash.completion.subcommandCompletionFunction" />
			</for-each>
			<for-each select="../prg:subcommands/prg:subcommand/prg:aliases/prg:alias">
				<call-template name="sh.functionDefinition">
					<with-param name="name">
						<call-template name="prg.bash.completion.subCommandCompletionFunctionName">
							<with-param name="name" select="." />
						</call-template>
					</with-param>
					<with-param name="content">
						<call-template name="prg.bash.completion.subCommandCompletionFunctionName">
							<with-param name="name" select="normalize-space(../../prg:name)" />
						</call-template>
					</with-param>
				</call-template>
			</for-each>
		</if>
		<value-of select="$str.unix.endl"/>
		<call-template name="sh.functionDefinition">
			<with-param name="name">
				<value-of select="$prg.bash.completion.completionFunctionName" />
			</with-param>
			<with-param name="content">
				<text>#Context</text>
				<value-of select="$str.unix.endl"/>
				<text>COMPREPLY=()</text>
				<value-of select="$str.unix.endl"/>
				<text>local current="${COMP_WORDS[COMP_CWORD]}"</text>
				<value-of select="$str.unix.endl"/>
				<text>local previous="${COMP_WORDS[COMP_CWORD-1]}"</text>
				<value-of select="$str.unix.endl"/>
				<text>local first="${COMP_WORDS[1]}"</text>
				<value-of select="$str.unix.endl"/>
				<text>local globalargs="</text>
				<call-template name="prg.bash.completion.itemList">
					<with-param name="path" select="$program/prg:options//prg:names/prg:long" />
					<with-param name="prepend">
						<text>--</text>
					</with-param>
				</call-template>
				<call-template name="prg.bash.completion.itemList">
					<with-param name="path" select="$program/prg:options/*/prg:names/prg:short" />
					<with-param name="prepend">
						<text> -</text>
					</with-param>
					<with-param name="separator" />
				</call-template>
				<text>"</text>
				<value-of select="$str.unix.endl"/>
				<text>local args="${globalargs}"</text>
				<value-of select="$str.unix.endl"/>
				<value-of select="$str.unix.endl"/>
				<!-- Subcommand completion -->
				<if test="$program/prg:subcommands">
					<text># Subcommand proposal</text>
					<value-of select="$str.unix.endl"/>
					<call-template name="sh.if">
						<with-param name="condition">
							<text>[ ${COMP_CWORD} -eq 1 ]</text>
						</with-param>
						<with-param name="then">
							<!-- Subcoomands -->
							<text>local subcommands="</text>
							<call-template name="prg.bash.completion.itemList">
								<with-param name="path" select="$program/prg:subcommands/prg:subcommand/prg:name" />
							</call-template>
							<call-template name="prg.bash.completion.itemList">
								<with-param name="path" select="$program/prg:subcommands/prg:subcommand/prg:aliases/prg:alias" />
								<with-param name="prepend">
									<text> </text>
								</with-param>
								<with-param name="separator" />
							</call-template>
							<text>"</text>
							<value-of select="$str.unix.endl"/>
							<!-- global options and subcommands -->
							<text>COMPREPLY=( $(compgen -W "${globalargs} ${subcommands}" -- ${current}) )</text>
							<value-of select="$str.unix.endl"/>
							<!--@todo complete only if <prg:values> and according to first prg:value Files and folders -->
							<text>local temporaryRepliesArray=( $(compgen -fd -- </text>
							<call-template name="sh.var">
								<with-param name="name">
									<text>current</text>
								</with-param>
								<with-param name="quoted" select="true()" />
							</call-template>
							<text>) )</text>
							<value-of select="$str.unix.endl"/>
							<call-template name="prg.bash.completion.compreplyAddFoldersSlashes">
								<with-param name="variableName">
									<text>temporaryRepliesArray</text>
								</with-param>
							</call-template>
							<value-of select="$str.unix.endl"/>
							<call-template name="sh.arrayCopy">
								<with-param name="from">
									<text>temporaryRepliesArray</text>
								</with-param>
								<with-param name="to">
									<text>COMPREPLY</text>
								</with-param>
								<with-param name="append" select="true()" />
							</call-template>
							<value-of select="$str.unix.endl"/>
							<call-template name="prg.bash.completion.compreplyAddSpaces" />
							<value-of select="$str.unix.endl"/>
							<text>return 0</text>
						</with-param>
					</call-template>
					<value-of select="$str.unix.endl"/>
					<text># Subcommand option argument proposal</text>
					<value-of select="$str.unix.endl"/>
					<text>local sc_function_name="</text>
					<call-template name="prg.bash.completion.subCommandCompletionFunctionName">
						<with-param name="name">
							<text>${first}</text>
						</with-param>
					</call-template>
					<text>"</text>
					<value-of select="$str.unix.endl"/>
					<call-template name="sh.if">
						<with-param name="condition">
							<text>[ "$(type -t ${sc_function_name})" = "function" ] &amp;&amp; ${sc_function_name}</text>
						</with-param>
						<with-param name="then">
							<text>return 0</text>
						</with-param>
					</call-template>
					<value-of select="$str.unix.endl"/>
					<!-- Add Subcommand option to the list of global args -->
					<text># Subcommand option completion</text>
					<value-of select="$str.unix.endl"/>
					<call-template name="sh.case">
						<with-param name="case">
							<text>${first}</text>
						</with-param>
						<with-param name="in">
							<for-each select="$program/prg:subcommands/prg:subcommand">
								<call-template name="sh.caseblock">
									<with-param name="case">
										<call-template name="prg.bash.completion.itemList">
											<with-param name="path" select="./prg:name" />
											<with-param name="quoted" select="true()" />
										</call-template>
										<call-template name="prg.bash.completion.itemList">
											<with-param name="path" select="./prg:aliases/prg:alias" />
											<with-param name="quoted" select="true()" />
											<with-param name="prepend">
												<text> | </text>
											</with-param>
											<with-param name="separator" />
										</call-template>
									</with-param>
									<with-param name="content">
										<text>args="</text>
										<call-template name="prg.bash.completion.itemList">
											<with-param name="path" select="./prg:options/*/prg:names/prg:long" />
											<with-param name="prepend">
												<text>--</text>
											</with-param>
										</call-template>
										<call-template name="prg.bash.completion.itemList">
											<with-param name="path" select="./prg:options/*/prg:names/prg:short" />
											<with-param name="prepend">
												<text> -</text>
											</with-param>
											<with-param name="separator" />
										</call-template>
										<text> ${globalargs}"</text>
									</with-param>
								</call-template>
							</for-each>
						</with-param>
					</call-template>
					<value-of select="$str.unix.endl"/>
				</if>
				<!-- subcommands exists -->
				<value-of select="$str.unix.endl"/>
				<text># Option proposal</text>
				<value-of select="$str.unix.endl"/>
				<call-template name="sh.if">
					<with-param name="condition">
						<text>[[ ${current} == -* ]]</text>
					</with-param>
					<with-param name="then">
						<text>COMPREPLY=( $(compgen -W "${args}" -- ${current}) )</text>
						<value-of select="$str.unix.endl"/>
						<call-template name="prg.bash.completion.compreplyAddSpaces" />
						<text>return 0</text>
					</with-param>
				</call-template>
				<if test="$program/prg:options//prg:argument">
					<value-of select="$str.unix.endl"/>
					<text># Option argument proposal</text>
					<value-of select="$str.unix.endl"/>
					<text>local option="$(</text>
					<value-of select="$prg.bash.completion.getArgOptionFunctionName" />
					<text> ${previous})"</text>
					<value-of select="$str.unix.endl"/>
					<call-template name="sh.if">
						<with-param name="condition">
							<text>[ ! -z "${option}" ]</text>
						</with-param>
						<with-param name="then">
							<call-template name="prg.bash.completion.argumentCompletionByTypeBlock">
								<with-param name="path" select="$program/prg:options//prg:argument" />
							</call-template>
						</with-param>
					</call-template>
				</if>
				<!-- well, completing files and folders... -->
				<value-of select="$str.unix.endl"/>
				<text># Last hope: files and folders</text>
				<value-of select="$str.unix.endl"/>
				<text>COMPREPLY=( $(compgen -fd -- </text>
				<call-template name="sh.var">
					<with-param name="name">
						<text>current</text>
					</with-param>
					<with-param name="quoted" select="true()" />
				</call-template>
				<text>) )</text>
				<value-of select="$str.unix.endl"/>
				<!-- Auto add '/' at end of folders -->
				<call-template name="prg.bash.completion.compreplyAddFoldersSlashes" />
				<value-of select="$str.unix.endl"/>
				<text>return 0</text>
			</with-param>
		</call-template>
		<!-- end of main function -->
		<text>complete -o nospace -F </text>
		<value-of select="$prg.bash.completion.completionFunctionName" />
		<text> </text>
		<value-of select="normalize-space($program/prg:name)" />
		<value-of select="$prg.bash.completion.programFileExtension" />
		<value-of select="$str.unix.endl"/>
	</template>

	<template match="/prg:program/prg:name">
		<call-template name="prg.bash.completion.main" />
	</template>

	<template match="/">
		<apply-templates select="/prg:program/prg:name" />
	</template>

</stylesheet>
