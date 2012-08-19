# -*- coding: utf-8 -*-
""" Copyright © 2012 by Renaud Guillard """
""" Distributed under the terms of the MIT License, see LICENSE """

""" Base and utils """

class Util:
    @classmethod
    def cli_option_name(cls, name):
        """Current option name as it appears on the command line"""
        if (name == None) or (len(name) == 0):
            return ""
        elif len(name) == 1:
            return "-" + name
        return "--" + name

    @classmethod
    def value_list_display(cls, values, separator = ", ", last_separator = " or ", enclose_start = "", enclose_end =""):
        length = len(values)
        
        if length < 2:
            return values[0]
        if length == 2:
            glue = enclose_end + last_separator + enclose_start 
            return enclose_start + glue.join(values) + enclose_end
        
        glue = enclose_end + separator + enclose_start
        msg = enclose_start + glue.join(values[0:(length - 1)])
        return msg + enclose_end + last_separator + enclose_start + values[(length - 1)] + enclose_end 
            
class State:
    """Parser context state"""
    Undef = 0
    EndOfOptions = 1
    GluedValue = 2
    SkipArgument = 4
    ArgumentExpected = 8
   
class Context:
    def __init__(self):
        self.state = State.Undef
        self.option = None
        self.option_name = ""
        self.option_args = []
        self.subcommand = None
        self.skip_count = 0
        self.issues = {"debug": [], "notices": [], "warnings": [], "errors": []}
            
    def unset_current_option(self):
        self.option = None
        self.option_name = ""
        
    def set_argument_skipping(self, b, count):
        if b:
            self.state |= State.SkipArgument
            self.skip_count = count
        else:
            self.state &= ~State.SkipArgument
            self.skip_count = 0
        
    def skip_argument(self):
        self.skip_count = self.skip_count - 1
        if self.skip_count == 0:
            self.state &= ~State.SkipArgument
    
    @property
    def cli_option_name(self):
        """Current option name as it appears on the command line"""
        return Util.cli_option_name(self.option_name)
    
    def add_issue(self, level, message):
        if level == "fatalerror":
            print "Fatal error: " + message
            return   
        self.issues[level].append(message)
        
    def debug(self, message):
        self.add_issue("debug", message)
        
    def notice(self, message):
        self.add_issue("notices", message)
        
    def warning(self, message):
        self.add_issue("warnings", message)
        
    def error(self, message):
        self.add_issue("errors", message) 

class Usage:
    Inline = 1
    Abstract = 2
    Details = 6
    """Imply Abstract"""
    AllInfos = 7
    Raw = 8