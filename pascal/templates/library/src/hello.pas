unit hello;

interface

const CURRENT_DATE = '2023-09-01';
const TARGET_NAME = 'i386-win32';
const VERSION_NAME = '0.0.1-SNAPSHOT';
const COMPILER_NAME = 'Freepascal';
const PROJECT_NAME = 'someproject';

{** This function returns the version of this library. }
Function GetVersion: String;


implementation

Function GetVersion: String;
Begin
 GetVersion := VERSION_NAME;
End;


end.

