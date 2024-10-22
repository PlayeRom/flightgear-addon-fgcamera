#
# Global aliases for boolean types to distinguish the use of "int" from "bool".
# NOTE: unfortunately, it doesn't work as an assignment of a default value for a function parameter!
# This file is not required for FG versions >= 2024.1.x because there Nasal supports true and false natively.
#
var true  = 1;
var false = 0;
