ns-xml
======
A collection of XML-based tools to generate source code and programs

# ns-xml components
## Program interface definition framework
Generation of command line option parser, usage string, bash completion file etc. 
from a single XML description of a program interface (options, positional arguments & subcommands)
## XSH - XML shell script
A basic XML structure to write reusable and portable UNIX shell script code across interpreters (bash, zsh, ksh)
## XSLT stylesheet library
Various XSLT stylesheet to generate code and documents
> See [the online documentation](http://ns-xml.nore.fr/index.php?tab=xsltdoc)
  
# Source structure
  
* ns The source directory
  * sh UNIX shellscript tools to build program parser etc.
  * xbl XBL element library
  * xsh XML shell scripts applications & libraries
  * xsl XSLT stylesheet library* resources Development resources 
* tools Development tools
* tests Tests for the program interface definition framework
* scripts Scripts & configurations files for IDE (mostly for Eclipse)
