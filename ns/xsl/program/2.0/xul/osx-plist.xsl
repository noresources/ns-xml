<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 - 2020 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Create a Mac OS X property list for the XUL frontend application -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<xsl:import href="../../../documents/osx-plist.xsl" />
	<xsl:import href="base.xsl" />

	<xsl:output method="xml" doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd" doctype-public="-//Apple Computer//DTD PLIST 1.0//EN" encoding="utf-8" indent="yes" />

	<xsl:param name="prg.xul.buildID" />

	<xsl:template match="/prg:program">
		<xsl:call-template name="plist.document">
			<xsl:with-param name="content">
				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundleInfoDictionaryVersion</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:text>6.0</xsl:text>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundlePackageType</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:text>APPL</xsl:text>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundleExecutable</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:text>xulrunner</xsl:text>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="plist.boolean">
					<xsl:with-param name="key">
						<xsl:text>NSAppleScriptEnabled</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value" select="true()" />
				</xsl:call-template>

				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundleGetInfoString</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:value-of select="$prg.xul.appName" />
						<xsl:text> </xsl:text>
						<xsl:value-of select="./prg:version" />
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundleName</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:call-template name="prg.programDisplayName" />
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundleShortVersion</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:value-of select="./prg:version" />
					</xsl:with-param>
				</xsl:call-template>

				<xsl:call-template name="plist.string">
					<xsl:with-param name="key">
						<xsl:text>CFBundleVersion</xsl:text>
					</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:choose>
							<xsl:when test="$prg.xul.buildID">
								<xsl:value-of select="$prg.xul.buildID" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="./prg:version" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
