<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011-2012 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the BSD License, see LICENSE -->

<!-- XUL application overlay -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<xsl:import href="ui-base.xsl" />

	<xsl:output method="xml" encoding="utf-8" indent="yes" />

	<xsl:template match="/prg:program">
		<xsl:element name="xul:overlay">

			<xsl:element name="xul:keyset">
				<xsl:attribute name="id">prg.ui.keyset</xsl:attribute>
				<xsl:element name="xul:key">
					<xsl:attribute name="id">prg.ui.key.quitApp</xsl:attribute>
					<xsl:attribute name="key">Q</xsl:attribute>
					<xsl:attribute name="modifiers">accel</xsl:attribute>
					<xsl:attribute name="oncommand">
					<xsl:value-of select="$prg.xul.js.applicationInstanceName" /><xsl:text>.quitApplication()</xsl:text>
				</xsl:attribute>
				</xsl:element>
				<xsl:element name="xul:key">
					<xsl:attribute name="id">key:closeWindow</xsl:attribute>
					<xsl:attribute name="key">W</xsl:attribute>
					<xsl:attribute name="modifiers">accel</xsl:attribute>
					<xsl:attribute name="oncommand">
						<xsl:text>window.close();</xsl:text>
					</xsl:attribute>
				</xsl:element>
				<xsl:element name="xul:key">
					<xsl:attribute name="id">prg.ui.key.hideApp</xsl:attribute>
					<xsl:attribute name="key">H</xsl:attribute>
					<xsl:attribute name="modifiers">accel</xsl:attribute>
				</xsl:element>
				<xsl:element name="xul:key">
					<xsl:attribute name="id">prg.ui.key.hideOtherApps</xsl:attribute>
					<xsl:attribute name="key">H</xsl:attribute>
					<xsl:attribute name="modifiers">accel,alt</xsl:attribute>
				</xsl:element>
			</xsl:element>

			<xsl:element name="xul:commandset">
				<xsl:attribute name="id">prg.ui.commandset</xsl:attribute>
				<xsl:element name="xul:command">
					<xsl:attribute name="id">prg.ui.cmd.quitApp</xsl:attribute>
					<xsl:attribute name="oncommand">
					<xsl:value-of select="$prg.xul.js.applicationInstanceName" /><xsl:text>.quitApplication()</xsl:text>
				</xsl:attribute>
				</xsl:element>
			</xsl:element>

			<xsl:element name="xul:menubar">
				<!-- Attach to xulrunner (or firefox) main menubar -->
				<xsl:attribute name="id">main-menubar</xsl:attribute>
				<xsl:if test="$prg.xul.platform = 'macosx'">
					<xsl:attribute name="hidden">true</xsl:attribute>
				</xsl:if>
				<xsl:element name="xul:menu">
					<xsl:if test="$prg.xul.platform = 'macosx'">
						<xsl:attribute name="id">mac-menu</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="label"><xsl:call-template name="prg.programDisplayName" /></xsl:attribute>
					<xsl:element name="xul:menupopup">
						<xsl:choose>
							<xsl:when test="$prg.xul.platform = 'macosx'">
								<xsl:attribute name="id">menu_MacApplicationPopup</xsl:attribute>
								<xsl:element name="xul:menuitem">
									<xsl:attribute name="id">menu_mac_hide_app</xsl:attribute>
									<xsl:attribute name="label">Hide <xsl:call-template name="prg.programDisplayName" /></xsl:attribute>
									<xsl:attribute name="key">prg.ui.key.hideApp</xsl:attribute>
								</xsl:element>
								<xsl:element name="xul:menuitem">
									<xsl:attribute name="id">menu_mac_hide_others</xsl:attribute>
									<xsl:attribute name="label">Hide Others</xsl:attribute>
									<xsl:attribute name="key">prg.ui.key.hideOtherApps</xsl:attribute>
								</xsl:element>
								<xsl:element name="xul:menuitem">
									<xsl:attribute name="id">menu_mac_show_all</xsl:attribute>
									<xsl:attribute name="label">Show All</xsl:attribute>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:element name="xul:menuitem">
							<xsl:attribute name="id">menu_FileQuitItem</xsl:attribute>
							<xsl:attribute name="label">Quit</xsl:attribute>
							<xsl:attribute name="key">prg.ui.key.quitApp</xsl:attribute>
							<xsl:attribute name="command">prg.ui.cmd.quitApp</xsl:attribute>
						</xsl:element>
					</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
