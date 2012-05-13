<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Create a Mac OS X property list for the XUL frontend application -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program">

	<import href="../../documents/macosx-plist.xsl" />
	<import href="xul-base.xsl" />

	<output method="xml" doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd" doctype-public="-//Apple Computer//DTD PLIST 1.0//EN" encoding="utf-8" indent="yes" />

	<param name="prg.xul.buildID" />

	<template match="/prg:program">
		<call-template name="plist.document">
			<with-param name="content">
				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundleInfoDictionaryVersion</text>
					</with-param>
					<with-param name="value">
						<text>6.0</text>
					</with-param>
				</call-template>

				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundlePackageType</text>
					</with-param>
					<with-param name="value">
						<text>APPL</text>
					</with-param>
				</call-template>

				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundleExecutable</text>
					</with-param>
					<with-param name="value">
						<text>xulrunner</text>
					</with-param>
				</call-template>

				<call-template name="plist.boolean">
					<with-param name="key">
						<text>NSAppleScriptEnabled</text>
					</with-param>
					<with-param name="value" select="true()" />
				</call-template>

				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundleGetInfoString</text>
					</with-param>
					<with-param name="value">
						<value-of select="$prg.xul.appName" />
						<text> </text>
						<value-of select="./prg:version" />
					</with-param>
				</call-template>

				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundleName</text>
					</with-param>
					<with-param name="value">
						<call-template name="prg.programDisplayName" />
					</with-param>
				</call-template>

				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundleShortVersion</text>
					</with-param>
					<with-param name="value">
						<value-of select="./prg:version" />
					</with-param>
				</call-template>

				<call-template name="plist.string">
					<with-param name="key">
						<text>CFBundleVersion</text>
					</with-param>
					<with-param name="value">
						<choose>
							<when test="$prg.xul.buildID">
								<value-of select="$prg.xul.buildID" />
							</when>
							<otherwise>
								<value-of select="./prg:version" />
							</otherwise>
						</choose>
					</with-param>
				</call-template>
			</with-param>
		</call-template>
	</template>
</stylesheet>
