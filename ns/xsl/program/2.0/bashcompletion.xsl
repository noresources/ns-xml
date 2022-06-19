<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">
	<xsl:import href="../../languages/shellscript.xsl" />
	<xsl:output method="text" indent="no" encoding="utf-8" />
	<xsl:param name="prg.bash.completion.programFileExtension" />
	<xsl:variable name="prg.bash.completion.completionFunctionName">
		<xsl:text>__</xsl:text>
		<xsl:call-template name="prg.bash.completion.shellFunctionName">
			<xsl:with-param name="name" select="/prg:program/prg:name" />
		</xsl:call-template>
		<xsl:text>_bashcompletion</xsl:text>
	</xsl:variable>
	<xsl:variable name="prg.bash.completion.getArgOptionFunctionName">
		<xsl:text>__</xsl:text>
		<xsl:call-template name="prg.bash.completion.shellFunctionName">
			<xsl:with-param name="name" select="/prg:program/prg:name" />
		</xsl:call-template>
		<xsl:text>_getoptionname</xsl:text>
	</xsl:variable>
	<xsl:variable name="prg.bash.completion.appendFileSystemItemsFunctionName">
		<xsl:text>__</xsl:text>
		<xsl:call-template name="prg.bash.completion.shellFunctionName">
			<xsl:with-param name="name" select="/prg:program/prg:name" />
		</xsl:call-template>
		<xsl:text>_appendfsitems</xsl:text>
	</xsl:variable>
	<xsl:variable name="programGetFindPermissionOptionsFunctionName">
		<xsl:text>__</xsl:text>
		<xsl:call-template name="prg.bash.completion.shellFunctionName">
			<xsl:with-param name="name" select="/prg:program/prg:name" />
		</xsl:call-template>
		<xsl:text>_getfindpermoptions</xsl:text>
	</xsl:variable>
	<!-- Chunks -->
	<xsl:template name="prg.bash.completion.itemList">
		<xsl:param name="path" />
		<xsl:param name="prepend" />
		<xsl:param name="separator">
			<xsl:text> </xsl:text>
		</xsl:param>
		<xsl:param name="quoted" select="false()" />
		<xsl:for-each select="$path">
			<xsl:value-of select="$prepend" />
			<xsl:if test="$quoted">
				<xsl:text>"</xsl:text>
			</xsl:if>
			<xsl:value-of select="." />
			<xsl:if test="$quoted">
				<xsl:text>"</xsl:text>
			</xsl:if>
			<xsl:if test="position() != last()">
				<xsl:value-of select="$separator" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Add trailing folder / to all folder results -->
	<xsl:template name="prg.bash.completion.compreplyAddFoldersSlashes">
		<xsl:param name="variableName">
			<xsl:text>COMPREPLY</xsl:text>
		</xsl:param>
		<xsl:call-template name="sh.for">
			<xsl:with-param name="condition">
				<xsl:text>((i=0;${i}&lt;${#</xsl:text>
				<xsl:value-of select="$variableName" />
				<xsl:text>[*]};i++))</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="do">
				<xsl:text>[ -d "${</xsl:text>
				<xsl:value-of select="$variableName" />
				<xsl:text>[$i]}" ] &amp;&amp; </xsl:text>
				<xsl:value-of select="$variableName" />
				<xsl:text>[$i]="${</xsl:text>
				<xsl:value-of select="$variableName" />
				<xsl:text>[$i]%/}/"</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.bash.completion.compreplyAddSpaces">
		<xsl:text>for ((i=0;$i&lt;${#COMPREPLY[*]};i++)); do COMPREPLY[${i}]="${COMPREPLY[${i}]} ";done</xsl:text>
		<xsl:value-of select="$str.unix.endl" />
	</xsl:template>

	<xsl:template name="prg.bash.completion.shellFunctionName">
		<xsl:param name="name" />
		<xsl:variable name="tname">
			<xsl:call-template name="str.trim">
				<xsl:with-param name="text" select="$name" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="translate($tname,'- ./', '_')" />
	</xsl:template>

	<xsl:template name="prg.bash.completion.subCommandCompletionFunctionName">
		<xsl:param name="subcommand" select="." />
		<xsl:param name="name" />
		<xsl:text>__sc_</xsl:text>
		<xsl:call-template name="prg.bash.completion.shellFunctionName">
			<xsl:with-param name="name">
				<xsl:choose>
					<xsl:when test="$name">
						<xsl:value-of select="$name" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="normalize-space($subcommand/prg:name)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:text>_bashcompletion</xsl:text>
	</xsl:template>

	<xsl:template name="prg.bash.completion.appendFileSystemItemFunction">
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.bash.completion.appendFileSystemItemsFunctionName" />
			<xsl:with-param name="content">
				<!-- Call find command -->
				<xsl:text>local current="${1}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>shift</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local currentLength="${#current}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local d</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local b</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local isHomeShortcut=false</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>[ "${current:0:1}" == "~" ] &amp;&amp; current="${HOME}${current:1}" &amp;&amp; isHomeShortcut=true</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ "${current:$(expr ${currentLength} - 1)}" == "/" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>d="${current%/}"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>b=''</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="else">
						<xsl:text>d="$(dirname "${current}")"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>b="$(basename "${current}")"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ -d "${d}" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>local findCommand="find \"${d}\" -mindepth 1 -maxdepth 1 -name \"${b}*\" -a \\( ${@} \\)"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>local files="$(eval ${findCommand} | while read file; do printf "%q\n" "${file#./}"; done)"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<!-- Transform to array -->
						<xsl:text>local IFS=$'\n'</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>local temporaryRepliesArray=(${files})</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:call-template name="sh.incrementalFor">
							<xsl:with-param name="limit">
								<xsl:call-template name="sh.arrayLength">
									<xsl:with-param name="name" select="'temporaryRepliesArray'" />
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="do">
								<xsl:text>local p="${temporaryRepliesArray[$i]}"</xsl:text>
								<xsl:value-of select="$str.unix.endl" />
								<xsl:text>[ "${d}" != "." ] &amp;&amp; p="${d}/$(basename "${p}")"</xsl:text>
								<xsl:value-of select="$str.unix.endl" />
								<xsl:text>[ -d "${p}" ] &amp;&amp; p="${p%/}/"</xsl:text>
								<xsl:value-of select="$str.unix.endl" />
								<xsl:text>temporaryRepliesArray[$i]="${p} "</xsl:text>
								<xsl:value-of select="$str.unix.endl" />
							</xsl:with-param>
						</xsl:call-template>
						<xsl:value-of select="$str.unix.endl" />
						<!-- Copy results to COMPREPLY -->
						<xsl:call-template name="sh.arrayCopy">
							<xsl:with-param name="from">
								<xsl:text>temporaryRepliesArray</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="to">
								<xsl:text>COMPREPLY</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="append" select="true()" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- "" <=> not an argument -->
	<xsl:template name="prg.bash.completion.getArgOptionNameFunction">
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$prg.bash.completion.getArgOptionFunctionName" />
			<xsl:with-param name="content">
				<xsl:text>local arg="${1}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ "${arg}"  = '--' ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text># End of options marker</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>return 0</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ "${arg:0:2}"  = "--" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text># It's a long option</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>echo "${arg:2}"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>return 0</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ "${arg:0:1}"  = "-" ] &amp;&amp; [ ${#arg} -gt 1 ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text># It's a short option (or a combination of)</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>local index="$(expr ${#arg} - 1)"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>echo "${arg:${index}}"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>return 0</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.bash.completion.getFindPermissionsOptionsFunction">
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$programGetFindPermissionOptionsFunctionName" />
			<xsl:with-param name="content">
				<xsl:text>local access="${1}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local res=''</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local permPrefix='/'</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>[ "$(uname -s)"  = 'Darwin' ] &amp;&amp; permPrefix='+'</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.while">
					<xsl:with-param name="condition">
						<xsl:text>[ ! -z "${access}" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="do">
						<xsl:text>res="${res} -perm ${permPrefix}u=${access:0:1},g=${access:0:1},o=${access:0:1}"</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:text>access="${access:1}"</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>echo "${res}"</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletion">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="path" />
		<xsl:param name="todo" />
		<xsl:if test="$path">
			<xsl:call-template name="sh.case">
				<xsl:with-param name="case">
					<xsl:call-template name="sh.var">
						<xsl:with-param name="name">
							<xsl:value-of select="$optionName" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="in">
					<xsl:call-template name="sh.caseblock">
						<xsl:with-param name="case">
							<xsl:if test="$path/prg:names/prg:long">
								<xsl:call-template name="prg.bash.completion.itemList">
									<xsl:with-param name="path" select="$path/prg:names/prg:long" />
									<xsl:with-param name="quoted" select="true()" />
									<xsl:with-param name="separator">
										<xsl:text> | </xsl:text>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:if test="$path/prg:names/prg:short">
									<xsl:text> | </xsl:text>
								</xsl:if>
							</xsl:if>
							<xsl:call-template name="prg.bash.completion.itemList">
								<xsl:with-param name="path" select="$path/prg:names/prg:short" />
								<xsl:with-param name="quoted" select="true()" />
								<xsl:with-param name="separator">
									<xsl:text> | </xsl:text>
								</xsl:with-param>
								<xsl:with-param name="separator" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="content">
							<xsl:value-of select="$todo" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionByTypeBlock">
		<xsl:param name="path" />
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:call-template name="sh.case">
			<xsl:with-param name="case">
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name">
						<xsl:value-of select="$optionName" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="in">
				<xsl:for-each select="$path">
					<xsl:call-template name="sh.caseblock">
						<xsl:with-param name="case">
							<xsl:if test="./prg:names/prg:long">
								<xsl:call-template name="prg.bash.completion.itemList">
									<xsl:with-param name="path" select="./prg:names/prg:long" />
									<xsl:with-param name="quoted" select="true()" />
									<xsl:with-param name="separator">
										<xsl:text> | </xsl:text>
									</xsl:with-param>
								</xsl:call-template>
								<xsl:if test="./prg:names/prg:short">
									<xsl:text> | </xsl:text>
								</xsl:if>
							</xsl:if>
							<xsl:call-template name="prg.bash.completion.itemList">
								<xsl:with-param name="path" select="./prg:names/prg:short" />
								<xsl:with-param name="quoted" select="true()" />
								<xsl:with-param name="separator">
									<xsl:text> | </xsl:text>
								</xsl:with-param>
								<xsl:with-param name="separator" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="content">
							<xsl:choose>
								<!-- Display only enum values -->
								<xsl:when test="./prg:select[@restrict]">
									<xsl:call-template name="prg.bash.completion.argumentCompletionEnum">
										<xsl:with-param name="optionName" select="$optionName" />
										<xsl:with-param name="currentVarName" select="$currentVarName" />
										<xsl:with-param name="root" select="." />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<!-- Display enum values (if any) and other depending on type -->
									<xsl:if test="./prg:select">
										<xsl:call-template name="prg.bash.completion.argumentCompletionEnum">
											<xsl:with-param name="optionName" select="$optionName" />
											<xsl:with-param name="currentVarName" select="$currentVarName" />
											<xsl:with-param name="root" select="." />
										</xsl:call-template>
									</xsl:if>
									<xsl:value-of select="$str.unix.endl" />
									<xsl:choose>
										<xsl:when test="./prg:type/prg:string">
											<xsl:call-template name="prg.bash.completion.argumentCompletionString">
												<xsl:with-param name="optionName" select="$optionName" />
												<xsl:with-param name="currentVarName" select="$currentVarName" />
												<xsl:with-param name="root" select="." />
											</xsl:call-template>
										</xsl:when>
										<!-- <when test="./prg:type/prg:number"> </when> <when test="./prg:type/prg:integer"> </when> <when test="./prg:type/prg:existingcommand"> </when> -->
										<xsl:when test="./prg:type/prg:existingcommand">
											<xsl:call-template name="prg.bash.completion.argumentCompletionCommand">
												<xsl:with-param name="optionName" select="$optionName" />
												<xsl:with-param name="currentVarName" select="$currentVarName" />
												<xsl:with-param name="root" select="." />
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="./prg:type/prg:path">
											<xsl:call-template name="prg.bash.completion.argumentCompletionPath">
												<xsl:with-param name="optionName" select="$optionName" />
												<xsl:with-param name="currentVarName" select="$currentVarName" />
												<xsl:with-param name="root" select="." />
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="./prg:type/prg:hostname">
											<xsl:call-template name="prg.bash.completion.argumentCompletionHostname">
												<xsl:with-param name="optionName" select="$optionName" />
												<xsl:with-param name="currentVarName" select="$currentVarName" />
												<xsl:with-param name="root" select="." />
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="prg.bash.completion.argumentCompletionOther">
												<xsl:with-param name="optionName" select="$optionName" />
												<xsl:with-param name="currentVarName" select="$currentVarName" />
												<xsl:with-param name="root" select="." />
											</xsl:call-template>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:value-of select="$str.unix.endl" />
							<xsl:call-template name="sh.if">
								<xsl:with-param name="condition">
									<xsl:text>[ ${#COMPREPLY[*]} -gt 0 ]</xsl:text>
								</xsl:with-param>
								<xsl:with-param name="then">
									<xsl:text>return 0</xsl:text>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:value-of select="$str.unix.endl" />
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionString">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:text>[ ${#COMPREPLY[*]} -eq 0 ] &amp;&amp; COMPREPLY[0]="\"${</xsl:text>
		<xsl:value-of select="$currentVarName" />
		<xsl:text>#\"}"</xsl:text>
		<xsl:value-of select="$str.unix.endl" />
		<xsl:text>return 0</xsl:text>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionEnum">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:param name="root" select="." />
		<xsl:text>COMPREPLY=()</xsl:text>
		<xsl:value-of select="$str.unix.endl" />
		<xsl:call-template name="sh.for">
			<xsl:with-param name="condition">
				<xsl:text>e in </xsl:text>
				<xsl:call-template name="prg.bash.completion.itemList">
					<xsl:with-param name="path" select="$root/prg:select/prg:option" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="do">
				<xsl:text>local res="$(compgen -W "${e}" -- </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$currentVarName" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text>)"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ ! -z "${res}" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>COMPREPLY[${#COMPREPLY[*]}]="\"${e}\" "</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionCompgenBased">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:param name="compgenOptions" />
		<xsl:param name="postProcess" />
		<!-- compgen -->
		<xsl:text>local temporaryRepliesArray=( $(compgen </xsl:text>
		<xsl:value-of select="$compgenOptions" />
		<xsl:text> -- </xsl:text>
		<xsl:call-template name="sh.var">
			<xsl:with-param name="name" select="$currentVarName" />
			<xsl:with-param name="quoted" select="true()" />
		</xsl:call-template>
		<xsl:text>) )</xsl:text>
		<xsl:value-of select="$str.unix.endl" />
		<!-- post processing compgen results -->
		<xsl:if test="$postProcess">
			<xsl:value-of select="$postProcess" />
			<xsl:value-of select="$str.unix.endl" />
		</xsl:if>
		<!-- Copy compgen result to COMPREPLY -->
		<xsl:call-template name="sh.arrayCopy">
			<xsl:with-param name="from">
				<xsl:text>temporaryRepliesArray</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="to">
				<xsl:text>COMPREPLY</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="append" select="true()" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionCommand">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:param name="root" />
		<xsl:call-template name="prg.bash.completion.argumentCompletionCompgenBased">
			<xsl:with-param name="optionName" select="$optionName" />
			<xsl:with-param name="currentVarName" select="$currentVarName" />
			<xsl:with-param name="compgenOptions">
				<xsl:text>-A command</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionHostname">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:param name="root" />
		<xsl:call-template name="prg.bash.completion.argumentCompletionCompgenBased">
			<xsl:with-param name="optionName" select="$optionName" />
			<xsl:with-param name="currentVarName" select="$currentVarName" />
			<xsl:with-param name="compgenOptions">
				<xsl:text>-A hostname</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Add path type related restrictions -->
	<xsl:template name="prg.bash.completion.argumentCompletionPath">
		<xsl:param name="optionName" select="'option'" />
		<xsl:param name="currentVarName" select="'current'" />
		<xsl:param name="root" />
		<xsl:variable name="pathNode" select="$root/prg:type/prg:path" />
		<xsl:variable name="kinds" select="$pathNode/prg:kinds" />
		<xsl:variable name="patterns" select="$pathNode/prg:patterns" />
		<xsl:variable name="findOptions">
			<xsl:if test="$pathNode/@access">
				<xsl:text>$(</xsl:text>
				<xsl:value-of select="$programGetFindPermissionOptionsFunctionName" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="$pathNode/@access" />
				<xsl:text>) </xsl:text>
			</xsl:if>
			<xsl:if test="$patterns and $patterns[@restrict = 'true']">
				<xsl:for-each select="$patterns/prg:pattern">
					<xsl:variable name="p" select="position()" />
					<xsl:for-each select="./prg:rules/prg:rule">
						<xsl:if test="($p != 1) or (position() != 1)">
							<xsl:text> -o</xsl:text>
						</xsl:if>
						<xsl:text> -name </xsl:text>
						<xsl:choose>
							<xsl:when test="./prg:endWith">
								<xsl:text>\"*</xsl:text>
								<xsl:value-of select="./prg:endWith" />
								<xsl:text>\"</xsl:text>
							</xsl:when>
							<xsl:when test="./prg:startWith">
								<xsl:text>\"</xsl:text>
								<xsl:value-of select="./prg:endWith" />
								<xsl:text>*\"</xsl:text>
							</xsl:when>
							<xsl:when test="./prg:contains">
								<xsl:text>\"*</xsl:text>
								<xsl:value-of select="./prg:endWith" />
								<xsl:text>*\"</xsl:text>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:if>
			<!-- stricly search for supported kinks -->
			<xsl:for-each select="$kinds/* [self::prg:file or self::prg:folder or self::prg:symlink]">
				<xsl:choose>
					<xsl:when test="./self::prg:file">
						<xsl:text> -type f</xsl:text>
					</xsl:when>
					<xsl:when test="./self::prg:folder">
						<xsl:text> -type d</xsl:text>
					</xsl:when>
					<xsl:when test="./self::prg:symlink">
						<xsl:text> -type l</xsl:text>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="position() != last()">
					<xsl:text> -o </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="true()">
				<!-- Using find command -->
				<xsl:value-of select="$prg.bash.completion.appendFileSystemItemsFunctionName" />
				<xsl:text> </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name" select="$currentVarName" />
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$findOptions" />
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<!-- Using compgen command -->
				<xsl:call-template name="prg.bash.completion.argumentCompletionCompgenBased">
					<xsl:with-param name="optionName" select="$optionName" />
					<xsl:with-param name="currentVarName" select="$currentVarName" />
					<xsl:with-param name="compgenOptions">
						<xsl:choose>
							<xsl:when test="$kinds/prg:folder and $kinds/prg:file">
								<xsl:text>-fd</xsl:text>
							</xsl:when>
							<xsl:when test="$kinds/prg:file">
								<xsl:text>-f</xsl:text>
							</xsl:when>
							<xsl:when test="$kinds/prg:folder">
								<xsl:text>-d</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>-fd</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="postProcess">
						<!-- TODO access checks -->
						<xsl:call-template name="prg.bash.completion.compreplyAddFoldersSlashes">
							<xsl:with-param name="variableName">
								<xsl:text>temporaryRepliesArray</xsl:text>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="prg.bash.completion.argumentCompletionOther">
		<xsl:param name="optionName">
			<xsl:text>option</xsl:text>
		</xsl:param>
		<xsl:param name="currentVarName">
			<xsl:text>current</xsl:text>
		</xsl:param>
		<xsl:param name="root" />
		<xsl:call-template name="prg.bash.completion.argumentCompletionCompgenBased">
			<xsl:with-param name="optionName" select="$optionName" />
			<xsl:with-param name="currentVarName" select="$currentVarName" />
			<xsl:with-param name="compgenOptions">
				<xsl:text>-fd</xsl:text>
			</xsl:with-param>
			<xsl:with-param name="postProcess">
				<xsl:call-template name="prg.bash.completion.compreplyAddFoldersSlashes">
					<xsl:with-param name="variableName">
						<xsl:text>temporaryRepliesArray</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- declare a subcommand option completion function -->
	<xsl:template name="prg.bash.completion.subcommandCompletionFunction">
		<xsl:param name="subcommand" select="." />
		<xsl:variable name="functionName">
			<xsl:call-template name="prg.bash.completion.subCommandCompletionFunctionName" />
		</xsl:variable>
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name" select="$functionName" />
			<xsl:with-param name="content">
				<xsl:text># Context</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local current="${COMP_WORDS[COMP_CWORD]}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local previous="${COMP_WORDS[COMP_CWORD-1]}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text># argument option</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local option="$(</xsl:text>
				<xsl:value-of select="$prg.bash.completion.getArgOptionFunctionName" />
				<xsl:text> ${previous})"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[ -z "${option}" ]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>return 1</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="prg.bash.completion.argumentCompletionByTypeBlock">
					<xsl:with-param name="path" select="$subcommand/prg:options//prg:argument" />
				</xsl:call-template>
				<xsl:text>return 1</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- The main template Called only if prg:program/prg:name exists -->
	<xsl:template name="prg.bash.completion.main">
		<xsl:param name="program" select=".." />
		<xsl:call-template name="prg.bash.completion.getArgOptionNameFunction" />
		<xsl:value-of select="$str.unix.endl" />
		<xsl:call-template name="prg.bash.completion.getFindPermissionsOptionsFunction" />
		<xsl:value-of select="$str.unix.endl" />
		<xsl:call-template name="prg.bash.completion.appendFileSystemItemFunction" />
		<xsl:value-of select="$str.unix.endl" />
		<xsl:if test="../prg:subcommands">
			<xsl:for-each select="../prg:subcommands/prg:subcommand">
				<xsl:call-template name="prg.bash.completion.subcommandCompletionFunction" />
			</xsl:for-each>
			<xsl:for-each select="../prg:subcommands/prg:subcommand/prg:aliases/prg:alias">
				<xsl:call-template name="sh.functionDefinition">
					<xsl:with-param name="name">
						<xsl:call-template name="prg.bash.completion.subCommandCompletionFunctionName">
							<xsl:with-param name="name" select="." />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="content">
						<xsl:call-template name="prg.bash.completion.subCommandCompletionFunctionName">
							<xsl:with-param name="name" select="normalize-space(../../prg:name)" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:if>
		<xsl:value-of select="$str.unix.endl" />
		<xsl:call-template name="sh.functionDefinition">
			<xsl:with-param name="name">
				<xsl:value-of select="$prg.bash.completion.completionFunctionName" />
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:text>#Context</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>COMPREPLY=()</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local current="${COMP_WORDS[COMP_CWORD]}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local previous="${COMP_WORDS[COMP_CWORD-1]}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local first="${COMP_WORDS[1]}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local globalargs="</xsl:text>
				<xsl:call-template name="prg.bash.completion.itemList">
					<xsl:with-param name="path" select="$program/prg:options//prg:names/prg:long" />
					<xsl:with-param name="prepend">
						<xsl:text>--</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="prg.bash.completion.itemList">
					<xsl:with-param name="path" select="$program/prg:options/*/prg:names/prg:short" />
					<xsl:with-param name="prepend">
						<xsl:text> -</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="separator" />
				</xsl:call-template>
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>local args="${globalargs}"</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:value-of select="$str.unix.endl" />
				<!-- Subcommand completion -->
				<xsl:if test="$program/prg:subcommands">
					<xsl:text># Subcommand proposal</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:call-template name="sh.if">
						<xsl:with-param name="condition">
							<xsl:text>[ ${COMP_CWORD} -eq 1 ]</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="then">
							<!-- Subcoomands -->
							<xsl:text>local subcommands="</xsl:text>
							<xsl:call-template name="prg.bash.completion.itemList">
								<xsl:with-param name="path" select="$program/prg:subcommands/prg:subcommand/prg:name" />
							</xsl:call-template>
							<xsl:call-template name="prg.bash.completion.itemList">
								<xsl:with-param name="path" select="$program/prg:subcommands/prg:subcommand/prg:aliases/prg:alias" />
								<xsl:with-param name="prepend">
									<xsl:text> </xsl:text>
								</xsl:with-param>
								<xsl:with-param name="separator" />
							</xsl:call-template>
							<xsl:text>"</xsl:text>
							<xsl:value-of select="$str.unix.endl" />
							<!-- global options and subcommands -->
							<xsl:text>COMPREPLY=( $(compgen -W "${globalargs} ${subcommands}" -- ${current}) )</xsl:text>
							<xsl:value-of select="$str.unix.endl" />
							<!--@todo complete only if <prg:values> and according to first prg:value Files and folders -->
							<xsl:text>local temporaryRepliesArray=( $(compgen -fd -- </xsl:text>
							<xsl:call-template name="sh.var">
								<xsl:with-param name="name">
									<xsl:text>current</xsl:text>
								</xsl:with-param>
								<xsl:with-param name="quoted" select="true()" />
							</xsl:call-template>
							<xsl:text>) )</xsl:text>
							<xsl:value-of select="$str.unix.endl" />
							<xsl:call-template name="prg.bash.completion.compreplyAddFoldersSlashes">
								<xsl:with-param name="variableName">
									<xsl:text>temporaryRepliesArray</xsl:text>
								</xsl:with-param>
							</xsl:call-template>
							<xsl:value-of select="$str.unix.endl" />
							<xsl:call-template name="sh.arrayCopy">
								<xsl:with-param name="from">
									<xsl:text>temporaryRepliesArray</xsl:text>
								</xsl:with-param>
								<xsl:with-param name="to">
									<xsl:text>COMPREPLY</xsl:text>
								</xsl:with-param>
								<xsl:with-param name="append" select="true()" />
							</xsl:call-template>
							<xsl:value-of select="$str.unix.endl" />
							<xsl:call-template name="prg.bash.completion.compreplyAddSpaces" />
							<xsl:value-of select="$str.unix.endl" />
							<xsl:text>return 0</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:text># Subcommand option argument proposal</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:text>local sc_function_name="</xsl:text>
					<xsl:call-template name="prg.bash.completion.subCommandCompletionFunctionName">
						<xsl:with-param name="name">
							<xsl:text>${first}</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text>"</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:call-template name="sh.if">
						<xsl:with-param name="condition">
							<xsl:text>[ "$(type -t ${sc_function_name})" = "function" ] &amp;&amp; ${sc_function_name}</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="then">
							<xsl:text>return 0</xsl:text>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$str.unix.endl" />
					<!-- Add Subcommand option to the list of global args -->
					<xsl:text># Subcommand option completion</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:call-template name="sh.case">
						<xsl:with-param name="case">
							<xsl:text>${first}</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="in">
							<xsl:for-each select="$program/prg:subcommands/prg:subcommand">
								<xsl:call-template name="sh.caseblock">
									<xsl:with-param name="case">
										<xsl:call-template name="prg.bash.completion.itemList">
											<xsl:with-param name="path" select="./prg:name" />
											<xsl:with-param name="quoted" select="true()" />
										</xsl:call-template>
										<xsl:call-template name="prg.bash.completion.itemList">
											<xsl:with-param name="path" select="./prg:aliases/prg:alias" />
											<xsl:with-param name="quoted" select="true()" />
											<xsl:with-param name="prepend">
												<xsl:text> | </xsl:text>
											</xsl:with-param>
											<xsl:with-param name="separator" />
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="content">
										<xsl:text>args="</xsl:text>
										<xsl:call-template name="prg.bash.completion.itemList">
											<xsl:with-param name="path" select="./prg:options/*/prg:names/prg:long" />
											<xsl:with-param name="prepend">
												<xsl:text>--</xsl:text>
											</xsl:with-param>
										</xsl:call-template>
										<xsl:call-template name="prg.bash.completion.itemList">
											<xsl:with-param name="path" select="./prg:options/*/prg:names/prg:short" />
											<xsl:with-param name="prepend">
												<xsl:text> -</xsl:text>
											</xsl:with-param>
											<xsl:with-param name="separator" />
										</xsl:call-template>
										<xsl:text> ${globalargs}"</xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:value-of select="$str.unix.endl" />
				</xsl:if>
				<!-- subcommands exists -->
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text># Option proposal</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:call-template name="sh.if">
					<xsl:with-param name="condition">
						<xsl:text>[[ ${current} == -* ]]</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="then">
						<xsl:text>COMPREPLY=( $(compgen -W "${args}" -- ${current}) )</xsl:text>
						<xsl:value-of select="$str.unix.endl" />
						<xsl:call-template name="prg.bash.completion.compreplyAddSpaces" />
						<xsl:text>return 0</xsl:text>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="$program/prg:options//prg:argument">
					<xsl:value-of select="$str.unix.endl" />
					<xsl:text># Option argument proposal</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:text>local option="$(</xsl:text>
					<xsl:value-of select="$prg.bash.completion.getArgOptionFunctionName" />
					<xsl:text> ${previous})"</xsl:text>
					<xsl:value-of select="$str.unix.endl" />
					<xsl:call-template name="sh.if">
						<xsl:with-param name="condition">
							<xsl:text>[ ! -z "${option}" ]</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="then">
							<xsl:call-template name="prg.bash.completion.argumentCompletionByTypeBlock">
								<xsl:with-param name="path" select="$program/prg:options//prg:argument" />
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<!-- well, completing files and folders... -->
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text># Last hope: files and folders</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>COMPREPLY=( $(compgen -fd -- </xsl:text>
				<xsl:call-template name="sh.var">
					<xsl:with-param name="name">
						<xsl:text>current</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="quoted" select="true()" />
				</xsl:call-template>
				<xsl:text>) )</xsl:text>
				<xsl:value-of select="$str.unix.endl" />
				<!-- Auto add '/' at end of folders -->
				<xsl:call-template name="prg.bash.completion.compreplyAddFoldersSlashes" />
				<xsl:value-of select="$str.unix.endl" />
				<xsl:text>return 0</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<!-- end of main function -->
		<xsl:text>complete -o nospace -F </xsl:text>
		<xsl:value-of select="$prg.bash.completion.completionFunctionName" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="normalize-space($program/prg:name)" />
		<xsl:value-of select="$prg.bash.completion.programFileExtension" />
		<xsl:value-of select="$str.unix.endl" />
	</xsl:template>

	<xsl:template match="/prg:program/prg:name">
		<xsl:call-template name="prg.bash.completion.main" />
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates select="/prg:program/prg:name" />
	</xsl:template>

</xsl:stylesheet>
