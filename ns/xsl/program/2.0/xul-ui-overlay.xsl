<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright (c) 2011 by Renaud Guillard (dev@niao.fr) -->
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:prg="http://xsd.nore.fr/program" xmlns:xul="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">

	<import href="./xul-ui-base.xsl" />

	<output method="xml" encoding="utf-8" indent="yes" />

	<strip-space elements="*" />

	<template match="/prg:program">
		<element name="xul:overlay">

			<element name="xul:keyset">
				<attribute name="id">prg.ui.keyset</attribute>
				<element name="xul:key">
					<attribute name="id">prg.ui.key.quitApp</attribute>
					<attribute name="key">Q</attribute>
					<attribute name="modifiers">accel</attribute>
					<attribute name="oncommand">
					<value-of select="$prg.xul.js.applicationInstanceName" /><text>.quitApplication()</text>
				</attribute>
				</element>
				<element name="xul:key">
					<attribute name="id">key:closeWindow</attribute>
					<attribute name="key">W</attribute>
					<attribute name="modifiers">accel</attribute>
					<attribute name="oncommand">
						<text>alert('close'); window.close();</text>
					</attribute>
				</element>
				<element name="xul:key">
					<attribute name="id">prg.ui.key.hideApp</attribute>
					<attribute name="key">H</attribute>
					<attribute name="modifiers">accel</attribute>
				</element>
				<element name="xul:key">
					<attribute name="id">prg.ui.key.hideOtherApps</attribute>
					<attribute name="key">H</attribute>
					<attribute name="modifiers">accel,alt</attribute>
				</element>
			</element>

			<element name="xul:commandset">
				<attribute name="id">prg.ui.commandset</attribute>
				<element name="xul:command">
					<attribute name="id">prg.ui.cmd.quitApp</attribute>
					<attribute name="oncommand">
					<value-of select="$prg.xul.js.applicationInstanceName" /><text>.quitApplication()</text>
				</attribute>
				</element>
			</element>

			<element name="xul:menubar">
				<attribute name="id">prg.ui.mainMenubar</attribute>
				<if test="$prg.xul.platform = 'macosx'">
					<attribute name="hidden">true</attribute>
				</if>
				<element name="xul:menu">
					<attribute name="id">mac-menu</attribute>
					<attribute name="label"><call-template name="prg.programDisplayName" /></attribute>
					<element name="xul:menupopup">
						<choose>
							<when test="$prg.xul.platform = 'macosx'">
								<attribute name="id">menu_MacApplicationPopup</attribute>
								<element name="xul:menuitem">
									<attribute name="id">menu_mac_hide_app</attribute>
									<attribute name="label">Hide <call-template name="prg.programDisplayName" /></attribute>
									<attribute name="key">prg.ui.key.hideApp</attribute>
								</element>
								<element name="xul:menuitem">
									<attribute name="id">menu_mac_hide_others</attribute>
									<attribute name="label">Hide Others</attribute>
									<attribute name="key">prg.ui.key.hideOtherApps</attribute>
								</element>
								<element name="xul:menuitem">
									<attribute name="id">menu_mac_show_all</attribute>
									<attribute name="label">Show All</attribute>
								</element>
							</when>
							<otherwise>
							</otherwise>
						</choose>
						<element name="xul:menuitem">
							<attribute name="id">menu_FileQuitItem</attribute>
							<attribute name="label">Quit</attribute>
							<attribute name="key">prg.ui.key.quitApp</attribute>
							<attribute name="command">prg.ui.cmd.quitApp</attribute>
						</element>
					</element>
				</element>
			</element>
		</element>
	</template>

</stylesheet>
