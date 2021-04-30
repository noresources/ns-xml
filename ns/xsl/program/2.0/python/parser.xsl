<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright © 2013-2021 by Renaud Guillard (dev@nore.fr) -->
<!-- Distributed under the terms of the MIT License, see LICENSE -->

<!-- Python Source code in customizable XSLT form -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="../../../strings.xsl" />
	<xsl:import href="base.xsl" />
	
	<xsl:output method="text" encoding="utf-8" />
	
	<!-- Base classes of the Python parser -->
<xsl:variable name="prg.python.base.code"><![CDATA[import os
import math
import textwrap

class Util(object):
    @classmethod
    def isArray(cls, var):
        return isinstance(var, (list, tuple))

    @classmethod
    def isString(cls, var):
        return isinstance(var, str)

    @classmethod
    def isInteger(cls, var):
        if cls.isString(var):
            return var.isdigit()
        else:
            try:
                int(var)
                return True
            except ValueError:
                return False
            except TypeError:
                return False

    @classmethod
    def isNumeric(cls, var):
        try:
            float(var)
            return True
        except ValueError:
            return False
        except TypeError:
            return False

    @classmethod
    def implode(cls, container, separator = ", ", lastSeparator = " or "):
        if not cls.isArray(container):
            return ""

        length = len(container)

        if length == 0:
            return ""
        elif length == 1:
            return container
        elif length == 2:
            return lastSeparator.join(container)

        return separator.join(container[0:(length - 1)]) + lastSeparator + container[length - 1]

class UsageFormat(object):
    SHORT_TEXT = 0x1
    ABSTRACT_TEXT = 0x2
    DETAILED_TEXT = 0x7

    INDENTOFFSET_FIRST = 0x1
    INDENTOFFSET_OTHER = 0x2
    INDENTOFFSET_ALL = 0x3

    lineLength = 80
    endOfLineString = "\n"
    indentString = "  "

    format = 0

    def __init__(self, format = DETAILED_TEXT):
        object.__init__(self)
        self.lineLength = 80
        self.endOfLineString = "\n"
        self.indentString = "  "
        self.format = format

    def wrap(self, text, mode, level):
        first = (self.indentString * level)
        other = (self.indentString * level)

        if mode & self.INDENTOFFSET_FIRST:
            first += self.indentString
        if mode & self.INDENTOFFSET_OTHER:
            other += self.indentString

        return textwrap.fill(text, width = self.lineLength, initial_indent = first, subsequent_indent = other)

class OptionName(object):
    SHORT = 1
    LONG = 2
    ANY = 3

    name = ""

    def __init__(self, name):
        object.__init__(self)
        self.name = name

    def __str__(self):
        return self.name

    def isShort(self):
        return len(self.name) == 1

    def getType(self):
        if self.isShort():
            return OptionName.SHORT
        return OptionName.LONG

    def cliName(self):
        if self.isShort():
            return "-" + self.name
        return "--" + self.name

class OptionNameList(object):

    def __init__(self, names):
        object.__init__(self)
        self.names = {}
        if Util.isArray(names):
            for n in names:
                if Util.isString(n):
                    self.names[n] = OptionName(n)
                elif isinstance(n, OptionName):
                    self.names[n.name] = n

    def __iter__(self):
        return iter(self.names.items())

    def getShortOptionNames(self):
        res = OptionNameList
        for k, n in self.names.items():
            if n.isShort():
                res.names[k] = n
        return res

    def getLongOptionNames(self):
        res = OptionNameList
        for k, n in self.names.items():
            if not n.isShort():
                res.names[k] = n
        return res

    def getFirstOptionName(self, type = OptionName.ANY, strict = False):
        if type == OptionName.ANY:
            return self.names[self.names.keys()[0]]

        other = None
        for k, n in self.names.items():
            if type == n.getType():
                return n

            if other == None:
                other = n

        if strict:
            return None

        return other

class ValueValidator(object):
    pass

    def validate(self, state, result, element, value):
        return True

    def usage(self, usageFormat = None):
        return ""

    def appendDefaultError(self, state, result, element, usageFormat = None):
        if Util.isInteger(element):
            result._appendMessage(Message.ERROR, 2, Message.ERROR_INVALID_POSARG_VALUE, element, self.usage(usageFormat))
        else:
            result._appendMessage(Message.ERROR, 1, Message.ERROR_INVALID_OPTION_VALUE, element.name.cliName(), self.usage(usageFormat))

class PathValueValidator(ValueValidator):
    EXISTS = 0x01

    ACCESS_READ = 0x02
    ACCESS_WRITE = 0x04
    ACCESS_EXECUTE = 0x08

    TYPE_FILE = 0x10
    TYPE_FOLDER = 0x20
    TYPE_SYMLINK = 0x40
    TYPE_ALL = 0x70

    flags = 0

    def __init__(self, flags):
        ValueValidator.__init__(self)
        self.flags = flags

    def validate(self, state, result, element, value):
        passed = True
        if self.flags & self.EXISTS:
            if self.flags & self.ACCESS_READ and not os.access(value, os.R_OK):
                passed = False
            if self.flags & self.ACCESS_WRITE and not os.access(value, os.W_OK):
                passed = False
            if self.flags & self.ACCESS_EXECUTE and not os.access(value, os.X_OK):
                passed = False

        if os.path.exists(value):
            types = (self.flags & TYPE_ALL)
            if not ((types == 0) or (types == TYPE_ALL)):
                typeFound = False
                if self.flags & TYPE_FILE and os.path.isfile(value):
                    typeFound = True
                elif self.flags & TYPE_FOLDER and os.path.isdir(value):
                    typeFound = True
                elif self.flags & self.TYPE_SYMLINK and os.path.islink(value):
                    typeFound = True

                if not typeFound:
                    passed = False

        if not passed:
            self.appendDefaultError(state, result, element)

        return passed

    def usage(self, usageFormat = UsageFormat()):
        text = ""
        types = self.flags & self.TYPE_ALL
        eol = usageFormat.endOfLineString

        if not (types == 0 or types & self.TYPE_ALL):
            types = { self.TYPE_FILE: "file", self.TYPE_FOLDER: "folder", self.TYPE_SYMLINK: "symbolic link" }
            names = []
            for t, name in types.items():
                if t & self.flags:
                    names.append(name)
            text += "Expected file type"
            if len(names) > 1:
                text += "s"
            text += ": " + Util.implode(names, ", ", " or ")

        access = self.flags & (self.ACCESS_EXECUTE | self.ACCESS_READ | self.ACCESS_WRITE)
        if access > 0:
            access = { self.ACCESS_EXECUTE: "executable", self.ACCESS_READ: "readable", self.ACCESS_WRITE: "writable"}
            names = []
            for a, name in access.items():
                names.append(name)

            if len(text) > 0:
                text += eol
            text += "Path argument must be " + Util.implode(names, ", ", " and ")

        return text

class NumberValueValidator(ValueValidator):
    minValue = None
    maxValue = None

    def __init__(self, min, max):
        self.minValue = min
        self.maxValue = max
        if Util.isNumeric(self.minValue):
            self.minValue = float(self.minValue)
        if Util.isNumeric(self.maxValue):
            self.maxValue = float(self.maxValue)

    def validate(self, state, result, element, value):
        passed = True
        if not Util.isNumeric(value):
            passed = False
        if passed and (self.minValue != None) and (float(value) < self.minValue):
            passed = False
        if passed and (self.maxValue != None) and (float(value) > self.maxValue):
            passed = False

        if not passed:
            self.appendDefaultError(state, result, element)

        return passed

    def usage(self, usageFormat = UsageFormat()):
        text = "Argument value must be a number";
        if self.minValue != None:
            if self.maxValue != None:
                text += " between " + str(self.minValue) + " and " + str(self.maxValue)
            else:
                text += " greater or equal than " + str(self.minValue)
        elif self.maxValue != None:
            text += " lesser or equal than " + str(self.maxValue)

        return text

class EnumerationValueValidator(ValueValidator):

    RESTRICT = 0x1

    values = ()
    flags = RESTRICT

    def __init__(self, values = (), flags = RESTRICT):
        self.values = values

    def validate(self, state, result, element, value):
        if not (self.flags & self.RESTRICT):
            return True

        for v in self.values:
            if v == value:
                return True

        self.appendDefaultError(state, result, element)
        return False

    def usage(self, usageFormat = UsageFormat()):
        text = "Argument value ";
        if self.flags & self.RESTRICT:
            text += "must be "
        else:
            text += "can be "
        text += Util.implode(self.values, ", ", " or ")
        return text

class ItemInfo(object):

    REQUIRED = 1

    abstract = ""
    details = ""

    def __init__(self, abstract = "", details = ""):
        object.__init__(self)
        self.abstract = abstract
        self.details = details

class OptionInfo(ItemInfo):

    optionFlags = 0
    variableName = None
    names = None
    parent = None
    validators = None

    def __init__(self, variableName = None, names = None, flags = 0):
        ItemInfo.__init__(self)
        self.optionFlags = flags
        self.variableName = variableName
        self.names = OptionNameList(names)
        self.validators = []

    def getKey(self):
        key = self.__class__.__name__
        if self.parent == None:
            return key
        index = 0
        for o in self.parent.options:
            if o == self:
                key = self.parent.getKey() + "." + str(index) + key
                break
            else:
                index = index + 1
        return key

class SwitchOptionInfo(OptionInfo):

    def __init__(self, variableName = None, names = None, flags = 0):
        OptionInfo.__init__(self, variableName, names, flags)

class ArgumentType:
    STRING = 1
    MIXED = 1
    EXISTINGCOMMAND = 2
    HOSTNAME = 3
    PATH = 4
    NUMBER = 5

    @classmethod
    def usageName(cls, type):
        if type == cls.EXISTINGCOMMAND:
            return "cmd"
        elif type == cls.HOSTNAME:
            return "host"
        elif type == cls.PATH:
            return "path"
        elif type == cls.NUMBER:
            return "number"

        return "?"

class ArgumentOptionInfo(OptionInfo):

    argumentType = ArgumentType.MIXED
    defaultValue = None

    def __init__(self, variableName = None, names = None, flags = 0):
        OptionInfo.__init__(self, variableName, names, flags)

class MultiArgumentOptionInfo(OptionInfo):

    argumentType = ArgumentType.MIXED
    minArgumentCount = 1
    maxArgumentCount = 0

    def __init__(self, variableName = None, names = None, flags = 0):
        OptionInfo.__init__(self, variableName, names, flags)

class OptionContainerOptionInfo(OptionInfo):
    def __init__(self, variableName = None, flags = None):
        OptionInfo.__init__(self, variableName, None, flags)
        self.options = []

    def appendOption(self, option):
        self.options.append(option)
        option.parent = self

    def getOptionNameListString(self):
        names = []
        for o in self.options:
            if isinstance(o, OptionContainerOptionInfo):
                names.append("(" + o.getOptionNameListString() + ")")
            else:
                names.append(o.names.getFirstOptionName(OptionName.LONG, False).cliName())

        return Util.implode(names, ", ", " or ")

    def flattenOptionTree(self):
        options = []

        for o in self.options:
            if isinstance(o, OptionContainerOptionInfo):
                options = options + o.flattenOptionTree()
            else:
                options.append(o)

        return options

    def optionShortUsage(self, usageFormat):
        text = ""
        visited = []
        optionlist = self.flattenOptionTree()
        required = []
        for o in optionlist:
            if o.optionFlags & ItemInfo.REQUIRED:
                required.append(o)
                optionlist.remove(o)
        optionlist = required + optionlist

        groups = [ [], [] ]
        for option in optionlist:
            firstShort = option.names.getFirstOptionName(OptionName.SHORT, True)
            if firstShort != None and isinstance(option, SwitchOptionInfo):
                groups[0].append(firstShort.name)
            else:
                first = option.names.getFirstOptionName(OptionName.SHORT, False)
                if first != None:
                    groups[1].append ({"option": option, "name": first})

        if len(groups[0]) > 0:
            text += "-" + "".join(groups[0])

        for other in groups[1]:
            option = other["option"]
            name = other["name"]
            required = (option.optionFlags & ItemInfo.REQUIRED)
            optionText = name.cliName()

            if isinstance(option, ArgumentOptionInfo):
                optionText += "=<" + ArgumentType.usageName(option.argumentType) + ">"
            elif isinstance(option, MultiArgumentOptionInfo):
                optionText += "=<" + ArgumentType.usageName(option.argumentType) + " ...>"

            if (not required) and (len(optionText) > 0):
                optionText = "[" + optionText + "]"

            if (len(text) > 0) and (len(optionText) > 0):
                text += " "
            text += optionText

        return text

    def optionUsage(self, usageFormat, level = 0):
        text = ""
        eol = usageFormat.endOfLineString

        for o in self.options:
            subtext = ""
            if not (isinstance(o, GroupOptionInfo)):
                clinames = []
                for k, name in o.names:
                    clinames.append(name.cliName())
                subtext += ", ".join(clinames)

            if usageFormat.format & UsageFormat.ABSTRACT_TEXT and Util.isString(o.abstract) and (len(o.abstract) > 0):
                if len(subtext) > 0:
                    subtext += ": "
                subtext += o.abstract

            if usageFormat.format & UsageFormat.DETAILED_TEXT and Util.isString(o.details) and (len(o.details) > 0):
                if len(subtext) > 0:
                    subtext += eol
                subtext += o.details

            if isinstance(o, GroupOptionInfo):
                if len(subtext) > 0:
                    subtext += eol

                subtext += o.optionUsage(usageFormat, level + 1)

                if len(subtext) > 0:
                    text += subtext + eol
            else:
                for v in o.validators:
                    vtext = v.usage(usageFormat)
                    if len(vtext) > 0:
                        if len(subtext) > 0:
                            subtext += eol
                        subtext += vtext

                if len(subtext) > 0:
                    text += usageFormat.wrap(subtext, UsageFormat.INDENTOFFSET_OTHER, level) + eol
        return text

    options = None

class GroupOptionInfo(OptionContainerOptionInfo):
    TYPE_NORMAL = 0
    TYPE_EXCLUSIVE = 1

    groupType = 0
    defaultOption = None

    def __init__(self, variableName = None, groupType = TYPE_NORMAL, flags = 0, dfltOption = None):
        OptionContainerOptionInfo.__init__(self, variableName, flags)
        self.groupType = groupType
        self.defaultOption = dfltOption

class PositionalArgumentInfo(ItemInfo):

    positionalArgumentFlags = 0
    argumentType = ArgumentType.MIXED
    maxArgumentCount = 1
    validators = None

    def __init__(self, maxArgumentCount = 1, argumentType = ArgumentType.MIXED, flags = 0):
        ItemInfo.__init__(self)
        self.positionalArgumentFlags = flags
        self.argumentType = argumentType
        self.maxArgumentCount = maxArgumentCount
        self.validators = []

class RootItemInfo(OptionContainerOptionInfo):

    positionalArguments = None

    def __init__(self):
        OptionContainerOptionInfo.__init__(self)
        self.positionalArguments = []

    def appendPositionalArgument(self, info):
        self.positionalArguments.append(info)
        return info

class SubcommandInfo(RootItemInfo):

    name = ""
    aliases = None

    def __init__(self, name, aliases = ()):
        RootItemInfo.__init__(self)
        self.name = name
        self.aliases = []

        if Util.isArray(aliases):
            for a in aliases:
                if Util.isString(a):
                    self.aliases.append(a)

    def getNames(self):
        allNames = []
        allNames.append(self.name)
        for a in self.aliases:
            allNames.append(a)

        return allNames

class ProgramInfo(RootItemInfo):

    name = ""
    subcommands = None

    def __init__(self, name):
        RootItemInfo.__init__(self)
        self.name = name
        self.subcommands = []

    def usage(self, usageFormat, subcommandName = None):
        usage = usageFormat
        if usage == None:
            usage = UsageFormat()
        eol = usage.endOfLineString
        subcommand = None
        root = self
        if Util.isString(subcommandName):
            subcommand = self.findSubcommand(subcommandName)
        text = "Usage: " + self.name
        if subcommand != None:
            root = subcommand
            text += " " + subcommand.name
        text = usageFormat.wrap(text + " " + self.optionShortUsage(usage), UsageFormat.INDENTOFFSET_OTHER, 0)

        if (usage.format & UsageFormat.ABSTRACT_TEXT) == UsageFormat.ABSTRACT_TEXT:
            rootUsage = ""
            if len(root.abstract) > 0:
                text += eol + usage.wrap(root.abstract, UsageFormat.INDENTOFFSET_OTHER, 1) + eol
                text += eol
            else:
                rootUsage = eol

            rootUsage += "With: " + eol

            if subcommand != None:
                rootUsage += subcommand.optionUsage(usage, 1)
            else:
                rootUsage += self.optionUsage(usage, 1)
            text += rootUsage
        if (usage.format & UsageFormat.DETAILED_TEXT == UsageFormat.DETAILED_TEXT):
            if len(root.details) > 0:
                text += usage.wrap(root.details, UsageFormat.INDENTOFFSET_OTHER, 0)
        return text

    def appendSubcommand(self, subcommandInfo):
        self.subcommands.append(subcommandInfo)
        return subcommandInfo

    def findSubcommand(self, name):
        for s in self.subcommands:
            if s.name == name:
                return s
            for a in s.aliases:
                if a == name:
                    return s
        return None

class ItemResult(object):
    pass

class OptionResult(ItemResult):

    isSet = False

    def __call__(self):
        return self.value()

class SwitchOptionResult(OptionResult):

    def value(self):
        return self.isSet

class ArgumentOptionResult(OptionResult):

    argument = None

    def value(self):
        if self.isSet:
            return self.argument
        return None

class MultiArgumentOptionResult(OptionResult):

    arguments = None

    def __init__(self):
        OptionResult.__init__(self)
        self.arguments = []

    def __getitem__(self, key):
        if self.isSet:
            return self.arguments[key]
        return None

    def __len__(self):
        if self.isSet:
            return len(self.arguments)
        return 0

    def __call__(self, *args):
        if not self.isSet:
            return []

        if Util.isArray(args) and (len(args) > 0):
            partialArgs = []
            for a in args:
                partialArgs.append(self.arguments[a])
            return partialArgs

        return self.arguments

    def value(self, *args):
        if not self.isSet:
            return []

        if Util.isArray(args) and (len(args) > 0):
            partialArgs = []
            for a in args:
                partialArgs.append(self.arguments[a])
            return partialArgs

        return self.arguments

class GroupOptionResult(OptionResult):

    selectedOption = None
    selectedOptionName = None

    def __init__(self):
        OptionResult.__init__(self)
        self.isSet = 0

    def value(self):
        if self.isSet > 0:
            return self.selectedOptionName

class Message(object):
    DEBUG = 0
    WARNING = 1
    ERROR = 2
    FATALERROR = 3

    FATALERROR_UNKNOWN_OPTION = "Unknown option %s"

    ERROR_INVALID_OPTION_VALUE = "Invalid value for option %s. %s"
    ERROR_INVALID_POSARG_VALUE = "Invalid value for positional argument %d. %s"
    ERROR_MISSING_ARG = "Missing argument for option %s"
    ERROR_REQUIRED_OPTION = "Missing required option %s"
    ERROR_REQUIRED_GROUP = "At least one of the following options have to be set: %s"
    ERROR_REQUIRED_XGROUP = "One of the following options have to be set: %s"
    ERROR_REQUIRED_POSARG = "Required positional argument %d is missing"
    ERROR_PROGRAM_POSARG = "Program does not accept positional arguments"
    ERROR_SUBCMD_POSARG = "Subcommand %s does not accept positional arguments"
    ERROR_TOOMANY_POSARG = "Too many positional arguments"
    ERROR_MISSING_MARG = "At least %d argument(s) required for %s option, got %d"
    ERROR_UNEXPECTED_OPTION = "Unexpected option %s"
    ERROR_SWITCH_ARG = "Option %s does not allow an argument"

    WARNING_IGNORE_EOA = "Ignore end-of-argument marker"

    type = DEBUG
    code = 0
    message = ""

    def __init__(self, type, code, message):
        object.__init__(self)
        self.type = type
        self.code = code
        self.message = message

    def __str__(self):
        return self.message

class RootItemResult(ItemResult):

    _options = {}

    def __init__(self):
        ItemResult.__init__(self)
        self._options = {}

    def __getitem__(self, item):
        return self._options[item]

    def __getattr__(self, attr):
        return self._options[attr]

    def __setitem__(self, attr, value):
        self._options[attr] = value

class SubcommandResult(RootItemResult):
    pass

class ProgramResult(RootItemResult):

    subcommandName = None
    subcommand = None

    def __init__(self):
        self.subcommandName = None
        self.subcommand = None
        self._subcommands = {}
        self._values = []
        self._messages = []
        RootItemResult.__init__(self)

    def __len__(self):
        return self.valueCount()

    def __getitem__(self, key):
        if Util.isInteger(key):
            return self._values[key]
        else:
            return RootItemResult.__getattr__(self, key)

    def __setitem__(self, key, value):
        if Util.isInteger(key):
            self._values.insert(key, value)
        else:
            RootItemResult.__setitem__(self, key, value)

    def __iter__(self):
        return enumerate(self._values)

    def __call__(self):
        return (len(self.getMessages(Message.ERROR, Message.FATALERROR)) == 0)

    def valueCount(self):
        return len(self._values)

    def getMessages(self, min = Message.WARNING, max = Message.FATALERROR):
        messages = []
        for m in self._messages:
            if m.type < min:
                continue
            if m.type > max:
                continue
            messages.append(m)

        return messages

    def _addSubcommand(self, name, scr):
        self._subcommands[name] = scr

    def _appendMessage(self, type, code, format, *args):
        msg = format % args
        self._messages.append(Message(type, code, msg))

    _subcommands = None
    _messages = None
    _values = None

class OptionBinding(object):
    name = None
    info = None
    result = None
    parentResults = None

    def __init__(self, name, info, result = None):
        object.__init__(self)
        self.name = name
        self.info = info
        self.result = result
        self.parentResults = []

class ParserState(object):
    ENDOFOPTIONS = 0x1
    UNEXPECTEDOPTION = 0x2
    ABORT = 0x4

    stateFlags = 0
    argv = None
    argIndex = 0
    optionNameBindings = None
    optionGroupBindings = None
    subcommandNameBindings = None
    activeSubcommandIndex = 0
    activeOption = None
    activeOptionArguments = None
    values = None
    anonymousOptionResults = None

    def __init__(self, programInfo):
        object.__init__(self)
        self.argv = []
        self.optionNameBindings = []
        self.optionGroupBindings = []
        self.subcommandNameBindings = {}
        self.activeOptionArguments = []
        self.values = []
        self.anonymousOptionResults = []

        self.optionNameBindings.append({})
        self.optionGroupBindings.append({})
        for o in programInfo.options:
            self.initializeStateData(None, o, 0)

        scIndex = 1
        for s in programInfo.subcommands:
            self.optionNameBindings.append({})
            self.optionGroupBindings.append({})
            for o in s.options:
                self.initializeStateData(None, o, scIndex)

            self.subcommandNameBindings[s.name] = { "subcommandIndex": scIndex, "subcommand": s }
            scIndex += 1

    def prepareState(self, programInfo, argv, startIndex):
        self.stateFlags = 0
        self.argv = list(argv)
        self.argIndex = startIndex
        self.activeOption = None
        self.activeOptionArguments = []
        self.values = []
        self.anonymousOptionResults = []

        result = ProgramResult()
        for o in programInfo.options:
            self.initializeStateData(result, o, 0)
        scIndex = 1
        for s in programInfo.subcommands:
            scr = SubcommandResult()
            result._addSubcommand(s.name, scr)
            for o in s.options:
                self.initializeStateData(scr, o, scIndex)

            scIndex += 1

        return result

    def createResult(self, rootItemResult, option):
        result = None
        if isinstance(option, SwitchOptionInfo):
            result = SwitchOptionResult()
        elif isinstance(option, ArgumentOptionInfo):
            result = ArgumentOptionResult()
        elif isinstance(option, MultiArgumentOptionInfo):
            result = MultiArgumentOptionResult()
        elif isinstance(option, GroupOptionInfo):
            result = GroupOptionResult()

        if Util.isString(option.variableName) and len(option.variableName) > 0:
            rootItemResult[option.variableName] = result
        else:
            self.anonymousOptionResults.append(result)

        return result

    def initializeStateData(self, rootItemResult, option, groupIndex, resultTree = []):
        result = None
        if rootItemResult != None:
            result = self.createResult(rootItemResult, option)

        optionKey = option.getKey()
        for k, n in option.names:
            nameKey = optionKey + '/' + k
            if rootItemResult == None:
                self.optionNameBindings[groupIndex][nameKey] = OptionBinding(n, option, None)
            else:
                self.optionNameBindings[groupIndex][nameKey].result = result
                self.optionNameBindings[groupIndex][nameKey].parentResults = list(resultTree)

        if isinstance(option, GroupOptionInfo):
            if rootItemResult == None:
                self.optionGroupBindings[groupIndex][optionKey] = OptionBinding(None, option, None)
            else:
                self.optionGroupBindings[groupIndex][optionKey].result = result
                self.optionGroupBindings[groupIndex][optionKey].parentResults = list(resultTree)

            for o in option.options:
                parentResults = []
                if rootItemResult != None:
                    parentResults = [result, ] + resultTree
                self.initializeStateData(rootItemResult, o, groupIndex, parentResults)

class Parser(object):

    def __init__(self, programInfo):
        object.__init__(self)
        self._programInfo = programInfo
        self._state = ParserState(programInfo)


    def parse(self, argv, startIndex = 1):
        result = self._state.prepareState(self._programInfo, argv, startIndex)
        argc = len(argv)

        while self._state.argIndex < argc:
            arg = argv[self._state.argIndex]

            if (self._state.activeOption != None):
                if not self._activeOptionAcceptsArguments():
                    self._unsetActiveOption(result)

            if self._state.stateFlags & ParserState.ENDOFOPTIONS:
                self._processPositionalArgument(result, arg)

            elif arg == "--":
                self._state.stateFlags |= ParserState.ENDOFOPTIONS
                self._unsetActiveOption(result)

            elif arg == "-":
                if (self._state.activeOption != None):
                    if isinstance(self._state.activeOption.info, MultiArgumentOptionInfo):
                        if (len(self._state.activeOptionArguments) == 0):
                            result._appendMessage(Message.WARNING, 2, Message.WARNING_IGNORE_EOA)
                            self._state.activeOptionArguments.append(arg)
                        else:
                            self._unsetActiveOption(result)
                    elif isinstance(self._state.activeOption.info, ArgumentOptionInfo):
                        self._state.activeOptionArguments.append(arg)
                else:
                    self._processPositionalArgument(result, arg)

            elif (len(arg) >= 2) and (arg[0:2] == "\\-"):
                arg = arg[1:len(arg)]
                if self._state.activeOption != None:
                    self._state.activeOptionArguments.append(arg)
                else:
                    self._processPositionalArgument(result, arg)

            elif (self._state.activeOption != None) and len(self._state.activeOptionArguments) == 0:
                self._state.activeOptionArguments.append(arg)

            elif (len(arg) > 2) and (arg[0:2] == "--"):
                if self._state.activeOption != None:
                    self._unsetActiveOption(result)

                cliName = arg
                name = arg[2:len(arg)]
                tail = ""
                hasTail = False
                equalSignIndex = name.find("=");
                if equalSignIndex >= 0:
                    hasTail = True
                    tail = name[(equalSignIndex + 1):len(name)]
                    name = name[0:equalSignIndex]
                    cliName = "--" + name

                self._state.activeOption = self._findOptionByName(name)
                if (self._state.activeOption != None):
                    if not self._optionExpected(self._state.activeOption):
                        self._state.stateFlags |= ParserState.UNEXPECTEDOPTION
                    if hasTail:
                        self._state.activeOptionArguments.append(tail)
                else:
                    result._appendMessage(Message.FATALERROR, 1, Message.FATALERROR_UNKNOWN_OPTION, cliName)
                    self._state.stateFlags |= ParserState.ABORT
                    break

            elif (len(arg) > 1) and (arg[0:1] == "-"):
                arg = arg[1:len(arg)]
                while (len(arg) > 0):
                    if self._state.activeOption != None:
                        self._unsetActiveOption(result)

                    name = arg[0:1]
                    cliName = "-" + name
                    arg = arg[1:len(arg)]

                    self._state.activeOption = self._findOptionByName(name)

                    if (self._state.activeOption != None):
                        if not self._optionExpected(self._state.activeOption):
                            self._state.stateFlags |= ParserState.UNEXPECTEDOPTION

                        if isinstance(self._state.activeOption.info, ArgumentOptionInfo) or isinstance(self._state.activeOption.info, MultiArgumentOptionInfo):
                          if len(arg) > 0:
                              self._state.activeOptionArguments.append(arg)
                              break
                    else:
                        result._appendMessage(Message.FATALERROR, 1, Message.FATALERROR_UNKNOWN_OPTION, cliName)
                        self._state.stateFlags |= ParserState.ABORT
                        break

            elif (self._state.activeOption != None):
                self._state.activeOptionArguments.append(arg)

            else:
                self._processPositionalArgument(result, arg)

            if self._state.stateFlags & ParserState.ABORT:
                break

            self._state.argIndex = self._state.argIndex + 1

        self._unsetActiveOption(result)

        changeCount = 1
        while (changeCount > 0):
            changeCount = self._postProcessOptions(result)

        for g, bindings in enumerate(self._state.optionNameBindings):
            if (g > 0) and (g != self._state.activeSubcommandIndex):
                continue

            binding = None
            nameKeys = bindings.keys()
            nameKeys = sorted(nameKeys)
            for nameKey in nameKeys:
                b = bindings[nameKey]
                if (binding != None) and (binding.info == b.info):
                    continue
                binding = b
                if ((not binding.result.isSet) and self._optionRequired(binding)):
                    result._appendMessage(Message.ERROR, 4, Message.ERROR_REQUIRED_OPTION, binding.name.cliName())

        for g, bindings in enumerate(self._state.optionGroupBindings):
            if (g > 0) and (g != self._state.activeSubcommandIndex):
                continue

            for n, binding  in bindings.items():
                if ((not binding.result.isSet) and self._optionRequired(binding)):
                    nameList = binding.info.getOptionNameListString()
                    if binding.info.groupType == GroupOptionInfo.TYPE_EXCLUSIVE:
                        result._appendMessage(Message.ERROR, 6, Message.ERROR_REQUIRED_XGROUP, nameList)
                    else:
                        result._appendMessage(Message.ERROR, 5, Message.ERROR_REQUIRED_GROUP, nameList)

        self._postProcessPositionalArguments(result)

        return result

    def _activeOptionAcceptsArguments(self):
        s = self._state
        ao = self._state.activeOption
        i = ao.info

        if (isinstance(i, MultiArgumentOptionInfo)):
            if i.maxArgumentCount > 0:
                return ((len(s.activeOptionArguments) + len(ao.result.arguments)) < i.maxArgumentCount)
            return True

        if (isinstance(i, ArgumentOptionInfo)):
            return len(s.activeOptionArguments) == 0

        return False

    def _unsetActiveOption(self, result):
        markSet = False
        if self._state.activeOption == None:
            return

        if self._state.stateFlags & ParserState.UNEXPECTEDOPTION:
            result._appendMessage(Message.ERROR, 12, Message.ERROR_UNEXPECTED_OPTION, self._state.activeOption.name.cliName())

        if isinstance(self._state.activeOption.info, SwitchOptionInfo):
            markSet = True
            if len(self._state.activeOptionArguments) > 0:
                if len(self._state.activeOptionArguments) > 1 or len(self._state.activeOptionArguments[0]) > 0:
                    markSet = False
                    result._appendMessage(Message.ERROR, 13, Message.ERROR_SWITCH_ARG, self._state.activeOption.name.cliName())
        elif isinstance(self._state.activeOption.info, ArgumentOptionInfo):
            if len(self._state.activeOptionArguments) > 0:
                value = self._state.activeOptionArguments[0]
                if ((not self._state.stateFlags & ParserState.UNEXPECTEDOPTION) and self._validateOptionArgument(result, self._state.activeOption, value)):
                    markSet = True
                    self._state.activeOption.result.argument = value
                else:
                    self._state.activeOption.result.argument = None
            else:
                result._appendMessage(Message.ERROR, 3, Message.ERROR_MISSING_ARG, self._state.activeOption.name.cliName())
        elif isinstance(self._state.activeOption.info, MultiArgumentOptionInfo):
            if len(self._state.activeOptionArguments) > 0:
                for value in self._state.activeOptionArguments:
                    if ((not self._state.stateFlags & ParserState.UNEXPECTEDOPTION) and self._validateOptionArgument(result, self._state.activeOption, value)):
                        markSet = True
                        self._state.activeOption.result.arguments.append(value)
                    else:
                        self._state.activeOption.result.arguments.append(None)
            else:
                result._appendMessage(Message.ERROR, 3, Message.ERROR_MISSING_MARG, self._state.activeOption.info.minArgumentCount, self._state.activeOption.name.cliName(), len(self._state.activeOptionArguments))

        if (not self._state.stateFlags & ParserState.UNEXPECTEDOPTION) and markSet:
            self._markOption(result, self._state.activeOption, True)

        self._state.activeOptionArguments = []
        self._state.activeOption = None
        self._state.stateFlags &= ~ParserState.UNEXPECTEDOPTION


    def _markOption(self, result, binding, value):
        binding.result.isSet = value
        childResult = binding.result
        childInfo = binding.info
        parentInfo = childInfo.parent;

        for parentResult in binding.parentResults:
            if value:
                parentResult.isSet += 1
            else:
                parentResult.isSet -= 1

            if parentInfo.groupType == GroupOptionInfo.TYPE_EXCLUSIVE:
                if value:
                    parentResult.selectedOption = childResult
                    parentResult.selectedOptionName = childInfo.variableName

            if parentResult.isSet == 0:
                parentResult.selectedOption = None
                parentResult.selectedOptionName = None

            childInfo = childInfo.parent
            parentInfo = parentInfo.parent
            childResult = parentResult

    def _validateOptionArgument(self, result, binding, value):
        validates = True
        for validator in binding.info.validators:
            v = validator.validate(self._state, result, binding, value)
            validates = (validates and v)
        return validates

    def _validatePositionalArgument(self, result, paInfo, paNumber, value):
        validates = True
        for validator in paInfo.validators:
            v = validator.validate(self._state, result, paNumber, value)
            validates = (validates and v)
        return validates

    def _processPositionalArgument(self, result, value):
        if (not self._state.stateFlags & ParserState.ENDOFOPTIONS) and (self._state.activeSubcommandIndex == 0) and (len(self._state.values) == 0):
            for name, binding in self._state.subcommandNameBindings.items():
                if name == value:
                    self._state.activeSubcommandIndex = binding["subcommandIndex"]
                    result.subcommandName = name
                    result.subcommand = result._subcommands[name]
                    return

                for alias in binding["subcommand"].aliases:
                    if alias == value:
                        self._state.activeSubcommandIndex = binding["subcommandIndex"]
                        result.subcommandName = name
                        result.subcommand = result._subcommands[name]
                        return

        self._state.values.append(value)

    def _findOptionByInfo(self, info):
        for i, group in enumerate(self._activeBindingGroups(0x2)):
            for n, binding in group.items():
                if info == binding.info:
                    return binding
        return None

    def _findOptionByName(self, name):
        for i, group in enumerate(self._activeBindingGroups(0x2)):
            for n, binding in group.items():
                if name == binding.name.name:
                    return binding
        return None
        
    def _activeBindingGroups(self, types):
        s = self._state
        g = []
        if s.activeSubcommandIndex > 0:
            if types & 0x1:
                g.append (s.optionGroupBindings[s.activeSubcommandIndex])
                g.append (s.optionGroupBindings[0])
            if types & 0x2:
                g.append (s.optionNameBindings[s.activeSubcommandIndex])
                g.append (s.optionNameBindings[0])
        else:
            if types & 0x1:
                g.append (s.optionGroupBindings[0])
            if types & 0x2:
                g.append (s.optionNameBindings[0])
        return g
        
    def _optionExpected(self, binding):
        parentInfo = binding.info.parent
        previousResult = binding.result

        for i, parentResult in enumerate(binding.parentResults):
            if parentInfo.groupType == GroupOptionInfo.TYPE_EXCLUSIVE:
                if parentResult.isSet and parentResult.selectedOption != previousResult:
                    return False

            parentInfo = parentInfo.parent
            previousResult = parentResult

        return True

    def _optionRequired(self, binding):
        if not (binding.info.optionFlags & ItemInfo.REQUIRED):
            return False

        parentInfo = binding.info.parent
        previousResult = binding.result

        for i, parentResult in enumerate(binding.parentResults):
            if parentInfo.groupType == GroupOptionInfo.TYPE_EXCLUSIVE:
                if (not parentResult.isSet) or (parentResult.selectedOption != previousResult):
                    return False

            parentInfo = parentInfo.parent
            previousResult = parentResult

        return True

    def _postProcessOption(self, result, current, forceSet):
        if isinstance(current.info, GroupOptionInfo):
            if (not current.result.isSet) and (forceSet or self._optionExpected(current)) and self._optionRequired(current) and (current.info.defaultOption != None):
                return self._postProcessOption(result, self._findOptionByInfo(current.info.defaultOption), True)
        if isinstance(current.info, SwitchOptionInfo) and (not current.result.isSet) and forceSet:
            self._markOption(result, current, True)
            return 1
        elif isinstance(current.info, ArgumentOptionInfo):
            if (not current.result.isSet):
                if (current.info.defaultValue != None) and (forceSet or self._optionExpected(current)):
                    current.result.argument = current.info.defaultValue
                    self._markOption(result, current, True)
                    return 1
                else:
                    current.result.argument = None
        elif isinstance(current.info, MultiArgumentOptionInfo):
            c = len(current.result.arguments)
            if current.result.isSet and (current.info.minArgumentCount > 0) and (c < current.info.minArgumentCount):
                result._appendMessage(Message.ERROR, 11, Message.ERROR_MISSING_MARG, current.info.minArgumentCount, current.name.cliName(), c)
                self._markOption(result, current, False)
                if not current.result.isSet:
                    current.result.arguments = []
                return 1
                
        return 0
    
    def _postProcessOptions(self, result):
        current = None
        changeCount = 0
        for i, group in enumerate(self._activeBindingGroups(0x3)):
            current = None
            for name, binding in group.items():
                if current != None and (current.info == binding.info):
                    continue
                current = binding
                changeCount += self._postProcessOption (result, current, False)

        return changeCount

    def _postProcessPositionalArguments(self, result):
        root = self._programInfo
        validPositionalArgumentCount = 0
        if self._state.activeSubcommandIndex > 0:
            root = self._programInfo.subcommands[self._state.activeSubcommandIndex - 1]

        paInfoCount = len(root.positionalArguments)
        if (paInfoCount == 0) and (len(self._state.values) > 0):
            if self._state.activeSubcommandIndex > 0:
                result._appendMessage(Message.ERROR, 9, Message.ERROR_SUBCMD_POSARG, root.name)
            else:
                result._appendMessage(Message.ERROR, 8, Message.ERROR_PROGRAM_POSARG)

            return validPositionalArgumentCount

        paInfoIndex = 0
        paNumber = 1
        currentPaiValueCount = 0
        processedValueCount = 0
        paInfo = None

        for value in self._state.values:
            if paInfoIndex >= paInfoCount:
                break

            currentPaiValueCount += 1
            processedValueCount += 1
            paInfo = root.positionalArguments[paInfoIndex]

            if self._validatePositionalArgument(result, paInfo, paNumber, value):
                result._values.append(value);
                validPositionalArgumentCount += 1
            else:
                pass
                """
                 @todo continue or abort ?
                """

            if ((paInfo.maxArgumentCount > 0) and (currentPaiValueCount == paInfo.maxArgumentCount)):
                currentPaiValueCount = 0
                paInfoIndex += 1

            paNumber += 1

        if (len(self._state.values) > processedValueCount):
            result._appendMessage(Message.ERROR, 10, Message.ERROR_TOOMANY_POSARG)
        elif (paInfoIndex < paInfoCount):
            """/**
             * @note not yet supported by schema
             */"""
            for i in range(paInfoIndex, paInfoCount):
                if (root.positionalArguments[i].positionalArgumentFlags & ItemInfo.REQUIRED):
                    result._appendMessage(Message.ERROR, 7, Message.ERROR_REQUIRED_POSARG, i)


    _programInfo = None
    _state = None

]]></xsl:variable>

	<!-- Output base code according to output rules -->
	<xsl:template name="prg.python.base.output">
		<xsl:value-of select="$prg.python.base.code" />
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:value-of select="$prg.python.codingHint" />
		<xsl:value-of select="$prg.python.copyright" />
		
		<xsl:call-template name="prg.python.base.output" />
	</xsl:template>
	
</xsl:stylesheet>
