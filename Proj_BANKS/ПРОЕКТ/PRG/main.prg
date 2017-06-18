PROCEDURE MAIN
PUBLIC gc_error
on error do ErrorHandler with Error( ), Message( ), Message(1), Lineno( ), Program( ), Sys(16)

SET ENGINEBEHAVIOR 70 
SET DELETED ON
GlPath=SYS(5)+SYS(2003)       
SET DEFAULT TO &GlPath
SET PATH TO ;&Glpath;FORM;PRG;DATA
IF ! USED("banks")
	USE banks IN 0	
	SELECT banks
ENDIF
DO FORM FRM_BANKS
READ events

ENDPROC 
procedure ErrorHandler
	parameters err, mes, mes1, lineNumber, progName, fileName
	if Set('TEXTMERGE') = 'OFF'
		set textmerge on show
	endif
	&& ������� ������������� ����� �� ������� � ����
	gc_error=GlPath+'\ErrText.txt'
	*set textmerge to d:\a.txt additive
	set textmerge to &gc_error additive
	\����� ������: <<Transform(err)>>
	\�������� ������: <<mes>>
	\����������� ������:
	\	��������: <<Upper(mes1)>>
	\	����� ������: <<Transform(lineNumber)>>
	\	��� ���������: <<progName>>
	\	��� �����: <<fileName>>
	&& ��������� ����, ���������� ��������� �� �������
	Fclose(_TEXT)
endProc
