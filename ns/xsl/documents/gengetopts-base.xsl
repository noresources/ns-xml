<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2011 by Renaud Guillard (dev@niao.fr) -->

<!-- Basic GNU Gengetopts elements -->
<stylesheet version="1.0" 
	xmlns="http://www.w3.org/1999/XSL/Transform" >

	<import href="../languages/base.xsl" />

	<!-- Comment block -->
	<template name="ggo.comment">
		<!-- Comment text -->
		<param name="content" select="." />
		<call-template name="code.comment">
			<with-param name="marker">
				<text># </text>
			</with-param>
			<with-param name="content" select="$content" />
		</call-template>
	</template>	
	
</stylesheet>